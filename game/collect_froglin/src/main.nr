use dep::game_lib::types::player::Player;
use dep::game_lib::froglin_types::get_froglin_type_by_id;

// player wants to prove he knows all the stats about the private input Player
// by providing a private input secret, serializizing and hashing it
// and comparing it against the known commitment (in the SC)
// this gives it authorization to make the changes in this circuit

// this circuit runs when the user "catches" a new froglin
// by proving its mana power is enough to overcome the current fog level
// and any modifications such as froglin's stealth, etc
fn main(    
    player: Player,
    secret: Field,
    froglin_id: pub Field, // unique id of the froglin, provided by the SC
    froglin_type_id: pub Field, // a froglin in the wild has always the same stats, for now. TODO would be cool to have different levels and etc
    old_identity: pub Field, // provided by the SC
    current_fog_level: pub Field, // provided by the SC
) -> pub Field {
    // check that the player is valid
    player.assert_identity(secret, old_identity);

    let caught_froglin = get_froglin_type_by_id(froglin_type_id);
    println(caught_froglin);

    let mut updated_player = player;
    updated_player.generate_identity(secret)
}

// #[test]
// fn test_main() {
//     let player = Player::default();
//     let secret = 0x1234;
//     let boost = 10;

//     let old_identity = 0;
//     let level_pub = 0;
//     main(player, secret, boost, old_identity);
// }
