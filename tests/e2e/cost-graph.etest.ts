import { test, expect } from '@playwright/test';
import {acceptBaseline, newProject, selectCoverageValues, expectPlotDataSummarySeries} from "./helpers";

test.beforeEach(async ({ page }) => {
    await page.goto("/");
    await newProject(page);
    await acceptBaseline(page);
    await selectCoverageValues(page);
    await page.locator(".nav-item a").getByText("Cost effectiveness").click();
});

test("Costs vs Cases averted has expected values", async ({page}) => {
    const firstGraphSummary = await page.locator(":nth-match(.mint-plot-data-summary, 1)");
    const series = await firstGraphSummary.locator(".mint-plot-data-summary-series");
    await expect(series).toHaveCount(8);
    await expectPlotDataSummarySeries(series.nth(0), "none", "No intervention", "scatter",
        1, "0", "0", 0, 0);
    await expectPlotDataSummarySeries(series.nth(1), "llin", "Pyrethroid LLIN only", "scatter",
        1, "120", "120", 2823, 2823, 1);
    await expectPlotDataSummarySeries(series.nth(2), "llin-pbo", "Pyrethroid-PBO ITN only", "scatter",
        1, "192", "192", 3120, 3120, 1)
    await expectPlotDataSummarySeries(series.nth(3), "pyrrole-pbo", "Pyrethroid-pyrrole ITN only", "scatter",
        1, "198", "198", 3418, 3418, 1);
    await expectPlotDataSummarySeries(series.nth(4), "irs", "IRS* only", "scatter",
        1, "768", "768", 17190, 17190, 1);
    await expectPlotDataSummarySeries(series.nth(5), "irs-llin", "Pyrethroid LLIN with IRS*", "scatter",
        1, "774", "774", 20013, 20013, 1);
    await expectPlotDataSummarySeries(series.nth(6), "irs-llin-pbo", "Pyrethroid-PBO ITN with IRS*", "scatter",
        1, "774", "774", 20310, 20310, 1);
    await expectPlotDataSummarySeries(series.nth(7), "irs-pyrrole-pbo", "Pyrethroid-pyrrole ITN with IRS*", "scatter",
        1, "774", "774", 20608, 20608, 1);
});


test("Costs per case averted has expected values", async ({page}) => {
    const secondGraphSummary = await page.locator(":nth-match(.mint-plot-data-summary, 2)");
    const series = await secondGraphSummary.locator(".mint-plot-data-summary-series");
    await expect(series).toHaveCount(7);
    await expectPlotDataSummarySeries(series.nth(0), "llin", "Pyrethroid LLIN only", "bar",
        1, "llin", "llin", 23.53, 23.53, 0.01);
    await expectPlotDataSummarySeries(series.nth(1), "llin-pbo", "Pyrethroid-PBO ITN only", "bar",
        1, "llin-pbo", "llin-pbo", 16.25, 16.25, 0.01);
    await expectPlotDataSummarySeries(series.nth(2), "pyrrole-pbo", "Pyrethroid-pyrrole ITN only", "bar",
        1, "pyrrole-pbo", "pyrrole-pbo", 17.26, 17.26, 0.01);
    await expectPlotDataSummarySeries(series.nth(3), "irs", "IRS* only", "bar",
        1, "irs", "irs", 22.38, 22.38, 0.01);
    await expectPlotDataSummarySeries(series.nth(4), "irs-llin", "Pyrethroid LLIN with IRS*", "bar",
        1, "irs-llin", "irs-llin", 25.86, 25.86, 0.01);
    await expectPlotDataSummarySeries(series.nth(5), "irs-llin-pbo", "Pyrethroid-PBO ITN with IRS*", "bar",
        1, "irs-llin-pbo", "irs-llin-pbo", 26.24, 26.24, 0.01);
    await expectPlotDataSummarySeries(series.nth(6), "irs-pyrrole-pbo", "Pyrethroid-pyrrole ITN with IRS*", "bar",
        1, "irs-pyrrole-pbo", "irs-pyrrole-pbo", 26.63, 26.63, 0.01);
});

