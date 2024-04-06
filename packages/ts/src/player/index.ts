import { ITEM_MAX, FROGLIN_MAX } from "../../constants";
import { Froglin } from "../froglin";
import { Poseidon2 } from "@signorecello/bb_hashes";
import { Item } from "../item";
import { mulPointEscalar, Base8 } from "@zk-kit/baby-jubjub";
import { FroglinTypes, FroglinTypesEnum } from "../../froglin_types";
import { ChildNodes, SMT } from "@zk-kit/smt";

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
		private stats: PlayerStats,
		private hasher: Poseidon2,
		private stash: { smt: SMT; db: Array<Froglin> },
		private secret: bigint,
		fromNew: boolean = false
	) {
		if (!fromNew)
			throw new Error("Use Player.new() to create a new player");
	}

	static async new(
		secret: bigint,
		player: PlayerStats = {
			mana: 0n,
			claimedMana: 0n,
			level: 0n,
			stashRoot: 0n,
			inventory: Array(ITEM_MAX).fill(new Item()),
		}
	) {
		const poseidon = await Poseidon2.new();
		const defaultFroglins = Array(FROGLIN_MAX).fill(
			await Froglin.new({ name: FroglinTypesEnum.default, id: 0n })
		);
		player.froglins = defaultFroglins;

		const smtHasher = (childNodes: ChildNodes) =>
			BigInt(poseidon.hash(childNodes as bigint[]));
		const stash = { smt: new SMT(smtHasher, true), db: [] };
		player.stashRoot = stash.smt.root as bigint;

		return new Player(player, poseidon, stash, secret, true);
	}

	// returns a bigint if passed a bigint, and a hex if passed a hex
	hash = (data: bigint[]) => {
		if (typeof data[0] === "bigint") {
			return BigInt(this.hasher.hash(data));
		}
		return this.hasher.hash(data).slice(2);
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

	commit(options?: { hex: boolean }) {
		let stats = this.serialize({ hex: options?.hex }) as bigint[];
		stats.push(this.secret);
		return this.hash(stats);
	}

	generateIdentity() {
		const derivedPublic = mulPointEscalar(Base8, this.secret);

		[this.publicKey.x, this.publicKey.y] = derivedPublic.map((i) =>
			BigInt(i)
		);

		this.commitment = this.commit() as bigint;
		this.identity = this.hash([
			this.commitment,
			this.publicKey.x,
			this.publicKey.y,
		]) as bigint;

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

	getFroglin(id: bigint) {
		return this.stats.froglins.find((f) => f.getId() == id);
	}

	getFroglinIndex(id: bigint) {
		return this.stats.froglins.findIndex((f) => f.getId() == id);
	}

	addFroglin(froglin: Froglin) {
		console.log(froglin);
		if (this.stats.froglins.every((f) => f.getId() != 0n)) {
			throw new Error(
				"Froglin inventory is full! Need to deposit one froglin to stash."
			);
		}

		let defaultFroglinIndex = this.stats.froglins.findIndex(
			(f) => f.getId() == 0n
		);
		// console.log(this.stats);
		this.stats.froglins[defaultFroglinIndex] = froglin;
		// console.log(this.stats);
	}

	removeFroglin(id: bigint) {
		const toRemoveIndex = this.getFroglinIndex(id);

		const froglin = { id: 0n, ...FroglinTypes[FroglinTypesEnum.default] };
		const defaultFroglin = new Froglin(froglin, this.hasher);
		this.stats.froglins[toRemoveIndex] = defaultFroglin;
	}

	getStash() {
		return this.stash;
	}

	depositToStash(id: bigint) {
		const froglinToDeposit = this.getFroglin(id);
		const value = froglinToDeposit.commit(this.secret) as bigint;

		const key = this.hash([value]) as bigint;
		this.stash.db.push(froglinToDeposit);
		this.stash.smt.add(key, value);

		this.removeFroglin(id);
	}

	withdrawFromStash(id: bigint) {
		const toRemoveIndex = this.stash.db.findIndex((f) => f.getId() == id);
		const froglin = this.stash.db[toRemoveIndex];

		const key = this.hash([
			this.stash.db[toRemoveIndex].commit(this.secret) as bigint,
		]);
		this.stash.smt.delete(key);
		this.stash.db.splice(toRemoveIndex, 1);

		this.addFroglin(froglin);
	}
}
