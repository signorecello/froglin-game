function toEpoch(time) {
	let [hours, minutes] = time.split(".").map(Number);
	return (hours * 60 + minutes) / 10;
}

// example for Peasant
// ["10.00", "13.00", "16.00", "19.00", "22.00"].map(toEpoch);
