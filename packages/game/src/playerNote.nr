use dep::aztec::prelude::{AztecAddress, NoteHeader, NoteInterface, PrivateContext, emit_encrypted_log};

use dep::aztec::{
    context::Context,
    oracle::{unsafe_rand::unsafe_rand, nullifier_key::get_nullifier_secret_key, get_public_key::get_public_key},
    note::{utils::compute_note_hash_for_consumption},
    hash::pedersen_hash
};

use dep::game_lib::entities::player::Player;
use dep::game_lib::globals::PLAYER_SIZE;

global PLAYER_NOTE_LENGTH = PLAYER_SIZE + 2;


#[aztec(note)]
struct PlayerNote {
    player: Player,
    owner: AztecAddress,
    secret: Field,
    randomness: Field,
    header: NoteHeader,
}

impl PlayerNote {
    pub fn new(owner: AztecAddress, secret: Field) -> Self {
        let player = Player::default();
        let randomness = unsafe_rand();
        let header = NoteHeader::empty();
        PlayerNote { player, owner, secret, randomness, header }
    }
}

impl NoteInterface<PLAYER_NOTE_LENGTH> for PlayerNote {

    fn compute_nullifier(self, context: &mut PrivateContext) -> Field {
        let note_hash_for_nullify = compute_note_hash_for_consumption(self);
        let secret = context.request_nullifier_secret_key(self.owner);
        pedersen_hash([
            note_hash_for_nullify,
            secret.low,
            secret.high,
        ],0)
    }

    fn compute_nullifier_without_context(self) -> Field {
        let note_hash_for_nullify = compute_note_hash_for_consumption(self);
        let secret = get_nullifier_secret_key(self.owner);
        pedersen_hash([
            note_hash_for_nullify,
            secret.low,
            secret.high,
        ],0)
    }

    fn serialize_content(self) -> [Field; PLAYER_NOTE_LENGTH] {
        let mut p = [0; PLAYER_NOTE_LENGTH];
        let serializedPlayer = self.player.serialize();
        
        for i in 0..PLAYER_SIZE {
            p[i] = serializedPlayer[i];
        }

        p[PLAYER_SIZE] = self.owner.to_field();
        p[PLAYER_SIZE + 1] = self.secret;
        p[PLAYER_SIZE + 2] = self.randomness;
        p
    }

    fn deserialize_content(serialized_note: [Field; PLAYER_NOTE_LENGTH]) -> Self {
        let mut p_notes = [0; PLAYER_SIZE];
        for i in 0..PLAYER_NOTE_LENGTH {
            p_notes[i] = serialized_note[i];
        }

        PlayerNote {
            player: Player::deserialize(p_notes),
            owner: AztecAddress::from_field(serialized_note[PLAYER_SIZE]),
            secret: serialized_note[PLAYER_SIZE + 1],
            randomness: serialized_note[PLAYER_SIZE + 2],
            header: NoteHeader::empty(),
        }
    }

    fn compute_note_content_hash(self) -> Field {
        pedersen_hash(self.serialize_content(), 0)
    }

    fn set_header(&mut self, header: NoteHeader) {
        self.header = header;
    }

    fn get_header(note: PlayerNote) -> NoteHeader {
        note.header
    }

    // Broadcasts the note to the opponent
    fn broadcast(self, context: &mut PrivateContext, slot: Field) {
        let encryption_pub_key = get_public_key(self.owner);
        emit_encrypted_log(
            context,
            (*context).this_address(),
            slot,
            Self::get_note_type_id(),
            encryption_pub_key,
            self.serialize_content(),
        );
    }

    fn get_note_type_id() -> Field {
        // TODO(#4519): autogenerate
        // python -c "print(int(''.join(str(ord(c)) for c in 'CardNote')))"
        679711410078111116101
    }
}
