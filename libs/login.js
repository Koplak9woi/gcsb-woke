const fs = require('fs');
const { waitForPage } = require('./browser');

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

const googleLogin = async ({ browser, username, password }) => {
    const googlePage = await waitForPage(browser, /v3\/signin\/identifier/);
    const authKeyMode = /authcode.html/.test(googlePage.url());

    const emailField = googlePage.locator('input[type=email]');
    await emailField.waitFor();
    await emailField.fill(username);
    await googlePage.locator('#identifierNext button[type=button]').click();

    const passwordField = googlePage.locator('#password input');
    await passwordField.waitFor();
    await passwordField.fill(password);
    await googlePage.locator('#passwordNext button[type=button]').click();
    await googlePage.waitForEvent('load');

    // I Understand
    if (!/signin\/oauth\/id/.test(googlePage.url())) {
        const uBtn = googlePage.locator('#confirm');
        await uBtn.waitFor();
        await uBtn.click();
    }

    // Continue
    // const contBTN = googlePage.locator('button', { hasText: 'Continue' });
    // await contBTN.waitFor();
    // await contBTN.click();

    // // Allow
    // const allowBtn = googlePage.locator('button', { hasText: 'Allow' });
    // await allowBtn.waitFor();
    // await allowBtn.click();

    if (!authKeyMode) return googlePage;

    const codeBlock = googlePage.locator('code.auth-code');
    const authCode = await codeBlock.innerText();
    writeFile('tmp/login_key.txt', authCode);
    return googlePage;
};

const writeFile = (filePath, content) => {
    fs.writeFile(filePath, content, 'utf-8', (err) => {
        if (!err) return;
        console.log(err);
        throw err;
    });
};

exports.lookerLogin = lookerLogin;
exports.googleLogin = googleLogin;
