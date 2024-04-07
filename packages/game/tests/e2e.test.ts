import { describe, test } from "vitest";
import { Froglin, Player } from "@froglin/game_lib";
import { FroglinTypes, FroglinTypesEnum } from "@froglin/game_lib";
import { Game } from "..";

describe("E2E tests", () => {
	let game = new Game(new Player(123n));

	test("Player adds some mana, captures a froglin, and deposits to stash", async () => {
		// set up game conditions, let's assume fog is 100
		game.setFog(100n);

		// and player is in the desert zone
		// coincidentally, at the very same epoch the froglin is awake
		let froglin1 = new Froglin(FroglinTypesEnum.desert_froglin, 1n);
		game.setEpoch(froglin1.stats.awake_at[0]);
		game.setZone(froglin1.stats.habitats[0]);

		// we boost the player's mana, and prove it
		const requiredMana = game.fog + froglin1.stats.stealth;
		await game.addMana(requiredMana);
	});
});
