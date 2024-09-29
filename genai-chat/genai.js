/**
 * CLOUDSKILLBOOST GENERATIVE AI Arcade TASK RUNNER
 * Use it Wisely!!!
 *
 * https://github.com/AguzzTN54 - https://github.com/Mantan21
 * Last Test: 11 Jul 2024
 *
 * HOW TO USE?
 * 1. Open Lab - don't start yet.
 * 2. Open Dev Tools Console (Ctrl + Shift + I).
 * 3. Paste the script -> Enter.
 * 4. Start Lab.
 * 5. Lab will be executed and ended automatically.
 *
 *
 * TIPS TO ACHIEVE FASTER RESULT:
 * 1. Run Quiz Task Only: This is possible, but not guaranteed to achieve a checklist.
 * 2. Use Fewer Messages: Ensure you leave a minimum of 1 "topic".
 * 3. Use Synchronous Loop: Edit the `chatPersona` function.
 * 4. Run `chatTask()` and `quizTask()` Function Synchronously: edit `taskCheater` function
 * 5. Use Faster and Low Latency Networks: Virtual Machines or Remote Dekstop can be beneficial.
 * 6. Replace CORS Proxy if Necessary: Use another low latency proxy if needed.
 *
 */

// Messages List, copy from Lab!
const messages = [
    'Hello',
    'What is the current time in "topic"?',
    'What can you tell me about the "item"?',
    'Can you list three important facts about "topic" ?',
    'Are there any tourist destinations I should visit in "topic"',
    'What\'s one thing you would recommend to do while in  "topic"',
    'Where is a good place to get food near the stadium in "topic"',
    'What teams are playing in "topic"',
];

let lab_persona = '';
let service_url = '';
let lab_topic = '';

const cors = 'https://cors-get-proxy.sirjosh.workers.dev/?url='; // CORS Anywhere, Replace this if necessary.
const corePath = '/main.dart.js';
const quizPath = '/assets/config/tasks.json';
const personaPath = '/v1/v1';

/**
 * CHATTING TASK
 */
const getChatAPIHost = async () => {
    const data = await fetch(cors + service_url + corePath);
    const txt = await data.text();
    const [, bk] = txt.split('arcade-api-');
    const [id] = bk.split('.run.app');
    const host = `https://arcade-api-${id}.run.app`;
    return host;
};

const chatPersona = async (personaURL) => {
    /**
     * Need Faster Result?
     * - You can change Async Loop to Synchronous loop
     */
    for (const msg of messages) {
        const topic = msg.replace(/"topic"/gi, lab_topic);
        const talk = await fetch(personaURL + '&message=' + topic);
        const { msg: response } = await talk.json();
        console.group(topic);
        console.log(response);
        console.groupEnd(msg);
        console.log('');
    }
};

const chatTask = async () => {
    console.log('%cFetching ChatBot.. Please Wait!', 'color: #4285f4; font-weight:bold;');
    const personaURL = await getChatAPIHost();
    const url = `${cors + personaURL}/v1/v1?name=${lab_persona}&message=Hello&role=tutor&knowledge=${lab_topic}`;
    const chat = await chatPersona(url);
    return chat;
};

/**
 * QUIZ TASK
 */
const quizTask = async () => {
    const data = await fetch(cors + service_url + quizPath);
    const { endpoint, uri } = await data.json();
    const targetURL = `https://${uri}${endpoint}?message=arcade`;
    const finalize = await fetch(targetURL);
    const response = await finalize.text();
    console.group('%c Quiz Task Done✔✔✔', 'color: #34a853;');
    console.log(response);
    console.groupEnd();
    return response;
};

/**
 * LAB CONTROLLER
 */
const checkLab = async (labInstanceId) => {
    console.log('%c Almost Done.. Verifying..', 'color:#00aaff; font-weight:800;');

    const qwiklab = 'https://www.cloudskillsboost.google';
    const stepURL = `${qwiklab}/assessments/run_step.json?id=${labInstanceId}&step=1&u=${Math.random()}`;
    const data = await fetch(stepURL);
    const { percent_complete } = await data.json();
    const isComplete = percent_complete === 100;

    if (!isComplete) return checkLab(labInstanceId);
    console.log('%c LAB ENDED !', 'color:green; font-weight:800; font-size: 200%');

    // Check Progress UI for better satisfaction :D.
    const trackerPanel = document.querySelector('ql-activity-tracking');
    const checkButton = trackerPanel.shadowRoot.querySelector('ql-button');
    const btn = checkButton.shadowRoot.querySelector('button');
    btn.click();
    endLab();
};

const endLab = async () => {
    const finalize = document.querySelector('#js-are-you-sure-button');
    const finalizeButton = finalize.shadowRoot.querySelector('button');
    finalizeButton.click();
};

/**
 * TASK RUNNER
 */
let isProcessed = false;
const taskCheater = async (resource) => {
    try {
        const { resourceData, labInstanceId } = await resource.json();
        const { startup_script = {} } = resourceData?.project_0;

        if (!startup_script.service_url) {
            console.log('%c PREPARING RESOURCES, Please Wait!', 'color: orange; font-weight:bold');
            return;
        }

        // Don't run function if already executed
        if (isProcessed) return;
        console.log('%c LAB STARTED !', 'color:#d93025; font-weight:800; font-size: 200%');
        console.table(startup_script);
        isProcessed = true;

        ({ service_url, lab_persona, lab_topic } = startup_script);
        // chatTask();
        await quizTask();
        checkLab(labInstanceId);
    } catch (e) {}
};

// Intercept Fetch Function
const { fetch: originalFetch } = window;
window.fetch = async (...args) => {
    const [resource, config] = args;
    const response = await originalFetch(resource, config);
    const data = response.clone();

    if (resource.includes('focuses/show')) {
        taskCheater(data);
    }
    return response;
};

console.clear();
