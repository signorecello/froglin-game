import { beforeAll, beforeEach, describe, test, it } from "vitest";
import { Froglin, Player } from "@froglin_game/ts";
import { execSync } from "child_process";
import { FroglinTypes, FroglinTypesEnum } from "@froglin_game/ts/froglin_types";

const nargoTest = async (testName: string) => {
	const capture = execSync(`nargo test --show-output ${testName}`);
	const filtered = capture
		.toString()
		.split(`#${testName}_end`)[0]
		.split(`#${testName}_start`)[1]
		.split("\n")
		.filter((x) => x);
	return filtered;
};

// teaching ts how to serialize BigInt
// so we can deeply compare objects
// @ts-ignore
BigInt.prototype.toJSON = function () {
	return this.toString();
};

describe("Froglin Tests", () => {
	let froglin;

	beforeEach(async () => {
		froglin = await Froglin.new({
			name: FroglinTypesEnum.desert_froglin,
			id: 1n,
		});
	});

	describe("Level up", () => {
		let testName = "test_level_up";
		let serialized;

		const expectedStats = FroglinTypes[FroglinTypesEnum.desert_froglin];

		test("Typescript", async ({ expect }) => {
			froglin.level_up();
			serialized = froglin.serialize();

			expect(froglin.stats.level).toEqual(expectedStats.level + 1n);
			expect(froglin.stats.attack).toEqual(expectedStats.attack + 1n);
			expect(froglin.stats.defense).toEqual(expectedStats.defense + 1n);
			expect(froglin.stats.health).toEqual(expectedStats.health + 100n);
		});

		test("Noir", async ({ expect }) => {
			const [outStats] = await nargoTest(testName);
			let sanitizedStats = outStats.slice(1, -1).split(",").map(BigInt);
			expect(sanitizedStats).toEqual(serialized);
		});
	});
});
