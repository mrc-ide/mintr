import { expect } from "@playwright/test";
export const newProject = async (page) => {
    await page.locator("#name").fill("test project");
    await page.locator(":nth-match(input,2)").fill("test-region");
    await page.locator("button.btn-primary").click();
}

export const acceptBaseline = async (page) => {
    const next = await page.getByText("Next");
    await next.click();
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
        "Pyrethroid-only ITN only",
        "Pyrethroid-PBO ITN only",
        "Pyrethroid-pyrrole ITN only",
        "IRS only",
        "Pyrethroid-only ITN with IRS",
        "Pyrethroid-PBO ITN with IRS",
        "Pyrethroid-pyrrole ITN with IRS"
    ]);

    // Net Use
    await expectColumnValues(rows, 1, [
        "n/a",
        "20%",
        "20%",
        "20%",
        "n/a",
        "20%",
        "20%",
        "20%"
    ]);

    // IRS use
    await expectColumnValues(rows, 2, [
        "n/a",
        "n/a",
        "n/a",
        "n/a",
        "60%",
        "60%",
        "60%",
        "60%"
    ]);
};

export const costStringToNumber = (costString) => {
    const regex =  /\$([0-9.]*)(k?)/;
    const match = costString.match(regex);
    if (!match) {
        return null;
    }
    const numericPart = Number.parseFloat(match[1]);
    const kPart = match[2] ? 1000 : 1;
    return numericPart * kPart;
};

export const approximatelyEqual = (val1, val2, tolerance = 1) => {
    return Math.abs(val1 - val2) <= tolerance;
}

export const expectOptionLabelAndName = async (optionRow, expectedLabel, expectedName, controlIsSelect = true) => {
    const label = await optionRow.locator("label").innerText();
    await expect(label.trim()).toBe(expectedLabel);
    const controlElementType = controlIsSelect ? "select" : "input";
    const name = await optionRow.locator(controlElementType).getAttribute("name");
    await expect(name).toBe(expectedName)
};

export const expectSelectOptionLabelAndValue = async (option, expectedLabel, expectedValue) => {
    const label = await option.innerText();
    await expect(label.trim()).toBe(expectedLabel);
    const value = await option.getAttribute("value");
    await expect(value).toBe(expectedValue);
};

export const expectPlotDataSummarySeries = async (summary, expectedId, expectedName, expectedType, expectedCount,
                                                  expectedXFirst, expectedXLast, expectedYMin, expectedYMax, yTolerance = null) => {
    await expect(await summary.getAttribute("name")).toBe(expectedName);
    await expect(await summary.getAttribute("id")).toBe(expectedId);
    await expect(await summary.getAttribute("type")).toBe(expectedType);
    await expect(parseInt(await summary.getAttribute("count"))).toBe(expectedCount);
    await expect(await summary.getAttribute("x-first")).toBe(expectedXFirst);
    await expect(await summary.getAttribute("x-last")).toBe(expectedXLast);
    const yMin = parseFloat(await summary.getAttribute("y-min"));
    const yMax = parseFloat(await summary.getAttribute("y-max"));
    if (yTolerance) {
        expect(approximatelyEqual(yMin, expectedYMin, yTolerance)).toBe(true);
        expect(approximatelyEqual(yMax, expectedYMax, yTolerance)).toBe(true);

    } else {
        expect(yMin).toBe(expectedYMin);
        expect(yMax).toBe(expectedYMax);
    }
};

export const expectBarchartTicks = async(plotlyBarchart) => {
    const ticks = await plotlyBarchart.locator("g.xtick");
    await expect(ticks).toHaveCount(7);
    await expect(ticks.nth(0)).toHaveText("Pyr-only ITN");
    await expect(ticks.nth(1)).toHaveText("Pyr-PBO ITN");
    await expect(ticks.nth(2)).toHaveText("Pyr-pyrr ITN");
    await expect(ticks.nth(3)).toHaveText("IRS");
    await expect(ticks.nth(4)).toHaveText("Pyr-only ITN + IRS");
    await expect(ticks.nth(5)).toHaveText("Pyr-PBO ITN + IRS");
    await expect(ticks.nth(6)).toHaveText("Pyr-pyrr ITN + IRS");
}