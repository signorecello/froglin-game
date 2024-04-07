use dep::game_lib::types::player::Player;
use dep::game_lib::zones_types::{zone_type::Zone, desert};
use dep::game_lib::froglin_types::{get_froglin_type_by_id, desert_froglin};
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
    current_zone: [Field; 2],
    froglin_id: pub Field, // unique id of the froglin, provided by the SC
    froglin_type_id: pub Field, // a froglin in the wild has always the same stats, for now. TODO would be cool to have different levels and etc
    old_identity: pub Field, // provided by the SC
    current_fog_level: pub u32, // provided by the SC
    current_epoch: pub u32 // provided by the SC
) -> pub Field {
    // check that the player is valid
    player.assert_identity(secret, old_identity);
    let mut updated_player = player;
    let caught_froglin = get_froglin_type_by_id(froglin_id, froglin_type_id);

    // check that the player has enough mana to catch the froglin
    let required_mana = caught_froglin.stealth + current_fog_level;
    assert(player.mana > required_mana, "Not enough mana to catch the froglin");
    updated_player.remove_mana(required_mana);

    // check that the player is in one of the froglin habitats
    let mut is_in_habitat = false;
    for h in 0..caught_froglin.habitats.len() {
        is_in_habitat = caught_froglin.habitats[h].coords.any(|loc : [Field; 2]| loc == current_zone);
    }
    assert(is_in_habitat, "Not in the right zone to catch the froglin");

    // check that the player is in the right epoch to catch the froglin
    let is_in_epoch = caught_froglin.awake_at.any(|epoch| epoch == current_epoch);
    assert(is_in_epoch, "Not at the right time to catch the froglin");

    // add froglin to inventory
    let _ = updated_player.add_froglin(caught_froglin);

    // update the player's identity
    let (_, identity) = updated_player.generate_identity(secret);
    identity
}

#[test]
fn test_success_capture() {
    let mut player = Player::default();
    player.add_mana(200);
    let secret = 0x123;
    let (_, old_identity) = player.generate_identity(secret);

    let froglin_id = 0x12;
    let mock_froglin = desert_froglin::new(froglin_id);
    let froglin_type_id = mock_froglin.type_id;
    let current_zone = mock_froglin.habitats[0].coords[0];
    let current_epoch = mock_froglin.awake_at[0];
    let current_fog_level = 100;

    let new_id = main(
        player,
        secret,
        current_zone,
        froglin_id,
        froglin_type_id,
        old_identity,
        current_fog_level,
        current_epoch
    );
    assert(new_id == 0x2a122862ca1821bd706ba3ca486c918fc0e220ef3182c5e0c9fc82c4b1df5f66);

    let mut adversary = Player::default();
    adversary.add_mana(200); // need to add AND remove so the claimed_mana stays the same
    adversary.remove_mana(101);
    let _ = adversary.add_froglin(mock_froglin);
    let (_, adversary_id) = adversary.generate_identity(secret);
    assert(adversary_id == new_id);
}

#[test(should_fail_with = "Not enough mana to catch the froglin")]
fn test_fail_no_mana() {
    let mut player = Player::default();
    player.add_mana(10);
    let secret = 0x123;
    let (_, old_identity) = player.generate_identity(secret);

    let froglin_id = 0x12;
    let mock_froglin = desert_froglin::new(froglin_id);
    let froglin_type_id = mock_froglin.type_id;
    let current_zone = mock_froglin.habitats[0].coords[0];
    let current_epoch = mock_froglin.awake_at[0];
    let current_fog_level = 100;

    let new_id = main(
        player,
        secret,
        current_zone,
        froglin_id,
        froglin_type_id,
        old_identity,
        current_fog_level,
        current_epoch
    );
    assert(new_id == 0x2a122862ca1821bd706ba3ca486c918fc0e220ef3182c5e0c9fc82c4b1df5f66);
}

#[test(should_fail_with = "Not in the right zone to catch the froglin")]
fn test_fail_no_habitat() {
    let mut player = Player::default();
    player.add_mana(200);
    let secret = 0x123;
    let (_, old_identity) = player.generate_identity(secret);

    let froglin_id = 0x12;
    let mock_froglin = desert_froglin::new(froglin_id);
    let froglin_type_id = mock_froglin.type_id;
    let current_zone = [500, 500];
    let current_epoch = mock_froglin.awake_at[0];
    let current_fog_level = 100;

    let new_id = main(
        player,
        secret,
        current_zone,
        froglin_id,
        froglin_type_id,
        old_identity,
        current_fog_level,
        current_epoch
    );
    assert(new_id == 0x2a122862ca1821bd706ba3ca486c918fc0e220ef3182c5e0c9fc82c4b1df5f66);
}

#[test(should_fail_with = "Not at the right time to catch the froglin")]
fn test_fail_no_epoch() {
    let mut player = Player::default();
    player.add_mana(200);
    let secret = 0x123;
    let (_, old_identity) = player.generate_identity(secret);

    let froglin_id = 0x12;
    let mock_froglin = desert_froglin::new(froglin_id);
    let froglin_type_id = mock_froglin.type_id;
    let current_zone = mock_froglin.habitats[0].coords[0];
    let current_epoch = 1;
    let current_fog_level = 100;

    let new_id = main(
        player,
        secret,
        current_zone,
        froglin_id,
        froglin_type_id,
        old_identity,
        current_fog_level,
        current_epoch
    );
    assert(new_id == 0x2a122862ca1821bd706ba3ca486c918fc0e220ef3182c5e0c9fc82c4b1df5f66);
}
