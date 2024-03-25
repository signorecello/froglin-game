function toEpoch(time) {
	let [hours, minutes] = time.split(".").map(Number);
	return (hours * 60 + minutes) / 10;
}
