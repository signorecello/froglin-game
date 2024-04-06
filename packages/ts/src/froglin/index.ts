import { Poseidon2 } from "@signorecello/bb_hashes";
import {
	FroglinTypes,
	FroglinTypesEnum,
	ZonesTypesEnum,
} from "../../froglin_types";

type FroglinStats = {
	id: bigint;
	type_id: bigint;
	stealth: bigint;
	attack: bigint;
	defense: bigint;
	health: bigint;
	level: bigint;
	awake_at: bigint[];
	habitats: ZonesTypesEnum[];
};

export class Froglin {
	constructor(private stats: FroglinStats, private hasher: Poseidon2) {}

	static async new({ name, id }: { name: FroglinTypesEnum; id: bigint }) {
		const poseidon = await Poseidon2.new();
		const froglin = { id, ...FroglinTypes[name] };
		return new Froglin(froglin, poseidon);
	}

	// returns a bigint if passed a bigint, and a hex if passed a hex
	hash = (data: bigint[]) => {
		if (typeof data[0] === "bigint") {
			return BigInt(this.hasher.hash(data));
		}
		return this.hasher.hash(data).slice(2);
	};

	getId() {
		return this.stats.id;
	}

	serialize(options?: { hex: boolean }): bigint[] | string[] {
		const { id, type_id, stealth, attack, defense, health, level } =
			this.stats;
		const serialized = [
			id,
			type_id,
			stealth,
			attack,
			defense,
			health,
			level,
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

	level_up() {
		this.stats.level += 1n;
		this.stats.attack += 1n;
		this.stats.defense += 1n;
		this.stats.health += 100n;
	}
}
