use dep::froglin::types::player::Player;

use crate::utils::identity;

// user gets a mana power increase by 10, so the circuit returns a new identity
fn mp_boost(
    player: Player,
    secret: Field,
    mp_boost: pub Field,
    old_identity: pub Field, // provided by the SC
    level_pub: pub Field // also provided by the SC - needs to be proven everytime because it's public
) {
    // user sends all the fields for the proof
    // it needs to serialize and hash together with the asserted public_key
    // and prove it matches the identity that was stored on_chain
    let serialized_player = player.serialize();
    identity::assert_identity(serialized_player, secret, old_identity);

    // we can construct the new identity right away

    // let new_serialized_player = new_player.serialize();
    // // and then assert every single stat
    // assert(new_player.level == player.level)
    // assert(new_player.level == level_pub)
    // assert(new_player.stash_root == player.stash_root)
    // assert(new_player.inventory == player.inventory)
    // assert(new_player.froglins == player.froglins)
    // // go back to serializing it
    // let new_serialized_player = new_player.serialize();
    // let mut new_identity : [Field; 18] = [Field; 0];
    // for i in 0..17 {
    // 	new_identity[i] = new_serialized_player[i]
    // }
    // new_identity[18] = pub_key;
    // poseidon2(new_identity) // return the new identity
}
