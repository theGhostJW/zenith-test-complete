//USEUNIT TestRunner

// this will not run it is for documentation only
function lastItemWithValidatorsEndPoint() {

/* A testCaseEndPoint configured in this way would run 
   the last test item with validators assigned */
 
function testCaseEndPoint(){
  var testParams = {
                    testConfig: TEST_CONFIGURATION,
                    itemSelector: lastItemWithValidators,
                    demo: true, 
                    mocking: true
                   };
  runTestCaseEndPoint(testParams);
}

}

// this will not run it is for documentation only
function topIssueEndPoint() {

/* A testCaseEndPoint configured in this way would run the first file with an issue according to the 
   <Test Case Name> + _Issues.txt file in the framework temp directory */
 
function testCaseEndPoint(){
  var testParams = {
                    testConfig: TEST_CONFIGURATION,
                    itemSelector: topIssue,
                    demo: true, 
                    mocking: true
                   };
  runTestCaseEndPoint(testParams);
}

}

// this will not run it is for documentation only
function allEndPoint() {

/* A testCaseEndPoint configured in this way would run 
   all the test items of the current test case */
 
function testCaseEndPoint(){
  var testParams = {
                    testConfig: TEST_CONFIGURATION,
                    itemSelector: lastItemWithValidators,
                    demo: true, 
                    mocking: true
                   };
  runTestCaseEndPoint(testParams);
}

}

// this will not run it is for documentation only
function runTestCaseEndPointEndPoint() {

/*
  item Id 1 would be run with runConfig properties:
                  {
                    demo: true, 
                    mocking: true
                   }
  plus default runConfig property values.
*/
 
function testCaseEndPoint(){
  var testParams = {
                    testConfig: TEST_CONFIGURATION,
                    itemSelector: 1,
                    demo: true, 
                    mocking: true
                   };
  runTestCaseEndPoint(testParams);
}

}
