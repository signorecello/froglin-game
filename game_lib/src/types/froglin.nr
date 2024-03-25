use crate::traits::{serialize::Serialize,froglin_type::FroglinType};
use crate::globals::{FROGLIN_SIZE, FROGLIN_MAX_AWAKE_AT, FROGLIN_MAX_HABITATS};
use crate::zones_types::zone_type::Zone;
use dep::std::println;
use dep::std::cmp::Eq;
use crate::froglin_types::desert_froglin;

struct Froglin {
    type_id: Field,
	id: Field, // unique ID of the froglin
    stealth: Field,
    attack: Field,
    defense: Field,
	health: Field,
    level: Field,
	awake_at: [Field; FROGLIN_MAX_AWAKE_AT], // this can be whatever
	habitats: [Zone; FROGLIN_MAX_HABITATS], // also can be any number
}

impl Serialize<FROGLIN_SIZE> for Froglin {
    fn serialize(self) -> [Field; FROGLIN_SIZE] {
        [self.type_id, self.id, self.stealth, self.attack, self.defense, self.health, self.level]
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

impl FroglinType for Froglin {
    fn get_type(&mut self) -> Field {
        self.type_id
    }
}

impl Froglin {
	pub fn level_up(&mut self) -> Froglin {
		let prev = *self;
		assert(self.id != 0, "Froglin does not exist!");

		self.level += 1;
        self.stealth += 1;
        self.attack += 1;
        self.defense += 1;
        self.health += 100;

        *self
	}
}

#[test]
fn test_level_up() {
	let mut desert_froglin = desert_froglin::new(0x01); // unique id for the froglin
    let prev = desert_froglin;
    desert_froglin.level_up();
    assert(prev.level != desert_froglin.level, "Level did not increase!");
    assert(prev.stealth != desert_froglin.stealth, "Stealth did not increase!");
    assert(prev.attack != desert_froglin.attack, "Attack did not increase!");
    assert(prev.defense != desert_froglin.defense, "Defense did not increase!");
    assert(prev.health != desert_froglin.health, "Health did not increase!");
}
