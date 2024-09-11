/** ========================================================================================================
 *  ----------------------------------- EDIT THE VARIABLES BELOW -------------------------------------------
 *  ------------ PLEASE ENSURE to SET THE LAB URI and VARIABLES before running the scripts!!! --------------
 *  ======================================================================================================== */

const labURI = 'games/5440/labs/35266'; // example => "https://cloudskillsboost.google/games/5156/labs/33678"
const delayBeforeCheckLab = 10; // in seconds
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

    const loginPage = await browser.newPage();
    await loginPage.goto('https://docs.google.com/forms/u/0/create');
    console.log('Google Form Exposed, please click login on that page to show the form');

    const labResources = await waitForResources(labPage);
    const { resourceData, labInstanceId, assessmentInfo } = labResources;
    console.log('Resources Retrived');

    // get Login Credentials
    const { username, password } = resourceData?.user_1 || {};

    // Console Login
    const page = await googleLogin({ browser, password, username, authorize: false });
    console.log('Login Finished');
    // const page = getPage(browser, /forms\/u/);

    await taskForm(page);
    taskSheets(browser);

    // Check Progress
    await delayed(delayBeforeCheckLab);
    await labPage.evaluate(labProgressChecker, {
        labID: labInstanceId,
        progress: assessmentInfo,
    });

    // Close browser Connection
    browserInstance.close();
    console.log('Task Complete!');
};

const taskForm = async (page) => {
    // const newForm = page.locator('.docs-homescreen-templates-templateview', { hasText: 'Blank form' });
    // await newForm.locator('.docs-homescreen-templates-templateview-preview').click();

    const header = page.locator('div[data-action-id=freebird-forms-home]').locator('..');
    const input = header.locator('input[aria-label="Document title"]');
    await input.click();
    await input.fill('On the Rise Bakery Survey');

    const response = page.locator('div[data-action-id=freebird-view-responses]');
    await response.click();

    await page.waitForResponse(/\/chrome\?id=/);

    const connect = page.locator('div[role="button"]', { hasText: 'Link to Sheets' });
    await connect.click();

    const dialog = page.locator('div[role=dialog] > div', { hasNotText: 'Select destination' });
    const create = dialog.locator('div[role=button]', { hasText: 'Create' });
    await create.click();

    return page;
};

const taskSheets = async (browser) => {
    const page = await waitForPage(browser, 'spreadsheets/d');
    await page.waitForEvent('domcontentloaded');

    await page.locator('#docs-file-menu').click();
    const importBtn = page.locator('.docs-icon-editors-ia-import').locator('..').locator('..');
    await importBtn.locator('..').click();

    const frame = page.mainFrame().frameLocator('.picker-dialog-content.picker-frame > iframe');
    const upload = frame.locator('button[role=tab]', { hasText: 'Upload' });
    await upload.click();

    const file = frame.locator('input[type=file]');
    await file.setInputFiles(path.join(__dirname, 'response.xlsx'));

    const selectMethod = page.locator('.docs-material-gm-labeled-select', { hasText: 'Create new' });
    await selectMethod.click();

    await delayed(0.5);
    const replace = page.locator('.goog-menuitem', { hasText: 'Replace spreadsheet' });
    await replace.click();

    const imprt = page.locator('button[name=import]', { hasText: 'Import data' });
    await imprt.click();
};

runner();
