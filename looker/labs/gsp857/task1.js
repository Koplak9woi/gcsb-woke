const task1 = async (browser, url, page) => {
    await page.goto(url + 'explore/faa/flights');

    const start = page.locator('div[role=button]', { hasText: 'task1' });
    await start.click();
    await page.waitForURL(/&toggle=vis/);

    await page.waitForResponse(/query_results/);

    const pivotGear = page.locator('th', { hasText: 'Distance Tiered' }).locator('button');
    await pivotGear.click();
    const pivot = page.locator('button[role="menuitem"]', { hasText: 'Pivot' });
    await pivot.click();

    const Line = page.locator('.vis-selector-menu').locator('div[aria-label=Line]');
    await Line.click();

    await page.locator('button[aria-label=Run]').click();
    await page.waitForResponse(/query_results/);

    const editVis = page.locator('div[aria-controls=explore-vis-editor-tab-content]', { hasText: 'Edit' });
    await editVis.click();
    const plot = page.locator('button[aria-controls=flexible_series_editor_panel]', { hasText: 'Plot' });
    await plot.click();
    const left = page.getByText('Left', { exact: true });
    await left.click();

    const gear = page.locator('button', { hasText: 'Explore actions' });
    await gear.click();
    const save = page.locator('button[role=menuitem]', { hasText: 'Save...' });
    await save.hover();

    const asLook = page.locator('button[role=menuitem]', { hasText: 'As a Look' });
    await asLook.click();

    const title = page.locator('.form-group', { hasText: 'A title is required' }).locator('input');
    await title.fill('Flight Count by Departure Week and Distance Tier');

    const submit = page.locator('button[type=submit]', { hasText: 'Save' });
    await submit.click();
};

exports.task1 = task1;
