/**
 * CLOUDSKILLBOOST Arcade ADVENTURE TASK RUNNER
 * Use it Wisely!!!
 *
 * https://github.com/AguzzTN54 - https://github.com/Mantan21
 * Last Test: 15 Dec 2024
 *
 * HOW TO USE?
 * 1. Open Lab - don't start yet.
 * 2. Open Dev Tools Console (Ctrl + Shift + I).
 * 3. Paste the script -> Enter.
 * 4. Start Lab.
 * 5. Lab will be executed and ended automatically.
 *
 */

const submitAssessment = async ({ project_id, region }) => {
    const targetHOST = `${region}-${project_id}.cloudfunctions.net`;
    const targetURL = `https://${targetHOST}/arcade-1?message=arcade`;
    try {
        const response = await fetch(targetURL);
        const text = await response.text();
        console.group('%c Task Done✔✔✔', 'color: #00aaff;');
        console.log(text);
        console.groupEnd();
        return text;
    } catch (error) {
        console.error('Error in submitAssessment:', error);
        return null;
    }
};

/**
 * LAB CONTROLLER
 */
const checkLab = async (labInstanceId, interval = 5000) => {
    console.log('%c Almost Done.. Verifying..', 'color:#00aaff; font-weight:800;');
    const qwiklab = 'https://www.cloudskillsboost.google';
    const stepURL = `${qwiklab}/assessments/run_step.json?id=${labInstanceId}&step=1&u=${Math.random()}`;
    
    const pollLab = async () => {
        try {
            const response = await fetch(stepURL);
            const { percent_complete } = await response.json();
            if (percent_complete === 100) {
                console.log('%c LAB ENDED!', 'color:green; font-weight:800; font-size: 200%');
                endLab();
                return true;
            }
        } catch (error) {
            console.error('Error in checkLab:', error);
        }
        return false;
    };

    // Poll at regular intervals
    const pollInterval = setInterval(async () => {
        const isComplete = await pollLab();
        if (isComplete) clearInterval(pollInterval);
    }, interval);
};

const endLab = async () => {
    try {
        const finalize = document.querySelector('#js-are-you-sure-button');
        const mdText = finalize?.shadowRoot.querySelector('md-text-button');
        const finalizeButton = mdText.shadowRoot.querySelector('button');
        finalizeButton.click();
    } catch (error) {
        console.error('Error in endLab:', error);
    }
};

/**
 * TASK RUNNER
 */
let isProcessed = false;
const taskCheater = async (resource) => {
    try {
        const { resourceData, labInstanceId } = await resource.json();
        const { startup_script = {}, default_region: region, project_id } = resourceData?.project_0;

        if (!startup_script.service_url) {
            console.log('%c PREPARING RESOURCES, Please Wait!', 'color: orange; font-weight:bold');
            return;
        }

        // Don't run function if already executed
        if (isProcessed) return;
        console.log('%c LAB STARTED!', 'color:#d93025; font-weight:800; font-size: 200%');
        console.table(startup_script);
        isProcessed = true;

        ({ arcade_data, lab_code, service_url } = startup_script);

        // Submit initial assessment
        await submitAssessment({ project_id, region });

        // Check lab completion
        checkLab(labInstanceId);

        // Batch multiple submissions concurrently
        await Promise.all(
            Array.from({ length: 4 }, () => submitAssessment({ project_id, region }))
        );
    } catch (e) {
        console.error('Error in taskCheater:', e);
    }
};

// Intercept Fetch Function
const { fetch: originalFetch } = window;
window.fetch = async (...args) => {
    const [resource, config] = args;
    const response = await originalFetch(resource, config);

    if (resource.includes('focuses/show')) {
        const data = response.clone();
        taskCheater(data);
    }
    return response;
};

console.clear();
