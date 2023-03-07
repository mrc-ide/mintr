import { test, expect } from '@playwright/test';

test('example', async ({ page }) => {
  await page.locator(".navbar");
});