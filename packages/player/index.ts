import { ITEM_MAX, FROGLIN_MAX } from "../ts/constants";
import { Froglin } from "../froglin";
import { Poseidon2 } from "@signorecello/bb_hashes";

export class Player {
	constructor(
		private mana: bigint = 0n,
		private claimed_mana: bigint = 0n,
		private level: bigint = 0n,
		private stash_root: bigint = 0n,
		private inventory: bigint[] = Array(ITEM_MAX).fill(0n),
		private froglins: Froglin[] = Array(FROGLIN_MAX).fill(new Froglin())
	) {}

	serialize(options?: { hex: boolean }): bigint[] | string[] {
		const serialized = [
			this.mana,
			this.claimed_mana,
			this.level,
			this.stash_root,
			...this.inventory,
			...this.froglins
				.map((f) => f.serialize({ hex: options.hex }) as bigint[])
				.flat(),
		];
		return options?.hex
			? serialized.map((x) => `0x${BigInt(x).toString(16)}`)
			: serialized;
	}

	// fn commit(self, secret: Field) -> Field {

	// 	let mut ret : [Field; PLAYER_SIZE + 1] = [0; PLAYER_SIZE + 1];
	// 	for i in 0..PLAYER_SIZE {
	// 		ret[i] = stats[i];
	// 	};
	//     ret[PLAYER_SIZE] = secret;
	//     Poseidon2::hash(ret, PLAYER_SIZE + 1)
	// }

	async commit(secret: bigint) {
		let stats = this.serialize() as bigint[];
		stats.push(secret);
		const poseidon = await Poseidon2.new();
		return poseidon.hash(stats);
	}
}
