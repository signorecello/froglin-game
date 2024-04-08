use crate::zones_types::Zone;
use crate::traits::zone_type::ZoneType;
use crate::globals::ZONES_COUNT;

struct Desert {
	id: Field,
	coords: [[Field; 2]; ZONES_COUNT],
}

impl ZoneType for Desert {
	fn new() -> Zone {
		Zone {
			id: 1,
			coords: [[0, 0], [0, 100], [100, 0], [100, 100]]
		}
	}
}
