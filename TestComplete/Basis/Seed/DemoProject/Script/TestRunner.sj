//USEUNIT _
//USEUNIT EndPointLauncherUtils
//USEUNIT SysUtils
//USEUNIT TestRunnerUtils

/** Module Info **

Functions used in excuting test runs and test case end points

**/

// test commit

/**

A basic list of test filter functions used for filtering test uns based on the: test name, run configuration and test configuration.
These can be updated and extended based on the needs of the organisation.

== Return ==
[function(testName, testConfig, runConfig): Boolean] - an array of functions applied to every test in the test case list
**/
function testFilters(){
  var includeTestNames = null;
  var emptyList = false;
  var lastConfig = null
 
  function nameInList(testName, runConfig){
    if (!hasValue(includeTestNames) || lastConfig !== runConfig) {
      var testList = forceArray(runConfig.tests);
      includeTestNames = _.map(testList, convertToTestName);
      emptyList = includeTestNames.length === 0;
      lastConfig = runConfig;
    }
    
    function matchesName(thisName){
      return wildcardMatch(testName, thisName);
    }
    
    return emptyList || hasValue(_.find(includeTestNames, matchesName));
  }
 
  return [
    function is_enabled(testName, testConfig, runConfig){
      return testConfig.enabled;
    },
   
    function country_check(testName, testConfig, runConfig){
      return _.contains(forceArray(testConfig.countries), runConfig.country);
    },
   
    function demo_check(testName, testConfig, runConfig){
      return testConfig.demo === runConfig.demo;
    },
   
    function is_in_test_list(testName, testConfig, runConfig){
      return nameInList(testName, runConfig);
    }
  ];
}

/**
framework use only
**/
function registerTestRunElement(testRunElementFunction){
  TestRunnerUtils.registerTestRunElement(testRunElementFunction);
}


/**

  Returns the default run config info used to validate and fill in missing properties in the run configuration prior to a test run

== Return ==
Object - an array of functions applied to every test in the test case list
**/
function defaultRunConfigInfo(){
  fullyEnableCallStack();
  notImplementedWarning('Only calling default - defaultRunConfigInfo - update this method as required');
  var result = {
      requiredProperties:['name'],
      mocking: false,
      mockReplace: MOCK_ADD_MISSING_REPLACE_FAILED(),
      demo: false,
      country: 'Australia',
      targetBrowserName: BROWSER_NAME_FIREFOX(),
      // an empty array in the tests property
      // means the test list will be ignored by default
      tests: [] 
  };
  return result;
}

/**
  framework use only
**/
function defaultRunConfigForTestCaseEndPoint(){
  return {
      name: 'Test Case End Point'
  }
}

/**

  Returns the default test config info used to validate and fill in missing properties in the test configuration prior to a test run

== Return ==
Object - an array of functions applied to every test in the test case list
**/
function defaultTestConfigInfo(){
  fullyEnableCallStack();
  notImplementedWarning('Only calling default - defaultTestConfigInfo - update this method as required');
  var result = {
    requiredProperties:['id', 'when', 'then', 'owner'],
    enabled: true,
    demo: false,
    countries: 'Australia',
    safeCall: doNothing
  };
  
  ensure(!hasValue(result.path) && !hasValue(result.name) &&
          !_.contains(result.requiredProperties, 'path') && !_.contains(result.requiredProperties, 'name'), 
          'Path and name are reserved by the framework - you cannot use these properties in a testConfig');
          
  return result;
}

/**

A testCaseEndPoint item selector. 

Returns the last item with validators in the testItems list.
This can be useful when working against mock data and developing validators. Just work from top to bottom adding validators to each test item.

Note: THE USER DOES NOT CALL THIS FUNCTION DIRECTLY. It is passed to the framework via testParams and used as a filter by the framework.

== Params ==
item: Object -  Required -  the index of the item
index: Integer -  Required -  the index of the item
allItems: [testItems] -  Required -  all testItems
== Return ==
Object  - a testItem to be run by the testCaseEndPoint (the last item with validators)
**/
function lastItemWithValidators(item, index, allItems){
   return hasValue(item.validators) && 
          (
            index === allItems.length - 1 ||
            !hasValue(allItems[index + 1].validators)
          );
}


/**

A testCaseEndPoint item selector. 

After a test case is run as part of a test run (or as part of a testCaseEndPoint with itemSelector: all) a summary of any test items with errors 
or a toDo property will be written to a text file <Test Case Name> + _Issues.txt in the framework's Temp directory.

If this function is used as an item selector and the <Test Case Name> + _Issues.txt file exists then the testcaseEndPoint will run the first item in this file.

This selector can be used by starting with this file and running each iteration with as issue then deleting it from the top of the file.

**/
function topIssue(){
  throwEx('This function is not intended to be called if it is being used as an item selector it must be used as a function i.e. ' +
  'topIssue not the invocation of the function topIssue()');
}

/**

A testCaseEndPoint item selector. 

Causes all test items (hence test iterations) for a test case to be run inside a testCaseEndPoint. 

**/
function all(){  
  throwEx('This function is not intended to be called if it is being used as an item selector it must be used as a function i.e. ' +
  'all not the invocation of the function all()');
}


/**

Invokes a single iteration of a test case. Used to speed up development. A call to this function from testCaseEndPoint is part of the 
standard test template.

See the Zenith Framework Users' Guide for more information on testcaseEndPoints

== Params ==
params: Object - Required - this is a runConfig object with an additional "itemSelector" and "testConfig" property 
**/
function runTestCaseEndPoint(params){
  
  function topIdFromFile(filePath){
    ensure(aqFileSystem.Exists(filePath), 'Target file does not exist: ' + filePath);
    var content = fileToString(filePath);
    var id = subStrBetween(content, 'item id: ', '-');
    id = trim(id);
    ensure(hasValue(id), 'No id property found in file: ' + filePath);
    return id;
  }
  
  var runConfig = _.omit(params, 'testConfig', 'itemSelector'),
      runConfig = _.defaults(runConfig, defaultRunConfigForTestCaseEndPoint()),
      itemSelector = params.itemSelector,
      testConfig = params.testConfig;
      
  if (itemSelector === topIssue){
    var testName = scriptNameFromId(testConfig.id);
    var filePath = tempFile(issuesFileName(testName, testConfig.id));
    itemSelector = topIdFromFile(filePath);
  }
        
  function id_matches_endpoint_target_test(testName, testConfig, runConfig){
    return testConfig.id === params.testConfig.id;
  }
    
  if (itemSelector === all){
    runConfig.tests = testConfig.id;
    runTests(runConfig, defaultRunConfigInfo(), defaultTestConfigInfo(), [id_matches_endpoint_target_test].concat(testFilters()), null);
  }
  else {
    TestRunnerUtils.runTestCaseEndPoint(
      testConfig, 
      itemSelector, 
      runConfig, 
      defaultRunConfigInfo(), 
      defaultTestConfigInfo());
  } 
}

