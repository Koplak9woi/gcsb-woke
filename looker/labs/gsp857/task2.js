const task2 = async (browser, url) => {
    const page = await browser.newPage();
    await page.goto(url + 'explore/faa/flights');

    const start = page.locator('div[role=button]', { hasText: 'task2' });
    await start.click();
    await page.waitForURL(/&toggle=vis/);

    await page.waitForResponse(/query_results/);

    const Line = page.locator('.vis-selector-menu').locator('div[aria-label=Line]');
    await Line.click();

    // await page.locator('button[aria-label=Run]').click();
    // await page.waitForResponse(/query_results/);

    const gear = page.locator('button', { hasText: 'Explore actions' });
    await gear.click();
    const save = page.locator('button[role=menuitem]', { hasText: 'Save...' });
    await save.hover();

    const asLook = page.locator('button[role=menuitem]', { hasText: 'As a Look' });
    await asLook.click();

    const title = page.locator('.form-group', { hasText: 'A title is required' }).locator('input');
    await title.fill('Percent of Flights Cancelled by State in 2000');

    const submit = page.locator('button[type=submit]', { hasText: 'Save' });
    await submit.click();
};

exports.task2 = task2;
