use crate::traits::{serialize::{Serialize, Commit}, level::{Level, LevelUp}, froglin_inv::FroglinInventory, stash::Stash};
use crate::globals::{PLAYER_SIZE, ITEM_MAX, FROGLIN_MAX, FROGLIN_SIZE, IDENTITY_SIZE, TREE_DEPTH};
use crate::types::froglin::Froglin;
use crate::types::item::Item;
use crate::froglin_types::desert_froglin;
use crate::froglin_types::tree_froglin;
use crate::utils::pretty_print::p_print;
use crate::smt::smt::{add, delete};

use dep::std::println;
use dep::std::hash::poseidon2::Poseidon2;
use dep::std::ec::consts::te::baby_jubjub;

struct Player {
	mana: u32,
    claimed_mana: u32,
	level: Field,
	stash_root: Field, // merkle tree root of the user's stash
	inventory: [Item; ITEM_MAX], // max 5 items
	froglins: [Froglin; FROGLIN_MAX], // max 5 froglins
}

impl Serialize<PLAYER_SIZE> for Player {
    fn serialize(self) -> [Field; PLAYER_SIZE] {
        let mut stats = [self.mana as Field, self.claimed_mana as Field, self.level, self.stash_root].as_slice();

        for i in 0..ITEM_MAX {
            stats = stats.append(self.inventory[i].serialize().as_slice());
        }
        for i in 0..FROGLIN_MAX {
            stats = stats.append(self.froglins[i].serialize().as_slice());
        }

		let mut ret : [Field; PLAYER_SIZE] = [0; PLAYER_SIZE];
		for i in 0..PLAYER_SIZE {
			ret[i] = stats[i];
		};
        ret
    }
}

impl Commit<PLAYER_SIZE> for Player {
    fn commit(self, secret: Field) -> Field {
		let mut stats = self.serialize().as_slice();

		let mut ret : [Field; PLAYER_SIZE + 1] = [0; PLAYER_SIZE + 1];
		for i in 0..PLAYER_SIZE {
			ret[i] = stats[i];
		};
        // println(Poseidon2::hash(ret, PLAYER_SIZE));

        ret[PLAYER_SIZE] = secret;
        Poseidon2::hash(ret, PLAYER_SIZE + 1)
	}
}

impl Default for Player {
	fn default() -> Self {
		Player {
			mana: 0,
            claimed_mana: 0,
			level: 0,
			stash_root: 0x0,
			inventory: [Item::default(); ITEM_MAX],
			froglins: [Froglin::default(); FROGLIN_MAX],
		}
	}
}

impl Eq for Player {
    fn eq(self, other: Self) -> bool {
        (self.mana == other.mana) &
        (self.claimed_mana == other.claimed_mana) &
        (self.level == other.level) &
		(self.stash_root == other.stash_root) &
		(self.inventory == other.inventory) &
		(self.froglins == other.froglins)
    }
}

impl Level for Player {
    fn get_level(self) -> Field {
        self.level
    }
}

impl FroglinInventory for Player {
    fn get_froglin(self, id: Field) -> Froglin {
        let mut found: Froglin = Froglin::default();
        for i in 0..FROGLIN_MAX {
            if (self.froglins[i].id == id) {
                found = self.froglins[i];
            }
        }
        assert(found.id != Froglin::default().id, "Froglin not found");
        found
    }

    fn add_froglin(&mut self, froglin: Froglin) {
        let is_storage_full = self.froglins.all(|f : Froglin| f.id != 0);
        assert(!is_storage_full, "Inventory is full! Deposit one froglin to stash first.");
        
        // no break statement in Noir so I need to use a flag
        let mut found_empty_slot = false;
        // iterate over all the inventory's froglins
        for i in 0..FROGLIN_MAX {
            if (self.froglins[i].id == 0) {
                if (found_empty_slot == false) {
                    self.froglins[i] = froglin;
                    found_empty_slot = true;
                }
            }
        }
    }

    fn remove_froglin(&mut self, id: Field) -> bool {
        // no break statement in Noir so I need to use a flag
        let mut removed = false;
        // iterate over all the inventory's froglins
        for i in 0..FROGLIN_MAX {
            if (self.froglins[i].id == id) {
                if (removed == false) {
                    self.froglins[i] = Froglin::default();
                    removed = true;
                }
            }
        }
        removed
    }

