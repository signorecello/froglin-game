import { Poseidon2 } from "@signorecello/bb_hashes";
import { Player } from "../player";
import { NoirInstance } from "../noir/noir";

const hasher = await Poseidon2.new();

export class Game {
	public actions: { [key: string]: NoirInstance };

	constructor() {}

	// returns a bigint if passed a bigint, and a hex if passed a hex
	static hash(data: bigint[]) {
		if (typeof data[0] === "bigint") {
			return BigInt(hasher.hash(data));
		}
		return hasher.hash(data).slice(2);
	}

	static manaBoost() {
		return new NoirInstance("mana_boost");
	}

	static stashDeposit() {
		return new NoirInstance("stash_deposit");
	}

	static stashWithdraw() {
		return new NoirInstance("stash_withdraw");
	}

	static captureFroglin() {
		return new NoirInstance("capture_froglin");
	}
}
