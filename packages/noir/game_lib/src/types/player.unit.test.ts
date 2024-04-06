import { beforeAll, beforeEach, describe, test, it } from "vitest";
import { Froglin, Player } from "@froglin_game/ts";
import { execSync } from "child_process";
import { FroglinTypesEnum } from "@froglin_game/ts/froglin_types";

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

describe("Player Tests", () => {
	let player1: Player, player2: Player;

	beforeEach(async () => {
		player1 = await Player.new(123n);
		player2 = await Player.new(123n);
	});

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

		test("Noir", async ({ expect }) => {
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
		let player1, player2;

		beforeAll(async () => {
			player1 = await Player.new(123n);
			player2 = await Player.new(123n);
			player2.addMana(10n);
		});

		test("Typescript", async ({ expect }) => {
			expect(JSON.stringify(player1)).not.toEqual(
				JSON.stringify(player2)
			);
		});

		test("Noir", async ({ expect }) => {
			const [player1_nargo, player2_nargo] = await nargoTest(testName);
			expect(player2.serialize({ hex: true }).map(BigInt)).toEqual(
				player2_nargo.slice(1, -1).split(",").map(BigInt)
			);
			expect(player1.serialize({ hex: true }).map(BigInt)).toEqual(
				player1_nargo.slice(1, -1).split(",").map(BigInt)
			);
		});
	});
});

describe("Player Mana", () => {
	describe("Add Mana", () => {
		let testName = "test_add_mana";
		let player1, player2;

		beforeAll(async () => {
			player1 = await Player.new(123n);
			player2 = await Player.new(123n);
		});

		test("Typescript", async ({ expect }) => {
			player1.addMana(10n);
			expect(player1.stats.mana).toEqual(10n);
			player1.addMana(100n);
			expect(player1.stats.claimedMana).toEqual(100n);
			expect(player1.stats.mana).toEqual(100n);
		});

		test("Noir", async ({ expect }) => {
			const [mana, claimedMana] = await nargoTest(testName);
			expect(player1.stats.mana).toEqual(BigInt(mana));
			expect(player1.stats.claimedMana).toEqual(BigInt(claimedMana));
		});
	});

	describe("Remove Mana", () => {
		let testName = "test_remove_mana";
		let player1;

		beforeAll(async () => {
			player1 = await Player.new(123n);
		});

		test("Typescript", async ({ expect }) => {
			player1.addMana(100n);
			expect(player1.stats.mana).toEqual(100n);
			player1.removeMana(10n);
			expect(player1.stats.mana).toEqual(90n);
		});

		test("Noir", async ({ expect }) => {
			const [mana] = await nargoTest(testName);
			expect(player1.stats.mana).toEqual(BigInt(mana));
		});
	});

	describe("Claimed Mana", () => {
		let testName = "test_claimed_mana";
		let player1;

		beforeAll(async () => {
			player1 = await Player.new(123n);
		});

		test("Typescript", async ({ expect }) => {
			player1.addMana(10n);
			expect(player1.stats.mana).toEqual(10n);
			player1.addMana(100n);
			expect(player1.stats.claimedMana).toEqual(100n);

			player1.removeMana(10n);
			expect(player1.stats.claimedMana).toEqual(100n);
			expect(player1.stats.mana).toEqual(90n);
		});

		test("Noir", async ({ expect }) => {
			const [mana, claimedMana] = await nargoTest(testName);
			expect(player1.stats.mana).toEqual(BigInt(mana));
			expect(player1.stats.claimedMana).toEqual(BigInt(claimedMana));
		});
	});
});

