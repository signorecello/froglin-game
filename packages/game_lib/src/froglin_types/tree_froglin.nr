use crate::entities::froglin::Froglin;
use crate::zones_types::{forest::Forest, Zone};
use crate::traits::froglin_type::FroglinType;
use crate::globals::{FROGLIN_MAX_AWAKE_AT, FROGLIN_MAX_HABITATS};

struct TreeFroglin {
    type_id: Field,
    stealth: u32, // used to camouflaging so they're pretty hard to see
    attack: u32, // they're strong like hell
    defense: u32, // they're not that good at defending themselves
    health: u32, // they're pretty healthy
    level: Field,
    awake_at: [Field; FROGLIN_MAX_AWAKE_AT],
    habitats: [Zone; FROGLIN_MAX_HABITATS],
}

impl FroglinType for TreeFroglin {
    fn new(id: Field, level: Field) -> Froglin {
        Froglin {
            type_id: 2,
            id,
            stealth: 6 * level as u32, // used to camouflaging so they're pretty hard to see
            attack: 7 * level as u32, // they're strong like hell
            defense: 5 * level as u32, // they're not that good at defending themselves
            health: 500 * level as u32, // they're pretty healthy
            level: level,
        }
    }

    fn get_awake_times() -> [u32; 4] {
        // they're mostly nighttime froglins
        // this is 01.20, 02.40, 05.10, 08.30
        [8, 16, 31, 51]
    }

    fn get_habitats() -> [Zone; 4] {
        // lives in forests only
        [Forest::new(), Zone::default(), Zone::default(), Zone::default()]
    }
}
