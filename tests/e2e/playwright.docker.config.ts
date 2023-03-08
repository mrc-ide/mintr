import type { PlaywrightTestConfig } from "@playwright/test";

const config: PlaywrightTestConfig = {
    testMatch: "*.etest.ts",
    use: {
        baseURL: "http://mint:8080",
        screenshot: "only-on-failure"
    },
    retries: 1,
    timeout: 60000
};

export default config;