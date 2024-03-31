import { beforeAll, beforeEach, describe, test, it } from "vitest";
import { Player } from "@froglin_game/ts";
import { execSync } from "child_process";

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
	let player1, player2;

	beforeEach(async () => {
		player1 = await Player.new();
		player2 = await Player.new();
	});

	describe("Player Equality", () => {
		let testName = "test_player_equality";
		let p1c, p1i, p2c, p2i;

		test("Typescript", async ({ expect }) => {
			expect(JSON.stringify(player1)).toEqual(JSON.stringify(player2));

			({ commitment: p1c, identity: p1i } = player1.generateIdentity({
				secret: 1n,
			}));
			({ commitment: p2c, identity: p2i } = player2.generateIdentity({
				secret: 1n,
			}));

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
			player1 = await Player.new();
			player2 = await Player.new();
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
			player1 = await Player.new();
			player2 = await Player.new();
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
			player1 = await Player.new();
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
			player1 = await Player.new();
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
// #[test]
// fn test_player_equality() {
//     let player1 = Player::default();
//     let player2 = Player::default();
//     assert(player1 == player2);

//     println(player1.serialize());
//     let (p1c, p1i) = player1.generate_identity(0x01);
//     let (p2c, p2i) = player2.generate_identity(0x01);
//     println(p1c);
//     assert(p1c == p2c);
//     assert(p1i == p2i);
// }

// #[test]
// fn test_add_mana() {
//     let mut player = Player::default();
//     player.add_mana(10); // user is entitled to 10 mana
//     assert(player.mana == 10);
//     player.add_mana(100); // user is entitled to 100 mana
//     assert(player.claimed_mana == 100); // he claimed all 100 mana
//     assert(player.mana == 100); // he didn't use any mana
// }

// #[test]
// fn test_claimed_mana() {
//     let mut player = Player::default();
//     player.add_mana(10); // user is entitled to 10 mana
//     assert(player.mana == 10);
//     player.add_mana(100); // user is entitled to 100 mana
//     assert(player.claimed_mana == 100); // he claimed all 100 mana

//     player.remove_mana(10); // user used 10 mana
//     assert(player.claimed_mana == 100); // he still claimed all 100 mana
//     assert(player.mana == 90); // but used 10
// }

// #[test]
// fn test_player_inequality() {
//     let player = Player::default();
//     let mut player2 = Player::default();
//     player2.add_mana(10);
//     assert(player != player2);
// }

// #[test]
// fn test_add_froglin() {
//     let mut player = Player::default();
//     let desert_froglin = desert_froglin::new(0x01); // unique id for the froglin
//     let to_stash = player.add_froglin(desert_froglin);
//     assert(to_stash == false);

//     let tree_froglin = tree_froglin::new(0x02);
//     let to_stash = player.add_froglin(tree_froglin);
//     assert(to_stash == false);

//     assert(player.froglins[0].id == 1);
//     assert(player.froglins[1].id == 2);
// }

// #[test]
// fn test_calculate_level() {
//     let mut player = Player::default();
//     let level = player.get_level();
//     assert(level == 0);

//     let mut desert_froglin = desert_froglin::new(0x01); // unique id for the froglin

//     player.add_froglin(desert_froglin);
//     let level = player.get_level();
//     assert(level == 0);

//     player.level_up(desert_froglin);
//     let level = player.get_level();
//     assert(level == 1);

//     player.level_up(desert_froglin);
//     let level = player.get_level();
//     assert(level == 2);
// }

// const froglin = new Froglin(1n);
// console.log(froglin.serialize({ hex: true }));
// froglin.level_up();
// console.log(froglin.serialize({ hex: true }));
