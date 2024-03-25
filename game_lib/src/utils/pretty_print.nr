use crate::types::player::PlayerTrait;
use crate::types::froglin::Froglin;
use crate::types::player::Player;
use dep::std::println;

unconstrained pub fn p_print<T>(player: T, secret: Field) where T: PlayerTrait {
    println("");
    println("");
    println("----------------");
    let id = player.generate_identity(secret);
    println(f"PLAYER - IDENTITY {id}");
    println("----------------");
    println("STATS");
    let mp = player.get_mana();
    println(f"    Mana Power: {mp}");
    let level = player._get_level();
    println(f"    Level: {level}");
    let stash_root = player.get_stash_root();
    println(f"    Stash Root: {stash_root}");
    println("");
    println("FROGLINS");
    let player_froglins = player.get_froglins();
    for i in 0..player_froglins.len() {
        if (player_froglins[i].id != 0) {
            let Froglin { type_id, id, stealth, attack, defense, health, level, awake_at, habitats } = player_froglins[i];
            println(f"    Froglin ID: {id}");
            println(f"    Type ID: {type_id}");
            println(f"    Stealth: {stealth}");
            println(f"    Attack: {attack}");
            println(f"    Defense: {defense}");
            println(f"    Health: {health}");
            println(f"    Level: {level}");
            print(f"    Awake at: ");
            for i in 0..awake_at.len() {
                let a = awake_at[i];
                print(f"{a}, ");
            }
            println("");
            print("    Habitats: ");
            for i in 0..habitats.len() {
                let h = habitats[i].id;
                print(f"{h}, ");
            }
            println("");
            println("");
        }
    }
}
