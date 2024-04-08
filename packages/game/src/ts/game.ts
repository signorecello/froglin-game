import { Froglin, Player } from "@froglin/game_lib";
import { NoirInstance } from "./noir";
import { toCircuitInputHex } from "../../../game_lib/src/utils/utils";
import { CircuitInput } from "../../../game_lib/src/types";
import { ZonesTypesEnum } from "../../../game_lib/src/froglin_types/froglin_types";

export class Game {
	public epoch: bigint = 0n;
	public fog: bigint = 0n;
	public zone: ZonesTypesEnum = ZonesTypesEnum.default;

	constructor(public player: Player) {}

	setEpoch(epoch: bigint) {
		// this will grab the epoch from the contract
		this.epoch = epoch;
	}

	setFog(level: bigint) {
		// this will grab the fog level from the contract
		this.fog = level;
	}

	setZone(zone: ZonesTypesEnum) {
		// this will grab x/y coordinates from the device
		// and match them with a zone
		// but for now let's just set it to the zone itself
		this.zone = zone;
	}

	async addMana(totalMana: bigint) {
		this.player.addMana(totalMana);

		const { identity } = this.player.generateIdentity();
		const inputs: CircuitInput = {
			player: this.player.toCircuitInput(),
			secret: toCircuitInputHex(this.player.secret),
			total_mana: toCircuitInputHex(totalMana),
			old_identity: toCircuitInputHex(identity),
		};
		return await new NoirInstance("mana_boost").prove(inputs);
	}

	async proveWithdrawFromStash(
		player: Player,
		froglin: Froglin,
		key: bigint
	) {
		// const { siblings } = player.stash.smt.createProof(key);
		// const inputs = {
		// 	id: froglin.id,
		// 	siblings,
		// 	secret: player.secret,
		// };
		// return await new NoirInstance("stash_withdraw").prove(inputs);
	}
}
