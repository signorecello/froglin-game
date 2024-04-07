import { Poseidon2 } from "@signorecello/bb_hashes";
import { CircuitInput } from "../types";

export function toCircuitInputHex(circuitInput: any): CircuitInput | string {
	// Function to pad a given hexadecimal string to 32 bytes (64 hexadecimal characters)
	const padTo32Bytes = (hexString: string) => hexString.padStart(64, "0");

	if (typeof circuitInput == "object") {
		for (const [key, value] of Object.entries(circuitInput)) {
			circuitInput[key] = `0x${padTo32Bytes(
				(value as bigint).toString(16)
			)}`;
		}
		return circuitInput;
	}

	return `0x${padTo32Bytes(circuitInput.toString(16))}`;
}

const hasher = await Poseidon2.new();

export function hash(data: bigint[] | bigint): bigint | string {
	if (typeof data[0] === "bigint") {
		return BigInt(hasher.hash(data as bigint[]));
	}

	return hasher.hash([data as bigint]).slice(2);
}

export function toEpoch(time: string) {
	let [hours, minutes] = time.split(".").map(Number);
	return (hours * 60 + minutes) / 10;
}
