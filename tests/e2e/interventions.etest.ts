import { test, expect } from '@playwright/test';
import {acceptBaseline, expectOptionLabelAndName, newProject} from "./helpers";

test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await newProject(page);
    await acceptBaseline(page);
});

const expectNumberInputStep = async (input, expectedStartValue, expectedStep) => {
    await expect(parseFloat(await input.inputValue())).toBe(expectedStartValue);
    await input.press("ArrowUp");
    await expect(parseFloat(await input.inputValue())).toBe(expectedStartValue + expectedStep);
    await input.press("ArrowDown");
    await expect(parseFloat(await input.inputValue())).toBe(expectedStartValue);
};

test("expected intervention options exist", async ({page}) => {
    const interventionsForm = page.locator(":nth-match(.dynamic-form, 2)");
    const rows = await interventionsForm.locator(".row .col-md-6");
    await expectOptionLabelAndName(rows.nth(0), "Expected ITN population use", "netUse");
    await expectOptionLabelAndName(rows.nth(1), "Expected IRS coverage", "irsUse");
    await expectOptionLabelAndName(rows.nth(2),
        "When planning procurement, what number of people per net is used?", "procurePeoplePerNet", false);
    await expectOptionLabelAndName(rows.nth(3),
        "What percentage is your procurement buffer, if used? (%)", "procureBuffer", false);
    await expectOptionLabelAndName(rows.nth(4),
        "Price of pyrethroid LLIN ($USD)", "priceNetStandard", false);
    await expectOptionLabelAndName(rows.nth(5),
        "Price of pyrethroid-PBO ITN ($USD)", "priceNetPBO", false);
    await expectOptionLabelAndName(rows.nth(6),
        "Price of pyrethroid-pyrrole ITN ($USD)", "priceNetPyrrole", false);
    await expectOptionLabelAndName(rows.nth(7),
        "ITN mass distribution campaign delivery cost per person ($USD)", "priceDelivery", false);
    await expectOptionLabelAndName(rows.nth(8),
        "Annual cost of IRS per person ($USD)", "priceIRSPerPerson", false);
});

test("price options have expected values and step", async ({page}) => {
    const priceNetStandardInput = await page.locator("input[name='priceNetStandard']");
    await expectNumberInputStep(priceNetStandardInput, 2, 0.01);

    const priceNetPBOInput = await page.locator("input[name='priceNetPBO']");
    await expectNumberInputStep(priceNetPBOInput, 2.5, 0.01);

    const priceNetPyrroleInput = await page.locator("input[name='priceNetPyrrole']");
    await expectNumberInputStep(priceNetPyrroleInput, 3, 0.01);

    const priceDeliveryInput = await page.locator("input[name='priceDelivery']");
    await expectNumberInputStep(priceDeliveryInput, 2.75, 0.01);

    const priceIRSInput = await page.locator("input[name='priceIRSPerPerson']");
    await expectNumberInputStep(priceIRSInput, 5.73, 0.01);
});

test("people per net has expected value and step", async ({page}) => {
    const peoplePerNetInput = await page.locator("input[name='procurePeoplePerNet']");
    await expectNumberInputStep(peoplePerNetInput, 1.8, 0.01);
});