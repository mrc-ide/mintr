import { test, expect } from '@playwright/test';
import {acceptBaseline, expectBarchartTicks, newProject, selectCoverageValues} from "./helpers";

test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await newProject(page);
    await acceptBaseline(page);
    await selectCoverageValues(page);
});

test("Prevalence has expected axes", async ({page}) => {
    const firstPlot = await page.locator(":nth-match(div.plotly, 1)");
    await expect(await firstPlot.locator("text.xtitle")).toHaveText("years since intervention");
    await expect(await firstPlot.locator("text.ytitle")).toHaveText("prevalence (%)");
    //expected tick format on y axis
    await expect(await firstPlot.locator(":nth-match(g.ytick, 1)")).toHaveText("0%");
});
test("Cases averted plot has expected bars", async ({page}) => {
    const secondPlot = await page.locator(":nth-match(div.plotly, 2)");
    await expectBarchartTicks(secondPlot);
});

