//USEUNIT SysUtils
//USEUNIT SysUtilsParent
//USEUNIT StringUtils
//USEUNIT FileUtils
//USEUNIT DateTimeUtils
//USEUNIT SimplifiedLogUtilsPrivate
//USEUNIT _


/** Module Info **
Provides a function to parse the simplified log generated throughout an outright framework run. Also provide some low level string functions for use 
if you wish to write your own parser for this text.
**/

var simplifiedLog = [];
var simplifiedLogsForPreviousRuns = [];

/**

Creates a zip file of all test case issues summaries.

Can be used to generate a file for emailing at the end of a test

== Params ==
folderPath: String - Optional - Default: the parent folder for the last log created - the source path for the issue summary files 
== Return ==
String - path to the zip file of log summaries
== Related ==
logsDirPath
**/function createIssuesSummaryZip(folderPath){
  folderPath = def(folderPath, logsDirPath(true));
  makeIssuesSummary(folderPath);
  return zipAll(folderPath, '*' + ISSUES_FILE_SUFFIX(), 'issues.zip'); 
}

/**
Framework use only
**/
function inExpectDefect(simplifiedLog){
  var length = simplifiedLog.length;
  var result = false;
  for (var counter = length - 1; counter > -1 ; counter--){
    var str = simplifiedLog[counter];
    if (isEndTest(str) ||
        isStartTest(str) ||
        isDefectEnd(str)){
          result = false;
          break;
      }
      else if (isActiveDefectStart(str)){
        result = true;
        break;
      }
  }
  return result;
}

/**
Framework use only
**/
function UNMET_DEFECT_EXPECTATION_PREFIX(){
  return 'Type 2 Error - Unmet Defect Expectation: ';
}

/**

?????_NO_DOC_?????

== Params ==
str: DATA_TYPE_?????_NO_DOC_????? -  Required -  DESCRIPTION_?????_NO_DOC_?????
== Return ==
DATA_TYPE_?????_NO_DOC_????? - DESCRIPTION_?????_NO_DOC_?????
== Related ==
?????_NO_DOC_?????
**/
function interestingMessage(str){ 
  return isEndTest(str) || isStartTest(str) || isDefectStart(str) || isFilterLog(str) || isDefectEnd(str); 
}

/**
This function is connected to the TestComplete onLogMessage event 
Used by the framework for accumulating the simplified log. See [[http://support.smartbear.com/viewarticle/33041/|Events]] for details
**/
function onLogMessage(Sender, LogParams){
  logThemessage(Sender, LogParams);
}

/**

?????_NO_DOC_?????

== Params ==
Sender: DATA_TYPE_?????_NO_DOC_????? -  Required -  DESCRIPTION_?????_NO_DOC_?????
LogParams: DATA_TYPE_?????_NO_DOC_????? -  Required -  DESCRIPTION_?????_NO_DOC_?????
LogLink: DATA_TYPE_?????_NO_DOC_????? -  Required -  DESCRIPTION_?????_NO_DOC_?????
== Related ==
?????_NO_DOC_?????
**/
function GeneralEvents_OnLogLink(Sender, LogParams, LogLink){
  logThemessage(Sender, LogParams);
}

/**
Framework use only
**/
function logThemessage(Sender, LogParams){
   /* function interestingMessage(str){
    return isEndTest(str) ||
      isStartTest(str) ||
      isDefectStart(str) ||
      isEndDefect; 
  }*/
  
  function unmetDefectExpectationText(simplifiedLog){
    var lastStartDefect = _.findLastIndex(simplifiedLog, isDefectStart),
        lastError = _.findLastIndex(simplifiedLog, isError);
    
    if (lastError === -1 || lastError < lastStartDefect){
      var message = simplifiedLog[lastStartDefect];
      if (hasText(message, ACTIVE_TOKEN() +  'True')){
        message = subStrBetween(message, DEFECT_EXPECTED_TOKEN(), ACTIVE_TOKEN());
        return message;
      }
    }
    else {
      return null;
    }
  }

  var message = LogParams.Str;
  var isEndDefect = isDefectEnd(message);
  
  if (isFilterLog(message)){
    simplifiedLog.push(logTime() + LogParams.AdditionalText);  
  }
  else if (interestingMessage(message)){
    
    if (isEndDefect){
      var unmetExpectationMessage = unmetDefectExpectationText(simplifiedLog);
      simplifiedLog.push(logTime() + message);
      if (hasValue(unmetExpectationMessage)){
        LogParams.Locked = true;
        logError(UNMET_DEFECT_EXPECTATION_PREFIX() + unmetExpectationMessage);
      }
    }
    else {
      simplifiedLog.push(logTime() + message);
    }
    
  }
  
  if (isStartTest(message)){
    pushLogFolder(message, null, false);
    LogParams.Locked = true;
  }
  else if (isEndTest(message)){
    popLogFolder();
    LogParams.Locked = true;
  }
}

