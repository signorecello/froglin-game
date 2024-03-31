export class Froglin {
	constructor(
		private id: bigint = 0n,
		private type_id: bigint = 0n,
		private stealth: bigint = 0n,
		private attack: bigint = 0n,
		private defense: bigint = 0n,
		private health: bigint = 0n,
		private level: bigint = 0n,
		private awake_at: bigint[] = Array(4).fill(0n),
		private habitats: bigint[] = Array(4).fill(0n)
	) {}

	serialize(options?: { hex: boolean }): bigint[] | string[] {
		const serialized = [
			this.id,
			this.type_id,
			this.stealth,
			this.attack,
			this.defense,
			this.health,
			this.level,
		];
		return options?.hex
			? serialized.map((x) => `0x${BigInt(x).toString(16)}`)
			: serialized;
	}

	level_up() {
		this.level += 1n;
		this.attack += 1n;
		this.defense += 1n;
		this.health += 100n;
	}
}
