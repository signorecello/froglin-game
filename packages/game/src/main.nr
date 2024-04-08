mod playerNote;

contract FroglinUniverse {
    use dep::aztec::prelude::{AztecAddress, NoteGetterOptions, Map, PublicMutable, PrivateSet, SharedImmutable};
    use dep::aztec::oracle::debug_log::{debug_log, debug_log_format};
    use crate::playerNote::PlayerNote;

    struct Storage {
        game_master: SharedImmutable<AztecAddress>,
        players: PrivateSet<PlayerNote>,
    }

    #[aztec(public)]
    #[aztec(initializer)]
    fn init(gm: AztecAddress) {
        storage.game_master.initialize(gm);
    }

    #[aztec(private)]
    fn register(owner: AztecAddress, secret: Field) {
        let p_note = PlayerNote::new(owner, secret);
        debug_log("Player registered");
    }

    // #[aztec(private)]
    // fn mana_boost(player: Player) {
    //     player.assert_identity(secret, old_identity);
    //     let mut updated_player = player;
    //     updated_player.add_mana(total_mana);
    //     let (_, identity) = updated_player.generate_identity(secret);
    //     identity
    // }
}
