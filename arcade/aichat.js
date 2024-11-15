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

const cors = 'https://cors-proxy.fringe.zone/';
const arcadePath = '/main.dart.js';
const taskPath = '/assets/config/tasks.json';
const personaPath = '/assets/config/persona.json';

/**
 * CHATTING TASK
 */
const getChatAPIHost = async () => {
  const data = await fetch(cors + service_url + arcadePath);
  const txt = await data.text();
  const [, bk] = txt.split('arcade-api-');
  const [id] = bk.split('.run.app');
  const host = `https://arcade-api-${id}.run.app`;
  return host;
};

const chatPersona = (personaURL) => {
  messages.forEach(async (msg) => {
    const topic = msg.replace(/"topic"/gi, lab_topic);
    const talk = await fetch(personaURL + '&message=' + topic);
    const { msg: response } = await talk.json();
    console.group(topic);
    console.log(response);
    console.groupEnd(msg);
    console.log('');
  });
};

const chatTask = async () => {
  console.log('%c Fetching ChatBot.. please Wait..', 'color: #4285f4; font-weight:bold');
  const data = await fetch(cors + service_url + personaPath);
  const { persona } = await data.json();
  const usedPersona = persona.find(({ name }) => name === lab_persona);
  const { name, endpoint, role, knowledge } = usedPersona;
  const personaURL = await getChatAPIHost();
  const url = `${personaURL}${endpoint}?name=${name}&role=${role}&knowledge=${knowledge}`;
  const chat = await chatPersona(url);
  return chat;
};

/**
 * QUIZ TASK
 */
const quizTask = async () => {
  const data = await fetch(cors + service_url + taskPath);
  const { endpoint, uri } = await data.json();
  const targetURL = `https://${uri}${endpoint}?message=arcade`;
  const finalize = await fetch(targetURL);
  const response = await finalize.text();
  console.group('%cQuiz Task Done✔✔✔', 'color: #34a853;');
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

  // Checklis Progress
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

// Start Lab Programaticaly
const startLab = () => {
  const panel = document.querySelector('ql-lab-control-panel');
  const controlButton = panel.shadowRoot.querySelector('#lab-control-button');
  const btnWrapper = controlButton.shadowRoot.querySelector('ql-button');
  const btn = btnWrapper.shadowRoot.querySelector('button');
  btn.click();
};

/**
 * TASK RUNNER
 */
let isLabStarted = false;
let isProcessed = false;
const taskCheater = async (resource) => {
  try {
    const { resourceData, labInstanceId } = await resource.json();
    const { startup_script = {} } = resourceData?.project_0;
    if (!isLabStarted) {
      console.table(resourceData.user_0);
      isLabStarted = true;
    }

    if (!startup_script.service_url) {
      console.log('%c PREPARING RESOURCES, Please Wait!', 'color: orange; font-weight:bold');
      return;
    }

    if (isProcessed) return;
    console.log('%c LAB STARTED !', 'color:#d93025; font-weight:800; font-size: 200%');
    console.table(startup_script);
    isProcessed = true;

    ({ service_url, lab_persona, lab_topic } = startup_script);
    chatTask();
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

