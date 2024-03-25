use crate::types::froglin::Froglin;
use crate::zones_types::{zone_type::Zone, forest};

pub fn new(id: Field) -> Froglin {
    Froglin {
        type_id: 2,
        id,
        stealth: 6, // used to camouflaging so they're pretty hard to see
        attack: 7, // they're strong like hell
        defense: 5, // they're not that good at defending themselves
        health: 500, // they're pretty healthy
        level: 1,
        awake_at: get_awake_times(), // Make sure this fits the array size
        habitats: get_habitats() // Make sure this fits the array size
    }
}

pub fn get_awake_times() -> [u32; 4] {
    // they're mostly nighttime froglins
    // this is 01.20, 02.40, 05.10, 08.30
    [8, 16, 31, 51]
}

pub fn get_habitats() -> [Zone; 4] {
    // lives in forests only
    [forest::new(), Zone::default(), Zone::default(), Zone::default()]
}