/**
This function is connected to the TestComplete onLogError event. 
Used by the framework for accumulating the simplified log. See [[http://support.smartbear.com/viewarticle/33041/|Events]] for details
**/
function onLogError(Sender, LogParams){
  simplifiedLog.push(logTime() + ERROR_PREFIX() + LogParams.MessageText);
  if (inExpectDefect(simplifiedLog)){
    LogParams.Locked = true;
    var attr = Log.CreateNewAttributes();
    attr.BackColor = clYellow;
    attr.FontColor = clRed;
    attr.Bold = true;
    var pic = Sys.Desktop.Picture();  
    var msg = 'Expected Error: ' + LogParams.MessageText;
    var msgExtra = def(LogParams.AdditionalText, msg);
    Log.Warning(msg, msgExtra, pmNormal, attr, pic);
  }
  else {
    callLogErrorWarningEvent(true, Sender, LogParams); 
  }
}

/**
This function is connected to the TestComplete onLogError event. 
Used by the framework for accumulating the simplified log. See [[http://support.smartbear.com/viewarticle/33041/|Events]] for details
**/
function onLogWarning(Sender, LogParams){
  callLogErrorWarningEvent(false, Sender, LogParams);  
}

var errorWarningPostProcessFunction = null;
/**
Framework use only
**/
function callLogErrorWarningEvent(isError, Sender, LogParams){
  if (hasValue(errorWarningPostProcessFunction)){
    errorWarningPostProcessFunction(isError, Sender, LogParams);
  }
}


/**
Framework use only
**/
function onLogErrorEndPoint() {
  logError('before');
  expectDefect('Defeect expected');
  logError('in defect');
  endDefect();
  logError('after'); 
  expectDefect('Defeect expected', false);
  logError('in inactive defect - should be error');
  endDefect();
}


/**
Provides a formatted string representation of the time used in logging
== Return ==
String - a formatted date time string
**/
function logTime(){
  var result = aqConvert.DateTimeToFormatStr(DateTimeUtils.now(),' %d-%b %H:%M:%S: ')
  return result;
}

/**
Determines if a string is a start test token in the simplified log file
== Params ==
str: String -  Required -  the target string
== Return ==
Boolean - true if the string matches the token
**/
function isStartTest(str){
  return hasText(str, START_TEST_TOKEN()) ;
}

/**
Determines if a string is a end test token in the simplified log file
== Params ==
str: String -  Required -  the target string
== Return ==
Boolean - true if the string matches the token
**/
function isEndTest(str){
  return hasText(str, END_TEST_TOKEN());
}

/**
Determines if a string is a defect start token in the simplified log file
== Params ==
str: String -  Required -  the target string
== Return ==
Boolean - true if the string matches the token
**/
function isDefectStart(str){
  return hasText(str, DEFECT_EXPECTED_TOKEN());
}

/**
Determines if a string is an active defect start token in the simplified log file
== Params ==
str: String -  Required -  the target string
== Return ==
Boolean - true if the string matches the token
**/
function isActiveDefectStart(str){
  var result = isDefectStart(str);
  if (result){
    var active = subStrAfter(str, 'Active:');
    active = aqString.Trim(active);
    result = sameText(active, 'true');
  }
  return result;
}

/**
Determines if a string is an inactive defect start token in the simplified log file
== Params ==
str: String -  Required -  the target string
== Return ==
Boolean - true if the string matches the token
**/
function isInActiveDefectStart(str){
  return isDefectStart(str) && !isActiveDefectStart(str);
}

/**
Determines if a string is a defect end token in the simplified log file
== Params ==
str: String -  Required -  the target string
== Return ==
Boolean - true if the string matches the token
**/
function isDefectEnd(str){
  return hasText(str, END_DEFECT_EXPECTED_TOKEN());
}
   
/**
A constant. Represents an error token in the simplified log file
**/
function ERROR_PREFIX(){
  return "ERROR: "
}

/**

A constant. Represents the filter log entry in the simplified log file: 'FILTER LOG: '

== Related ==
isFilterLog
**/
function FILTER_LOG_TOKEN(){
  return 'FILTER LOG'
}