    fn update_froglin(&mut self, froglin: Froglin) -> Self {
        for i in 0..FROGLIN_MAX {
            if (self.froglins[i].id == froglin.id) {
                self.froglins[i] = froglin;
            }
        }

        *self
    }
}

impl Stash for Player {
    // passing the ID, because it's assumed the Froglin is in inventory
    // so what if the user captures a froglin with a full inventory? that's fine, this is the
    // proving layer... the game itself knows it so it will prompt the user "inventory full, select one froglin to deposit"
    // this can change later ofc
    fn stash_deposit(&mut self, id: Field, siblings: [Field; TREE_DEPTH], secret: Field) {
        // prove froglin in inventory
        let froglin : Froglin = self.get_froglin(id);
        assert(froglin.id != 0, "Trying to deposit a froglin that is not in inventory!");

        // get key value
        let value = froglin.commit(secret);
        let key = Poseidon2::hash([value], 1);

        // prove add (membership proof)
        let new_root = add([key, value], self.stash_root, siblings);
        self.stash_root = new_root;
    }

    fn stash_withdraw(&mut self, froglin: Froglin, siblings: [Field; TREE_DEPTH], secret: Field) {
        // get key value
        let value = froglin.commit(secret);
        let key = Poseidon2::hash([value], 1);

        // prove delete (membership + non-membership)
        let new_root = delete([key, value], self.stash_root, siblings);

        // prove it is now in inventory
        self.add_froglin(froglin);
        self.stash_root = new_root;
    }
}

impl Player {
    fn level_up(&mut self, froglin: Froglin) {
        self.get_froglin(froglin.id).level_up();
        for i in 0..FROGLIN_MAX {
            self.level += self.froglins[i].level;
        }
    }

    fn add_mana(&mut self, total_mana: u32) {
        let unclaimed_mana = total_mana - self.claimed_mana;
        self.mana += unclaimed_mana;
        self.claimed_mana = total_mana;
    }

    fn remove_mana(&mut self, amount: u32) {
        self.mana -= amount;
    }

    fn generate_identity(self, secret: Field) -> (Field, Field) {
        let commitment = self.commit(secret);
        println(commitment);

        let bjj = baby_jubjub();
        let pubkey = bjj.curve.mul(secret, bjj.base8);

        (commitment, Poseidon2::hash([commitment, pubkey.x, pubkey.y], 3))
    }

    fn assert_identity(self, secret: Field, other: Field) {
        let (_, identity) = self.generate_identity(secret);
        assert(identity == other, "Identity does not match");
    }
}

#[test]
fn test_player_equality() {
    let player1 = Player::default();
    let player2 = Player::default();
    assert(player1 == player2);

    let (p1c, p1i) = player1.generate_identity(0x7b);
    let (p2c, p2i) = player2.generate_identity(0x7b);
    assert(p1c == p2c);
    assert(p1i == p2i);

    // output for js tests
    println("#test_player_equality_start");
    println(p1c);
    println(p1i);
    println(p2c);
    println(p2i);
    println("#test_player_equality_end");
}

#[test]
fn test_player_inequality() {
    let player = Player::default();
    let mut player2 = Player::default();
    player2.add_mana(10);
    assert(player != player2);

    // output for js tests
    println("#test_player_inequality_start");
    println(player.serialize());
    println(player2.serialize());
    println("#test_player_inequality_end");
}

#[test]
fn test_add_mana() {
    let mut player = Player::default();
    player.add_mana(10); // user is entitled to 10 mana
    assert(player.mana == 10);
    player.add_mana(100); // user is entitled to 100 mana
    assert(player.claimed_mana == 100); // he claimed all 100 mana
    assert(player.mana == 100); // he didn't use any mana

    // output for js tests
    println("#test_add_mana_start");
    println(player.mana);
    println(player.claimed_mana);
    println("#test_add_mana_end");
}

#[test]
fn test_remove_mana() {
    let mut player = Player::default();
    player.add_mana(100);
    assert(player.mana == 100);
    player.remove_mana(10);
    assert(player.mana == 90);

    // output for js tests
    println("#test_remove_mana_start");
    println(player.mana);
    println("#test_remove_mana_end");
}

#[test]
fn test_claimed_mana() {
    let mut player = Player::default();
    player.add_mana(10); // user is entitled to 10 mana
    assert(player.mana == 10);
    player.add_mana(100); // user is entitled to 100 mana
    assert(player.claimed_mana == 100); // he claimed all 100 mana

    player.remove_mana(10); // user used 10 mana
    assert(player.claimed_mana == 100); // he still claimed all 100 mana
    assert(player.mana == 90); // but used 10

    // output for js tests
    println("#test_claimed_mana_start");
    println(player.mana);
    println(player.claimed_mana);
    println("#test_claimed_mana_end");
}

