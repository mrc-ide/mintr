import { expect } from "@playwright/test";
export const newProject = async (page) => {
    await page.locator("#name").fill("test project");
    await page.locator(":nth-match(input,2)").fill("test-region");
    await page.locator("button.btn-primary").click();
};

export const acceptBaseline = async (page) => {
    await page.getByText("Next").click();
};

export const selectCoverageValues = async (page, itn = "0.2", irs = "0.6") => {
    await page.locator("select[name='netUse']").selectOption(itn);
    await page.locator("select[name='irsUse']").selectOption(irs);
};

export const getTableRows = async (page) => {
    return await page.locator("tbody tr");
};

export const getTextFromRowCell = async (row, index) => {
    return await row.locator(`:nth-match(td, ${index + 1})`).innerText();
};

export const expectColumnValues = async (rows, columnIndex, expectedValues) => {
    await expect(rows).toHaveCount(expectedValues.length);
    for(let idx = 0; idx < expectedValues.length; idx++) {
        await expect(await getTextFromRowCell(rows.nth(idx), columnIndex)).toBe(expectedValues[idx]);
    }
};

export const testCommonTableValues = async (page) => {
    const rows = await getTableRows(page);
    // The impact and cost tables share their first three columns:
    // Intervention
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

    // Net Use
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

    // IRS use
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
};

export const costStringToNumber = (costString) => {
    // regex: /\$([0-9.]*)(k?)/gm
    //.. then expect with rounding to nearest $
};