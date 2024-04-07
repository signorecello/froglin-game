
// id and two coords, let's assume 0.0 is top left and 500.500 is bottom right
// make sure this one matches zones_drawing lol

use crate::zones_types::zone_type::Zone;

#[export]
pub fn new() -> Zone {
    Zone { id: 1, coords: [[0, 0], [0, 100], [100, 0], [100, 100]] }
}
