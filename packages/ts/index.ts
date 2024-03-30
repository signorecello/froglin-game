import { ChildNodes, SMT } from "@zk-kit/smt";
import { Froglin } from "./froglin";
import { Player } from "./player";

async function main() {
	// const froglin = new Froglin(1n);
	// console.log(froglin.serialize({ hex: true }));
	// froglin.level_up();
	// console.log(froglin.serialize({ hex: true }));

	const player = new Player();
	console.log(player.serialize().length);
	console.log(await player.commit(1n));
}

main();