/**
Framework use only
**/
function FILTER_RESULTS_HEADER(){
  return 'Filter Results'
}

/**
Determines if a string is an error token in the simplified log file
== Params ==
str: String -  Required -  the target string
== Return ==
Boolean - true if the string matches the token
**/
function isError(str){
  return hasText(str, ERROR_PREFIX());
}


/**
Determines if a string is an filterLog token in the simplified log file
== Params ==
str: String -  Required -  the target string
== Return ==
Boolean - true if the string matches the token
**/
function isFilterLog(str){
  return hasText(str, FILTER_LOG_TOKEN()) && !hasText(str, 'copied to');
}

/**
Saves the simplified log file to the TestComplete log Directory then runs the
provided function(runConfig, simplifiedLog). Used by the framework.
== Params ==
runConfig: Object -  Required -  The run config object
simpleLogProcessingMethod: function -  Required -  function(runConfig, simplifiedLog)
== Related ==
defaultSimpleLogProcessing
**/
function saveProcessSimplifiedLog(runConfig, simpleLogProcessingMethod) {
  var logDir = logsDirPath(true);  
  var fileName = combine(logDir, nowLogSuffix() + '.log');
  var logStr = arrayToString(simplifiedLog);
  log('Saving simplified log to file: ' + fileName, logStr);
  stringToFile(logStr, fileName);
  simpleLogProcessingMethod(runConfig, simplifiedLog);
}

/**
This function calls a default log processing method which summarises errors in a test run after the test run is finished and 
and writes the result to the TestComplete log - used as a default from Main only
**/
function defaultSimpleLogProcessing(runConfig, arLogEntries){
  // runConfig not in use
  parseSimplifiedLogFileWriteToTestLog(runConfig, arLogEntries);
}

/**
A default simplified log parser.
== Params ==
arLog: [String] -  Required -  a string array representing the simplified log
== Return ==
[String]  - a String array representing a log summary
== Related ==
parseSimplifiedLogFileWriteToTestLog
**/
function parseSimplifiedLogFile(arLog){
  var result = {
    sectionsWithType1ErrorCount: 0,
    sectionsWithType2ErrorCount: 0,
    filterLog: '',
    logedSections: [],
    knownDefectSections: [],
    knownDefects: 0,
    hasErrors: function(){return result.sectionsWithType1ErrorCount > 0 || result.sectionsWithType2ErrorCount > 0},
    summary: function(){
      var t1 = result.sectionsWithType1ErrorCount,
          t2 = result.sectionsWithType2ErrorCount,
          hasErrors = t1  !== 0 || t2 !== 0,
          knownDefects = result.knownDefects,
          hasKnownDefects = knownDefects !== 0;

      var sumResult = !hasErrors && hasKnownDefects ?
                                              'No Errors in Test Run' :
                                              'Type 1 Errors: ' +  t1.toString() + ' - Type 2 Errors: ' + t2.toString() 
                                                + ' - Known Defects: ' + knownDefects.toString(); 
      return sumResult;
    }
  };
  
  var state = {
    inTest: false,
    inError: false,
    expectDefect: false,
    type1Error: false,
    type2Error: false,
    knownDefectsInTest: 0,
    lines: []
  }
  
  function parseLine(str){
    return parseLineUpdateStateAndResult(str, state, result);
  }
  
  function isType2ErrorNotificationOrSummary(str){
    return hasText(str, UNMET_DEFECT_EXPECTATION_PREFIX()) ||
            hasText(str, TEST_SUMMARY_PREFIX());
  }
  
  arLog = _.reject(arLog, isType2ErrorNotificationOrSummary);
  _.each(arLog, parseLine);
  
  updateResultAndResetState(state, result);
  return result;
}

/**
Framework use only
**/
function parseLineUpdateStateAndResult(str, state, result){
  var isTestStart = isStartTest(str);
    
  if (isFilterLog(str)){
    result.filterLog = str
  } else if (!isTestStart){
    state.lines.push(str);
  } 
    
  // error
  if (isError(str)){
    state.inError = true;
    state.type1Error = state.type1Error || !state.expectDefect;
  } 
    
  if (isActiveDefectStart(str)){
    state.inError = false;
    state.expectDefect = true;
  }
    
  if (isDefectEnd(str)){
    state.type2Error = state.type2Error || (state.expectDefect && !state.inError);
    updateKnowDefectCount(state);
    state.inError = false;
    state.expectDefect = false;
  }
    
  if (isTestStart){
    updateResultAndResetState(state, result);
    state.inTest = true;
  }
    
  if (isEndTest(str)){
    updateResultAndResetState(state, result);
    state.inTest = false;
  }
    
  if (isTestStart){
    state.lines.push(str);
  }
}

