import { Poseidon2 } from "@signorecello/bb_hashes";
import {
	FroglinTypes,
	FroglinTypesEnum,
	ZonesTypes,
	ZonesTypesEnum,
} from "../froglin_types/froglin_types";
import { hash } from "../utils/utils";
import { toCircuitInputHex } from "../utils/utils";

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
	stats: FroglinStats;

	constructor(public name: FroglinTypesEnum, public id: bigint) {
		const froglin = { id, ...FroglinTypes[name] };
		this.stats = froglin;
	}

	serialize() {
		const { id, type_id, stealth, attack, defense, health, level } =
			this.stats;
		return [id, type_id, stealth, attack, defense, health, level];
	}

	import(serialized: bigint[]) {
		this.stats = {
			id: serialized[0],
			type_id: serialized[1],
			stealth: serialized[2],
			attack: serialized[3],
			defense: serialized[4],
			health: serialized[5],
			level: serialized[6],
			awake_at: serialized.slice(7, 11),
			habitats: serialized
				.slice(11)
				.map((h) => ZonesTypesEnum[h.toString(10)]),
		};
	}

	commit(secret: bigint) {
		let stats = this.serialize();
		stats.push(secret);
		return hash(stats);
	}

	toCircuitInput() {
		let circuitInput = toCircuitInputHex({
			id: this.id,
			type_id: this.stats.type_id,
			stealth: this.stats.stealth,
			attack: this.stats.attack,
			defense: this.stats.defense,
			health: this.stats.health,
			level: this.stats.level,
		});
		circuitInput["awake_at"] = this.stats.awake_at.map(toCircuitInputHex);
		circuitInput["habitats"] = this.stats.habitats.map((h) => {
			return {
				id: toCircuitInputHex(ZonesTypes[h].id),
				coords: ZonesTypes[h].coords.map((c) =>
					c.map(toCircuitInputHex)
				),
			};
		});

		return circuitInput;
	}

	level_up() {
		this.stats.level += 1n;
		this.stats.attack += 1n;
		this.stats.defense += 1n;
		this.stats.health += 100n;
	}
}