describe("Player Froglin Inventory", () => {
	describe("Add Froglin to Inventory", () => {
		let testName = "test_add_froglin";

		let player1: Player;
		let froglin1: Froglin, froglin2: Froglin;

		beforeEach(async () => {
			player1 = await Player.new(123n);
			[froglin1, froglin2] = [
				await Froglin.new({
					name: FroglinTypesEnum.desert_froglin,
					id: 1n,
				}),
				await Froglin.new({
					name: FroglinTypesEnum.tree_froglin,
					id: 2n,
				}),
			];
		});

		test("Typescript", async ({ expect }) => {
			player1.addFroglin(froglin1);
			player1.addFroglin(froglin2);
			expect(player1.getFroglin(froglin1.getId()).getId()).toBeTruthy();
			expect(player1.getFroglin(froglin2.getId()).getId()).toBeTruthy();
		});

		test("Noir", async ({ expect }) => {
			player1.addFroglin(froglin1);
			player1.addFroglin(froglin2);
			const froglinIds = await nargoTest(testName);

			const [id1, id2] = froglinIds.map(BigInt);
			expect(player1.getFroglin(froglin1.getId()).getId()).toEqual(id1);
			expect(player1.getFroglin(froglin2.getId()).getId()).toEqual(id2);
		});
	});

	describe("Remove Froglin from Inventory", () => {
		let testName = "test_remove_froglin";

		let player1: Player;
		let froglin1: Froglin;

		beforeEach(async () => {
			player1 = await Player.new(123n);
			froglin1 = await Froglin.new({
				name: FroglinTypesEnum.desert_froglin,
				id: 1n,
			});
		});

		test("Typescript", async ({ expect }) => {
			player1.addFroglin(froglin1);
			expect(player1.getFroglin(froglin1.getId()).getId()).toBeTruthy();

			player1.removeFroglin(froglin1.getId());
			expect(player1.getFroglin(froglin1.getId())).toBeFalsy();
		});

		test("Noir", async ({ expect }) => {
			player1.addFroglin(froglin1);
			const [beforeId, isEmpty] = await nargoTest(testName);

			expect(player1.getFroglin(froglin1.getId()).getId()).toEqual(
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
			player1 = await Player.new(123n);
			[froglin1, froglin2] = [
				await Froglin.new({
					name: FroglinTypesEnum.desert_froglin,
					id: 1n,
				}),
				await Froglin.new({
					name: FroglinTypesEnum.tree_froglin,
					id: 2n,
				}),
			];
		});

		test("Typescript", async ({ expect }) => {
			expect(player1.getStash().smt.root).toEqual(0n);
			expect(player1.getStash().db).toHaveLength(0);

			player1.addFroglin(froglin1);
			player1.depositToStash(froglin1.getId());

			const smtProof1 = player1
				.getStash()
				.smt.createProof(
					froglin1.hash([froglin1.commit(123n) as bigint])
				);

			expect(smtProof1.root).toEqual(
				8471127447559042083782711663856862886182885973376147476697535599297241401301n
			);
			expect(smtProof1.membership).toBe(true);
			expect(smtProof1.siblings).toHaveLength(0);
			expect(player1.getStash().db).toContain(froglin1);

			player1.addFroglin(froglin2);
			player1.depositToStash(froglin2.getId());

			const smtProof2 = player1
				.getStash()
				.smt.createProof(
					froglin1.hash([froglin2.commit(123n) as bigint])
				);

			expect(smtProof2.root).toEqual(
				10100837414160198147507679111801633728684173158568628823171386341278612230344n
			);
			expect(smtProof2.membership).toBe(true);
			expect(smtProof2.siblings[0]).toBe(
				8471127447559042083782711663856862886182885973376147476697535599297241401301n
			);
			expect(player1.getStash().db).toContain(froglin2);
		});

		test("Noir", async ({ expect }) => {
			expect(player1.getStash().smt.root).toEqual(0n);

			player1.addFroglin(froglin1);
			player1.depositToStash(froglin1.getId());

			const smtProof = player1
				.getStash()
				.smt.createProof(
					froglin1.hash([froglin1.commit(123n) as bigint])
				);

			const [newRoot] = await nargoTest(testName);
			expect(`0x${smtProof.root.toString(16)}`).toEqual(newRoot);
		});
	});

	describe("Withdraw Froglin from Stash", () => {
		let testName = "test_withdraw_from_stash";
		let player1: Player;
		let froglin1: Froglin;

		// using beforeEach here because I want a clean slate for the noir test
		beforeEach(async () => {
			player1 = await Player.new(123n);
			froglin1 = await Froglin.new({
				name: FroglinTypesEnum.desert_froglin,
				id: 1n,
			});
		});

		test("Typescript", async ({ expect }) => {
			expect(player1.getStash().smt.root).toEqual(0n);
			expect(player1.getStash().db).toHaveLength(0);

			player1.addFroglin(froglin1);
			player1.depositToStash(froglin1.getId());
			player1.withdrawFromStash(froglin1.getId());

			expect(player1.getStash().smt.root).toEqual(0n);
			expect(player1.getStash().db).toHaveLength(0);
			expect(player1.getFroglin(froglin1.getId()).getId()).toBeTruthy();
		});

		// test("Noir", async ({ expect }) => {
		// 	expect(player1.getStash().smt.root).toEqual(0n);

		// 	player1.depositToStash(froglin1);

		// 	const smtProof = player1
		// 		.getStash()
		// 		.smt.createProof(
		// 			froglin1.hash([froglin1.commit(123n) as bigint])
		// 		);

		// 	const [newRoot] = await nargoTest(testName);
		// 	expect(`0x${smtProof.root.toString(16)}`).toEqual(newRoot);
		// });
	});
});
