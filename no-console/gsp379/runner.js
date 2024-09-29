/** ========================================================================================================
 *  ----------------------------------- EDIT THE VARIABLES BELOW -------------------------------------------
 *  ------------ PLEASE ENSURE to SET THE LAB URI and VARIABLES before running the scripts!!! --------------
 *  ======================================================================================================== */

const labURI = 'games/5441/labs/35271'; // example => "https://cloudskillsboost.google/games/5156/labs/33678"
const delayBeforeCheckLab = 2; // in seconds
const browserPORT = 9222; // Your Browser Debugging Port

/** =================================== END OF REQUIRED VARIABLES ========================================== */

const bs = require('../../libs/browser');
const { googleLogin } = require('../../libs/login');
const { browserContext, delayed, labProgressChecker, waitForPage, waitForResources, uploadDrag, getPage } = bs;

// BROWSER RUNNER
const runner = async () => {
    const { browser, browserInstance } = await browserContext(browserPORT);
    const labPage = await waitForPage(browser, labURI);
    console.log('Lab Page Connected');
    await labPage.evaluate(() => {
        console.log('%c Connected to This Lab!', 'color:#00aaff; font-weight:800;font-size:large;');
    });

    const drive = await browser.newPage();
    await drive.goto('https://drive.google.com/drive/my-drive');

    const labResources = await waitForResources(labPage);
    const { resourceData, labInstanceId, assessmentInfo } = labResources;
    console.log('Resources Retrived');

    // get Login Credentials
    const { username, password } = resourceData?.user_1 || {};

    // Console Login
    const loginPage = await googleLogin({ browser, password, username, authorize: false });

    const spreadsheetID = await uploadFiles(loginPage);
    console.log('SpreadSheet Created: ' + spreadsheetID);
    taskSheets(browser, spreadsheetID);

    // Check Progress
    await delayed(delayBeforeCheckLab);
    await labPage.evaluate(labProgressChecker, {
        labID: labInstanceId,
        progress: assessmentInfo,
    });

    console.log('TASK COMPLETE!!');
    // Close browser Connection
    browserInstance.close();
};

const uploadFiles = async (page) => {
    const fileList = [
        {
            filePath: './files/On the Rise Bakery Business Challenge.xlsx',
            mime: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        },
        {
            filePath: './files/Staff Roles.pptx',
            mime: 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
        },
    ];
    await uploadDrag(page, 'div[data-enable-upload-to-view]', fileList);

    await page.route(/v2internal\/batch/, async (route, request) => {
        const data = request.postData();
        const postData = data.replaceAll(/convert=false/g, 'convert=true');
        await route.continue({ postData });
    });

    const sheetID = await processUploadResponse(page);
    return sheetID;
};

const processUploadResponse = async (page) => {
    const response = await page.waitForResponse(/\/v1\/items:get/);
    const data = (await response.json()) || {};
    const responseArr = data[0][0][1];
    const findSheet = responseArr.find((val) => /(On the Rise Bakery)/.test(val));
    if (!findSheet) return await processUploadResponse(page);

    const spreadsheetID = responseArr[0];
    return spreadsheetID;
};

const taskSheets = async (browser, sheetID) => {
    const page = await browser.newPage();
    await page.goto('https://docs.google.com/spreadsheets/d/' + sheetID);

    await page.locator('#docs-insert-menu').click();
    await page.locator('.goog-menuitem.apps-menuitem[role=menuitem]', { hasText: 'Chart' }).click();
};

runner();
