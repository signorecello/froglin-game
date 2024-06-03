use dep::aztec::prelude::{AztecAddress, NoteHeader, NoteInterface, PrivateContext, emit_encrypted_log};

use dep::aztec::{
    context::Context,
    oracle::{unsafe_rand::unsafe_rand, nullifier_key::get_nullifier_secret_key, get_public_key::get_public_key},
    note::{utils::compute_note_hash_for_consumption}, hash::pedersen_hash,
    protocol_types::traits::{Serialize, Deserialize}
};

use dep::aztec::oracle::debug_log::{debug_log, debug_log_format, debug_log_field};

global EPOCH_NOTE_LEN = 2;

struct Epoch {
    epoch: Field,
    timestamp: u64,
}

impl Epoch {
    pub fn new(epoch: Field, timestamp: u64) -> Self {
        Epoch { epoch, timestamp }
    }
}

impl Serialize<EPOCH_NOTE_LEN> for Epoch {
    fn serialize(self) -> [Field; EPOCH_NOTE_LEN] {
        [self.epoch, self.timestamp as Field]
    }
}

impl Deserialize<EPOCH_NOTE_LEN> for Epoch {
    fn deserialize(data: [Field; EPOCH_NOTE_LEN]) -> Self {
        Epoch {
            epoch: data[0],
            timestamp: data[1] as u64,
        }
    }
}
