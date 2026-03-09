const { $ } = require('@wdio/globals')
const Page = require('./page')

class SuccessPage extends Page {
    get title() {
        return $('~Success')
    }

    get confirmation() {
        return $('-ios predicate string:label BEGINSWITH "You are signed in as"')
    }

    get logoutButton() {
        return $('~Logout')
    }

    // check the Success screen UI: title, confirmation message, logout button
    async isDisplayed(username) {
        await this.title.waitForExist()
        await expect(this.confirmation).toBeDisplayed()
        await expect(this.confirmation).toHaveAttr('label', `You are signed in as ${username}.`)
        await expect(this.logoutButton).toBeDisplayed()
        return this.title.isDisplayed()
    }

    // perform logout
    async logout() {
        // check the logout button is active and tap on it
        await expect(this.logoutButton).toHaveAttr('enabled', 'true')
        await this.logoutButton.click()
    }
}

module.exports = new SuccessPage()
