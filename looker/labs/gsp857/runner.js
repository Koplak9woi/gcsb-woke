/** ========================================================================================================
 *  ----------------------------------- EDIT THE VARIABLES BELOW -------------------------------------------
 *  ------------ PLEASE ENSURE to SET THE LAB URI and VARIABLES before running the scripts!!! --------------
 *  ======================================================================================================== */

const labURI = 'games/5429/labs/35215'; // example => "https://cloudskillsboost.google/games/5156/labs/33678"
const delayBeforeCheckLab = 60; // in seconds
const browserPORT = 9222; // Your Browser Debugging Port

/** =================================== END OF REQUIRED VARIABLES ========================================== */

const { chromium } = require('playwright');
const { text } = require('./model');
const { task1 } = require('./task1');
const { task2 } = require('./task2');
const { task3 } = require('./task3');
const { task4 } = require('./task4');
const { task5 } = require('./task5');

// BROWSER RUNNER
let browserInstance = {};
const runner = async () => {
    const browser = await browserContext();
    const labPage = await waitForPage(browser, labURI);
    const labResources = await waitForResources(labPage);
    const { resourceData, labInstanceId, assessmentInfo } = labResources;

    // get Login Credentials
    const { developer_username: username, developer_password: password, student_url: url } = resourceData?.looker || {};

    // Console Login
    const lookerPage1 = await lookerLogin({ browser, username, password, url });
    const lookerPage2 = await deployModel(browser, lookerPage1, url);
    const tasks = [task1, task2, task3, task4, task5].map(async (t) => t(browser, url, lookerPage2));
    Promise.all(tasks);

    // Check Progress
    await delayed(delayBeforeCheckLab);
    await labPage.evaluate(labProgressChecker, {
        labID: labInstanceId,
        progress: assessmentInfo,
    });

    // Close browser Connection
    browserInstance.close();
};

// Connect to the browser you used to log in to the GCSB.
const browserContext = async () => {
    browserInstance = await chromium.connectOverCDP('http://localhost:' + browserPORT);
    const defaultContext = browserInstance.contexts()[0];
    defaultContext.setDefaultTimeout(1000 * 60 * 10); // 10 minutes
    return defaultContext;
};

// Find a specific page by URL
const getPage = (browser, urlRegexp) => {
    const pages = browser.pages();
    const filter = (page) => new RegExp(urlRegexp).test(page.url());
    const selected = pages.find(filter);
    return selected;
};

const waitForPage = (browser, uri) => {
    return new Promise((resolve, reject) => {
        const pageReady = getPage(browser, uri);
        if (pageReady) return resolve(pageReady);

        const timeout = setInterval(() => {
            const page = getPage(browser, uri);
            if (!page) return;
            clearInterval(timeout);
            return resolve(page);
        }, 2000);
    });
};

// Waiting for Lab Resources
const waitForResources = async (labPage) => {
    const resources = await labPage?.waitForResponse(/focuses\/show/);
    const data = (await resources?.json()) || {};
    const { resourceData, labInstanceId, labDetails } = data;
    const { provisioning, labControlButton = {}, assessmentInfo } = data;
    const isResourceReady = !provisioning && labControlButton?.running;
    if (!isResourceReady) return waitForResources();
    return { resourceData, labInstanceId, labDetails, assessmentInfo };
};

// Login into console and connect with GCloud SDK
const lookerLogin = async ({ browser, username, password, url }) => {
    const lookerPage = await browser.newPage();
    await lookerPage.goto(url);

    const emailField = lookerPage.locator('#login-email');
    await emailField.fill(username);
    const passwordField = lookerPage.locator('#login-password');
    await passwordField.fill(password);

    await lookerPage.locator('#login-submit').click();
    await lookerPage.waitForEvent('domcontentloaded');

    return lookerPage;
};

const deployModel = async (browser, page, url) => {
    const devMode = page.locator('label', { hasText: 'Development Mode' });
    await devMode.click();

    await page.waitForEvent('domcontentloaded');

    const modelURL = url + 'projects/qwiklabs-flights/files/general/flights/faa.model.lkml';
    await page.goto(modelURL, { waitUntil: 'domcontentloaded' });

    const modelPage = await browser.newPage();
    await modelPage.setContent(`<textarea>${text}</textarea>`);
    await modelPage.focus('textarea');
    await modelPage.keyboard.press('Control+A');
    await modelPage.keyboard.press('Control+C');

    const textarea = page.locator('.ace_content').first();
    await textarea.click({ position: { x: 50, y: 100 } });

    await page.keyboard.press('Control+A');
    await page.keyboard.press('Control+V');

    const save = page.locator('button', { hasText: 'Save Changes' });
    await save.click();

    const validate = page.locator('button', { hasText: 'Validate LookML' });
    await validate.click();

    const commit = page.locator('button', { hasText: 'Commit Changes' });
    await commit.click();
    const commdiv = page.locator('.form-group', { hasText: 'Briefly describe the changes' });
    const commsg = commdiv.locator('input');
    await commsg.fill('Hublaa');
    const submit = page.locator('button[lk-track-action=Commit]');
    await submit.click();

    const deploy = page.locator('button', { hasText: 'Deploy to Production' });
    await deploy.click();

    await page.waitForResponse(url + 'api/internal/projects/qwiklabs-flights/deploy');
    return modelPage;
};

// Automatically check and end the lab, running in a browser instance rather than in a playwright/NodeJS environment.
const labProgressChecker = async ({ labID, progress }) => {
    let assessmentInfo = progress || [];
    const checkLab = async () => {
        console.log('%cChecking Progress..', 'color:#00aaff;');
        const { step_complete = [] } = assessmentInfo;

        const steps = step_complete.map(async (isComplete, i) => {
            if (isComplete) return checkUI(i);
            const justComplete = await checkStep(labID, i + 1);
            if (justComplete) checkUI(i);
            return justComplete;
        });
        const checkResult = await Promise.all(steps);

        assessmentInfo = { step_complete: checkResult };
        console.log(checkResult);
        if (checkResult.includes(false)) return checkLab();
        endLab();
    };

    const checkStep = async (labInstanceId, step = 1) => {
        const gcsb = 'https://www.cloudskillsboost.google';
        const stepURL = `${gcsb}/assessments/run_step.json?id=${labInstanceId}&step=${step}&u=${Math.random()}`;
        const data = await fetch(stepURL);
        const { step_complete } = await data.json();
        const isComplete = step_complete[step - 1];
        return isComplete;
    };

    // Checklis Progress
    const trackerPanel = document.querySelectorAll('ql-activity-tracking');
    const checkUI = (i) => {
        return true;
        if (!trackerPanel[i]) return true;
        const checkButton = trackerPanel[i].shadowRoot.querySelector('ql-button');
        const btn = checkButton?.shadowRoot.querySelector('button');
        if (btn.disabled) return true;
        btn.click();
        return true;
    };

    const endLab = async () => {
        const finalize = document.querySelector('#js-are-you-sure-button');
        const finalizeButton = finalize.shadowRoot.querySelector('button');
        finalizeButton.click();
    };

    return checkLab();
};

// delay promise
const delayed = (time) => {
    return new Promise((resolve, reject) => {
        if (isNaN(time) || time < 1) return resolve('ok');
        const t = setTimeout(() => {
            resolve('ok');
            clearTimeout(t);
        }, time * 1000);
    });
};

runner();
