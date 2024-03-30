use dep::game_lib::types::{player::Player, froglin::Froglin};
use dep::game_lib::smt;

fn main(
    player: Player,
    in_froglin: Froglin,
    out_froglin: Froglin,
    secret: Field,
    old_identity: pub Field // provided by the SC
) -> pub Field {
    // check that the player is the same as the one that was provided by the SC
    player.assert_identity(secret, old_identity);

    // new_value: Field,
    // old_entry: [Field; 2],
    // old_root: Field,
    // siblings: [Field; TREE_DEPTH]

    smt::update();

    let mut updated_player = player;
    let (_, identity) = updated_player.generate_identity(secret);
    identity
}
