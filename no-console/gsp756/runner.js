/** ========================================================================================================
 *  ----------------------------------- EDIT THE VARIABLES BELOW -------------------------------------------
 *  ------------ PLEASE ENSURE to SET THE LAB URI and VARIABLES before running the scripts!!! --------------
 *  ======================================================================================================== */

const labURI = 'games/5425/labs/35151'; // example => "https://cloudskillsboost.google/games/5156/labs/33678"
const delayBeforeCheckLab = 2; // in seconds
const browserPORT = 9222; // Your Browser Debugging Port

/** =================================== END OF REQUIRED VARIABLES ========================================== */

const bs = require('../../libs/browser');
const { googleLogin } = require('../../libs/login');
const { browserContext, delayed, getPage, labProgressChecker, waitForPage, waitForResources } = bs;

// BROWSER RUNNER
const runner = async () => {
    const { browser, browserInstance } = await browserContext(browserPORT);
    const labPage = await waitForPage(browser, labURI);
    console.log('Lab Page Connected');

    const loginPage = await browser.newPage();
    await loginPage.goto('https://www.appsheet.com/Template/AppDef?appName=InventoryManager-5986379-24-09-10-2&copy=1');
    console.log('Appsheet page exposed, please click login on that page to show the form');

    const labResources = await waitForResources(labPage);
    const { resourceData, labInstanceId, assessmentInfo } = labResources;
    console.log('Resources Retrived');

    // // get Login Credentials
    const { username, password } = resourceData?.user_0 || {};

    // Console Login
    const page = await googleLogin({ browser, password, username });
    await taskAppsheet(page);

    // Check Progress
    await delayed(delayBeforeCheckLab);
    await labPage.evaluate(labProgressChecker, {
        labID: labInstanceId,
        progress: assessmentInfo,
    });

    // Close browser Connection
    browserInstance.close();
};

const taskAppsheet = async (page) => {
    const copy = page.locator('button', { hasText: 'content_copy' });
    await copy.click();

    const confirmCopy = page.locator('.MuiDialog-paper button.MuiButtonBase-root', { hasText: 'Copy app' });
    await confirmCopy.click();
};

runner();
