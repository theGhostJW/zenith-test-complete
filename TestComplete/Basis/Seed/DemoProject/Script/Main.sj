//USEUNIT MainPrivate
//USEUNIT SysUtils
//USEUNIT CheckUtils
//USEUNIT TestRunnerUtils

function demoTestRun(){
  run_THE_COMPANY_NAME_Tests(
                              {
                                name: 'demo Run',
                                demo: true,
                                tests: 'Demo_Test'
                              }
                            );
}

function testTwoTestRuns(){
  run_THE_COMPANY_NAME_Tests(demoConfig);
  run_THE_COMPANY_NAME_Tests(demoConfig);
}

function demoDataDrivenTestRun(){
  run_THE_COMPANY_NAME_Tests(
                              {
                                name: 'Data Driven Tests Demo',
                                tests: ['*Deferr*', '*HOF*'],
                                demo: true
                              }
                            );
}

function demoExtraFilter(){
  run_THE_COMPANY_NAME_Tests(demoConfig, [hasWithDefectInName]);
}

function hasWithDefectInName(testName, testConfig, runConfig){
   return hasText(testName, 'with_defect');
}

function summaryManifest(){
  generateManifest(logItem, doNothing, 'testSummary.txt');
}

function deleteRegenerateBatchFiles(){
  MainPrivate.deleteRegenerateBatchFiles();
}