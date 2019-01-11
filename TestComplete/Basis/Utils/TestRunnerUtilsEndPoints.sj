//USEUNIT TestRunnerUtils
//USEUNIT CheckUtils

function expect_defectEndPoint() {
  /* example test item the error encountered in demo_validation_will_fail would be logged as a warning not an error because of expect_defect.
     if another_validation failed this would cause an error to be logged
  */
  function testItems(){
    return [
            {
                id: 5,
                when: '4',
                then: '44',
                message: 'item 3',
                toDo: 'Need to think of some more validation here',
                validators: [
                              expect_defect("that's gotta hurt", true),
                              demo_validation_will_fail,
                              another_validation
                            ]
            }
          ];
  }  
}


function testSubListEndPoint() {
  var result = testSubList('demo3Test', 'DisableddemoTest');
}

function runTestCaseEndPointEndPoint(){
  function startIfNotRunning(){};
  runTestCaseEndPoint({}, 0, startIfNotRunning);
}

function runLastConfigUnitTest(){
  runLastConfig();
}

function runTestsUnitTest(){
  runTests("SelectedTests");
}

// © John Walker 2013 – Permission for unrestricted use and modification granted within 
// THE-COMPANY and affiliated companies