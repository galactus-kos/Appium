const { $, expect } = require('@wdio/globals')
const Page = require('./page')
const successPage = require('./succes.page')

class LoginPage extends Page {
  get signInHeader() {
    return $("~Sign In");
  }

  get usernameField() {
    return $('-ios predicate string:placeholderValue == "Username"');
  }

  get passwordField() {
    return $('-ios predicate string:placeholderValue == "Password"');
  }

  get loginButton() {
    return $("~Login");
  }

  get errorTitle() {
    return $(
      '-ios class chain:**/XCUIElementTypeAlert[`name == "Login Error"`]',
    );
  }

  get errorDescription() {
    return $('-ios predicate string:label BEGINSWITH "Could not sign in as"');
  }

  get attepmtsErrorDescription() {
    return $(
      '-ios predicate string:value == "Too many attempts. Try again later"',
    );
  }

  get OkButton() {
    return $("~OK");
  }

  async checkUi() {
    // check the Sign In header is displaying
    await expect(this.signInHeader).toBeDisplayed();

    // check the login button is not active
    await expect(this.loginButton).toHaveAttr("enabled", "false");

    // checking the default username value is displaying
    await expect(this.usernameField).toHaveAttr("value", "Username");

    // checking the default password value is displaying
    await expect(this.passwordField).toHaveAttr("value", "Password");

    // check the password field is hiding input
    await expect(this.passwordField).toHaveAttr(
      "type",
      "XCUIElementTypeSecureTextField",
    );
  }

  async login(username, password) {
    // eneter username
    await this.usernameField.setValue(username);

    // entering password
    await this.passwordField.setValue(password);

    // checking the credentials entered correctly
    await this.checkCred(username, password);

    // click on login button
    await this.loginButton.click();
  }

  async checkCred(username, password) {
    await this.usernameField.waitForExist();

    // check the username field has a correct value
    await expect(this.usernameField).toHaveAttr("value", username);

    // check the password field is not empty
    const passwordValue = await this.passwordField.getAttribute("value");
    await expect(passwordValue).not.toBe("Password");
    await expect(passwordValue.length).toBeGreaterThan(0);
  }

  async wrongCreds(wrongUsername, wrongPassword) {
    await this.usernameField.setValue(wrongUsername);
    await this.passwordField.setValue(wrongPassword);
    await expect(this.loginButton).toHaveAttr("enabled", "true");
    await this.loginButton.click();
    await this.errorTitle.waitForExist();
    await expect(this.errorDescription).toHaveAttr(
      "value",
      `Could not sign in as ${wrongUsername}. Please check credentials and try again.`,
    );
    await expect(this.OkButton).toBeDisplayed();
    await expect(this.OkButton).toHaveAttr("enabled", "true");
    await this.OkButton.click();
  }

  async relogin(username, password) {
    // await this.login(username, password)
    await successPage.isDisplayed(username);
    await successPage.logout();
    await this.loginButton.click();
  }

  async attemptsError() {
    await this.errorTitle.waitForExist();
    await expect(this.attepmtsErrorDescription).toBeDisplayed();
    await expect(this.OkButton).toBeDisplayed();
    await expect(this.OkButton).toHaveAttr("enabled", "true");
    await this.OkButton.click();
  }

  async closePasswordSavingPopup() {
    try {
      const text = await driver.getAlertText();
      if (text && text.toLowerCase().includes("save")) {
        await driver.dismissAlert();
      }
    } catch (error) {}
  }

  // check the log in button is only active when
  // both fields username and password are filled
  async checkLoginButton(username, password) {
    await this.usernameField.setValue(username);
    await expect(this.loginButton).toHaveAttr("enabled", "false");
    await this.usernameField.clearValue();
    await this.passwordField.setValue(password);
    await expect(this.loginButton).toHaveAttr("enabled", "false");
    await this.usernameField.setValue(username);
    await expect(this.loginButton).toHaveAttr("enabled", "true");
  }
}

module.exports = new LoginPage()
