use dep::game_lib::types::player::Player;
use dep::game_lib::froglin_types::get_froglin_type_by_id;
use dep::game_lib::utils::pretty_print::p_print;
use dep::std::field::bn254::gt;

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
    current_fog_level: pub u32 // provided by the SC
) -> pub Field {
    // check that the player is valid
    player.assert_identity(secret, old_identity);
    let mut updated_player = player;

    let caught_froglin = get_froglin_type_by_id(froglin_id, froglin_type_id);

    // check that the player has enough mana to catch the froglin
    let required_mana = caught_froglin.stealth + current_fog_level;
    assert(player.mana_power > required_mana, "Not enough mana to catch the froglin");

    // update the player's stats
    updated_player.remove_mana(required_mana);

    // froglin action will decide whether to store in inventory or in the stash
    let _ = updated_player.add_froglin(caught_froglin);

    // update the player's identity
    updated_player.generate_identity(secret)
}

#[test]
fn test_success_capture() {
    let mut player = Player::default();
    player.add_mana(200);
    let secret = 0x123;
    let old_identity = player.generate_identity(secret);

    let froglin_id = 0x12;
    let froglin_type_id = 1;
    let current_fog_level = 100;

    // p_print(player, secret);
    let new_id = main(
        player,
        secret,
        froglin_id,
        froglin_type_id,
        old_identity,
        current_fog_level
    );
    assert(new_id == 0x1678219dbdb51e9130e70b6401ea4e0e797c47dc4e8a5f95a0424c3ffbe8d99e);

    let mut adversary = Player::default();
    adversary.add_mana(99);
    let caught_froglin = get_froglin_type_by_id(froglin_id, froglin_type_id);
    let _ = adversary.add_froglin(caught_froglin);
    let adversary_id = adversary.generate_identity(secret);
    assert(adversary_id == new_id);
}

#[test(should_fail_with = "Not enough mana to catch the froglin")]
fn test_fail_capture() {
    let mut player = Player::default();
    player.add_mana(10);
    let secret = 0x123;
    let old_identity = player.generate_identity(secret);

    let froglin_id = 0x12;
    let froglin_type_id = 1;
    let current_fog_level = 100;
    let new_id = main(
        player,
        secret,
        froglin_id,
        froglin_type_id,
        old_identity,
        current_fog_level
    );
    assert(new_id == 0x1678219dbdb51e9130e70b6401ea4e0e797c47dc4e8a5f95a0424c3ffbe8d99e);
}
