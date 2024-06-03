import {
	createPXEClient,
	PXE,
	GrumpkinScalar,
	AccountManager,
	AccountWallet,
	AztecAddress,
	waitForPXE,
	CheatCodes,
	Fr,
} from "@aztec/aztec.js";
import { FroglinUniverseContract } from "../artifacts/FroglinUniverse";
import { describe, beforeAll, test } from "vitest";
import { getSchnorrAccount } from "@aztec/accounts/schnorr";
import { Player } from "@froglin/game_lib";

describe("E2E Tests", () => {
	const ethRpcUrl = process.env.ANVIL_URL || "http://localhost:8545";
	const pxeURL = process.env.PXE_URL || "http://localhost:8080";
	let wallets: { [key: string]: AccountWallet | null } = {
		gameMaster: null,
		player1: null,
		player2: null,
	};

	const privateKeys = {
		gameMaster: GrumpkinScalar.random(),
		player1: GrumpkinScalar.random(),
		player2: GrumpkinScalar.random(),
	};
	let game: FroglinUniverseContract;
	let cc: CheatCodes;
	const timeAdvance = async (seconds: number) =>
		await cc.aztec.warp((await cc.eth.timestamp()) + seconds);

	beforeAll(async () => {
		console.log("hey");

		let pxe: PXE = createPXEClient(pxeURL);
		const pk = GrumpkinScalar.random();
		await getSchnorrAccount(pxe, pk, pk).waitSetup();
		console.log("hey2");

		// cc = CheatCodes.create(ethRpcUrl, pxe);

		// game = await FroglinUniverseContract.deploy(
		// 	wallets.gameMaster,
		// 	wallets.gameMaster.getCompleteAddress().address
		// )
		// 	.send()
		// 	.deployed();
	});

	describe("Game Master", () => {
		test("Can deploy the game", async ({ expect }) => {
			console.log(game.address);
			expect(game.methods).toHaveProperty("register");
		});

		test("Can advance the epoch and set fog", async ({ expect }) => {
			const epochReceipt = await game
				.withWallet(wallets.gameMaster)
				.methods.advance_epoch()
				.send()
				.wait();
			expect(epochReceipt.status).toBe("mined");
			console.log(epochReceipt);
		});

		test.fails(
			"Fails to advance epoch if 10 seconds have not passed",
			async ({ expect }) => {
				const epochReceipt = await game
					.withWallet(wallets.gameMaster)
					.methods.advance_epoch()
					.send()
					.wait();
				expect(epochReceipt.status).toBe("mined");
			},
			30000
		);

		test("Advances epoch if 10 seconds have passed", async ({ expect }) => {
			await timeAdvance(10);
			const epochReceipt = await game
				.withWallet(wallets.gameMaster)
				.methods.advance_epoch()
				.send()
				.wait();
			expect(epochReceipt.status).toBe("mined");
		});
	});

	describe("Player", () => {
		test("Can register in the game", async ({ expect }) => {
			const accountContract = new SingleKeyAccountContract(
				privateKeys.player1
			);
			const player = new AccountManager(
				pxe,
				privateKeys.player1,
				accountContract
			);
			wallets.player1 = await player.register();

			const registerReceipt = await game
				.withWallet(wallets.player1)
				.methods.register(wallets.player1.getCompleteAddress(), 1)
				.send()
				.wait();
			expect(registerReceipt.status).toBe("mined");
		});

		test("Can claim mana", async ({ expect }) => {
			const [epoch, timestamp, fog]: bigint[] = await game
				.withWallet(wallets.player1)
				.methods.view_game()
				.simulate();

			const sq = Math.sqrt(Number(fog.toString(10)));

			const boostReceipt = await game
				.withWallet(wallets.player1)
				.methods.mana_boost(sq)
				.send()
				.wait();
			expect(boostReceipt.status).toBe("mined");

			const player_read = await game
				.withWallet(wallets.player1)
				.methods.view_player(wallets.player1.getCompleteAddress())
				.simulate();

			const player = Player.import(1n, player_read);
			console.log(player);
			expect(player.mana).toBe(100n);
		});
	});

	// test("Can register a second player", async ({ expect }) => {
	// 	const accountContract = new SingleKeyAccountContract(
	// 		privateKeys.player2
	// 	);
	// 	const player = new AccountManager(
	// 		pxe,
	// 		privateKeys.player2,
	// 		accountContract
	// 	);
	// 	wallets.player2 = await player.register();

	// 	const registerReceipt = await game
	// 		.withWallet(wallets.player2)
	// 		.methods.register(wallets.player2.getCompleteAddress(), 1)
	// 		.send()
	// 		.wait();
	// 	expect(registerReceipt.status).toBe("mined");
	// });

	// test("Game master can pair two players", async ({ expect }) => {
	// 	const pairReceipt = await game.methods.pair().send().wait();
	// 	expect(pairReceipt.status).toBe("mined");
	// });
});
