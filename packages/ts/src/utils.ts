export function toCircuitInputHex(
	circuitInput: any
): { [key: string]: string } | string {
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
