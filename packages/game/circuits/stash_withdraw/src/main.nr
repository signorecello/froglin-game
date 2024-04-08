use dep::game_lib::entities::{player::Player, froglin::Froglin};
use dep::game_lib::globals::TREE_DEPTH;
use dep::game_lib::froglin_types::desert_froglin;
use dep::game_lib::smt;

fn main(
    player: Player,
    out_froglin: Froglin,
    out_froglin_siblings: [Field; TREE_DEPTH],
    secret: Field,
    old_identity: pub Field // provided by the SC
) -> pub Field {
    // check that the player is the same as the one that was provided by the SC
    player.assert_identity(secret, old_identity);

    let mut updated_player = player;
    updated_player.stash_withdraw(out_froglin, out_froglin_siblings, secret);

    let mut updated_player = player;
    let (_, identity) = updated_player.generate_identity(secret);
    identity
}

#[test]
fn test_e2e_withdraw() {
    // generate an identity without any froglin
    let mut player = Player::default();
    let secret = 0x123;
    let (_, initial_identity) = player.generate_identity(secret);

    let froglin_id = 0x12;
    let froglin = desert_froglin::new(froglin_id);
    let mut siblings: [Field; TREE_DEPTH] = [0; TREE_DEPTH];

    // add a froglin, then deposit it
    player.add_froglin(froglin);
    player.stash_deposit(froglin.id, siblings, secret);

    // generate the identity after the deposit, and run the withdraw function
    let (_, identity_after_deposit) = player.generate_identity(secret);
    let _ = main(player, froglin, siblings, secret, identity_after_deposit);

    // froglin is now in the player's inventory, remove it
    // and check the identity is back to the initial one
    let _ = player.remove_froglin(froglin.id);
    let (_, identity_after_test) = player.generate_identity(secret);

    assert(identity_after_test == initial_identity);
}
