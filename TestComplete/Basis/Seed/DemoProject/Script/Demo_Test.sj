//USEUNIT TestRunner
//USEUNIT SysUtils
//USEUNIT StringUtils
//USEUNIT _
//USEUNIT FileUtils
//USEUNIT Demo_Test_Data
//USEUNIT EndPointLauncherUtils

var TEST_CONFIGURATION  = {
  id: -11,
  when: 'a deferred validation test is implemented',
  then: 'it executes as expected',
  owner: 'JW',
  demo: true,
  enabled: true
};

function testCaseEndPoint(){
  var testParams = {
                    testConfig: TEST_CONFIGURATION,
                    itemSelector: 999999, //all, //topIssue, //1, all, lastItemWithValidators, topIssue, {otherProp: }
                    demo: true, 
                    mocking: false
                   };
  runTestCaseEndPoint(testParams);
}
  
function interactor(runConfig, item, apState){
  apState.id = item.id;
  apState.message = item.message;
//  
//  expectDefect('This should NOT result in a warning', false);
//  logCheckPoint('no defect here');
//  endDefect();
//  
  //expectDefect('This should result in a warning');
  //logCheckPoint('no defect here');
  //logError('known defect');
  //endDefect();
  
  if (item.id > 2){
    apState.details.sqlExecuted = 'A very big sql string';   
  }
  
  if (item.id === 4) {
    throwEx('dummy interactor error');
  //  logError('another interactor error');
  //  logError('and another interactor error');
  }
  else if (item.id === 1){
    logWarning('first item dummy warning');
  }
  log(apState.message);
  apState.importantProp = 'An important prop should go to top';
  return reorderProps(apState, 'importantProp');
}

function summarise(runConfig, item, apState){
  return 'this is a test';
}

function mockFileNameNoExtension(item, runConfig){
  return null;
}

function demo_validation(apState, item, runConfig){
  //ensure(false, "Deliberate throw with abort test", ABORT_TEST_TOKEN());
  check(item.id < 2, 'make sure id is less than 2', 'blahh');
}

function another_validation(apState, item, runConfig){
  check(true, 'this will always pass');
}

function demo_validation_will_fail(apState, item, runConfig){
  check(false, 'force fail disabled');
}

function testItems(runConfig){
  var baseDataExample = baseData();
  toTemp(baseDataExample);
  
  var result = [
    {
      id: 1,
      toDo: 'add some validations to this',
      message: 'item 0',
      validators: demo_validation,
      details: {
                request: 'a big request file text !!!'
              }
    },
    {
      id: 2,
      when: '1',
      then: '11',
      message: 'item 1',
      validators: [
                   // expect_defect('demo validation will fail'),
                  //  demo_validation
                  ]
    },
    
    {
      id: 3,
      when: '2',
      then: '22',
      message: 'item 1',
      validators: [
                    demo_validation, 
                    another_validation
                  ]
    },
    
    {
      id: 4,
      when: '3',
      then: '33',
      message: 'item 2',
      toDo: 'Need to think of some more validation here'//,
   //   validators: doNothing
    },
    
    {
      id: 5,
      when: '4',
      then: '44',
      message: 'item 3',
      toDo: 'Need to think of some more validation here',
      validators: [
                    expect_defect("that's gotta hurt", false),
                    demo_validation_will_fail,
                    another_validation
                  ]
    },
    
    {
      id: 6,
      when: '4',
      then: '44',
      message: 'item 3',
      toDo: 'Need to think of some more validation here',
      validators: [
                    expect_defect("that's gotta hurt", false),
                    demo_validation_will_fail,
                    another_validation
                  ]
    },
    
    {
      id: 7,
      when: undefined,
      then: undefined,
      message: 'item 3',
      toDo: 'Need to think of some more validation here',
      validators: [
                    expect_defect("that's gotta hurt", false),
                    demo_validation_will_fail,
                    another_validation
                  ]
    }
  ]
  
  return result;
}

function testItemsEndPoint() {
  var runConfig = {
                  };
  var result = testItems(runConfig);
  toTempReadable(result, null, false);
}

;(function register(){
  registerTestRunElement(TEST_CONFIGURATION);
}())