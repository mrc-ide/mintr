import type { PlaywrightTestConfig } from "@playwright/test";

const config: PlaywrightTestConfig = {
    testMatch: "*.etest.ts",
    fullyParallel: true,
    use: {
        baseURL: "http://mint:8080",
        screenshot: "only-on-failure",
        actionTimeout: 0
    }
};

export default config;