//USEUNIT SysUtils
//USEUNIT TestRunnerUtilsPrivate
//USEUNIT StringUtils
//USEUNIT SimplifiedLogUtils
//USEUNIT FileUtils
//USEUNIT _


/** Module Info **

Functions related to configuring and  executing test runs

**/

/**

A constant used in the runConfig when set as follows:
  {
    mockReplace: MOCK_REPLACE_NONE() 
  }
The framework will not save any mock files at the end of a test iteration

== Return ==
String - a descriptive string used internally by the framework to identify the required mock replacement behaviour 
== Related ==
MOCK_REPLACE_NONE, MOCK_ADD_MISSING_REPLACE_FAILED, MOCK_REPLACE_ALL
**/
function MOCK_REPLACE_NONE(){return TestRunnerUtilsPrivate.MOCK_REPLACE_NONE();}

/**

A constant used in the runConfig when set as follows:
  {
    mockReplace: MOCK_ADD_MISSING_REPLACE_FAILED() 
  }
The framework will only replace a mock at the end of a test iteration if the mock file is missing or the iteration has errors.

This is the default setting for the framework.

== Return ==
String - a descriptive string used internally by the framework to identify the required mock replacement behaviour
== Related ==
MOCK_REPLACE_NONE, MOCK_REPLACE_ALL
**/
function MOCK_ADD_MISSING_REPLACE_FAILED(){return TestRunnerUtilsPrivate.MOCK_ADD_MISSING_REPLACE_FAILED();}

/**

A constant used in the runConfig when set as follows:
  {
    mockReplace: MOCK_REPLACE_ALL() 
  }
The framework will replace all mock files at the end of the test iteration

== Return ==
String - a descriptive string used internally by the framework to identify the required mock replacement behaviour
== Related ==
MOCK_REPLACE_NONE, MOCK_ADD_MISSING_REPLACE_FAILED
**/
function MOCK_REPLACE_ALL(){return TestRunnerUtilsPrivate.MOCK_REPLACE_ALL();}

/**

Used to add a defect expectation in list of validators. When the next validator fails then the failure will be logged as a warning not an error.
See the Zenith Users' Guide (Handling Known Defects) for details

== Params ==
defectIdDescription: String - Required - describes the expected defect for self documenting code and is logged during a run
active: Boolean - Optional - Default: true - Defect expected (ie. not fixed)
== Return ==
function(): No return value - a function used by the framework to generate a defect expectation
== Related ==
expectDefect
**/
function expect_defect(defectIdDescription, active){
  function defectExpectation(){
    expectDefect(defectIdDescription, active);
  }
  defectExpectation.isDefectExpectation = true;
  return defectExpectation;
}

/**
  Framework use only
**/
function registerTestRunElement(testRunElementFunction){
 TestRunnerUtilsPrivate.registerTestRunElement(testRunElementFunction);
}


/**
 Framework use only
**/
function getConfig(testScriptName){
  return TestRunnerUtilsPrivate.getConfig(testScriptName);
}


/**
Framework Use Only
**/
function isRestart(str){
  return TestRunnerUtilsPrivate.isRestart(str);
}

/**

Returns all test items as listed between two test names. Can be used in conjunction with the tests property on the runConfig
for running sections of the test list

== Params ==
fromTestName: String -  Required - The name of the test from
toTestName: String -  Required - The name of the test to
== Return ==
String[] - All the items between and including fromTestName and toTestName as listed in the TestCaseList
**/
function testSubList(fromTestName, toTestName){
  var all = _.reject(testListItemNames(), isRestart);
  
  function ensuredIndex(name){
    var result = _.indexOf(all, name);
    ensure(result > -1, name + ' not found in test list');
    return result;
  }
  
  var startIndex = ensuredIndex(fromTestName);
  var endIndex = ensuredIndex(toTestName);
  ensure(startIndex < endIndex, 'from script: ' + fromTestName + ' is after to script: ' + toTestName);
  var result = all.slice(startIndex, endIndex + 1);
  return result;
}

/**
  Framework use only
**/
function issuesPath(testName){
  return TestRunnerUtilsPrivate.issuesPath(testName);
}

/**
  Framework use only
**/
function issuesFileName(testName, testId){
  return TestRunnerUtilsPrivate.issuesFileName(testName, testId);
}



