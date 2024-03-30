use crate::types::froglin::Froglin;
use crate::zones_types::{zone_type::Zone, desert};

pub fn new(id: Field) -> Froglin {
    Froglin {
        type_id: 1,
        id,
        stealth: 1, // have very little experience with stealth
        attack: 8, // strong attack because of their strong legs
        defense: 4, // but low defense due to the lack of armor
        health: 200, // still pretty tough to kill
        level: 1,
        awake_at: get_awake_times(), // Make sure this fits the array size
        habitats: get_habitats() // Make sure this fits the array size
    }
}

pub fn get_awake_times() -> [u32; 4] {
    // is awake at 10am, 13am, 16am, 19am, 22am
    [60, 78, 96, 114]
}

pub fn get_habitats() -> [Zone; 4] {
    // lives in prairies only
    [desert::new(), Zone::default(), Zone::default(), Zone::default()]
}

