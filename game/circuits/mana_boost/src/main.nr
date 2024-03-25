use dep::game_lib::types::player::Player;

// player wants to prove he knows all the stats about the private input Player
// by providing a private input secret, serializizing and hashing it
// and comparing it against the known commitment (in the SC)

// this gives it authorization to make the changes in this circuit
// which are to add a known amount of mana to its stats
fn main(    
    player: Player,
    secret: Field,
    mp_boost: pub Field,
    old_identity: pub Field, // provided by the SC
) -> pub Field {
    // check that the player is the same as the one that was provided by the SC
    player.assert_identity(secret, old_identity);

    let mut updated_player = player;
    updated_player.add_mana(mp_boost);
    updated_player.generate_identity(secret)
}

#[test]
fn test_main() {
    let player = Player::default();
    let secret = 0x1234;
    let boost = 10;

    let old_identity = 0;
    let level_pub = 0;
    main(player, secret, boost, old_identity);
}
