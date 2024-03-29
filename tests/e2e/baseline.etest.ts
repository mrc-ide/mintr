import { test } from '@playwright/test';
import {newProject, expectOptionLabelAndName, expectSelectOptionLabelAndValue} from "./helpers";

test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await newProject(page);
});

test("expected baseline options exist", async ({page}) => {
    const rows = await page.locator(".dynamic-form .row .col-md-6");
    await expectOptionLabelAndName(rows.nth(0), "Size of population at risk", "population", false);
    await expectOptionLabelAndName(rows.nth(1), "Seasonality of transmission", "seasonalityOfTransmission");
    await expectOptionLabelAndName(rows.nth(2), "Current malaria prevalence", "currentPrevalence");
    await expectOptionLabelAndName(rows.nth(3), "Preference for biting indoors", "bitingIndoors");
    await expectOptionLabelAndName(rows.nth(4), "Preference for biting people", "bitingPeople");
    await expectOptionLabelAndName(rows.nth(5), "Level of pyrethroid resistance", "levelOfResistance");
    await expectOptionLabelAndName(rows.nth(6), "ITN population usage in last survey (%)", "itnUsage");
    await expectOptionLabelAndName(rows.nth(7), "IRS population coverage in last survey (%)", "sprayInput");
});

test("expected past ITN usage options exist", async({page}) => {
    const options = await page.locator("select[name='itnUsage'] option");
    await expectSelectOptionLabelAndValue(options.nth(0), "0% usage", "0%");
    await expectSelectOptionLabelAndValue(options.nth(1), "20% usage", "20%");
    await expectSelectOptionLabelAndValue(options.nth(2), "40% usage", "40%");
    await expectSelectOptionLabelAndValue(options.nth(3), "60% usage", "60%");
    await expectSelectOptionLabelAndValue(options.nth(4), "80% usage", "80%");
});

test("expected past IRS coverage options exist", async ({page}) => {
    const options = await page.locator("select[name='sprayInput'] option");
    await expectSelectOptionLabelAndValue(options.nth(0), "0% coverage", "0%");
    await expectSelectOptionLabelAndValue(options.nth(1), "60% coverage", "60%");
    await expectSelectOptionLabelAndValue(options.nth(2), "80% coverage", "80%");
});