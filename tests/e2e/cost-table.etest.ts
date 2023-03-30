import { test, expect } from '@playwright/test';
import {
    acceptBaseline,
    newProject,
    selectCoverageValues,
    testCommonTableValues,
    getTableRows,
    getTextFromRowCell, costStringToNumber, approximatelyEqual
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
        "IRS cover (%)",
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

test("cost per case averted values match total cost and cases averted values", async ({page}) => {
    const expectCostPerCaseAvertedValue = async (row) => {
        const totalCasesAverted = Number.parseInt(await getTextFromRowCell(row, 3));
        const totalCosts = costStringToNumber(await getTextFromRowCell(row, 4));
        const costPerCaseAverted = costStringToNumber(await getTextFromRowCell(row, 5));
        // Values are approximately equal because of rounding
        expect(approximatelyEqual(costPerCaseAverted, totalCosts / totalCasesAverted)).toBe(true);
    };
    const rows = await getTableRows(page);
    for (let idx = 1; idx < 8; idx++) {
        await expectCostPerCaseAvertedValue(await rows.nth(idx));
    }
});