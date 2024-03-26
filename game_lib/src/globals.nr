// 4 zones with 2 fields each (x and y)
global ZONES_COUNT = 4;

global FROGLIN_MAX_AWAKE_AT = 4; // 4 awake times
global FROGLIN_MAX_HABITATS = 4; // 4 max habitats

// 6 stats: id, stealth, attack, defense, health, level and type
// we don't need to serialize the other two stats (awake_at and habitat)
global FROGLIN_SIZE = 7;

global ITEM_SIZE = 2;
global ITEM_MAX = 5;

global FROGLIN_MAX = 5;
global PLAYER_SIZE = 3 + ITEM_MAX * ITEM_SIZE + FROGLIN_MAX * FROGLIN_SIZE;

global IDENTITY_SIZE = 2;
