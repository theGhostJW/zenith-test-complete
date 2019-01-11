//USEUNIT _
//USEUNIT DemoSmartBearSite
//USEUNIT EndPointLauncherUtils
//USEUNIT FileUtils
//USEUNIT StringUtils
//USEUNIT SysUtils
//USEUNIT TestRunner
//USEUNIT WebUtils

var TEST_CONFIGURATION  = {
  id: -2,
  when: 'a user attempts to log in',
  then: 'access is granted or denied as expected',
  owner: '',
  demo: true,
  enabled: true
};

function testCaseEndPoint(){
  var testParams = {
                    testConfig: TEST_CONFIGURATION,
                    itemSelector: 1,
                    mocking: false,
                    demo: true
                   // ,mocking: true
                   };
  runTestCaseEndPoint(testParams);
}
   
function interactor(runConfig, item, apState){
  logInSmartBear(
                  item.userName, 
                  item.password
                );
  apState.url = activeUrl();
  var statusLabel = seekByIdStr(0, 'ctl00_MainContent_status');
  apState['error message'] = hasValue(statusLabel) ? statusLabel.contentText: 'N/A';
}

function mockFileNameNoExtension(item, runConfig){
  // use default naming convention
  return null;
}

function logged_in_successfully(apState, item, runConfig){
  checkEqual(WEB_ORDERS_DEFAULT_URL(), apState.url);
}

function log_in_should_have_failed(apState, item, runConfig){
  checkContains(apState.url, 'Login.aspx');
}

/* 
function error_message_as_expected(apState, item, runConfig){
  checkEqual('Invalid Login or Password.', apState['error message']);
}
*/

// refactored for use with different error messages
function error_message_check(errorMsg){
  function error_message_as_expected(apState, item, runConfig){
    checkEqual(errorMsg, apState['error message']);
  }
  return error_message_as_expected;
}

function testItems(runConfig){
  return [
    {
      id: 1,
      when: 'the correct login credentials are used',
      then: 'the user is able to log in',
      userName: 'Tester',
      password: 'test',
      validators: logged_in_successfully
    },
    {
      id: 2,
      when: 'the user name is incorrect',
      then: 'the user is not able to log in and gets the expected error message',
      userName: 'Tester1',
      password: 'test',
      validators: [
                    log_in_should_have_failed,
                    expect_defect(),
                    error_message_check('Invalid Login or Passwoord.')
                  ]
    }
  ]
}

function testItemsEndPoint() {
  var runConfig = {
                  };
  var result = testItems(runConfig);
  toTemp(result);
}

;(function register(){
  registerTestRunElement(TEST_CONFIGURATION);
}())

