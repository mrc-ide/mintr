import { test, expect } from '@playwright/test';

test('example', async ({ page }) => {
  await page.locator(".navbar");
});

test('test nonexistent', async ({ page }) => {
  await page.locator(".doesnotexist");
});