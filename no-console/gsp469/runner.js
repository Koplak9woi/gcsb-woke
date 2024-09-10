/** ========================================================================================================
 *  ----------------------------------- EDIT THE VARIABLES BELOW -------------------------------------------
 *  ------------ PLEASE ENSURE to SET THE LAB URI and VARIABLES before running the scripts!!! --------------
 *  ======================================================================================================== */

const labURI = 'games/5439/labs/35257'; // example => "https://cloudskillsboost.google/games/5156/labs/33678"
const delayBeforeCheckLab = 1; // in seconds
const browserPORT = 9222; // Your Browser Debugging Port

/** =================================== END OF REQUIRED VARIABLES ========================================== */

const path = require('path');
const { readFileSync } = require('fs');
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
    const { username, password } = resourceData?.user_0 || {};

    // Console Login
    const loginPage = await googleLogin({ browser, password, username });
    // const loginPage = getPage(browser, '/drive/');

    taskCreate(browser); // Please Create multiple tab manually

    await taskUpload(loginPage);
    await taskConvertCSV(loginPage);

    // Check Progress
    await delayed(delayBeforeCheckLab);
    await labPage.evaluate(labProgressChecker, {
        labID: labInstanceId,
        progress: assessmentInfo,
    });

    // Close browser Connection
    browserInstance.close();
};

const taskUpload = async (page) => {
    const fileList = [
        { fileName: 'exported-data.csv', mime: 'text/csv' },
        {
            fileName: 'Copy of Explore this data (budget request by department).xlsx',
            mime: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        },
    ];
    await dragUpload(page, fileList);

    await page.waitForResponse(/\/v1\/items:get/);
    await page.waitForResponse(/\/v1\/items:get/);

    const dialog = page.locator('div[role=dialog] button', { hasNotText: 'Next' });
    await dialog.click();
    return page;
};

const taskConvertCSV = async (page) => {
    const target = page.locator('div[role=group]', { hasText: 'exported-data.csv' });
    await target.click();

    await page.waitForResponse(/\/files?/);

    await page.locator('div[aria-label="Open with"]').click();
    await page.locator('div[role=menu] div[role=menuitem]', { hasText: 'Google Sheets' }).first().click();

    // await page.waitForTimeout(1000);
    // await page.reload();
};

const taskCreate = async (browser) => {
    const page = await browser.newPage();
    await page.goto('https://docs.google.com/spreadsheets/u/0/create');

    const title = page.locator('input.docs-title-input');
    await title.fill('important-data');

    // Please manual add sheet tab: Overview and Detail

    // Share
    const frame = page.mainFrame().frameLocator('.modal-dialog-content > iframe');
    await frame.locator('button', { hasText: 'Restricted' }).click();
    await frame.locator('li', { hasText: 'Qwiklabs' }).click();
    await frame.locator('button', { hasText: 'Done', exact: true });
};

const dragUpload = async (page, fileList = []) => {
    const files = [];

    fileList.forEach(({ fileName, mime }) => {
        const filePath = path.join(__dirname, './files/' + fileName);
        const file = readFileSync(filePath).toString('base64');
        const buffer = `data:application/octet-stream;base64,${file}`;
        files.push({ buffer, fileName, mime });
    });

    const dataTransfer = await page.evaluateHandle(async (files = []) => {
        const dt = new DataTransfer();
        for (let i = 0; i < files.length; i++) {
            const { buffer, fileName, mime } = files[i];
            const blobData = await fetch(buffer).then((res) => res.blob());
            const file = new File([blobData], fileName, { type: mime });
            dt.items.add(file);
        }
        return dt;
    }, files);

    await page.dispatchEvent('div[data-enable-upload-to-view]', 'drop', { dataTransfer });
};
runner();
