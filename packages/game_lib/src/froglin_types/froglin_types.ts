export enum ZonesTypesEnum {
	default = "default",
	desert = "desert",
	forest = "forest",
}

export const ZonesTypes = {
	[ZonesTypesEnum.default]: {
		id: 0n,
		coords: [
			[0n, 0n],
			[0n, 0n],
			[0n, 0n],
			[0n, 0n],
		],
	},
	[ZonesTypesEnum.desert]: {
		id: 1n,
		coords: [
			[0n, 0n],
			[0n, 100n],
			[100n, 0n],
			[100n, 100n],
		],
	},
	[ZonesTypesEnum.forest]: {
		id: 2n,
		coords: [
			[400n, 400n],
			[400n, 500n],
			[500n, 400n],
			[500n, 500n],
		],
	},
};

export enum FroglinTypesEnum {
	default = "default",
	desert_froglin = "desert_froglin",
	tree_froglin = "tree_froglin",
}

export const FroglinTypes = {
	[FroglinTypesEnum.default]: {
		name: "default",
		type_id: 0n,
		stealth: 0n,
		attack: 0n,
		defense: 0n,
		health: 0n,
		level: 0n,
		awake_at: [0n, 0n, 0n, 0n],
		habitats: [
			ZonesTypesEnum.default,
			ZonesTypesEnum.default,
			ZonesTypesEnum.default,
			ZonesTypesEnum.default,
		],
	},
	[FroglinTypesEnum.desert_froglin]: {
		name: "desert_froglin",
		type_id: 1n,
		stealth: 1n,
		attack: 8n,
		defense: 4n,
		health: 200n,
		level: 1n,
		awake_at: [60n, 78n, 96n, 114n],
		habitats: [
			ZonesTypesEnum.desert,
			ZonesTypesEnum.default,
			ZonesTypesEnum.default,
			ZonesTypesEnum.default,
		],
	},
	[FroglinTypesEnum.tree_froglin]: {
		name: "tree_froglin",
		type_id: 2n,
		stealth: 6n,
		attack: 7n,
		defense: 5n,
		health: 500n,
		level: 1n,
		awake_at: [8n, 16n, 31n, 51n],
		habitats: [
			ZonesTypesEnum.forest,
			ZonesTypesEnum.default,
			ZonesTypesEnum.default,
			ZonesTypesEnum.default,
		],
	},
};
