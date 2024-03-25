use crate::traits::{serialize::Serialize, player::PlayerTrait};
use crate::globals::{PLAYER_SIZE, ITEM_MAX, FROGLIN_MAX, FROGLIN_SIZE, IDENTITY_SIZE};
use crate::types::froglin::Froglin;
use crate::types::item::Item;
use crate::froglin_types::desert_froglin;
use crate::froglin_types::tree_froglin;
use crate::utils::pretty_print::p_print;

use dep::std::println;
use dep::std::hash::poseidon2::Poseidon2;
use dep::std::eddsa::eddsa_to_pub;

struct Player {
	mana_power: u32,
	level: Field,
	stash_root: Field, // merkle tree root of the user's stash
	inventory: [Item; ITEM_MAX], // max 5 items
	froglins: [Froglin; FROGLIN_MAX], // max 5 froglins
}

impl Serialize<PLAYER_SIZE> for Player {
    fn serialize(self) -> [Field; PLAYER_SIZE] {
		let mut stats = [self.mana_power as Field, self.level, self.stash_root].as_slice();

        for i in 0..ITEM_MAX {
            stats = stats.append(self.inventory[i].serialize().as_slice());
        }
        for i in 0..FROGLIN_MAX {
			for j in 0..FROGLIN_SIZE {
	            stats = stats.push_back(self.froglins[i].serialize()[j]);
			}
        }
    
		let mut ret : [Field; PLAYER_SIZE] = [0; PLAYER_SIZE];
		for i in 0..PLAYER_SIZE {
			ret[i] = stats[i];
		};
		ret
	}
}

impl Default for Player {
	fn default() -> Self {
		Player {
			mana_power: 0,
			level: 0,
			stash_root: 0x0,
			inventory: [Item::default(); ITEM_MAX],
			froglins: [Froglin::default(); FROGLIN_MAX],
		}
	}
}

impl Eq for Player {
    fn eq(self, other: Self) -> bool {
        (self.mana_power == other.mana_power) &
        (self.level == other.level) &
		(self.stash_root == other.stash_root) &
		(self.inventory == other.inventory) &
		(self.froglins == other.froglins)
    }
}

impl PlayerTrait for Player {
	fn get_level(&mut self) -> Field {
		for i in 0..FROGLIN_MAX {
			self.level += self.froglins[i].level;
		}
		self.level
	}

	fn _get_level(self) -> Field {
		self.level
	}

	fn get_stash_root(self) -> Field {
		self.stash_root
	}

	fn get_mana(self) -> u32 {
		self.mana_power
	}

    fn add_mana(&mut self, amount: u32) {
        self.mana_power += amount;
    }

    fn remove_mana(&mut self, amount: u32) {
        self.mana_power -= amount;
    }

	fn get_froglins(self) -> [Froglin; FROGLIN_MAX] {
		self.froglins
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
        let prev = *self;

        for i in 0..FROGLIN_MAX {
            if (self.froglins[i].id == froglin.id) {
                self.froglins[i] = froglin;
            }
        }

        *self
    }

    fn generate_identity(self, secret: Field) -> Field {
        let mut identity : [Field; IDENTITY_SIZE] = [0; IDENTITY_SIZE];
        let serialized = self.serialize();

        for i in 0..PLAYER_SIZE {
            identity[i] = serialized[i];
        }

        let (pub_key_x, pub_key_y) = eddsa_to_pub(secret);
        identity[PLAYER_SIZE] = pub_key_x;
        identity[PLAYER_SIZE + 1] = pub_key_y;

        Poseidon2::hash(identity, IDENTITY_SIZE)
    }

    fn assert_identity(self, secret: Field, other: Field) {
        let identity = self.generate_identity(secret);
        assert(identity == other, "Identity does not match");
    }
}

#[test]
fn test_player_equality() {
    let player = Player::default();
    let player2 = Player::default();
    assert(player == player2);
}

#[test]
fn test_boost_mp() {
    let mut player = Player::default();
    player.add_mana(10);
    assert(player.mana_power == 10);
    player.add_mana(100);
    assert(player.mana_power == 110);
}

#[test]
fn test_player_inequality() {
    let player = Player::default();
    let mut player2 = Player::default();
    player2.add_mana(10);
    assert(player != player2);
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
    player = player.update_froglin(desert_froglin.level_up());

    let level = player.get_level();
    assert(level == 2);
}

