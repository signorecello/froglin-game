import { ITEM_MAX, FROGLIN_MAX } from "../../constants";
import { Froglin } from "../froglin";
import { Poseidon2 } from "@signorecello/bb_hashes";
import { Item } from "../item";
import { mulPointEscalar, Base8 } from "@zk-kit/baby-jubjub";

type PlayerStats = {
	mana?: bigint;
	claimedMana?: bigint;
	level?: bigint;
	stashRoot?: bigint;
	inventory?: Item[];
	froglins?: Froglin[];
};

export class Player {
	private publicKey: { x: bigint; y: bigint } = { x: 0n, y: 0n };
	private commitment: bigint;
	private identity: bigint;

	constructor(
		private stats: PlayerStats = {
			mana: 0n,
			claimedMana: 0n,
			level: 0n,
			stashRoot: 0n,
			inventory: Array(ITEM_MAX).fill(new Item()),
			froglins: Array(FROGLIN_MAX).fill(new Froglin()),
		},
		private hasher: Poseidon2,
		fromNew: boolean = false
	) {
		if (!fromNew)
			throw new Error("Use Player.new() to create a new player");
	}

	static async new(player?: PlayerStats) {
		const poseidon = await Poseidon2.new();
		return new Player(player, poseidon, true);
	}

	hash = (data: bigint[]) => {
		return BigInt(this.hasher.hash(data));
	};

	serialize(options?: { hex: boolean }): bigint[] | string[] {
		const { mana, claimedMana, level, stashRoot, inventory, froglins } =
			this.stats;
		const serialized = [
			mana,
			claimedMana,
			level,
			stashRoot,
			...inventory
				.map((i) => i.serialize({ hex: options?.hex }) as bigint[])
				.flat(),
			...froglins
				.map((f) => f.serialize({ hex: options?.hex }) as bigint[])
				.flat(),
		];
		return options?.hex
			? serialized.map((x) => `0x${BigInt(x).toString(16)}`)
			: serialized;
	}

	commit(secret: bigint, options?: { hex: boolean }) {
		let stats = this.serialize({ hex: options?.hex }) as bigint[];
		stats.push(secret);
		return this.hash(stats);
	}

	generateIdentity({ secret }: { secret: bigint }) {
		const derivedPublic = mulPointEscalar(Base8, secret);

		[this.publicKey.x, this.publicKey.y] = derivedPublic.map((i) =>
			BigInt(i)
		);

		this.commitment = this.commit(secret);
		this.identity = this.hash([
			this.commitment,
			this.publicKey.x,
			this.publicKey.y,
		]);

		const { commitment, identity } = this;
		return { commitment, identity };
	}

	addMana(totalMana: bigint) {
		const unclaimedMana = totalMana - this.stats.claimedMana;
		this.stats.mana += unclaimedMana;
		this.stats.claimedMana = totalMana;

		if (process.env.DRY_RUN) return;
	}

	removeMana(amount: bigint) {
		this.stats.mana -= amount;

		if (process.env.DRY_RUN) return;
	}

	// fn generate_identity(self, secret: Field) -> (Field, Field) {
	//     let commitment = self.commit(secret);
	//     let (pub_key_x, pub_key_y) = eddsa_to_pub(secret);

	//     (commitment, Poseidon2::hash([commitment, pub_key_x, pub_key_y], 3))
	// }
}
