/** ========================================================================================================
 *  ----------------------------------- EDIT THE VARIABLES BELOW -------------------------------------------
 *  ------------ PLEASE ENSURE to SET THE LAB URI and VARIABLES before running the scripts!!! --------------
 *  ======================================================================================================== */

const labURI = '5496/labs/35508'; // example => "https://cloudskillsboost.google/games/5156/labs/33678"
const delayBeforeCheckLab = 5; // in seconds
const browserPORT = 9222; // Your Browser Debugging Port

/** =================================== END OF REQUIRED VARIABLES ========================================== */

const bs = require('../../libs/browser');
const { googleLogin } = require('../../libs/login');
const { sendEmail } = require('../../libs/mailer');
const { browserContext, delayed, labProgressChecker, waitForPage, waitForResources, uploadDrag } = bs;

// BROWSER RUNNER
const runner = async () => {
    const { browser, browserInstance } = await browserContext(browserPORT);
    const labPage = await waitForPage(browser, labURI);
    console.log('Lab Page Connected');
    await labPage.evaluate(() => {
        console.log('%c Connected to This Lab!', 'color:#00aaff; font-weight:800;font-size:large;');
    });

    const loginPage = await browser.newPage();
    await loginPage.goto('https://drive.google.com/drive/my-drive');
    console.log('Google Drive Exposed, please click login with another account on that page and leave the form open');

    const labResources = await waitForResources(labPage);
    const { resourceData, labInstanceId, assessmentInfo } = labResources;
    console.log('Resources Retrived');

    // get Login Credentials
    const { username, password } = resourceData?.user_1 || {};

    // Console Login
    const page = await googleLogin({ browser, password, username, authorize: false });
    console.log('Login Finished');

    taskSheets(page);
    taskMail(browser, username, password);

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

const taskMail = async (browser, username, password) => {
    const page = await browser.newPage();
    await page.goto('https://www.google.com/settings/security/lesssecureapps');
    await page.locator('button[role="switch"]').click();

    await page.waitForResponse(/\/data\/batchexecute/);
    await sendEmail(username, password);
};

const taskSheets = async (page) => {
    const fileList = [
        {
            filePath: 'task1.xlsx',
            mime: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        },
    ];
    await uploadDrag(page, 'div[data-enable-upload-to-view]', fileList);

    await page.route(/v2internal\/batch/, async (route, request) => {
        const data = request.postData();
        const postData = data.replaceAll(/convert=false/g, 'convert=true');
        await route.continue({ postData });
    });

    const sheetID = await processUploadResponse(page);
    console.log(sheetID + ' Successfully Uploaded');
    return sheetID;
};

const processUploadResponse = async (page) => {
    const response = await page.waitForResponse(/\/v1\/items:get/);
    const data = (await response.json()) || {};
    const responseArr = data[0][0][1];
    const findSheet = responseArr.find((val) => /(task1)/.test(val));
    if (!findSheet) return await processUploadResponse(page);

    const spreadsheetID = responseArr[0];
    return spreadsheetID;
};

runner();
