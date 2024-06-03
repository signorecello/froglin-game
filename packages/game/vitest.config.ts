/// <reference types="vitest" />
import { defineConfig } from "vite";

export default defineConfig({
	test: {
		hookTimeout: 30000,
		testTimeout: 30000,
	},
});
