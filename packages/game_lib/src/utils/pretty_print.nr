use crate::entities::froglin::Froglin;
use crate::entities::player::Player;
use dep::std::println;

unconstrained pub fn p_print(player: Player, secret: Field) {
    println("");
    println("");
    println("----------------");
    let (commitment,id) = player.generate_identity(secret);
    println(f"PLAYER - IDENTITY {id} COMMITMENT {commitment}");
    println("----------------");
    println("STATS");
    let mana = player.mana;
    println(f"    Mana: {mana}");
    let c_mana = player.claimed_mana;
    println(f"    Claimed Mana: {c_mana}");
    let level = player.level;
    println(f"    Level: {level}");
    let stash_root = player.stash_root;
    println(f"    Stash Root: {stash_root}");
    println("");
    println("FROGLINS");
    let player_froglins = player.froglins;
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
