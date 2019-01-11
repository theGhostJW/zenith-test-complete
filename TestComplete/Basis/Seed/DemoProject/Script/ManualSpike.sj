//USEUNIT ManualSpikeHelper
//USEUNIT TestRunner
//USEUNIT SysUtils
//USEUNIT StringUtils

function config(){return TEST_CONFIGURATION;}
  
var TEST_CONFIGURATION = {
  id: 123,
  when: '',
  then: '',
  owner: 'JW',
  enabled: true
};

function testCase(runConfig,  iteration, params){
      
}

function testCaseEndPoint(){
  runTestCaseEndPoint(configuration);
}

function manualRunner(body, runConfig, testConfig, iteration, params){
  new Function('runConfig, testConfig, testCaseID, iteration, params', body)(runConfig, testConfig, iteration, params);
}

function logIt(msg){
  logItalic(msg)
}

function test(/* hello */){
  return unpackString();
}

function unpackString(){
  var source = arguments.caller;
  var fullStr = source.toString()
}











 
