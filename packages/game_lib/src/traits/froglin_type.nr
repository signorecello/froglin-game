use crate::entities::froglin::Froglin;
use crate::zones_types::Zone;
use crate::globals::{FROGLIN_MAX_AWAKE_AT, FROGLIN_MAX_HABITATS};

trait FroglinType {
    fn new(id: Field, level: Field) -> Froglin;
    fn get_awake_times() -> [u32; FROGLIN_MAX_AWAKE_AT];
    fn get_habitats() -> [Zone; FROGLIN_MAX_HABITATS];
}
