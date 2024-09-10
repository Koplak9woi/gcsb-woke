const { chromium } = require('playwright');

// Connect to the browser you used to log in to the GCSB.
const browserContext = async (port) => {
    const browserInstance = await chromium.connectOverCDP('http://localhost:' + port);
    const browser = browserInstance.contexts()[0];
    browser.setDefaultTimeout(1000 * 60 * 10); // 10 minutes
    return { browserInstance, browser };
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

// Automatically check and end the lab, running in a browser instance rather than in a playwright/NodeJS environment.
const labProgressChecker = async ({ labID, progress, ui = false }) => {
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
        if (!ui) return true;
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

exports.browserContext = browserContext;
exports.getPage = getPage;
exports.waitForPage = waitForPage;
exports.waitForResources = waitForResources;
exports.labProgressChecker = labProgressChecker;
exports.delayed = delayed;
