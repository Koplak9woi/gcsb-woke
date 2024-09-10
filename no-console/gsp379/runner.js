/** ========================================================================================================
 *  ----------------------------------- EDIT THE VARIABLES BELOW -------------------------------------------
 *  ------------ PLEASE ENSURE to SET THE LAB URI and VARIABLES before running the scripts!!! --------------
 *  ======================================================================================================== */

const labURI = 'games/5441/labs/35271'; // example => "https://cloudskillsboost.google/games/5156/labs/33678"
const delayBeforeCheckLab = 20; // in seconds
const browserPORT = 9222; // Your Browser Debugging Port

/** =================================== END OF REQUIRED VARIABLES ========================================== */

const path = require('path');
const bs = require('../../libs/browser');
const { googleLogin } = require('../../libs/login');
const { browserContext, delayed, getPage, labProgressChecker, waitForPage, waitForResources } = bs;

// BROWSER RUNNER
const runner = async () => {
    const { browser, browserInstance } = await browserContext(browserPORT);
    const labPage = await waitForPage(browser, labURI);
    console.log('Lab Page Connected');

    const labResources = await waitForResources(labPage);
    const { resourceData, labInstanceId, assessmentInfo } = labResources;
    console.log('Resources Retrived');

    // // get Login Credentials
    const { username, password } = resourceData?.user_1 || {};

    // // Console Login
    const loginPage = await googleLogin({ browser, password, username });
    // const loginPage = getPage(browser, '/drive/home');

    const sheets = loginPage.locator('div[role=presentation]', { hasText: 'On the Rise Bakery' });
    const sheetID = await sheets.getAttribute('data-id');

    taskSheets(browser, sheetID);
    taskSlides(browser);

    // Check Progress
    await delayed(delayBeforeCheckLab);
    await labPage.evaluate(labProgressChecker, {
        labID: labInstanceId,
        progress: assessmentInfo,
    });

    // Close browser Connection
    browserInstance.close();
};

const taskSheets = async (browser, sheetID) => {
    const page = await browser.newPage();
    await page.goto('https://docs.google.com/spreadsheets/d/' + sheetID);

    await page.locator('#docs-file-menu').click();
    await page.locator('.goog-menuitem.apps-menuitem[role=menuitem]', { hasText: 'Import' }).nth(1).click();

    const frame = page.mainFrame().frameLocator('.picker-dialog-content.picker-frame > iframe');
    const upload = frame.locator('button[role=tab]', { hasText: 'Upload' });
    await upload.click();

    const file = frame.locator('input[type=file]');
    await file.setInputFiles(path.join(__dirname, 'bakery.xlsx'));

    const selectMethod = page.locator('.docs-material-gm-labeled-select', { hasText: 'Create new' });
    await selectMethod.click();

    const replace = page.locator('.goog-menuitem', { hasText: 'Replace spreadsheet' });
    await replace.click();

    const imprt = page.locator('button[name=import]', { hasText: 'Import data' });
    await imprt.click();

    await page.locator('#docs-insert-menu').click();
    await page.locator('.goog-menuitem.apps-menuitem[role=menuitem]', { hasText: 'Chart' }).click();

    const range = page.locator('.docs-charts-editor-col', { hasText: 'Data range' });
    const rangeInput = range.locator('input');
    await rangeInput.fill('D1:D16');

    await page.locator('body').focus();
};

const taskSlides = async (browser) => {
    const page = await browser.newPage();
    await page.goto('https://docs.google.com/presentation/u/0/create');

    await importSlide(page);
    await importSlide(page);
};

const importSlide = async (page) => {
    // Import 1
    await page.locator('#docs-file-menu').click();
    await page.locator('.goog-menuitem.apps-menuitem[role=menuitem]', { hasText: 'Import' }).click();

    const frame = page.mainFrame().frameLocator('.picker-dialog-content.picker-frame > iframe');
    const upload = frame.locator('button[role=tab]', { hasText: 'Upload' });
    await upload.click();

    const file = frame.locator('input[type=file]');
    await file.setInputFiles(path.join(__dirname, 'Staff Roles.pptx'));

    const slide = page.locator('.modal-dialog .goog-inline-block[role=checkbox]').nth(1);
    await slide.click();

    const submit = page.locator('.punch-importslides-buttons div[role=button]', { hasText: 'Import slides' });
    await submit.click();
};
runner();
