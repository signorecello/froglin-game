use crate::zones_types::Zone;
use crate::traits::zone_type::ZoneType;
use crate::globals::ZONES_COUNT;

struct Forest {
	id: Field,
	coords: [[Field; 2]; ZONES_COUNT],
}

impl ZoneType for Forest {
	fn new() -> Zone {
		Zone {
            id: 2,
            coords: [[400,400], [400, 500], [500, 400], [500,500]]
		}
	}
}
