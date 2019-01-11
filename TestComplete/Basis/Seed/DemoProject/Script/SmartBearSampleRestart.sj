//USEUNIT SysUtils
//USEUNIT TestRunner
//USEUNIT WebUtils
//USEUNIT CheckUtils
//USEUNIT DemoSmartBearSite


var RESTART_CONFIGURATION = {
  id: -10
}

function rollOver(runConfig, paramStr){
  log('no back end rollover - ' + paramStr);
}

function rollOverEndPoint() {
  var runConfig = defaultRunConfigInfo();
  rollOver(runConfig, '');
}

function goHome(runConfig, paramStr){
  var link = seekInPage({ObjectType: 'Link', contentText: 'View all orders'}, 0);
  if (link.Exists){
    link.Click();
  }
  else {
    logInSmartBear();
  }  
  waitActivePage();
}

function goHomeEndPoint(){
  var runConfig = defaultRunConfigInfo();
  goHome(runConfig, '');
}


function isHome(runConfig, paramStr){
  return hasText(activeUrl(), '/samples/TestComplete10/WebOrders/default.aspx');
}

function isHomeEndPoint() {
  var runConfig = defaultRunConfigInfo();
  var result = isHome(runConfig, '');
}


function close(runConfig, paramStr){
  closeBrowser();
}

function stateChangeEndPoint() {
  var runConfig = defaultRunConfigInfo();
  var paramStr = '';
  var result;
  
  goHome(runConfig);
  result = isHome(runConfig, paramStr);
  check(result);
  
  close(runConfig, paramStr)
}

;(function register(){
  registerTestRunElement(RESTART_CONFIGURATION);
}())
