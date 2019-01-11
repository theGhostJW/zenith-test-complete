//USEUNIT TestRunner
//USEUNIT SysUtils
//USEUNIT StringUtils
//USEUNIT _

var TEST_CONFIGURATION = {
  id: -3,
  when: 'an action is taken',
  then: 'an equal and opposite reaction occurs',
  owner: 'Li',
  demo: true,
  enabled: true
};

function testCaseEndPoint(){
  var testParams = {
                    testConfig: TEST_CONFIGURATION,
                    itemSelector: all,// topIssue,
                    demo: true,
                    mocking: true
                   };
  runTestCaseEndPoint(testParams);
}

function interactor(runConfig, item, apState){
  apState.id = 'Singlton test id will be null';
  apState.message = 'Hello from singleton test';  
  log(apState.message); 
}

function mockFileNameNoExtension(item, runConfig){
  return null;
}

function testItems(runConfig){
  return [
    {
      id: 1,
      toDo: 'add some validations to this'
    }
  ]
}

function testItemsEndPoint() {
  var runConfig = {
                  };
  var result = testItems(runConfig);
}

;(function register(){
  registerTestRunElement(TEST_CONFIGURATION);
}())