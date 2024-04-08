use dep::game_lib::entities::player::Player;

// player wants to prove he knows all the stats about the private input Player
// by providing a private input secret, serializizing and hashing it
// and comparing it against the known commitment (in the SC)

// this gives it authorization to make the changes in this circuit
// which are to add a known amount of mana to its stats
fn main(
    player: Player,
    secret: Field,
    total_mana: pub u32,
    old_identity: pub Field // provided by the SC
) -> pub Field {
    // check that the player is the same as the one that was provided by the SC
    player.assert_identity(secret, old_identity);

    let mut updated_player = player;
    updated_player.add_mana(total_mana);

    let (_, identity) = updated_player.generate_identity(secret);
    identity
}

#[test]
fn test_success_boost_mana() {
    let player = Player::default();
    let secret = 0x1234;
    let boost = 10;

    let (_, old_identity) = player.generate_identity(secret);
    let new_id = main(player, secret, boost, old_identity);
    assert(new_id != old_identity);

    let mut adversary = Player::default();
    adversary.add_mana(boost);
    let (_, adversary_id) = adversary.generate_identity(secret);
    assert(new_id == adversary_id);
}

#[test(should_fail)]
fn test_fail_boost_man() {
    let player = Player::default();
    let secret = 0x1234;
    let boost = 10;

    let (_, old_identity) = player.generate_identity(secret);
    let new_id = main(player, secret, boost, old_identity);
    assert(new_id != old_identity);

    let mut adversary = Player::default();
    let (_, adversary_id) = adversary.generate_identity(secret);

    assert(new_id == adversary_id);
}
