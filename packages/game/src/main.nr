mod playerNote;
mod epochs;
mod fog_mana_capsule;

contract FroglinUniverse {
    use dep::aztec::prelude::{
        PrivateMutable, FunctionSelector, AztecAddress, NoteViewerOptions, Map, PublicMutable,
        PrivateSet, SharedImmutable
    };
    use dep::aztec::oracle::{
        unsafe_rand::unsafe_rand,
        debug_log::{debug_log, debug_log_format, debug_log_field, debug_log_array_with_prefix}
    };
    use dep::aztec::state_vars::shared_mutable::SharedMutable;
    use dep::authwit::auth::{
        assert_current_call_valid_authwit, compute_call_authwit_hash,
        assert_current_call_valid_authwit_public, compute_outer_authwit_hash
    };
    use crate::playerNote::PlayerNote;
    use crate::epochs::Epoch;
    use dep::game_lib::entities::player::{Player, PLAYER_SIZE};

    use dep::aztec::note::note_getter_options::{NoteStatus, NoteGetterOptions};
    use dep::aztec::context::{PrivateContext, PublicContext, Context, gas::GasOpts};

    use crate::fog_mana_capsule::pop_capsule;

    #[aztec(storage)]
    struct Storage {
        game_master: SharedImmutable<AztecAddress>,
        epoch: PublicMutable<Epoch>,
        fog: PublicMutable<Field>,
        players: Map<AztecAddress, PrivateMutable<PlayerNote>>,
    }

    #[aztec(public)]
    #[aztec(initializer)]
    fn constructor(gm: AztecAddress) {
        storage.game_master.initialize(gm);

        let epoch = Epoch::new(0, context.timestamp());
        storage.epoch.write(epoch);
    }

    #[aztec(public)]
    fn advance_epoch() {
        assert(
            context.msg_sender() == storage.game_master.read_public(), "Only the game master can advance the epoch"
        );
        let mut current_epoch = storage.epoch.read();

        assert(
            current_epoch.timestamp + 10 < context.timestamp(), "Epoch can only be advanced every 10 seconds"
        );
        current_epoch.timestamp = context.timestamp();
        current_epoch.epoch += 1;
        storage.epoch.write(current_epoch);

        // Set the fog to a random number for now
        let amount = unsafe_rand() as u32;
        let normalized_amount = amount % 100;

        let _ : Field = context.call_public_function(
            context.this_address(),
            FunctionSelector::from_signature("set_fog(u32)"),
            [normalized_amount as Field],
            GasOpts::default()
        ).deserialize_into();
    }

    #[aztec(public)]
    #[aztec(internal)]
    fn set_fog(amount: Field) {
        storage.fog.write(amount);
    }

    #[aztec(private)]
    fn register(owner: AztecAddress, secret: Field) {
        let mut player = storage.players.at(owner);
        let mut p_note = PlayerNote::new(owner, secret);

        player.initialize(&mut p_note, true);
        debug_log("Player registered");
    }

    #[aztec(private)]
    fn mana_boost(amount: Field) {
        let player_storage = storage.players.at(context.msg_sender());

        let mut player_note = player_storage.get_note(true);

        let current_fog = storage.fog.read();

        // the idea here is to make the capsule give the square root of the fog
        // and assert oracle_amount[0].pow(2), otherwise the number of constraints lol
        assert((amount * amount) as u32 == current_fog as u32, "Fog amount does not match");
        player_note.player.add_mana(amount as u32);

        player_storage.replace(&mut player_note, true);
        debug_log("Mana boost");
    }

    unconstrained fn view_game() -> pub [Field; 3] {
        let epoch = storage.epoch.read();
        let fog = storage.fog.read();
        debug_log("Game State");
        debug_log("Epoch");
        debug_log_field(epoch.epoch as Field);
        debug_log_field(epoch.timestamp as Field);
        debug_log("Fog");
        debug_log_field(fog as Field);
        [epoch.epoch as Field, epoch.timestamp as Field, fog as Field]
    }

    unconstrained fn view_player(owner: AztecAddress) -> pub [Field; PLAYER_SIZE] {
        let player_storage = storage.players.at(owner);

        let player_note = player_storage.view_note();
        debug_log("Player");
        debug_log_array_with_prefix("", Player::serialize(player_note.player));
        Player::serialize(player_note.player)
    }
}
