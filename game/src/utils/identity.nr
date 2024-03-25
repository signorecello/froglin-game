
use dep::std::eddsa::eddsa_to_pub;
use dep::std::println;

use dep::std::hash::poseidon2::Poseidon2;
use dep::froglin::types::player::Player;
use dep::froglin::globals::{PLAYER_SIZE, IDENTITY_SIZE};

pub fn assert_identity(serialized_player: [Field; PLAYER_SIZE], secret: Field, old_identity: Field) {
    let mut identity : [Field; IDENTITY_SIZE] = [0; IDENTITY_SIZE];
    for i in 0..PLAYER_SIZE {
        identity[i] = serialized_player[i];
    }

    let (pub_key_x, pub_key_y) = eddsa_to_pub(secret);
    identity[PLAYER_SIZE] = pub_key_x;
    identity[PLAYER_SIZE + 1] = pub_key_y;
    assert(Poseidon2::hash(identity, IDENTITY_SIZE) == old_identity, "Identity check failed");
}