/**
Framework use only
**/
function updateKnowDefectCount(state){
  if (state.inError && state.expectDefect){
    state.knownDefectsInTest = state.knownDefectsInTest + 1;
  }
}

/**
Framework use only
**/
function updateResultAndResetState(state, result){
  // update result
  if (state.type1Error || state.type2Error){
    var header = state.type1Error && state.type2Error 
        ? '1 & 2 Errors' : state.type1Error ? '1 Error' : '2 Error';
    header = '****** Type ' + header + ' - ' + (state.inTest ? ' In ' : ' Out of ') + 'Test ******';
    var section = [header];
    section = section.concat(state.lines);
    section.push('*********************');
    section.push('');
      
    if (state.type1Error){
      result.sectionsWithType1ErrorCount++;  
    }
      
    if (state.type2Error){
      result.sectionsWithType2ErrorCount++;  
    }
      
    result.logedSections = result.logedSections.concat(section);
  }
  
  updateKnowDefectCount(state);
  if (state.knownDefectsInTest > 0){
    result.knownDefects = result.knownDefects + state.knownDefectsInTest; 
    
    var defectSection = result.knownDefectSections;
    function pushLine(line){
      defectSection.push(line);
    }
    pushLine('***** Known Defect *****');
    _.each(state.lines, pushLine);
    pushLine('*********************');
    pushLine('');
  }
    
  state.inTest = false;
  state.inError = false;
  state.expectDefect = false;
  state.loggedSections =[];
  state.type1Error = false;
  state.knownDefectsInTest = 0;
  state.type2Error = false;
  state.lines = [];
}

/**
Parses a simplified log array and writes it to the TestComplete log
== Params ==
arLog: [String] -  Required -  a string array representing the simplified log
== Return ==
Object - an object that represents the result of parsing the simplified log file the object has the following properties: 
    sectionsWithType1ErrorCount: number of type 1 errors,
    sectionsWithType2ErrorCount: number of type 1 errors,
    logedSections: an array of array of strings representing sections of the log with errors,
    hasErrors: function that returns true if any type 1 or type 2 errors exist in the log,
    summary: a function that returns a string summarising the results
    }
== Related ==
parseSimplifiedLogFile
**/
function parseSimplifiedLogFileWriteToTestLog(runConfig, arLog){
  var result = parseSimplifiedLogFile(arLog);
  var errors = result.hasErrors();
  var sections = result.logedSections.join(newLine());
  var errorText = sections.length > 0 ?  '==== Errors ====' + newLine() 
                                          + sections + newLine(2) 
                                          : '';
                    
  var knownDefectsText = result.knownDefectSections.length > 0 ? 
                          '==== Known Defects ====' + newLine() + result.knownDefectSections.join(newLine()) + newLine(2):
                          '';
        
  var toLog = 
          '==== Run Configuration ===='  + newLine() +
          objectToReadable(runConfig) + newLine(2) + '=== Error Totals ===' + newLine() 
          + result.summary() + newLine(2) + errorText
          + knownDefectsText  
          + '==== Complete Log Summary ====' 
          +  newLine() + _.reject(arLog, isFilterLog).join(newLine())
          +  newLine(2) + '==== Filter Log ===='  
          + subStrAfter(result.filterLog, FILTER_LOG_TOKEN());  
      
  var header, status;      
  if (errors) {
    var attr = Log.CreateNewAttributes();
    attr.Bold = true;
    header = '==== Unexpected Errors in Log: ' + result.summary() + ' ====';
    status = ENUM_ERROR();
  } 
  else if (result.knownDefects > 0) {
    header = '==== Only Expected Defects in Log: ' + result.summary() + ' ====';
    status = ENUM_WARNING();
  }
  else {
    header = '==== No Errors in Log ====';
    status = ENUM_PASS();
  }
  
  toLog = header + newLine(2) + toLog;
  var path = logFilePath('Run Summary.txt', true);
  stringToFile(logDateHeader() + newLine(2) + toLog, path);
  logLink(header, toLog, path, logColourAttributes(status));

  return result;
}

/**
Framework use only
**/
function parseSimplifiedLogFileWriteToTestLogEndPoint() {
  var logArray = fromTestData('simpleLogWitErrors.json');
  parseSimplifiedLogFileWriteToTestLog({country: 'Australia'}, logArray);
}

// © John Walker 2013 – Permission for unrestricted use and modification granted within 
// THE-COMPANY and affiliated companies

