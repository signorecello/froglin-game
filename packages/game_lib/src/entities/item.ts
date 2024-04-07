import { toCircuitInputHex } from "../utils/utils";

export class Item {
	constructor(private id: bigint = 0n, private quantity: bigint = 0n) {}

	serialize() {
		return [this.id, this.quantity];
	}

	toCircuitInput() {
		return {
			id: toCircuitInputHex(this.id),
			quantity: toCircuitInputHex(this.quantity),
		};
	}
}
