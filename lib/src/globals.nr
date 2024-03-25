// Zones are serialized into 3 Fields: id and two coords
global ZONE_SIZE = 3;

global FROGLIN_MAX_AWAKE_AT = 4; // 4 awake times
global FROGLIN_MAX_HABITATS = 4; // 4 max habitats

// 5 stats: id, base_stealth, base_attack, base_defense, and base_health
// plus 4 awake times
// plus 4 habitats (each habitat is a zone so 4 fields each)
global FROGLIN_TYPE_SIZE = 5 + FROGLIN_MAX_AWAKE_AT * 1 + ZONE_SIZE * FROGLIN_MAX_HABITATS;

// 6 stats: id, stealth, attack, defense, health, and level
// plus the base stats of the type
global FROGLIN_SIZE = FROGLIN_TYPE_SIZE + 6;

global ITEM_SIZE = 2;
global ITEM_MAX = 5;

global FROGLIN_MAX = 5;
global PLAYER_SIZE = 3 + ITEM_MAX * ITEM_SIZE + FROGLIN_MAX * FROGLIN_SIZE;

global IDENTITY_SIZE = PLAYER_SIZE + 2;
