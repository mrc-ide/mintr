import { test, expect } from '@playwright/test';
import { newProject, acceptBaseline, selectCoverageValues, expectColumnValues, getTableRows } from "./helpers";

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

test("impact table has expected interventions", async ({page}) => {
    const rows = await getTableRows(page);
    await expectColumnValues(rows, 0, [
        "No intervention",
        "Pyrethroid LLIN only",
        "IRS* only",
        "Pyrethroid LLIN with IRS*",
        "Pyrethroid-PBO ITN only",
        "Pyrethroid-PBO ITN with IRS*",
        "Pyrethroid-pyrrole ITN only",
        "Pyrethroid-pyrrole ITN with IRS*"
    ]);
});

test("impact table has expected net use values", async ({page}) => {
    const rows = await getTableRows(page);
    await expectColumnValues(rows, 1, [
        "n/a",
        "20%",
        "n/a",
        "20%",
        "20%",
        "20%",
        "20%",
        "20%"
    ]);
});

test("impact table has expected irs use values", async ({page}) => {
    const rows = await getTableRows(page);
    await expectColumnValues(rows, 2, [
        "n/a",
        "n/a",
        "60%",
        "60%",
        "n/a",
        "60%",
        "n/a",
        "60%"
    ]);
});