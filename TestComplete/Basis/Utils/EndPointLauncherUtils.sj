

/** Module Info **

?????_NO_DOC_?????

**/



jw = undefined;

/**

?????_NO_DOC_?????

== Return ==
DATA_TYPE_?????_NO_DOC_????? - DESCRIPTION_?????_NO_DOC_?????
== Related ==
?????_NO_DOC_?????
**/
function getUserFunc(){
  // update to use windows user name on site with a map
  return jw;
}

/**

?????_NO_DOC_?????

== Return ==
DATA_TYPE_?????_NO_DOC_????? - DESCRIPTION_?????_NO_DOC_?????
== Related ==
?????_NO_DOC_?????
**/
function runEndPoint(){
  if (jw === undefined){
    Log.Error('No Default End Point Assigned');
  }
  else {
    callStack = Log.CallStackSettings;
    callStack.EnableStackOnMessage = true;
    callStack.EnableStackOnWarning = true;
    callStack.EnableStackOnError = true;
    callStack.EnableStackOnCheckpoint = true;
    callStack.EnableStackOnEvent = true;
  
    var funcName = getUserFunc().toString();
    funcName = funcName.slice(funcName.indexOf(' '), funcName.indexOf('('));
    
    if (aqString.Find(funcName, 'TestRun') > -1){
      Log.Message(funcName + ' is test run');
    }
    
    var attr = Log.CreateNewAttributes();
    attr.Bold = true;
    Log.Message('Running UnitTest / EndPoint ' + funcName, 
                'Running UnitTest / EndPoint ' + funcName, 
                pmNormal,
                attr);
    getUserFunc()();
    return true
  }
}
