import { test, expect } from '@playwright/test';
import {
    newProject,
    acceptBaseline,
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
});

test('impact table has expected columns', async ({ page }) => {
    const headers = await page.locator("th div");
    await expect(headers).toHaveCount(10);
    await expect(await headers.allInnerTexts()).toStrictEqual([
      "Interventions",
      "Net use (%)",
      "IRS* cover (%)",
      "Prevalence under 5 years: Year 1 post intervention",
      "Prevalence under 5 years: Year 2 post intervention",
      "Prevalence under 5 years: Year 3 post intervention",
      "Relative reduction in prevalence at 36 months post intervention",
      "Mean cases averted per 1,000 people annually across 3 years since intervention",
      "Relative reduction in clinical cases across 3 years since intervention (%)",
      "Mean cases per person per year averaged across 3 years"
    ]);
});


test("impact table has expected common table values", async ({page}) => {
    await testCommonTableValues(page);
});

test("impact table has expected no intervention values", async ({page}) => {
    const firstRow = (await getTableRows(page)).nth(0);
    await expect(await getTextFromRowCell(firstRow, 6)).toBe("0.0"); // Relative reduction in prevalence
    await expect(await getTextFromRowCell(firstRow, 7)).toBe("0"); // Mean cases averted per 1,000
    await expect(await getTextFromRowCell(firstRow, 8)).toBe("0.0"); // Relative reduction in cases
});