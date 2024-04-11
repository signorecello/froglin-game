import { ITEM_MAX, FROGLIN_MAX } from "../globals";
import { Froglin } from "../entities/froglin";
import { Item } from "../entities/item";
import { mulPointEscalar, Base8 } from "@zk-kit/baby-jubjub";
import { FroglinTypesEnum } from "../froglin_types/froglin_types";
import { ChildNodes, SMT } from "@zk-kit/smt";

import { hash, toCircuitInputHex } from "../utils/utils";
import { CircuitInput } from "../types";

export class Player {
	public stash: { smt: SMT; db: Froglin[]; root: bigint };

	constructor(
		public secret: bigint,
		public mana = 0n,
		public level = 0n,
		public stashRoot = 0n,
		public inventory = Array(ITEM_MAX).fill(new Item()),
		public froglins = Array(FROGLIN_MAX).fill(
			new Froglin(FroglinTypesEnum.default, 0n)
		)
	) {
		const smtHasher = (childNodes: ChildNodes) =>
			BigInt(hash(childNodes as bigint[]));

		const smt = new SMT(smtHasher, true);
		this.stash = { smt: smt, db: [], root: smt.root as bigint };
	}

	static import(secret: bigint, serialized: bigint[]) {
		const [mana, level, stashRoot, ...rest] = serialized;

		const inventory = [];
		for (let i = 0; i < ITEM_MAX; i++) {
			inventory.push(Item.import(rest.slice(i * 2, i * 2 + 2)));
		}

		const froglins = [];
		for (let i = 0; i < FROGLIN_MAX; i++) {
			froglins.push(
				Froglin.import(rest.slice(ITEM_MAX).slice(i * 7, i * 7 + 7))
			);
		}

		return new Player(secret, mana, level, stashRoot, inventory, froglins);
	}

	serialize() {
		const serialized = [
			this.mana,
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
		return hash(stats);
	}

	toCircuitInput(): CircuitInput {
		let circuitInput = toCircuitInputHex({
			mana: this.mana,
			level: this.level,
			stash_root: this.stashRoot,
		}) as CircuitInput;

		circuitInput["inventory"] = this.inventory.map(
			(i: Item) => i.toCircuitInput() as CircuitInput
		) as CircuitInput[];
		circuitInput["froglins"] = this.froglins.map((i) => i.toCircuitInput());

		return circuitInput;
	}

	generateIdentity() {
		const derivedPublic = mulPointEscalar(Base8, this.secret);

		const bigintDerivedPublic = derivedPublic.map((i) => BigInt(i));

		const commitment = this.commit() as bigint;
		const identity = hash([
			commitment,
			bigintDerivedPublic[0],
			bigintDerivedPublic[1],
		]) as bigint;

		return { commitment, identity };
	}

	addMana(amount: bigint) {
		this.mana += amount;
	}

	removeMana(amount: bigint) {
		this.mana -= amount;
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
	}

	removeFroglin(id: bigint) {
		const toRemoveIndex = this.getFroglinIndex(id);

		const defaultFroglin = new Froglin(FroglinTypesEnum.default, 0n);
		this.froglins[toRemoveIndex] = defaultFroglin;
	}

	depositToStash(id: bigint) {
		const froglinToDeposit = this.getFroglin(id);
		const value = froglinToDeposit.commit(this.secret) as bigint;

		const key = hash([value]) as bigint;
		this.stash.db.push(froglinToDeposit);
		this.stash.smt.add(key, value);

		this.removeFroglin(id);
	}

	withdrawFromStash(id: bigint) {
		const toRemoveIndex = this.stash.db.findIndex((f) => f.id == id);
		const froglin = this.stash.db[toRemoveIndex];

		const key = hash([froglin.commit(this.secret) as bigint]);
		this.stash.smt.delete(key);
		this.stash.db.splice(toRemoveIndex, 1);

		this.addFroglin(froglin);
	}
}
