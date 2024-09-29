const task3 = async (browser, url) => {
    const page = await browser.newPage();
    await page.goto(url + 'explore/faa/flights');

    const start = page.locator('div[role=button]', { hasText: 'task3' });
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
    await page.keyboard.type('${flights.cancelled_count}/${flights.count}');

    const format = dialog.locator('label', { hasText: 'Format' }).locator('..');
    await format.locator('div[role=combobox]').click();
    const percentFormat = page.locator('li', { hasText: 'Percent' });
    await percentFormat.click();

    const saveCalc = dialog.locator('button', { hasText: 'Save' });
    await saveCalc.click();

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
    await title.fill('Percent of Flights Cancelled by Aircraft Origin 2004');

    const submit = page.locator('button[type=submit]', { hasText: 'Save' });
    await submit.click();
};

exports.task3 = task3;
