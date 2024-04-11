mod playerNote;

contract FroglinUniverse {
    use dep::aztec::prelude::{
        PrivateMutable, AztecAddress, NoteGetterOptions, NoteViewerOptions, Map, PublicMutable,
        PrivateSet, SharedImmutable
    };
    use dep::aztec::oracle::debug_log::{debug_log, debug_log_format, debug_log_field, debug_log_array_with_prefix};
    use crate::playerNote::PlayerNote;
    use dep::game_lib::entities::player::{Player, PLAYER_SIZE};

    use dep::aztec::note::note_getter_options::NoteStatus;
    use dep::aztec::context::{PrivateContext, PublicContext, Context};

    struct Storage {
        game_master: SharedImmutable<AztecAddress>,
        epoch: PublicMutable<u32>,
        fog: PublicMutable<u32>,
        players: Map<AztecAddress, PrivateMutable<PlayerNote>>,
    }

    #[aztec(public)]
    #[aztec(initializer)]
    fn init(gm: AztecAddress) {
        storage.game_master.initialize(gm);
        storage.epoch.write(0);
    }

    #[aztec(public)]
    fn advance_epoch() {
        assert(
            context.msg_sender() == storage.game_master.read_public(), "Only the game master can set the epoch"
        );

        let mut epoch = storage.epoch.read();
        storage.epoch.write(epoch + 1);
    }

    #[aztec(private)]
    fn register(owner: AztecAddress, secret: Field) {
        let mut player = storage.players.at(owner);
        let mut p_note = PlayerNote::new(owner, secret);

        player.initialize(&mut p_note, true);
        debug_log("Player registered");
    }

    #[aztec(private)]
    fn mana_boost(amount: u32) {
        let player_storage = storage.players.at(context.msg_sender());

        let mut player_note = player_storage.get_note(true);
        player_note.player.add_mana(amount);

        player_storage.replace(&mut player_note, true);
        debug_log("Mana boost");
    }

    unconstrained fn view_player(owner: AztecAddress) -> pub [Field; PLAYER_SIZE] {
        let player_storage = storage.players.at(owner);

        let player_note = player_storage.view_note();
        debug_log("Player");
        debug_log_array_with_prefix("", Player::serialize(player_note.player));
        Player::serialize(player_note.player)
    }
}
