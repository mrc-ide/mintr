import { test, expect } from '@playwright/test';
import { approximatelyEqual, costStringToNumber } from "./helpers";

test("approximatelyEqual returns true for values within tolerance", () => {
    expect(approximatelyEqual(1, 1.5)).toBe(true);
    expect(approximatelyEqual(2.4, 1.4)).toBe(true);
    expect(approximatelyEqual(11, 1.5, 10)).toBe(true);
});

test("approximatelyEqual return false for values outside tolerance", () => {
    expect(approximatelyEqual(1, 2.01)).toBe(false);
    expect(approximatelyEqual(2.3, 1.2)).toBe(false);
    expect(approximatelyEqual(12, 1.5, 10)).toBe(false);
});

test("costStringToNumber returns correct value", () => {
    expect(costStringToNumber("$10.99")).toBe(10.99);
    expect(costStringToNumber("$25.17k")).toBe(25170);
});