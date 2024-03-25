use crate::traits::serialize::Serialize;
use crate::globals::{PLAYER_SIZE, ITEM_MAX, FROGLIN_MAX, FROGLIN_SIZE, IDENTITY_SIZE};
use crate::types::froglin::Froglin;
use crate::types::item::Item;
use dep::std::println;
use dep::std::hash::poseidon2::Poseidon2;
use dep::std::eddsa::eddsa_to_pub;

struct Player {
	mana_power: Field,
	level: Field,
	stash_root: Field, // merkle tree root of the user's stash
	inventory: [Item; ITEM_MAX], // max 5 items
	froglins: [Froglin; FROGLIN_MAX], // max 5 froglins
}

impl Serialize<PLAYER_SIZE> for Player {
    fn serialize(self) -> [Field; PLAYER_SIZE] {
		let mut stats = [self.mana_power, self.level, self.stash_root].as_slice();

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
			stash_root: 0,
			inventory: [Item::default(); ITEM_MAX],
			froglins: [Froglin::default(); FROGLIN_MAX],
		}
	}
}

impl Player {
	fn assert_unchanged(self, other: Player) {
        println(f"Asserting Player unchanged: {self}");
		assert(self.mana_power == other.mana_power);
		assert(self.level == other.level);
		assert(self.stash_root == other.stash_root);
		for i in 0..ITEM_MAX {
			self.inventory[i].assert_unchanged(other.inventory[i]);
		}
		for i in 0..FROGLIN_MAX {
			self.froglins[i].assert_unchanged(other.froglins[i]);
		}
	}

	pub fn calculate_level(&mut self) -> Field {
		// player level is the sum of all its current goblin's level
		// this makes it potentially change quite drastically
		// so maybe "Power" would be better than "Level"
		for i in 0..FROGLIN_MAX {
			self.level += self.froglins[i].level;
		}
		self.level
	}

	pub fn boost_mp(&mut self, amount: Field) {
		let prev = *self;
		self.mana_power += amount;
		assert(self.mana_power == prev.mana_power + amount);
	}


	pub fn froglin_level_up(&mut self, froglin_id: Field) {
		let prev = *self;
		self.froglins[froglin_id].level += 1;
		assert(self.froglins[froglin_id].level == prev.froglins[froglin_id].level + 1);
	}

	pub fn add_froglin(&mut self, froglin: Froglin) {
		let prev = *self;
		let mut found = false;

		// iterate over all the inventory's froglins
		for i in 0..FROGLIN_MAX {
			// no break statement in Noir so I need to use a flag

			// id 0 is unique and means the slot is empty
			if (self.froglins[i].id == 0) {
				if (!found) {
					self.froglins[i] = froglin;
					found = true;
				}
			}
		}
		assert(found, "Inventory is full!");
		assert(self.froglins != prev.froglins);
	}
}

#[test]
fn test_add_froglin() {
	let mut player = Player::default();
	let froglins = player.froglins;
	// println(froglins.map(|f : Froglin| f.id));

	let froglin = Froglin::new(1);
	println(froglin)
	// player.add_froglin(Froglin::default());
}

// #[test]
// fn test_calculate_level() {
// 	let mut player = Player::default();
// 	let level = player.calculate_level();
// 	assert(level == 0);
// 	player.froglin_level_up(0); // level up first froglin
// 	player.froglin_level_up(4); // level up last froglin
// 	let level = player.calculate_level();
// 	assert(level == 2);
// }

// #[test]
// fn test_unchanged_player() {
// 	let player = Player::default();
// 	let player2 = Player::default();
// 	player.assert_unchanged(player2);
// }

// #[test]
// fn test_boost_mp() {
// 	let mut player = Player::default();
// 	player.boost_mp(10);
// 	assert(player.mana_power == 10);
// 	player.boost_mp(100);
// 	assert(player.mana_power == 110);
// }


