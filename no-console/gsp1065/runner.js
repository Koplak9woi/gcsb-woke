/** ========================================================================================================
 *  ----------------------------------- EDIT THE VARIABLES BELOW -------------------------------------------
 *  ------------ PLEASE ENSURE to SET THE LAB URI and VARIABLES before running the scripts!!! --------------
 *  ======================================================================================================== */

const labURI = '5440/labs/35265'; // example => "https://cloudskillsboost.google/games/5156/labs/33678"
const delayBeforeCheckLab = 3; // in seconds
const browserPORT = 9222; // Your Browser Debugging Port

/** =================================== END OF REQUIRED VARIABLES ========================================== */

const bs = require('../../libs/browser');
const { googleLogin } = require('../../libs/login');
const { browserContext, delayed, labProgressChecker, waitForPage, waitForResources, uploadDrag } = bs;

// BROWSER RUNNER
const runner = async () => {
    const { browser, browserInstance } = await browserContext(browserPORT);
    const labPage = await waitForPage(browser, labURI);
    console.log('Lab Page Connected');

    const loginPage = await browser.newPage();
    await loginPage.goto('https://drive.google.com/drive/u/0/home');
    console.log('Google Sheets Exposed, please click login with another account on that page and leave the form open');

    const labResources = await waitForResources(labPage);
    const { resourceData, labInstanceId, assessmentInfo } = labResources;
    console.log('Resources Retrived');

    // get Login Credentials
    const { username, password } = resourceData?.user_1 || {};

    // Console Login
    const page = await googleLogin({ browser, password, username, authorize: false });
    console.log('Login Finished');

    await taskSheets(page);

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
    const fileList = [
        {
            filePath: 'On the Rise Bakery Web Traffic.xlsx',
            mime: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        },
    ];
    await uploadDrag(page, 'div[data-enable-upload-to-view]', fileList);

    await page.route(/v2internal\/batch/, async (route, request) => {
        const data = request.postData();
        const postData = data.replaceAll(/convert=false/g, 'convert=true');
        await route.continue({ postData });
    });
};

// const getCredentials = async (page) => {
//     const response = await page.waitForResponse(/\?openDrive=/);
//     const url = new URL(response.url());
//     const key = url.searchParams.get('key');

//     const request = response.request();
//     const authorization = await request.headerValue('authorization');
//     if (!(key && authorization)) return getCredentials(page);

//     console.log({ key, authorization });
//     return { key, authorization };
// };

runner();
