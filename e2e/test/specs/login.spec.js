const loginPage = require('../pageobjects/login.page')
const successPage = require('../pageobjects/succes.page')

const username = 'qa'
const password = 'automation'
const wrongUsername = 'blablabla'
const wrongPassword = "blablabla";

describe("Login positive flow", () => {
  it("Login page has required UI elements", async () => {
    // Perform UI checks
    await loginPage.checkUi();
  });

  it("Login button requires both fields to be filed", async () => {
    await loginPage.checkLoginButton(username, password);
  });

  it("Should successfully login with valid credentials", async () => {
    // perform login
    await loginPage.login(username, password);

    // close Saving Password popup
    await loginPage.closePasswordSavingPopup();

    // check the Success page UI
    await successPage.isDisplayed(username);
    await browser.pause(4000);
  });

  it("Log out performed correctly", async () => {
    // perform logout
    await successPage.logout();
    await loginPage.checkCred(username, password);
  });
});

describe("Login negative flow", () => {
  it("Login with incorrect creds", async () => {
    await loginPage.wrongCreds(wrongUsername, wrongPassword);
  });
});


// since there is no solid requirement for the rate limit popup I can't 
// cover it with e2e tests properly
// this test will fail randomly until there is no clear behaviour defined
describe.skip("several logins in a row", () => {
  before(async () => {
    await browser.reloadSession();
  });
  it("Log in using corrects credentials several times", async () => {
    await loginPage.login(username, password);
    for (let i = 0; i < 3; i++) {
      await loginPage.relogin(username, password);
      await browser.pause(2000);
    }
    await loginPage.attemptsError();
  });
});
