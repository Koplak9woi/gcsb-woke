const task5 = async (browser, url) => {
    const page = await browser.newPage();
    await page.goto(url + 'explore/faa/flights');

    const start = page.locator('div[role=button]', { hasText: 'task5' });
    await start.click();
    await page.waitForURL(/&toggle=vis/);

    await page.waitForResponse(/query_results/);

    const ul = page.locator('div[role=tabpanel]');
    const add = ul.locator('button', { hasText: 'Add' });
    await add.click();

    const tblCal = page.locator('button[role=menuitem]', { hasText: 'Table Calculation' });
    await tblCal.click();

    const dialog = page.locator('div[role=dialog]', { hasText: 'Expression' });
    const editor = dialog.locator('.ace_content').first();
    await editor.click({ position: { x: 50, y: 100 } });
    const expression = '(${flights.count}-pivot_offset(${flights.count}, -1))/pivot_offset(${flights.count}, -1)';
    await page.keyboard.type(expression);

    const format = dialog.locator('label', { hasText: 'Format' }).locator('..');
    await format.locator('div[role=combobox]').click();
    const percentFormat = page.locator('li', { hasText: 'Percent' });
    await percentFormat.click();

    const saveCalc = dialog.locator('button', { hasText: 'Save' });
    await saveCalc.click();

    const bar = page.locator('.vis-selector-menu').locator('div[aria-label=Table]');
    await bar.click();

    const orderGear = page.locator('th', { hasText: 'Count' }).locator('button');
    await orderGear.click();
    const order = page.locator('button[role="menuitem"]', { hasText: 'Hide from visualization' });
    await order.click();

    const pivotGear = page.locator('th', { hasText: 'Depart Year' }).locator('button');
    await pivotGear.click();
    const pivot = page.locator('button[role="menuitem"]', { hasText: 'Pivot' });
    await pivot.click();

    // Edit Visualitation Config
    const editVis = page.locator('div[aria-controls=explore-vis-editor-tab-content]', { hasText: 'Edit' });
    await editVis.click();
    const plot = page.locator('button[aria-controls=flexible_series_editor_panel]', { hasText: 'Formatting' });
    await plot.click();

    const toggle = page.locator('lk-switch[lk-track-action="Enable Conditional Formatting"]');
    await toggle.click();

    // Run and Save

    await page.locator('button[aria-label=Run]').click();
    await page.waitForResponse(/query_results/);

    const gear = page.locator('button', { hasText: 'Explore actions' });
    await gear.click();
    const save = page.locator('button[role=menuitem]', { hasText: 'Save...' });
    await save.hover();

    const asLook = page.locator('button[role=menuitem]', { hasText: 'As a Look' });
    await asLook.click();

    const title = page.locator('.form-group', { hasText: 'A title is required' }).locator('input');
    await title.fill('YoY Percent Change in Flights flown by Distance, 2000-Present');

    const submit = page.locator('button[type=submit]', { hasText: 'Save' });
    await submit.click();
};

exports.task5 = task5;
