use crate::traits::serialize::Serialize;
use crate::globals::{ZONE_SIZE};

struct Zone {
	id: Field,
	coords: [Field; 2]
}

impl Serialize<ZONE_SIZE> for Zone {
    fn serialize(self) -> [Field; ZONE_SIZE] {
        [self.id, self.coords[0], self.coords[1]]
    }
}

impl Default for Zone {
    fn default() -> Zone {
        Zone {
            id: 0,
            coords: [0, 0]
        }
    }
}

impl Zone {
    pub fn assert_unchanged(self, other: Zone) {
        println(f"Asserting Zone unchanged: {self}");
        assert(self.id == other.id);
        assert(self.coords[0] == other.coords[0]);
        assert(self.coords[1] == other.coords[1]);
    }
}
