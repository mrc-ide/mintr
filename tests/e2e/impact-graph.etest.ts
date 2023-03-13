import { test, expect } from '@playwright/test';
import {acceptBaseline, newProject, selectCoverageValues} from "./helpers";

test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await newProject(page);
    await acceptBaseline(page);
    await selectCoverageValues(page);
});
