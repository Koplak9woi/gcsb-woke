/** ========================================================================================================
 *  ----------------------------------- EDIT THE VARIABLES BELOW -------------------------------------------
 *  ------------ PLEASE ENSURE to SET THE LAB URI and VARIABLES before running the scripts!!! --------------
 *  ======================================================================================================== */

const labURI = 'https://www.cloudskillsboost.google/games/5869/labs/37344'; // example => "https://cloudskillsboost.google/games/5156/labs/33678"
const delayBeforeCheckLab = 90; // in seconds
const checkUI = false; // Show Green tick after step complete?
const browserPORT = 9222; // Your Browser Debugging Port
const terms = [
    // 'cloud', // GCP API
    // 'universal', // WorkSpace API
    // 'fitness', // Fitness API
    // 'script', // Appscript API
];
const manual = [
    // Manual Step, automatically open a new tab, so you can complete faster. (auto replace {project} with PROJECT_ID)
    // 'https://console.firebase.google.com/project/{project}', // Grant Firebase Terms
    // 'https://script.google.com/home/usersettings', // Enable Apscript API Access
];
const variables = [
    { var: 'ZONE', prop: 'project_0.default_zone_1' },
    // NEEDS TO BE CHANGED depending on the lab's requirements.
    // Find the required variable in VARIABLES.md or leave this array blank if the lab doesn't need one.
];

/** =================================== END OF REQUIRED VARIABLES ========================================== */

const fs = require('fs');
const { chromium } = require('playwright');

// BROWSER RUNNER
let browserInstance = {};
const runner = async () => {
    const browser = await browserContext();
    const labPage = await waitForPage(browser, labURI);
    console.log('Lab Page Connected');
    await labPage.evaluate(() => {
        console.log('%c Connected to This Lab!', 'color:#00aaff; font-weight:800;font-size:large;');
    });

    const labResources = await waitForResources(labPage);
    const { resourceData, labInstanceId, labDetails, assessmentInfo } = labResources;
    const project_id = storeVariables(resourceData, variables);

    // get Login Credentials
    const { value: username } = labDetails.find(({ property }) => property === 'username');
    const { value: password } = labDetails.find(({ property }) => property === 'password');

    // Console Login\
    await consoleLogin({ browser, username, password, terms, project_id, manual });

    // Check Progress
    await delayed(delayBeforeCheckLab);
    await labPage.evaluate(labProgressChecker, {
        labID: labInstanceId,
        progress: assessmentInfo,
        ui: checkUI,
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
const consoleLogin = async ({ browser, username, password, project_id, terms, manual }) => {
    const consolePage = await waitForPage(browser, /v3\/signin\/identifier/);
    const authKeyMode = /authcode.html/.test(consolePage.url());

    const emailField = consolePage.locator('input[type=email]');
    await emailField.waitFor();
    await emailField.fill(username);
    await consolePage.locator('#identifierNext button[type=button]').click();

    const passwordField = consolePage.locator('#password input');
    await passwordField.waitFor();
    await passwordField.fill(password);
    await consolePage.locator('#passwordNext button[type=button]').click();
    await consolePage.waitForEvent('load');

    // I Understand
    if (!/signin\/oauth\/id/.test(consolePage.url())) {
        const uBtn = consolePage.locator('#confirm');
        await uBtn.waitFor();
        await uBtn.click();
    }

    if (Array.isArray(terms) && terms.length > 0) {
        terms.forEach((term) => acceptTOS(browser, term));
    }

    if (Array.isArray(manual) && manual.length > 0) {
        manual.forEach(async (tab) => {
            const page = await browser.newPage();
            const urlTarget = tab.replace('{project}', project_id);
            await page.goto(urlTarget);
        });
    }

    // Continue
    const contBTN = consolePage.locator('button', { hasText: 'Continue' });
    await contBTN.waitFor();
    await contBTN.click();

    // Allow
    const allowBtn = consolePage.locator('button', { hasText: 'Allow' });
    await allowBtn.waitFor();
    await allowBtn.click();

    if (!authKeyMode) return;
    const codeBlock = consolePage.locator('code.auth-code');
    const authCode = await codeBlock.innerText();
    writeFile('tmp/login_key.txt', authCode);
};

// Accept Terms and Condition
const acceptTOS = async (browser, type = 'cloud') => {
    const termsPage = await browser.newPage();
    const cloudTOSURL = `https://console.cloud.google.com/terms/${type}?pli=1&authuser=1&hl=en`;
    await termsPage.goto(cloudTOSURL);

    const wrapper = termsPage.locator('cfc-virtual-viewport');
    const pageTxt = await wrapper.textContent();
    if (/Click the button below/.test(pageTxt)) {
        const acceptBtn = termsPage.locator('cfc-progress-button button');
        await acceptBtn.click();
    }
};

// Store dynamic variables from the lab into environment variables.
const storeVariables = (resourceData, varList = []) => {
    // Storing Project ID
    const { project_0, primary_project, user_0, primary_user } = resourceData || {};
    const { project_id } = project_0 || primary_project || {};
    const { username } = user_0 || primary_user || {};
    writeFile('tmp/project_id.txt', project_id);

    // Storing Lab Variables
    const variables = varList.map(({ var: str = '', prop = '' }) => {
        const findVal = `.${prop}`.split('.').reduce((pv, curr, i) => {
            const obj = pv || resourceData || {};
            const currentVal = obj[curr];
            return currentVal;
        });
        return `${str}=${findVal}`;
    });
    const project = `PROJECT_ID=${project_id}`;
    const userEmail = `USER_EMAIL=${username}`;
    const varResult = [project, userEmail, ...variables].join('\n') + '\n';
    writeFile('tmp/variables.txt', varResult);

    return project_id;
};

const writeFile = (filePath, content) => {
    fs.writeFile(filePath, content, 'utf-8', (err) => {
        if (!err) return;
        console.log(err);
        throw err;
    });
};

const clearTMPFiles = () => {
    const tmpFiles = ['project_id', 'login_key', 'variables'];
    tmpFiles.forEach((f) => writeFile('tmp/' + f + '.txt', ''));
};

// Automatically check and end the lab, running in a browser instance rather than in a playwright/NodeJS environment.
const labProgressChecker = async ({ labID, progress, ui = false }) => {
    let assessmentInfo = progress || [];
    const checkLab = async () => {
        console.log('%cChecking Progress..', 'color:#00aaff;');
        const { step_complete = [] } = assessmentInfo;

        const steps = step_complete.map(async (isComplete, i) => {
            if (isComplete !== false) return checkUI(i);
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
        if (!ui) return;
        if (!trackerPanel[i]) return true;
        const checkButton = trackerPanel[i].shadowRoot.querySelector('ql-button');
        const filledBTN = checkButton?.shadowRoot.querySelector('md-filled-button');
        const btn = filledBTN?.shadowRoot.querySelector('button');
        if (btn.disabled) return true;
        btn.click();
        return true;
    };

    const endLab = async () => {
        const finalize = document.querySelector('#js-are-you-sure-button');
        const mdText = finalize?.shadowRoot.querySelector('md-text-button');
        const finalizeButton = mdText.shadowRoot.querySelector('button');
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

clearTMPFiles();
runner();
