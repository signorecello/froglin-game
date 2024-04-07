use crate::traits::serialize::Serialize;
use crate::globals::{ZONES_COUNT};

struct Zone {
	id: Field,
	coords: [[Field; 2]; ZONES_COUNT],
}

impl Default for Zone {
	fn default() -> Self {
		Zone {
			id: 0,
			coords: [[0,0], [0, 0], [0, 0], [0,0]]
		}
	}
}
