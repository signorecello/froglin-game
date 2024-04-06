import { beforeAll, beforeEach, describe, test, it } from "vitest";
import { Froglin, Player } from "@froglin/game";
import { exec } from "child_process";
import { FroglinTypesEnum } from "@froglin/game/froglin_types";
import { Game } from "@froglin/game/src/game";

const nargoTest = async (testName: string) => {
	return new Promise<string[]>((resolve) => {
		exec(`nargo test --show-output ${testName}`, (error, stdout) => {
			const filtered = stdout
				.toString()
				.split(`#${testName}_end`)[0]
				.split(`#${testName}_start`)[1]
				.split("\n")
				.filter((x) => x);
			resolve(filtered);
			return filtered;
		});
	});
};

// teaching ts how to serialize BigInt
// so we can deeply compare objects
// @ts-ignore
BigInt.prototype.toJSON = function () {
	return this.toString();
};

describe("Player Tests", () => {
	let [player1, player2] = [new Player(123n), new Player(123n)];

	describe("Player Equality", () => {
		let testName = "test_player_equality";
		let p1c, p1i, p2c, p2i;

		test("Typescript", async ({ expect }) => {
			expect(JSON.stringify(player1)).toEqual(JSON.stringify(player2));

			({ commitment: p1c, identity: p1i } = player1.generateIdentity());
			({ commitment: p2c, identity: p2i } = player2.generateIdentity());

			expect(p1c).toEqual(p2c);
			expect(p1i).toEqual(p2i);
		});

		test("Noir", async ({ expect, skip }) => {
			if (process.env.SKIP_NOIR_TESTS) skip();

			const [p1c_nargo, p1i_nargo, p2c_nargo, p2i_nargo] =
				await nargoTest(testName);
			expect(p1c).toEqual(BigInt(p1c_nargo));
			expect(p1i).toEqual(BigInt(p1i_nargo));
			expect(p2c).toEqual(BigInt(p2c_nargo));
			expect(p2i).toEqual(BigInt(p2i_nargo));
		});
	});

	describe("Player Inequality", () => {
		let testName = "test_player_inequality";
		let [player1, player2] = [new Player(123n), new Player(123n)];

		test("Typescript", async ({ expect }) => {
			await player2.addMana(10n);
			expect(JSON.stringify(player1)).not.toEqual(
				JSON.stringify(player2)
			);
		});

		test("Noir", async ({ expect, skip }) => {
			if (process.env.SKIP_NOIR_TESTS) skip();

			const [player1_nargo, player2_nargo] = await nargoTest(testName);
			expect(player2.serialize()).toEqual(
				player2_nargo.slice(1, -1).split(",").map(BigInt)
			);
			expect(player1.serialize()).toEqual(
				player1_nargo.slice(1, -1).split(",").map(BigInt)
			);
		});
	});
});

describe("Player Mana", () => {
	describe("Add Mana", () => {
		let testName = "test_add_mana";
		let player1 = new Player(123n);

		test("Typescript", async ({ expect }) => {
			await player1.addMana(10n);
			expect(player1.mana).toEqual(10n);
			await player1.addMana(100n);
			expect(player1.claimedMana).toEqual(100n);
			expect(player1.mana).toEqual(100n);
		}, 120000);

		test("Noir", async ({ expect, skip }) => {
			if (process.env.SKIP_NOIR_TESTS) skip();

			const [mana, claimedMana] = await nargoTest(testName);
			expect(player1.mana).toEqual(BigInt(mana));
			expect(player1.claimedMana).toEqual(BigInt(claimedMana));
		});
	});

	describe("Remove Mana", () => {
		let testName = "test_remove_mana";
		let player1;

		beforeAll(async () => {
			player1 = new Player(123n);
		});

		test("Typescript", async ({ expect }) => {
			await player1.addMana(100n);
			expect(player1.mana).toEqual(100n);
			player1.removeMana(10n);
			expect(player1.mana).toEqual(90n);
		});

		test("Noir", async ({ expect, skip }) => {
			if (process.env.SKIP_NOIR_TESTS) skip();

			const [mana] = await nargoTest(testName);
			expect(player1.mana).toEqual(BigInt(mana));
		});
	});

	describe("Claimed Mana", () => {
		let testName = "test_claimed_mana";
		let player1;

		beforeAll(async () => {
			player1 = new Player(123n);
		});

		test("Typescript", async ({ expect }) => {
			await player1.addMana(10n);
			expect(player1.mana).toEqual(10n);
			await player1.addMana(100n);
			expect(player1.claimedMana).toEqual(100n);

			player1.removeMana(10n);
			expect(player1.claimedMana).toEqual(100n);
			expect(player1.mana).toEqual(90n);
		});

		test("Noir", async ({ expect, skip }) => {
			if (process.env.SKIP_NOIR_TESTS) skip();

			const [mana, claimedMana] = await nargoTest(testName);
			expect(player1.mana).toEqual(BigInt(mana));
			expect(player1.claimedMana).toEqual(BigInt(claimedMana));
		});
	});
});

