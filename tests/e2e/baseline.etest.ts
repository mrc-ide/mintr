import { test, expect } from '@playwright/test';
import {newProject} from "./helpers";

test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await newProject(page);
});

const expectOptionLabelAndName = async (optionRow, expectedLabel, expectedName, controlIsSelect = true) => {
    const label = await optionRow.locator("label").innerText();
    await expect(label.trim()).toBe(expectedLabel);
    const controlElementType = controlIsSelect ? "select" : "input";
    const name = await optionRow.locator(controlElementType).getAttribute("name");
    await expect(name).toBe(expectedName)
};

test("expected options exist", async ({page}) => {
    const rows = await page.locator(".dynamic-form .row .col-md-6");
    await expectOptionLabelAndName(rows.nth(0), "Size of population at risk", "population", false);
    await expectOptionLabelAndName(rows.nth(1), "Seasonality of transmission", "seasonalityOfTransmission");
    await expectOptionLabelAndName(rows.nth(2), "Current malaria prevalence", "currentPrevalence");
    await expectOptionLabelAndName(rows.nth(3), "Preference for biting indoors", "bitingIndoors");
    await expectOptionLabelAndName(rows.nth(4), "Preference for biting people", "bitingPeople");
    await expectOptionLabelAndName(rows.nth(5), "Level of pyrethroid resistance", "levelOfResistance");
    await expectOptionLabelAndName(rows.nth(6), "Evidence of PBO synergy", "metabolic");
    await expectOptionLabelAndName(rows.nth(7), "ITN population usage in last survey (%)", "itnUsage");
});