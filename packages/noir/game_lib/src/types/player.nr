use crate::traits::{serialize::{Serialize, Commit}, level::{Level, LevelUp}, froglin_inv::FroglinInventory, stash::Stash};
use crate::globals::{PLAYER_SIZE, ITEM_MAX, FROGLIN_MAX, FROGLIN_SIZE, IDENTITY_SIZE};
use crate::types::froglin::Froglin;
use crate::types::item::Item;
use crate::froglin_types::desert_froglin;
use crate::froglin_types::tree_froglin;
use crate::utils::pretty_print::p_print;

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
        let mut found: bool = false;
        for i in 0..FROGLIN_MAX {
            if (self.froglins[i].id == id) {
                found = true;
                self.froglins[i]
            }
        }
        assert(found == true, "Froglin not found");
        Froglin::default()
    }

    fn add_froglin(&mut self, froglin: Froglin) -> bool {
        let is_storage_full = self.froglins.all(|f : Froglin| f.id != 0);
        if (is_storage_full) {
            // TODO will add to stash
            assert(false, "Inventory is full!");
        }

        // no break statement in Noir so I need to use a flag
        let mut found = false;
        // iterate over all the inventory's froglins
        for i in 0..FROGLIN_MAX {
            if (self.froglins[i].id == 0) {
                if (found == false) {
                    self.froglins[i] = froglin;
                    found = true;
                }
            }
        }
        assert(found, "Inventory is full!");
        is_storage_full
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
    fn update_stash(&mut self, new_root: Field) {
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

        let bjj = baby_jubjub();
        let pubkey = bjj.curve.mul(secret, bjj.base8);

        println(pubkey.x);
        println(pubkey.y);
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

    let (p1c, p1i) = player1.generate_identity(0x01);
    let (p2c, p2i) = player2.generate_identity(0x01);
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
    println("#test_removs_mana_end");
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
    let to_stash = player.add_froglin(desert_froglin);
    assert(to_stash == false);

    let tree_froglin = tree_froglin::new(0x02);
    let to_stash = player.add_froglin(tree_froglin);
    assert(to_stash == false);

    assert(player.froglins[0].id == 1);
    assert(player.froglins[1].id == 2);
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

