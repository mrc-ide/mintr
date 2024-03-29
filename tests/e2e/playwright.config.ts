import type { PlaywrightTestConfig } from "@playwright/test";

const config: PlaywrightTestConfig = {
    testMatch: "*.etest.ts",
    fullyParallel: true,
    use: {
        baseURL: "http://localhost:8080",
        screenshot: "only-on-failure",
        actionTimeout: 0
    }
};

export default config;