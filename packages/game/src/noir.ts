import { InputMap, Noir } from "@noir-lang/noir_js";
import { Backend, BarretenbergBackend } from "@noir-lang/backend_barretenberg";
import { resolve, join } from "path";
import { readFileSync } from "fs";
import os from "os";

export class NoirInstance {
	noir: Noir;

	constructor(circuitName: string) {
		const file = JSON.parse(
			readFileSync(
				resolve(
					join(
						__dirname,
						`../../../noir/game/${circuitName}/target/${circuitName}.json`
					)
				),
				"utf-8"
			)
		);

		const backend = new BarretenbergBackend(file, {
			threads: os.cpus().length,
		});
		this.noir = new Noir(file, backend);
	}

	async prove(inputs: InputMap) {
		const proof = await this.noir.generateProof(inputs);
		return proof;
	}
}
