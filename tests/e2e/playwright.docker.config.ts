import type { PlaywrightTestConfig } from "@playwright/test";

const config: PlaywrightTestConfig = {
    testMatch: "*.etest.ts",
    use: {
        baseURL: "http://mint:8080",
        screenshot: "only-on-failure"
    },
    workers: 1,
    retries: 1,
    timeout: 120000
};

export default config;