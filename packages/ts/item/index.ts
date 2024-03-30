export class Item {
	constructor(private id: bigint = 0n, private quantity: bigint = 0n) {}

	serialize(options?: { hex: boolean }): bigint[] | string[] {
		const serialized = [this.id, this.quantity];
		return options?.hex
			? serialized.map((x) => `0x${BigInt(x).toString(16)}`)
			: serialized;
	}
}