/**

Generates a customisable summary of tests. Copies the result to the temp directory.

== Params ==
logItemFunction: function - Required - a function that takes the test script name and returns a String
logRestartFunction: function  - Required - - a function that takes the restart script name and returns a String
fileName: String - Required -   the name of the output file - this will be copied to the temp directory
**/
function generateManifest(logItemFunction, logRestartFunction, fileName){
  var testList = testListItemNames();
  testList.sort();
  function addToResult(result, testItem){
    var thisResult = isRestart(testItem) ? 
                      logRestartFunction(testItem): 
                      logItemFunction(testItem, getConfig(testItem));
                      
    if(hasValue(thisResult)){
      result.push(thisResult);
    }
    return result;
  }
  var result = _.reduce(testList, addToResult, []);
  
  result = removeDuplicateRestarts(result, function(item){return hasText(item, 'restart');});
  var result = result.join(newLine());
  toTempString(result, fileName);
  log('Manifest written to: ' + tempFile(fileName), result);
}

/**
  Framework use only
**/
function runTests(configFileNoDirOrConfigObj, defaultRunConfigInfo, defaultTestConfigInfo, testFilters, simpleLogProcessingMethod, testOverrideFunc, preTestRunFunction){
  // TC Logging Defaults
  fullyEnableCallStack();
  
  // allow for multiple calls to run tests from one function call
  if (simplifiedLog.length > 0){
    simplifiedLogsForPreviousRuns.push(simplifiedLog);
    simplifiedLog = [];
  }

  ensure(hasValue(configFileNoDirOrConfigObj), 'configFileNoDirOrConfigObj - is null');
  var runConfig = _.isString(configFileNoDirOrConfigObj) ? getLastRunConfig() : configFileNoDirOrConfigObj;
  runFromConfig(configFileNoDirOrConfigObj, defaultRunConfigInfo, defaultTestConfigInfo, testFilters, simpleLogProcessingMethod,  testOverrideFunc, preTestRunFunction);
}

/**
  Framework use only
**/
function validateAndSetDefaultConfigProperties(config, defaultConfig, configType,  wantThrow){
  TestRunnerUtilsPrivate.validateAndSetDefaultConfigProperties(config, defaultConfig, configType,  wantThrow);
}

/**
  Framework use only
**/
function runTestCaseEndPoint(testConfig, itemSelector, runConfig, defaultRunConfigInfo, defaultTestConfigInfo){
  fullyEnableCallStack();
  validateAndSetDefaultConfigProperties(runConfig, defaultRunConfigInfo, CONFIGURATION_TYPE.RUN_CONFIG);
  validateAndSetDefaultConfigProperties(testConfig, defaultTestConfigInfo, CONFIGURATION_TYPE.TEST_CONFIG);
  setTargetBrowserName(runConfig.targetBrowserName); // For X-browser testing
    
  var arDataSource = testItems(testConfig, runConfig);
  validateTestItemsArray(arDataSource);

  var index = hasValue(itemSelector) ?
     itemFromDataSource(arDataSource, itemSelector, testConfig.id, runConfig) :
     arDataSource.length - 1;
   
  testItem = arDataSource[index];

  var restartInfo = getRestartAndParams(testConfig);
  
  var testScriptName = scriptNameFromId(testConfig.id);
  
  function rollover(){
    rolloverIfNotHome(restartInfo.script, runConfig, restartInfo.params);
  }
  
  function goHome(){
    goHomeOrRestart(restartInfo.script, runConfig, restartInfo.params);
  }
  
  var endPointMessage = 'EndPoint - ' + testScriptName + ' id: ' + testConfig.id + ' - item id: ' + testItem.id + ' - ' + whenThenMessage(testItem, testConfig);
  logBold(endPointMessage, endPointMessage + newLine(2) + '---- Run Config ----' + newLine() + objectToReadable(runConfig));
  
  executeDeferredLoggingTest(
                              {
                                scriptName: testScriptName,
                                scriptId: testConfig.id,  
                                runConfig: runConfig, 
                                index: index, 
                                item: testItem,
                                issuesReport: [],
                                rollover: rollover,
                                goHome: goHome 
                              }
                            );
}

/**
  Framework use only
**/
function scriptNameFromId(id){
  return TestRunnerUtilsPrivate.scriptNameFromId(id);
}



// © John Walker 2013 – Permission for unrestricted use and modification granted within 
// THE-COMPANY and affiliated companies