describe("Player Froglin Inventory", () => {
	describe("Add Froglin to Inventory", () => {
		let testName = "test_add_froglin";

		let player1: Player;
		let froglin1: Froglin, froglin2: Froglin;

		beforeEach(async () => {
			player1 = new Player(123n);
			[froglin1, froglin2] = [
				new Froglin(FroglinTypesEnum.desert_froglin, 1n),
				new Froglin(FroglinTypesEnum.tree_froglin, 2n),
			];
		});

		test("Typescript", async ({ expect }) => {
			player1.addFroglin(froglin1);
			player1.addFroglin(froglin2);
			expect(player1.getFroglin(froglin1.id).id).toBeTruthy();
			expect(player1.getFroglin(froglin2.id).id).toBeTruthy();
		});

		test("Noir", async ({ expect, skip }) => {
			if (process.env.SKIP_NOIR_TESTS) skip();

			player1.addFroglin(froglin1);
			player1.addFroglin(froglin2);
			const froglinIds = await nargoTest(testName);

			const [id1, id2] = froglinIds.map(BigInt);
			expect(player1.getFroglin(froglin1.id).id).toEqual(id1);
			expect(player1.getFroglin(froglin2.id).id).toEqual(id2);
		});
	});

	describe("Remove Froglin from Inventory", () => {
		let testName = "test_remove_froglin";

		let player1: Player;
		let froglin1: Froglin;

		beforeEach(async () => {
			player1 = new Player(123n);
			froglin1 = new Froglin(FroglinTypesEnum.desert_froglin, 1n);
		});

		test("Typescript", async ({ expect }) => {
			player1.addFroglin(froglin1);
			expect(player1.getFroglin(froglin1.id).id).toBeTruthy();

			player1.removeFroglin(froglin1.id);
			expect(player1.getFroglin(froglin1.id)).toBeFalsy();
		});

		test("Noir", async ({ expect, skip }) => {
			if (process.env.SKIP_NOIR_TESTS) skip();

			player1.addFroglin(froglin1);
			const [beforeId, isEmpty] = await nargoTest(testName);

			expect(player1.getFroglin(froglin1.id).id).toEqual(
				BigInt(beforeId)
			);
			expect(isEmpty).toBeTruthy();
		});
	});
});

describe("Player Stash", () => {
	describe("Deposit Froglin to Stash", () => {
		let testName = "test_deposit_to_stash";
		let player1: Player;
		let froglin1: Froglin, froglin2: Froglin;

		// using beforeEach here because I want a clean slate for the noir test
		beforeEach(async () => {
			player1 = new Player(123n);
			[froglin1, froglin2] = [
				new Froglin(FroglinTypesEnum.desert_froglin, 1n),
				new Froglin(FroglinTypesEnum.tree_froglin, 2n),
			];
		});

		test("Typescript", async ({ expect }) => {
			expect(player1.stash.root).toEqual(0n);
			expect(player1.stash.db).toHaveLength(0);

			player1.addFroglin(froglin1);
			player1.depositToStash(froglin1.id);

			const smtProof1 = player1.stash.smt.createProof(
				Game.hash([froglin1.commit(123n) as bigint])
			);

			expect(smtProof1.root).toEqual(
				8471127447559042083782711663856862886182885973376147476697535599297241401301n
			);
			expect(smtProof1.membership).toBe(true);
			expect(smtProof1.siblings).toHaveLength(0);
			expect(player1.stash.db).toContain(froglin1);

			player1.addFroglin(froglin2);
			player1.depositToStash(froglin2.id);

			const smtProof2 = player1.stash.smt.createProof(
				Game.hash([froglin2.commit(123n) as bigint])
			);

			expect(smtProof2.root).toEqual(
				10100837414160198147507679111801633728684173158568628823171386341278612230344n
			);
			expect(smtProof2.membership).toBe(true);
			expect(smtProof2.siblings[0]).toBe(
				8471127447559042083782711663856862886182885973376147476697535599297241401301n
			);
			expect(player1.stash.db).toContain(froglin2);
		});

		test("Noir", async ({ expect, skip }) => {
			if (process.env.SKIP_NOIR_TESTS) skip();
			expect(player1.stash.smt.root).toEqual(0n);

			player1.addFroglin(froglin1);
			player1.depositToStash(froglin1.id);

			const smtProof = player1.stash.smt.createProof(
				Game.hash([froglin1.commit(123n) as bigint])
			);

			const [newRoot] = await nargoTest(testName);
			expect(`0x${smtProof.root.toString(16)}`).toEqual(newRoot);
		});
	}, 120000);

	describe("Withdraw Froglin from Stash", () => {
		let testName = "test_withdraw_from_stash";
		let player1: Player;
		let froglin1: Froglin;
		let expectedRootAfterFroglin1 =
			8471127447559042083782711663856862886182885973376147476697535599297241401301n;

		// using beforeEach here because I want a clean slate for the noir test
		beforeEach(async () => {
			froglin1 = new Froglin(FroglinTypesEnum.desert_froglin, 1n);
			player1 = new Player(123n);
		});

		test("Typescript", async ({ expect }) => {
			expect(player1.stash.smt.root).toEqual(0n);
			expect(player1.stash.db).toHaveLength(0);

			player1.addFroglin(froglin1);
			player1.depositToStash(froglin1.id);
			expect(player1.stash.smt.root).toEqual(expectedRootAfterFroglin1);

			player1.withdrawFromStash(froglin1.id);
			expect(player1.stash.smt.root).toEqual(0n);
			expect(player1.stash.db).toHaveLength(0);
			expect(player1.getFroglin(froglin1.id).id).toBeTruthy();
		});

		test("Noir", async ({ expect, skip }) => {
			if (process.env.SKIP_NOIR_TESTS) skip();
			expect(player1.stash.smt.root).toEqual(0n);

			player1.addFroglin(froglin1);
			player1.depositToStash(froglin1.id);

			const [rootAfterInsert, rootAfterWithdraw] = await nargoTest(
				testName
			);
			expect(rootAfterInsert).toEqual(
				`0x${expectedRootAfterFroglin1.toString(16)}`
			);
			expect(rootAfterWithdraw).toEqual("0x00");
		});
	}, 120000);
});
