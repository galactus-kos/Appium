## Login pairs

qa / automation
user / pass
admin / admin123
john / letmein


## Some issues were found during the tests. 
## They might cause the test fail.
## I decided not to fix them because the test's purpose 
## is to fail if some issue occurs

## BUG-001: Log in is stucked in progress
Severity: High   
Steps: 
- enter valid credentials
- tap Login button

ER:
user is getting to the Success screen

Actual:
infinite loading w/o Success screen

Comment: is flaky

## BUG-002: Rate limit popup occurs randomly
Severity: High
Steps:
- enter valid credentials
- tap Login button

ER:
user is getting to the Success screen

Actual:
system popup appears: Too many attempts

Comment: is flaky, doesnt' depend on the amount of login tries

## BUG-003: Undefined error appears randomly
Severity: High
Steps:
- enter any credentials
- tap Login button

ER:
user is getting to the Success screen

Actual:
system popup appears: Something went wrong. Try again.

Comment: is flaky, doesnt' depend on the amount of login tries

## BUG-004: Login button doesn't respond
Severity: High
Steps:
- enter any credentials
- tap Login button

ER:
user is getting to the Success screen

Actual:
nothing happens as if login button wasn't tapped

Comment: is flaky, doesnt' depend on the amount of login tries

## BUG-005: Credentials are filled after Logout
Severity: High
Steps:
- enter valid credentials
- tap Login button
- logout

ER:
for security reasons er should be the following:
- username and password fields are empty
- login button is inactive

Actual:
- username and password fields are filled already
- login button is active

## BUG-006: Success screen UI is shifting after login
Severity: Low
Steps:
- enter valid credentials
- tap Login button
- check the Success screen

ER:
- UI is not moving, logout button can be tapped immediately

Actual:
- UI is shifting to the bottom a bit which makes it impossible 
to tap logout button immediately