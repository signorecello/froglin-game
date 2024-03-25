use crate::traits::serialize::Serialize;
use crate::globals::{FROGLIN_TYPE_SIZE, ZONE_SIZE, FROGLIN_MAX_AWAKE_AT, FROGLIN_MAX_HABITATS};
use crate::types::zone::Zone;
use dep::std::cmp::Eq;

struct FroglinType {
    id: Field, // this is an unique ID for each type of froglin
	base_stealth: Field, // say global evasiveness is 700, this will remove 20 so base_stealth is 640,
	base_attack: Field,
	base_defense: Field,
	base_health: Field,
	awake_at: [Field; FROGLIN_MAX_AWAKE_AT], // this can be whatever
	habitats: [Zone; FROGLIN_MAX_HABITATS], // also can be any number
}


impl Serialize<FROGLIN_TYPE_SIZE> for FroglinType {
    fn serialize(self) -> [Field; FROGLIN_TYPE_SIZE] {
        let mut stats : [Field] = [self.id, self.base_stealth, self.base_attack, self.base_defense, self.base_health].as_slice();
        
        for i in 0..FROGLIN_MAX_AWAKE_AT {
            stats = stats.push_back(self.awake_at[i]);
        }

        for i in 0..FROGLIN_MAX_HABITATS {
            for j in 0..ZONE_SIZE {
                stats = stats.push_back(self.habitats[i].serialize()[j]);
            }
        }

        let mut ret : [Field; FROGLIN_TYPE_SIZE] = [0; FROGLIN_TYPE_SIZE];
        for i in 0..FROGLIN_TYPE_SIZE {
            ret[i] = stats[i];
        };
        ret
    }
}

impl Default for FroglinType {
    // FroglinType with id 0 is an unexistent type
    // I think I also don't need to serialize the zones, just its ID
    // as zones will be constant
    fn default() -> Self {
        FroglinType {
            id: 0,
            base_stealth: 1,
            base_attack: 1,
            base_defense: 1,
            base_health: 100,
            awake_at: [0; FROGLIN_MAX_AWAKE_AT],
            habitats: [Zone::default().id; FROGLIN_MAX_HABITATS],
        }
    }
}

impl Eq for FroglinType {
    fn eq(self, other: Self) -> bool {
        self.id == other.id
    }
}

impl FroglinType {
    pub fn new(type_id: Field) -> Self {
        // there's a list of all froglin types, this is just a constructor
        FroglinType {
            id,
            base_stealth,
            base_attack,
            base_defense,
            base_health,
            awake_at,
            habitats,
        }
    }

    pub fn assert_unchanged(self, other: FroglinType) {
        println(f"Asserting FroglinType unchanged: {self}");
        assert(self.id == other.id);
        assert(self.base_stealth == other.base_stealth);
        assert(self.base_attack == other.base_attack);
        assert(self.base_defense == other.base_defense);
        assert(self.base_health == other.base_health);
        for i in 0..FROGLIN_MAX_AWAKE_AT {
            assert(self.awake_at[i] == other.awake_at[i]);
        }
        for i in 0..FROGLIN_MAX_HABITATS {
            self.habitats[i].assert_unchanged(other.habitats[i]);
        }
    }
}
