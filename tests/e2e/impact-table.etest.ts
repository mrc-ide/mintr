import { test, expect } from '@playwright/test';
import {
    newProject,
    acceptBaseline,
    selectCoverageValues,
    testCommonTableValues,
    getTableRows,
    getTextFromRowCell, approximatelyEqual
} from "./helpers";

test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await newProject(page);
    await acceptBaseline(page);
    await selectCoverageValues(page);
    await page.locator(".nav-item a").getByText("Table").click();
});

const expectedRowCount = 7;

test('impact table has expected columns', async ({ page }) => {
    const headers = await page.locator("th div");
    await expect(headers).toHaveCount(10);
    await expect(await headers.allInnerTexts()).toStrictEqual([
      "Interventions",
      "Net use (%)",
      "IRS cover (%)",
      "Prevalence under 5 years: Year 1 post intervention",
      "Prevalence under 5 years: Year 2 post intervention",
      "Prevalence under 5 years: Year 3 post intervention",
      "Relative reduction in prevalence at 36 months post intervention",
      "Mean cases averted per 1,000 people annually across 3 years since intervention",
      "Relative reduction in clinical cases across 3 years since intervention",
      "Mean cases per person per year averaged across 3 years"
    ]);
});


test("impact table has expected common table values", async ({page}) => {
    await testCommonTableValues(page);
});

test("impact table has expected no intervention values", async ({page}) => {
    const firstRow = (await getTableRows(page)).nth(0);
    await expect(await getTextFromRowCell(firstRow, 6)).toBe("0%"); // Relative reduction in prevalence
    await expect(await getTextFromRowCell(firstRow, 7)).toBe("0"); // Mean cases averted per 1,000
    await expect(await getTextFromRowCell(firstRow, 8)).toBe("0%"); // Relative reduction in cases
});

test("cases averted annually values match total cases averted from costs table", async ({page}) => {
    const rows = await getTableRows(page);
    const casesAvertedAnnually = [];
    for (let idx = 1; idx <= expectedRowCount; idx++) {
        const value = Number.parseInt(await getTextFromRowCell(rows.nth(idx), 7));
        casesAvertedAnnually.push(value);
    }

    await page.locator(".nav-item a").getByText("Cost effectiveness").click();
    const costRows = await getTableRows(page);
    for (let idx = 1; idx < 8; idx++) {
        const totalCasesAverted = Number.parseInt(await getTextFromRowCell(costRows.nth(idx), 3));
        const annualValue = Number.parseInt(casesAvertedAnnually[idx-1]);
        // Values are approximately equal because of rounding
        expect(approximatelyEqual(totalCasesAverted, annualValue * 3, 10)).toBe(true);
    }
});

test("mean cases per person per year values have expected format", async ({page}) => {
    const regex =  /^0\.[0-9]{3}$/; // expect 3 decimal places
    const rows = await getTableRows(page);
    for (let idx = 1; idx < 8; idx++) {
        const meanCasesPerPerson = await getTextFromRowCell(rows.nth(idx), 9);
        expect(meanCasesPerPerson.match(regex)).not.toBe(null);
    }
});

test("percentage column formats", async ({page}) => {
    const regex =/^[0-9]{1,3}%$/; // expect whole number percentages
    const percentColIndexes = [3, 4, 5, 6, 8];
    const rows = await getTableRows(page);
    for (let rowIdx = 1; rowIdx < 8; rowIdx++) {
        for (let colIdx = 0; colIdx < percentColIndexes.length; colIdx++) {
            const value = await getTextFromRowCell(rows.nth(rowIdx), percentColIndexes[colIdx]);
            expect(value.match(regex)).not.toBe(null);
        }
    }
});