#[test]
fn test_add_froglin() {
    let mut player = Player::default();
    let desert_froglin = desert_froglin::new(0x01); // unique id for the froglin
    player.add_froglin(desert_froglin);

    let tree_froglin = tree_froglin::new(0x02);
    player.add_froglin(tree_froglin);

    assert(player.froglins[0].id == 1);
    assert(player.froglins[1].id == 2);
    println("#test_add_froglin_start");
    println(player.froglins[0].id);
    println(player.froglins[1].id);
    println("#test_add_froglin_end");
}

#[test]
fn test_remove_froglin() {
    let mut player = Player::default();
    let desert_froglin = desert_froglin::new(0x01); // unique id for the froglin

    player.add_froglin(desert_froglin);
    assert(player.froglins[0].id == 1);

    println("#test_remove_froglin_start");
    println(player.froglins[0].id);

    let is_removed = player.remove_froglin(desert_froglin.id);
    assert(is_removed);
    assert(player.froglins.all(|f : Froglin| f.id == 0));
    println(player.froglins.all(|f : Froglin| f.id == 0));
    println("#test_add_froglin_end");
}

#[test(should_fail_with="Inventory is full! Deposit one froglin to stash first.")]
fn test_fail_inventory_full() {
    let mut player = Player::default();
    assert(player.stash_root == 0x0);

    for i in 1..FROGLIN_MAX + 2 {
        let desert_froglin = desert_froglin::new(i as Field);
        player.add_froglin(desert_froglin);
    }
}

#[test]
fn test_calculate_level() {
    let mut player = Player::default();
    let level = player.get_level();
    assert(level == 0);

    let mut desert_froglin = desert_froglin::new(0x01); // unique id for the froglin

    player.add_froglin(desert_froglin);
    let level = player.get_level();
    assert(level == 0);

    player.level_up(desert_froglin);
    let level = player.get_level();
    assert(level == 1);

    player.level_up(desert_froglin);
    let level = player.get_level();
    assert(level == 2);
}

#[test]
fn test_deposit_to_stash() {
    let mut player = Player::default();
    assert(player.stash_root == 0x0);

    let desert_froglin = desert_froglin::new(0x01);
    player.add_froglin(desert_froglin);
    let mut siblings: [Field; TREE_DEPTH] = [0; TREE_DEPTH];

    player.stash_deposit(desert_froglin.id, siblings, 0x7b);
    assert(player.stash_root == 0x12ba7cfc51431da3cd27aa60267f8d5de4b3b51cd211a0c85e378ef541c9c7d5);
    println("#test_deposit_to_stash_start");
    println(player.stash_root);
    println("#test_deposit_to_stash_end");
}

#[test(should_fail_with="Froglin not found")]
fn test_fail_deposit_to_stash_not_in_inv() {
    let mut player = Player::default();
    assert(player.stash_root == 0x0);

    let desert_froglin = desert_froglin::new(0x01);
    let mut siblings: [Field; TREE_DEPTH] = [0; TREE_DEPTH];

    player.stash_deposit(desert_froglin.id, siblings, 0x7b);
    println("#test_fail_deposit_to_stash_not_in_inv_start");
    println(player.stash_root);
    println("#test_fail_deposit_to_stash_not_in_inv_end");
}

#[test]
fn test_withdraw_from_stash() {
    let mut player = Player::default();
    assert(player.stash_root == 0x0);
    println("#test_withdraw_from_stash_start");

    // add one froglin to inventory and deposit it to stash
    let desert_froglin = desert_froglin::new(0x01);
    let mut desert_froglin_siblings: [Field; TREE_DEPTH] = [0; TREE_DEPTH];
    player.add_froglin(desert_froglin);
    player.stash_deposit(desert_froglin.id, desert_froglin_siblings, 0x7b);
    assert(player.stash_root == 0x12ba7cfc51431da3cd27aa60267f8d5de4b3b51cd211a0c85e378ef541c9c7d5);
    println(player.stash_root);

    // and now withdraw the first froglin and check the root is 0x0
    player.stash_withdraw(desert_froglin, desert_froglin_siblings, 0x7b);
    assert(player.stash_root == 0x0);
    println(player.stash_root);

    println("#test_withdraw_from_stash_end");
}
