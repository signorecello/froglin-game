use dep::game_lib::entities::{player::Player, froglin::Froglin};
use dep::game_lib::smt::smt::{add, verify};
use dep::game_lib::globals::{FROGLIN_SIZE, TREE_DEPTH};
use dep::game_lib::froglin_types::desert_froglin;
use dep::std::hash::poseidon2::Poseidon2;

fn main(
    player: Player,
    in_froglin: Froglin,
    froglin_siblings: [Field; TREE_DEPTH],
    secret: Field,
    old_identity: pub Field
) -> pub Field {
    player.assert_identity(secret, old_identity);

    let mut updated_player = player;
    updated_player.add_froglin(in_froglin);
    updated_player.stash_deposit(in_froglin.id, froglin_siblings, secret);

    let (_, identity) = updated_player.generate_identity(secret);
    identity
}

#[test]
fn test_e2e_deposit() {
    let mut player = Player::default();
    let secret = 0x123;
    let (_, old_identity) = player.generate_identity(secret);

    let froglin_id = 0x12;
    let froglin = desert_froglin::new(froglin_id);
    let mut siblings: [Field; TREE_DEPTH] = [0; TREE_DEPTH];

    let identity = main(player, froglin, siblings, secret, old_identity);
    assert(identity == 0x229d883c386bc4e0996b9bb3798928b6c3f85b77718e8549f43e19047de9ab96);
}
