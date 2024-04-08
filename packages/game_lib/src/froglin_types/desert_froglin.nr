use crate::entities::froglin::Froglin;
use crate::zones_types::{desert::Desert, Zone};
use crate::traits::froglin_type::FroglinType;
use crate::globals::{FROGLIN_MAX_AWAKE_AT, FROGLIN_MAX_HABITATS};

struct DesertFroglin {
    type_id: Field,
    stealth: u32, // used to camouflaging so they're pretty hard to see
    attack: u32, // they're strong like hell
    defense: u32, // they're not that good at defending themselves
    health: u32, // they're pretty healthy
    level: Field,
    awake_at: [Field; FROGLIN_MAX_AWAKE_AT],
    habitats: [Zone; FROGLIN_MAX_HABITATS],
}

impl FroglinType for DesertFroglin {
    pub fn new(id: Field, level: Field) -> Froglin {
        Froglin {
            type_id: 1,
            id,
            stealth: 1 * level as u32, // have very little experience with stealth
            attack: 8 * level as u32, // strong attack because of their strong legs
            defense: 4 * level as u32, // but low defense due to the lack of armor
            health: 200 * level as u32, // still pretty tough to kill
            level: 1,
        }
    }

    pub fn get_awake_times() -> [u32; 4] {
        // is awake at 10am, 13am, 16am, 19am, 22am
        [60, 78, 96, 114]
    }

    pub fn get_habitats() -> [Zone; 4] {
        // lives in prairies only
        [Desert::new(), Zone::default(), Zone::default(), Zone::default()]
    }
}
