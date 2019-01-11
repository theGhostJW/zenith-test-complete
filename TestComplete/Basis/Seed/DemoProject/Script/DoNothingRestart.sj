//USEUNIT SysUtils
//USEUNIT TestRunner
//USEUNIT WebUtils
//USEUNIT CheckUtils


var RESTART_CONFIGURATION = {
  id: -9
}

function rollOver(runConfig, paramStr){

}


function rollOverEndPoint() {
  var runConfig = defaultRunConfigInfo();
  rollOver(runConfig, '');
}


function goHome(runConfig, paramStr){
  doNothing();
}


function goHomeEndPoint(){
  var runConfig = defaultRunConfigInfo();
  goHome(runConfig, '');
}


function isHome(runConfig, paramStr){
  return true;
}


function isHomeEndPoint() {
  var runConfig = defaultRunConfigInfo();
  var result = isHome(runConfig, '');
}

function close(runConfig, paramStr){

}

function stateChangeEndPoint() {
  var runConfig = defaultRunConfigInfo();
  var paramStr = '';
  var result;
  
  goHome(runConfig);
  result = isHome(runConfig, paramStr);
  check(result);
  
  close(runConfig, paramStr);
}

(function register(){
  registerTestRunElement(RESTART_CONFIGURATION);
}())

