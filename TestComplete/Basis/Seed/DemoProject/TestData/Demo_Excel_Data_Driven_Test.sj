//USEUNIT TestRunner
//USEUNIT SysUtils
//USEUNIT StringUtils
//USEUNIT _

var TEST_CONFIGURATION = {
  id: -1,
  when: 'an action is taken',
  then: 'an equal and opposite reaction occurs',
  owner: 'Li',
  demo: true,
  enabled: false
};

function testCaseEndPoint(){
  var testParams = {
                    testConfig: TEST_CONFIGURATION,
                    itemSelector: ALL(),// itemOfTopId('demo_Deferred_Validation_Test Issues.json', testItems),
                    runConfig: {mocking: true}
                   };
  runTestCaseEndPoint(testParams);
}

function interactor(runConfig, itemIndex, item, apState){
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