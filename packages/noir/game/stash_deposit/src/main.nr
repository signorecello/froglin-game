use dep::game_lib::types::{player::Player, froglin::Froglin};
use dep::game_lib::smt::smt::{add, verify};
use dep::game_lib::globals::{FROGLIN_SIZE, TREE_DEPTH};
use dep::std::hash::poseidon2::Poseidon2;

fn main(
    player: Player,
    in_froglin: Froglin,
    froglin_siblings: [Field; TREE_DEPTH],
    matching_entry: [Option<Field>; 2],
    secret: Field,
    old_identity: pub Field
) -> pub Field {
    // check that the player is the same as the one that was provided by the SC
    player.assert_identity(secret, old_identity);

    let value = in_froglin.commit(secret);
    let key = Poseidon2::hash([value], 1);

    // prove non-membership
    verify(
        [key, value],
        matching_entry,
        froglin_siblings,
        player.stash_root
    );

    // add the new entry
    let new_root = add([key, value], player.stash_root, froglin_siblings);

    // update the player
    let mut new_player = player;
    new_player.update_stash(new_root);
    let (_, identity) = new_player.generate_identity(secret);
    identity
}
