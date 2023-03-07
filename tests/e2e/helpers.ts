import { Page } from "@playwright/test";
export const newProject = async (page) => {
    await page.getByText("Start new project").click();
    await page.locator("#name").fill("test project");
    await page.locator(":nth-match(input,2)").fill("test-region");
    await page.locator("button.btn-primary").click();
};

export const acceptBaseline = async (page) => {
    await page.getByText("Next").click();
};