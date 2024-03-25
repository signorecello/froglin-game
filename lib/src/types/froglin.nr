use crate::traits::serialize::Serialize;
use crate::globals::{FROGLIN_SIZE, FROGLIN_TYPE_SIZE};
use crate::types::froglin_type::FroglinType;
use dep::std::println;
use dep::std::cmp::Eq;

struct Froglin {
	id: Field, // unique ID of the froglin
    stealth: Field,
    attack: Field,
    defense: Field,
	health: Field,
    level: Field,
	froglin_type: FroglinType,
}

impl Serialize<FROGLIN_SIZE> for Froglin {
    fn serialize(self) -> [Field; FROGLIN_SIZE] {
        let mut stats = [self.id, self.attack, self.defense, self.health, self.level].as_slice();
        
        for i in 0..FROGLIN_TYPE_SIZE {
            stats = stats.push_back(self.froglin_type.serialize()[i]);
        }

        let mut ret : [Field; FROGLIN_SIZE] = [0; FROGLIN_SIZE];
        for i in 0..FROGLIN_SIZE {
            ret[i] = stats[i];
        };
        ret
    }
}

impl Default for Froglin {
    // id 0 for a Froglin is like "no identity", kind of unborn lol
    // I also realize I don't need to serialize its type, that's a waste of space
    // only the type ID should be enough
    fn default() -> Self {
        Froglin {
            id: 0,
            attack: FroglinType::default().base_attack,
            defense: FroglinType::default().base_defense,
            health: FroglinType::default().base_health,
            level: 0,
            froglin_type: FroglinType::default().id,
        }
    }
}

impl Eq for Froglin {
    fn eq(self, other: Self) -> bool {
        (self.id == other.id) &
        (self.froglin_type == other.froglin_type)
    }
}

impl Froglin {
    pub fn new(id: Field, type_id: Field) -> Self {
        let mut froglin = Froglin::default();
        // we make a Froglin into the real world by assigning it an ID and a type
        froglin.id = id;
        froglin.froglin_type = FroglinType::new(type_id);
        froglin
    }

    pub fn assert_unchanged(self, other: Froglin) {
        println(f"Asserting Froglin unchanged: {self}");
        assert(self.id == other.id);
        assert(self.health == other.health);
        assert(self.level == other.level);
        self.froglin_type.assert_unchanged(other.froglin_type);
    }
}
