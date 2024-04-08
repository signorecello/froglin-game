mod desert;
mod forest;

use crate::globals::ZONES_COUNT;

struct Zone {
	id: Field,
	coords: [[Field; 2]; ZONES_COUNT],
}

impl Default for Zone {
	fn default() -> Self {
		Zone {
			id: 10,
			coords: [[0, 0], [0, 0], [0, 0], [0, 0]]
		}
	}
}
