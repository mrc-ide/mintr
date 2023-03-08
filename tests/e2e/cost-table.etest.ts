import { test, expect } from '@playwright/test';
import {
    acceptBaseline,
    newProject,
    selectCoverageValues,
    testCommonTableValues,
    getTableRows,
    getTextFromRowCell
} from "./helpers";

test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await newProject(page);
    await acceptBaseline(page);
    await selectCoverageValues(page);
    await page.locator(".nav-item a").getByText("Table").click();
    await page.locator(".nav-item a").getByText("Cost effectiveness").click();
});

test('cost table has expected columns', async ({ page }) => {
    const headers = await page.locator("th div");
    await expect(headers).toHaveCount(6);
    await expect(await headers.allInnerTexts()).toStrictEqual([
        "Interventions",
        "Net use (%)",
        "IRS* cover (%)",
        "Total cases averted",
        "Total costs",
        "Cost per case averted across 3 years"
    ]);
});

test("cost table has expected common table values", async ({page}) => {
    await testCommonTableValues(page);
});

test("cost table has expected no intervention values", async ({page}) => {
    const firstRow = (await getTableRows(page)).nth(0);
    await expect(await getTextFromRowCell(firstRow, 3)).toBe("0"); // Total cases averted
    await expect(await getTextFromRowCell(firstRow, 4)).toBe("$0"); // Total costs
    await expect(await getTextFromRowCell(firstRow, 5)).toBe("reference"); // Cost per case averted
});