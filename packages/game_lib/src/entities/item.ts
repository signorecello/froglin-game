import { toCircuitInputHex } from "../utils/utils";

export class Item {
	constructor(private id: bigint = 0n, private quantity: bigint = 0n) {}

	serialize() {
		return [this.id, this.quantity];
	}

	static import(serialized: bigint[]) {
		return new Item(serialized[0], serialized[1]);
	}

	toCircuitInput() {
		return {
			id: toCircuitInputHex(this.id),
			quantity: toCircuitInputHex(this.quantity),
		};
	}
}
