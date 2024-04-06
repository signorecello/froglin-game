import { beforeAll, beforeEach, describe, test, it } from "vitest";
import { Froglin, Player } from "@froglin/game";
import { execSync } from "child_process";
import { FroglinTypes, FroglinTypesEnum } from "@froglin/game/froglin_types";

describe("E2E tests", () => {
	let player1 = new Player(123n);
	let froglin1 = new Froglin(FroglinTypesEnum.desert_froglin, 1n);

	test("Player adds some mana, captures a froglin, and deposits to stash", () => {
		const currentEpoch =
			FroglinTypes[FroglinTypesEnum.desert_froglin].awake_at[0];
		const currentZone =
			FroglinTypes[FroglinTypesEnum.desert_froglin].habitats[0];
		const currentFogLevel = 100n;

		// adding 100 mana more than required
		// so we actually get a different identity after the capture
		const requiredMana =
			FroglinTypes[FroglinTypesEnum.desert_froglin].stealth +
			currentFogLevel +
			100n;

		player1.addMana(requiredMana);
	});
});
