/** ========================================================================================================
 *  ----------------------------------- EDIT THE VARIABLES BELOW -------------------------------------------
 *  ------------ PLEASE ENSURE to SET THE LAB URI and VARIABLES before running the scripts!!! --------------
 *  ======================================================================================================== */

const labURI = '5440/labs/35265'; // example => "https://cloudskillsboost.google/games/5156/labs/33678"
const delayBeforeCheckLab = 5; // in seconds
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
    await loginPage.goto('https://docs.google.com/spreadsheets/u/0/create');
    console.log('Google Sheets Exposed, please click login with another account on that page and leave the form open');

    const labResources = await waitForResources(labPage);
    const { resourceData, labInstanceId, assessmentInfo } = labResources;
    console.log('Resources Retrived');

    // get Login Credentials
    const { username, password } = resourceData?.user_1 || {};

    // Console Login
    const page = await googleLogin({ browser, password, username, authorize: false });
    console.log('Login Finished');

    taskSheets(page);

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

const taskSheets = async (page) => {
    const title = page.locator('input.docs-title-input');
    await title.fill('On the Rise Bakery Web Traffic');

    await page.locator('#docs-file-menu').click();
    const importMenu = page.locator('.docs-icon-editors-ia-import').locator('..').locator('..');
    await importMenu.locator('..').click();

    const frame = page.mainFrame().frameLocator('.picker-dialog-content.picker-frame > iframe');
    const upload = frame.locator('button[role=tab]', { hasText: 'Upload' });
    await upload.click();

    const file = frame.locator('input[type=file]');
    await file.setInputFiles(path.join(__dirname, 'bakery-traffic.xlsx'));

    await delayed(1);
    const selectMethod = page.locator('.docs-material-gm-labeled-select', { hasText: 'Create new' });
    await selectMethod.click();

    const replace = page.locator('.goog-menuitem', { hasText: 'Replace spreadsheet' });
    await replace.click();

    const imprt = page.locator('button[name=import]', { hasText: 'Import data' });
    await imprt.click();
};

runner();
