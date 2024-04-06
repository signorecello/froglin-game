import { ITEM_MAX, FROGLIN_MAX } from "../../constants";
import { Froglin } from "../froglin";
import { Item } from "../item";
import { mulPointEscalar, Base8 } from "@zk-kit/baby-jubjub";
import { FroglinTypesEnum } from "../../froglin_types";
import { ChildNodes, SMT } from "@zk-kit/smt";
import { Game } from "../game";
import { toCircuitInputHex } from "../utils";
import { NoirInstance } from "../noir/noir";

export class Player {
	public stash: { smt: SMT; db: Froglin[]; root: bigint };

	constructor(
		public secret: bigint,
		public mana = 0n,
		public claimedMana = 0n,
		public level = 0n,
		public stashRoot = 0n,
		public inventory = Array(ITEM_MAX).fill(new Item()),
		public froglins = Array(FROGLIN_MAX).fill(
			new Froglin(FroglinTypesEnum.default, 0n)
		)
	) {
		const smtHasher = (childNodes: ChildNodes) =>
			BigInt(Game.hash(childNodes as bigint[]));

		const smt = new SMT(smtHasher, true);
		this.stash = { smt: smt, db: [], root: smt.root as bigint };
	}

	serialize() {
		const serialized = [
			this.mana,
			this.claimedMana,
			this.level,
			this.stashRoot,
			...this.inventory.map((i) => i.serialize()).flat(),
			...this.froglins.map((f) => f.serialize()).flat(),
		];

		return serialized;
	}

	commit(options?: { hex: boolean }) {
		let stats = this.serialize();
		stats.push(this.secret);
		return Game.hash(stats);
	}

	toCircuitInput() {
		let circuitInput = toCircuitInputHex({
			mana: this.mana,
			claimed_mana: this.claimedMana,
			level: this.level,
			stash_root: this.stashRoot,
		});
		circuitInput["inventory"] = this.inventory.map((i) =>
			i.toCircuitInput()
		);
		circuitInput["froglins"] = this.froglins.map((i) => i.toCircuitInput());

		return circuitInput;
	}

	generateIdentity() {
		const derivedPublic = mulPointEscalar(Base8, this.secret);

		const bigintDerivedPublic = derivedPublic.map((i) => BigInt(i));

		const commitment = this.commit() as bigint;
		const identity = Game.hash([
			commitment,
			bigintDerivedPublic[0],
			bigintDerivedPublic[1],
		]) as bigint;

		return { commitment, identity };
	}

	async addMana(totalMana: bigint) {
		const unclaimedMana = totalMana - this.claimedMana;
		this.mana += unclaimedMana;
		this.claimedMana = totalMana;

		// drop here for no proving
		if (process.env.DRY_RUN) return;

		const { identity } = this.generateIdentity();
		const inputs = {
			player: this.toCircuitInput(),
			secret: toCircuitInputHex(this.secret),
			total_mana: toCircuitInputHex(totalMana),
			old_identity: toCircuitInputHex(identity),
		};

		const proof = await Game.manaBoost().prove(inputs);
		return proof;
	}

	removeMana(amount: bigint) {
		this.mana -= amount;

		// this will actually run a circuit
		if (process.env.DRY_RUN) return;
	}

	getFroglin(id: bigint) {
		return this.froglins.find((f) => f.id == id);
	}

	getFroglinIndex(id: bigint) {
		return this.froglins.findIndex((f) => f.id == id);
	}

	addFroglin(froglin: Froglin) {
		if (this.froglins.every((f) => f.id != 0n)) {
			throw new Error(
				"Froglin inventory is full! Need to deposit one froglin to stash."
			);
		}

		let defaultFroglinIndex = this.froglins.findIndex((f) => f.id == 0n);
		this.froglins[defaultFroglinIndex] = froglin;

		// this will actually run a circuit (eg. capture, or after a fight)
		if (process.env.DRY_RUN) return;
	}

	removeFroglin(id: bigint) {
		const toRemoveIndex = this.getFroglinIndex(id);

		const defaultFroglin = new Froglin(FroglinTypesEnum.default, 0n);
		this.froglins[toRemoveIndex] = defaultFroglin;

		// this will actually run a circuit (eg. after a fight)
		if (process.env.DRY_RUN) return;
	}

	depositToStash(id: bigint) {
		const froglinToDeposit = this.getFroglin(id);
		const value = froglinToDeposit.commit(this.secret) as bigint;

		const key = Game.hash([value]) as bigint;
		this.stash.db.push(froglinToDeposit);
		this.stash.smt.add(key, value);

		this.removeFroglin(id);

		// this will actually run a circuit (eg. when user deposits a froglin to stash)
		if (process.env.DRY_RUN) return;
	}

	withdrawFromStash(id: bigint) {
		const toRemoveIndex = this.stash.db.findIndex((f) => f.id == id);
		const froglin = this.stash.db[toRemoveIndex];

		const key = Game.hash([froglin.commit(this.secret) as bigint]);
		this.stash.smt.delete(key);
		this.stash.db.splice(toRemoveIndex, 1);

		this.addFroglin(froglin);

		// prepare inputs to circuit
		const { siblings } = this.stash.smt.createProof(key);
		const inputs = {
			id: froglin.id,
			siblings,
			secret: this.secret,
		};

		// this will actually run a circuit (eg. when user withdraws a froglin from stash)
		if (process.env.DRY_RUN) return inputs;
	}
}
