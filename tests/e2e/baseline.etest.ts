import { test } from '@playwright/test';
import {newProject, expectOptionLabelAndName} from "./helpers";

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
});