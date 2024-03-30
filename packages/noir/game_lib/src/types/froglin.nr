use crate::traits::{serialize::{Serialize, Commit}, level::{Level, LevelUp}};
use crate::globals::{FROGLIN_SIZE, FROGLIN_MAX_AWAKE_AT, FROGLIN_MAX_HABITATS};
use crate::zones_types::zone_type::Zone;
use dep::std::println;
use dep::std::cmp::Eq;
use dep::std::hash::poseidon2::Poseidon2;
use crate::froglin_types::desert_froglin;

struct Froglin {
	id: Field, // unique ID of the froglin
    type_id: Field,
    stealth: u32,
    attack: u32,
    defense: u32,
	health: u32,
    level: Field,
	awake_at: [u32; FROGLIN_MAX_AWAKE_AT], // this can be whatever
	habitats: [Zone; FROGLIN_MAX_HABITATS], // also can be any number
}

impl Serialize<FROGLIN_SIZE> for Froglin {
    fn serialize(self) -> [Field; FROGLIN_SIZE] {
        [self.id, self.type_id, self.stealth as Field, self.attack as Field, self.defense as Field, self.health as Field, self.level]
    }
}

impl Commit<FROGLIN_SIZE> for Froglin {
    fn commit(self, secret: Field) -> Field {
		let mut stats = self.serialize();
    
		let mut ret : [Field; FROGLIN_SIZE + 1] = [0; FROGLIN_SIZE + 1];
		for i in 0..FROGLIN_SIZE {
			ret[i] = stats[i];
		};
        ret[FROGLIN_SIZE] = secret;
        Poseidon2::hash(ret, FROGLIN_SIZE + 1)
	}
}

impl Default for Froglin {
    fn default() -> Self {
        Froglin {
            type_id: 0,
            id: 0,
            stealth: 0,
            attack: 0,
            defense: 0,
            health: 0,
            level: 0,
            awake_at: [0, 0, 0, 0],
            habitats: [Zone::default(), Zone::default(), Zone::default(), Zone::default()],
        }
    }
}

impl Eq for Froglin {
    fn eq(self, other: Self) -> bool {
        (self.id == other.id) &
        (self.type_id == other.type_id)
    }
}

impl Level for Froglin {
    fn get_level(self) -> Field {
        self.level
    }
}

impl LevelUp for Froglin {
    fn level_up(&mut self) {
        self.level += 1;
        self.attack += 1;
        self.defense += 1;
        self.health += 100;
    }
}

impl Froglin {
    fn get_type(self) -> Field {
        self.type_id
    }
}

#[test]
fn test_level_up() {
    let mut desert_froglin = desert_froglin::new(0x01); // unique id for the froglin
    let prev = desert_froglin;
    desert_froglin.level_up();
    println(desert_froglin.serialize());
    assert(prev.level != desert_froglin.level, "Level did not increase!");
    assert(prev.attack != desert_froglin.attack, "Attack did not increase!");
    assert(prev.defense != desert_froglin.defense, "Defense did not increase!");
    assert(prev.health != desert_froglin.health, "Health did not increase!");
}
