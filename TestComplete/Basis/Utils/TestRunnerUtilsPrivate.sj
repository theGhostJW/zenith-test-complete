//USEUNIT SysUtils
//USEUNIT SysUtilsParent
//USEUNIT StringUtils
//USEUNIT FileUtils
//USEUNIT SimplifiedLogUtils
//USEUNIT CheckUtils
//USEUNIT ReflectionUtils
//USEUNIT DateTimeUtils
//USEUNIT SimplifiedLogUtils
//USEUNIT _
//USEUNIT TestCaseListUtils
//USEUNIT WebUtils
//USEUNIT DateTimeUtils

function MOCK_REPLACE_NONE(){return "No Mock File Replacement"; /*Do not replace test data mock files*/}
function MOCK_ADD_MISSING_REPLACE_FAILED(){return "Replace Mock File for Failed Tests or Missing Files"; /*Replace test data mock files for failed and missing files*/}
function MOCK_REPLACE_ALL(){return "Replace All Mock Files"; /*Replace all test data mock files*/}
function NO_VALIDATION_TOKEN(){return 'Item Has No Validations';}

function executeDeferredLoggingTest(testParams){
  var scriptName = testParams.scriptName,
      runConfig = testParams.runConfig, 
      index = testParams.index, 
      item = testParams.item, 
      scriptId = testParams.scriptId,
      issuesReport = testParams.issuesReport;
 
  try {
    ensure(_.isObject(item), 'All test items must be objects this test item is not an object: ' + scriptName + ' index: ' + index);
 
    var mockInfo =  calculateMockInfo(scriptName, runConfig, item),
                    mockFilePath = mockInfo.path,
                    apState = { details: {}},
                    useMockData = mockInfo.use;

    if (useMockData){
      // italic and bold
      Log.Message('Mocking interactor - using mock file: ' + mockFilePath, 
                  'Mocking interactor - using mock file: ' + mockFilePath,
                   pmNormal,
                   logAttributes(true, true));
      var mockInfo = fileToObject(mockFilePath);
      apState = mockInfo["application state"];
    }
    else if (runConfig.mocking) {
      logBold('No mock file - running interactor');
    }
  
    var interactorFailure = false,
    summaryObject = {
                        resultSaved: trimChars(trim(logTime()), [':']),
                        'test item': _.omit(item, 'validators'),
                        'application state': apState
                      };
      
    if (!useMockData){
      var interactorOutcome = executeInteractor(testParams, apState);
      interactorFailure = interactorOutcome === ROLLOVER_FAIL() || interactorOutcome === GO_HOME_FAIL();
    }

    var result,
        validationInfo = {};
        
    if (interactorFailure){
      result = {
        interactorError: apState
      }
    }
    else {
      // executeValidatorsWithCall is a workaround for TCs crappy exception handling
      summaryObject.validation = validationInfo;
      executeValidatorsWithCall(apState, item, runConfig, validationInfo);
      if (areEqual(validationInfo, {})){
        summaryObject.validation = NO_VALIDATION_TOKEN(); 
      }
    
      if (!useMockData){
        summaryObject = _.omit(summaryObject, 'resultSaved');
      }
    
      var hasErrorsWarnings = hasValue(validationInfo) && validationsContainErrorOrWarnings(validationInfo);
      if (!useMockData){
        saveMockIfRequired(validationInfo, runConfig.mockReplace, mockFilePath, summaryObject, hasErrorsWarnings);
      }
    
      if (hasErrorsWarnings && !isRunnningInInteractiveMode()) {
        var fileName = aqFileSystem.GetFileName(mockFilePath);
        var logPath = logFilePath(fileName, true);
        objectToFile(summaryObject, logPath);
      }
  
      result = summaryObject;
    }
  }
  finally {
    // reset here because exception handling does not work
    SimplifiedLogUtils.errorWarningPostProcessFunction = null; 
    postLog(summaryObject, scriptName, scriptId, item, validationInfo, issuesReport, runConfig);
  }
  
  return result;
}

function SUMMARY_MARKER(){
  return newLine() + '---SUMMARY---' + newLine()
}

function postLog(summaryObject, scriptName, scriptId, item, validationInfo, issuesReport, runConfig){
  // need to do this in case of exceptions
  popLogFoldersToLevel(2);
  
  var summaryState = summaryObject['application state'],
      summaryMainText = TEST_SUMMARY_PREFIX() + scriptName + ' - id: ' + scriptId + ' / item id: ' + item.id + " ===",
      //status and toDos won't work unless run before 
      // prettyUpValidationInfo and prettySummaryObject
      status = statusEnum(summaryObject, false),
      toDos = hasToDos(summaryObject);
   
  summaryObject.summary = callOptionalTestScriptFunction(scriptName, 'summarise', runConfig, item, summaryState); 
  summaryObject = prettyUpValidationInfo(summaryObject, item);
  summaryObject = prettySummaryObject(scriptName, scriptId, summaryObject);

  if (hasValue(issuesReport) && status !== ENUM_PASS()){
    updateIssuesReport(summaryObject, issuesReport);
  }
  
  var summaryPath = logFilePath(scriptName + '_' + scriptId + '_' + def(item.id, 'NO ID') + '.txt', true);
  var summary = summaryText(summaryObject, item, true);
  stringToFile(summary, summaryPath);

  logLink(summaryMainText, summary, summaryPath, logColourAttributes(status));
}

function prettySummaryObject(scriptName, scriptId, summaryObject){
  var item = summaryObject['test item'],
      apState = summaryObject['application state'],
      result = hasValue(summaryObject.resultSaved) ? {'mock result saved': summaryObject.resultSaved} : {};
      
  result = _.extend(result, {
                              path: 'test id: ' + scriptId + ' / item id: ' + item.id +  ' - ' + scriptName,
                              when: item.when,
                              then: item.then,
                              validation: summaryObject.validation
                            }); 
                                
  function apStatePropertytoResult(propName){
    var val = summaryObject['application state'][propName];
    if (hasValue(val)){
      summaryObject['application state'] = _.omit(summaryObject['application state'], propName);
      result[propName] = val;
    }
  }
  
  _.each(['interactor exception', 'interactor errors', 'interactor warnings'], apStatePropertytoResult);
  
  if (hasValue(summaryObject.summary)){
    result.summary = _.isString(summaryObject.summary) ? SUMMARY_MARKER() + summaryObject.summary : summaryObject.summary;
  }
  
  summaryObject['test item'] = _.omit(item, 'when', 'then', 'id');
  summaryObject = _.omit(summaryObject, 'validation', 'resultSaved', 'summary'); 
  
  var details = {};
  function moveDetails(propName){
    var theseDetails = summaryObject[propName].details;
    if (hasValue(theseDetails) && _.keys(theseDetails).length > 0){
      details[propName] = theseDetails;
    }
    summaryObject[propName] = _.omit(summaryObject[propName], 'details');
  }
  
  moveDetails('test item', item);
  moveDetails('application state', item);
  
  var result = _.extend(result, summaryObject);
  
  if (_.keys(details).length > 0){
    result = _.extend(result, {details: details}); 
  }
  return result;
}

function executeValidatorsWithCall(apState, item, runConfig, validationInfo){
  callTestScriptFunction('TestRunnerUtilsPrivate', 'executeValidators', apState, item, runConfig, validationInfo);
}

function executeValidators(apState, item, runConfig, validationInfo){
  var validators = hasValue(item) ? forceArray(def(item.validators, [])) : [];
  validators = activateDefectExpectations(validators);
  
  function executeValidator(accum, validator){
    return exeValidator(accum, validator, apState, item, runConfig);
  }
             
  if (validators.length > 0){
    pushLogFolder('=== Validating ===', null, false, true);
    _.reduce(validators, executeValidator, {result: validationInfo, defectExpectation: null}).result;
    popLogFolder();
  }
  else {
      logItalic(NO_VALIDATION_TOKEN());
  }
}

function activateDefectExpectations(validators){
  
  function wrapInDefectExpectation(expectFunc, validator){
    function wrappedFunction(apState, item, runConfig){
      expectFunc();
      validator(apState, item, runConfig);
      endDefect();
    }
    wrappedFunction.targetFunction = validator;
    return wrappedFunction;
  }
  
  function wrapFuncsWhereRequired(accum, validator){
    var isDefectExpectation = validator.isDefectExpectation;
    if (isDefectExpectation){
      if (accum.length > 0){
        var targetValidator = accum.pop();
        targetValidator = wrapInDefectExpectation(validator, targetValidator);
        accum.push(targetValidator);
      }
      else {
        logError("Error: expect_defect has no effect when it is the last in the list of validators")
      }
    }
    else {
      accum.push(validator);
    }
    return accum;
  }
  
  var result = _.chain(validators)
                    .filter(hasValue)
                    .reduceRight(wrapFuncsWhereRequired, [])
                    .value();
                    
  return result.reverse();
}

function addSectionRowPadding(arLogLines){
  var lastWasDetails = false;
  
  function addLineDividers(str){
    var trimedLine = trim(str);
    var wantLine =  _.contains([
                        'validation:', 
                        'application state:', 
                        'details:', 
                        'test item:',
                        'summary:'
                      ], trimedLine) || startsWith(trimedLine, 'path:');
              
    if (wantLine) {
      if (lastWasDetails) {
        lastWasDetails = false; 
        wantLine = false;
      }
      else if (trimedLine === 'details:'){
         lastWasDetails = true; 
      }
    }
    
    return wantLine ? newLine() + str: str;
  }
  
  return _.chain(arLogLines)
          .map(addLineDividers)
          .value();
}

function summaryText(summaryObject, item, wantHeader){
  var indentLength = 3,
      indent = repeatString(' ', 3),
      result = objectToReadable(summaryObject, indent).split(newLine()),
      result = hasValue(trim(result[0])) ? result : result.slice(1);

  function trimOneIndent(str){
    return str.slice(indentLength);
  }
  
  result = _.chain(result)
            .map(trimOneIndent)
            .value();

  result = addSectionRowPadding(result);
  result = hasValue(summaryObject.summary) && _.isString(summaryObject.summary) ? removeSummaryMarker(result) : result;
  return (wantHeader ? logDateHeader() + newLine() : '') + result.join(newLine());
}

function removeSummaryMarker(lines, scanWholeFile){
  scanWholeFile = def(scanWholeFile, false);
  var result = [],
      summaryHit = false,
      markerRemoved = false,
      TRIMMED_MARKER = trimWhiteSpace(SUMMARY_MARKER());
  
  function processLine(line){
    if (markerRemoved || !summaryHit) {
     result.push(line);
    }
    
    if (!summaryHit && trimWhiteSpace(line) === 'summary:'){
      summaryHit = true;    
    }
    else if (summaryHit && !markerRemoved && hasText(line, TRIMMED_MARKER, true)){
      markerRemoved = true;
    }
    else if (scanWholeFile && markerRemoved){
       markerRemoved = false;
       summaryHit = false;
    }
  }
  
  _.each(lines, processLine);
  return result;
}

function saveMockIfRequired(validationInfo, fileBehaviour, mockFilePath, summaryObject, hasErrorsWarnings) {
  ensure(hasValue(fileBehaviour), 'mock file replacement behaviour is undefined');
  var wantMockSaved =  fileBehaviour === MOCK_REPLACE_ALL() ||
                        (
                          fileBehaviour === MOCK_ADD_MISSING_REPLACE_FAILED() &&
                          (hasErrorsWarnings || !aqFileSystem.exists(mockFilePath))
                        );
  if (wantMockSaved){
    objectToFile(summaryObject, mockFilePath);
  }
}

function ROLLOVER_SUCCESS(){return 'Rollover Success';}
function ROLLOVER_FAIL(){return 'Rollover Failed';}
function GO_HOME_SUCCESS(){return 'Go Home Success';}
function GO_HOME_FAIL(){return 'Go Home Failed';}
function INTERACTOR_EXECUTED(){return 'Interactor Executed';}

function executeInteractor(testParams, apState){
  var scriptName = testParams.scriptName,
      runConfig = testParams.runConfig, 
      item = testParams.item, 
      index = testParams.index, 
      rollover = testParams.rollover,
      goHome = testParams.goHome;
   
  // we can only try once as the passed in function will be wired to run only once anyway
  var result = retry(rollover, 1, ROLLOVER_SUCCESS(), ROLLOVER_FAIL());
    
  if (result === ROLLOVER_SUCCESS()){
    result = retry(goHome, 3, GO_HOME_SUCCESS(), GO_HOME_FAIL());
    if (result === GO_HOME_SUCCESS()){
      pushLogFolder('=== Reading Application State ===', null, false, true);
      var interactorErrorsAndWarnings = {errors: [], warnings: []}
      SimplifiedLogUtils.errorWarningPostProcessFunction = makeLogErrorsOrWarningsFunction(interactorErrorsAndWarnings);
      try {
        var passedInApState = _.clone(apState);
        var returnedApState = callTestScriptFunction(scriptName, 'interactor', runConfig, item, passedInApState);
        var finalApState = def(returnedApState, passedInApState); 
        _.extend(apState, finalApState);
        result = INTERACTOR_EXECUTED();
      }
      catch(e){
        var eString = objectToReadable(e);
        eString = 'Note: Due to issues with JScript error handling sometimes the wrong error message can be reported here.' 
                  + 'Check TestComplete logs carefully for the correct exception.' + newLine() + 'Exception:' + newLine() + eString;
        apState['interactor exception'] = eString;
        throwEx(eString);
      }
      finally {
        SimplifiedLogUtils.errorWarningPostProcessFunction = null;
      }
      
      var iteractorErrors = interactorErrorsAndWarnings.errors,
          iteractorWarnings = interactorErrorsAndWarnings.warnings;
      
      if (iteractorErrors.length > 0){
        apState['interactor errors'] = errorWarningString(iteractorErrors);
      }
      
      if (iteractorWarnings.length > 0){
        apState['interactor warnings'] = errorWarningString(iteractorWarnings);
      }
      
      popLogFolder();
    }
  }
  return result;
}

function errorWarningString(arr){
  return arr.join(newLine());
}

function makeLogErrorsOrWarningsFunction(interactorErrorsAndWarnings){
  function logErrorOrWarning(isError, Sender, LogParams){
    if (isError) {
      interactorErrorsAndWarnings.errors.push(LogParams.MessageText);
    }
    else {
      interactorErrorsAndWarnings.warnings.push(LogParams.MessageText);
    }
  }
  return logErrorOrWarning;
}

function retry(func, retryCount, resultOnSuccess, resultOnFailure){

  var attemptCount = 0,
      funcName = functionNameFromFunction(func),
      result = resultOnFailure;
      
  function tryFunction(){
    try {
      attemptCount++;
      func();
      result = resultOnSuccess;
    }
    catch (e) {
      logError('Attempt ' + attemptCount + ' of ' + retryCount + '. ' + resultOnFailure + ': ' + funcName, objectToJson(e));
    }
  }
  
  do {
    tryFunction();
  } while (result !== resultOnSuccess && attemptCount < retryCount);
  
  return result;
}

function retryEndPoint() {
  var fails = 3;
      
  
  function doMe(){
    invokeCount++;
    if (invokeCount > fails){
      logCheckPoint('And now I pass')
    }
    else {
      throw('This time I fail');
    }
  }
  
  var invokeCount = 0;
  var result = retry(doMe, 1, 'I Passed', 'I Blew It');
      invokeCount = 0;
      result = retry(doMe, 2, 'I Passed', 'I Blew It');
      invokeCount = 0;
      result = retry(doMe, 3, 'I Passed', 'I Blew It');
      invokeCount = 0;
      result = retry(doMe, 4, 'I Passed', 'I Blew It');
  
}

// returns path
function calculateMockInfo(testScriptName, runConfig, item){
  var mockFilePath = getMockPath(testScriptName, item, runConfig);
  result = {
    path: mockFilePath,
    use: runConfig.mocking && aqFileSystem.Exists(mockFilePath)
  };
 return result;
}

function prettyUpValidationInfo(summaryObject, item){
  function reformatValidation(accum, val, name){
    if (sameText(name, 'defectExpectation')){
      // skip this property
      return accum;
    }
    else if (_.isString(val)){
      accum[name] = val;
    }
    else {
      accum[name] = _.reduce(val, reformatValidationItem, {});
    }
    return accum;
  }
  
  var validation = summaryObject.validation;
  summaryObject.validation = sameText(validation, NO_VALIDATION_TOKEN()) ? 
                                  validation: 
                                  _.reduce(validation, reformatValidation, {});
                               
  return summaryObject;
}



function reformatValidationItem(accum, val){
  var thisType = val.type,
      index = getIndex(thisType, accum),
      propName = lowerCase(thisType + ' ' + index),
      message = trimWhiteSpace(val.message),
      additionalText = trimWhiteSpace(val.additionalText);

  if (hasValue(additionalText) && 
      !sameText(message, additionalText) &&
      //check function message is: Check - .... additional text is: Check ...
      !sameText(replace(message, ' -', ''), additionalText)){
    accum[propName] = {
                        message: message,
                        additionalText: additionalText
                      };
  }
  else {
    accum[propName] = message;
  }
  return accum;
}

function getIndex(type, result){
  function startsWithType(str){
    return startsWith(str, type);
  }
  
  var result = _.chain(result)
                .keys()
                .filter(startsWithType)
                .value()
                .length;

  return result + 1;
}


function validationsContainWarnings(validationInfo){
   return validationsContains(validationInfo, arrayContainsWarnings);
}

function validationsContainErrors(validationInfo){
   return validationsContains(validationInfo, arrayContainsErrors);
}

function validationsContainErrorOrWarnings(validationInfo){
   return validationsContains(validationInfo, arrayContainsErrorOrWarning);
}

function validationsContains(validationInfo, predicate){
   return _.chain(validationInfo)
                    .values()
                    .some(predicate)
                    .value();
}

function ERROR_TOKEN(){return 'error'}
function WARNING_TOKEN(){return 'warning'}

function arrayContainsErrorOrWarning(arr){
  return arrayContainsErrors(arr) ||
               arrayContainsWarnings(arr);
}

function arrayContainsErrors(arr){
  function itemIsError(item){
    return sameText(item.type, ERROR_TOKEN())
  }
  return _.isArray(arr) &&
               _.some(arr, itemIsError);
}

function arrayContainsWarnings(arr){
  function itemIsWarning(item){
    return  sameText(item.type,  WARNING_TOKEN())
  }
  return _.isArray(arr) &&
               _.some(arr, itemIsWarning);
}

function getMockPath(scriptName, item, runConfig){
  var name = callOptionalTestScriptFunction(scriptName, 'mockFileNameNoExtension', item, runConfig);

  if (!hasValue(name)){
    var id = 0;
    if (hasValue(item)){
      id = item.id;
      ensure(hasValue(id), 'Test items must have an id property');
    }
    name = 'mock_' + scriptName + '_' + id + '.json';
  }
  return mockFile(name);
}

function functionNameFromValidatorFunction(validator){
  return hasValue(validator.targetFunction) ? 
          functionNameFromFunction(validator.targetFunction):
          functionNameFromFunction(validator);
  
}

function exeValidator(validationInfo, validator, apState, params, runConfig){
  var result = validationInfo.result;
  var defectExpectation = validationInfo.defectExpectation;
  validationInfo.defectExpectation = null;
  
  var functionName = def(replace(functionNameFromValidatorFunction(validator), '_', ' '), 'unnamed validator');
  var idx = 0;
  while (hasValue(validationInfo[functionName])) {
    functionName = functionName + idx;
    idx++;
  }
  
  var validationResults = [];
  var errorOrWarningLogged = false;
  function processErrorOrWarning(isError, Sender, LogParams){
    errorOrWarningLogged = true;
    var errorInfo = {
                      type: isError ? ERROR_TOKEN(): WARNING_TOKEN(),
                      message: LogParams.MessageText
                    };

    if (LogParams.MessageText !== LogParams.AdditionalText){
      var extraText = replace(LogParams.AdditionalText, newLine(), ' ');
      var MAX_EXTRA_TEXT_LENGTH = 250;
      if (extraText.length > MAX_EXTRA_TEXT_LENGTH){
        extraText = extraText.slice(0, MAX_EXTRA_TEXT_LENGTH) + '...';
      }
        
      if (LogParams.MessageText !== extraText){
        errorInfo.additionalText = extraText; 
      }
    }
    validationResults.push(errorInfo);
  }

  var hasDefect = hasValue(defectExpectation);
  SimplifiedLogUtils.errorWarningPostProcessFunction = processErrorOrWarning;
  try {
    if (hasDefect){
      defectExpectation();
    }
    
    // the actual validator may be wrapped in a defect expectation
    var trueValidator = hasValue(validator.targetFunction) ? validator.targetFunction: validator;
    pushLogFolder(replace(functionNameFromFunction(trueValidator), '_', ' '));
    // note exception handling will not work here due to a TC / JSScript bug
    var exceptionInfo = {
                      type: ERROR_TOKEN(),
                      message: 'Exception thrown in validator. See TestComplete log for details'
                    };
    var exceptionalResults = forceArray(exceptionInfo);
    result[functionName] = exceptionalResults; 
    validator(apState, params, runConfig);
    popLogFolder();
      
    if (hasDefect){
      endDefect();
    } 
    result[functionName] = errorOrWarningLogged ? validationResults : 'passed';
  }
  finally {
    SimplifiedLogUtils.errorWarningPostProcessFunction = null;
  }
  return validationInfo;
}

function statusEnum(summaryObject, treatToDoAsWarning){
  function hasSummaryProp(propName){
    return hasValue(seekInObj(summaryObject, propName));
  }

  treatToDoAsWarning = def(treatToDoAsWarning, true);
  var validation = summaryObject.validation, //forceArray(summaryObject.validation)
      errors = validationsContainErrors(validation) || 
               hasSummaryProp('interactor errors') || 
               hasSummaryProp('interactor exception');
             
    var warnings = hasSummaryProp('interactor warnings') ||
                   validationsContainWarnings(validation);
    
  return errors ? ENUM_ERROR() : (warnings || (treatToDoAsWarning && hasToDos(summaryObject))) 
                                  ? ENUM_WARNING() : ENUM_PASS();
}

function hasToDos(summaryObject){
  var item = summaryObject['test item'];
  return hasValue(def(item.toDo, item.todo));
}

function updateIssuesReport(summaryObject, issuesReport, status, toDos){
  if (status !== ENUM_PASS() || toDos){
    // force includeReason to the top
    var reportItem =  {
                        issue: appendDelim((status !== ENUM_PASS() ? 'ERRORS / WARNINGS': ''), ' AND ',  (toDos ? 'TO DO': ''))
                      };
    reportItem = _.extend(reportItem, summaryObject);
    issuesReport.push(reportItem);
  }
}

var configInfo = [];
function registerTestRunElement(testRunElementFunction){
  configInfo.push(testRunElementFunction);
}

var scriptsRestarts = null;
function testScriptsAndRestarts(){
  if (!hasValue(scriptsRestarts)){
    scriptsRestarts = filter(scriptFilesInProject(), function(item){return isRestart(item.name) || endsWith(item.name, '_Test')});
  }
  return scriptsRestarts;
}

var testRunItemsSingletonVar = null;
function testRunItems(){
  if (!hasValue(testRunItemsSingletonVar)){
    var scripts = scriptFilesInProject();
    var idToName = runItemIdToNameMapWithDuplicateIdsRemoved(); 
    
    function updateWithName(config){
      var id = config.id;
      config.name = def(idToName[id], null);
      return config;
    }
    
    var configMap = _.chain(configInfo)
                    .map(updateWithName)
                    .reject(noName)
                    .indexBy('name')
                    .value();
    
    function addConfig(scriptItem){
      var config = def(configMap[scriptItem.name], {});
      return _.defaults(scriptItem, config);
    }
    
    var testRunItemsSingletonVar = _.chain(testScriptsAndRestarts())
                                      .map(addConfig)
                                      .indexBy('name')
                                      .value();
  }
  return testRunItemsSingletonVar;
}

function noName(config){
  return !hasValue(config.name);
}

var idToNameMapSingleton = null;
function runItemIdToNameMapWithDuplicateIdsRemoved(validateTestItemsOnMissingId){
  /*
    cachedInfo:  [
         {
                 name: 
                 path: 
                 id: 
                 dateRead: 
         }
    ]
   runItems: [
         {
                 name: 
                 path: 
         } .......
    ]
  */
  validateTestItemsOnMissingId = def(validateTestItemsOnMissingId, true);
  if (hasValue(idToNameMapSingleton)){
    return idToNameMapSingleton;
  }
  
  var ID_CACHE_FILE_NAME = 'ids.json';
  var cachePath = tempFile(ID_CACHE_FILE_NAME),
        cachedInfo = aqFileSystem.Exists(cachePath) ? fileToObject(cachePath) : {},
        runItems = testScriptsAndRestarts();
        
  var runItemNames = itemNames(runItems, true);
                                                    
  function notInProject(item){
    return _.indexOf(runItemNames, item.name, true) === -1;
  }
  
  var runItemLookup = _.indexBy(runItems, 'name')
   
  function updatePathAndDateReadFromRunItems(pathInfo){
    var lookUpItem = runItemLookup[pathInfo.name];
    if (pathInfo.path !== lookUpItem.path){
      pathInfo.path = lookUpItem.path;
      pathInfo.dateRead = 0;
    }
    return pathInfo;
  }
  
  function updateIdFromFileIfChanged(item){
    var fileInfo = aqFileSystem.GetFileInfo(item.path);
    if (tcDateTimeToInt(fileInfo.DateLastModified) !== def(item.dateRead, 0)){
      item.id = testItemId(item.name, item.path);
      // work around for json not serialising TC dates
      item.dateRead = tcDateTimeToInt(now()); 
    }
    return item;
  }
  
  cachedInfo = _.chain(cachedInfo)
                    .reject(notInProject)
                    .map(updatePathAndDateReadFromRunItems)
                    .map(updateIdFromFileIfChanged)
                    .value();
   
  var chachedInfoNames = itemNames(cachedInfo, false);                                   
  var newItems = _.difference(runItemNames, chachedInfoNames);
  
  function makeNewItem(scriptName){
    var item = runItemLookup[scriptName];
    return  {
               name: item.name,
               path: item.path, 
               id: null,
               dateRead: 0
            }
  }
  
  var newInfo = _.chain(newItems)
                  .map(makeNewItem)
                  .map(updateIdFromFileIfChanged)
                  .value();
                  
  var allInfo = cachedInfo.concat(newInfo);
  
  if (isRunnningInInteractiveMode()){
    updateNullIdsAndThrow(allInfo, validateTestItemsOnMissingId);
  }
  
  // save the updated file
  objectToFile(allInfo, cachePath);
  
  function addMapItem(accum, fileInfo){
    var duplicates = accum.duplicates,
        result = accum.result,
        id = fileInfo.id;
      
      // skip unassigned 
      if (hasValue(id)){
        if (hasValue(result[id])){
          duplicates.push(fileInfo);
          if (_.isObject(result[id])){
            duplicates.push(
              {
                name: result[id].name,
                id: id
              }
            );
            result[id] = 'N/A - DUPLICATE'
          }
        }
        else {
          result[id] = fileInfo.name;
        }
      }
      return accum;  
  }
  
  var accum = _.reduce(allInfo, addMapItem, {duplicates:[], result: {}}),
      duplicates = accum.duplicates,
      result = accum.result;
    
  if (duplicates.length > 0){
    duplicates = _.map(duplicates, function(obj){return _.pick(obj, 'name', 'id');})
    logError('Duplicate test / restart ids detected - see Addidtional Information for details',
      'The easiest way to fix this is to update from version control, set these values to null and run any testCaseEndPoint.' +
      'This will update the Ids. Then check into version control immediately' + newLine(2) + 
      'Note this exception is only raised if running interactively. When running from a *.bat file only an error is logged'
       + newLine(2) + 
      objectToJson(duplicates));
    ensure(!isRunnningInInteractiveMode(), 'Please fix duplicate ids'); 
    result = _.omit(result, _.pluck(duplicates, 'id'));
  }

  idToNameMapSingleton = result;
  return result;
}

function updateNullIdsAndThrow(allItemInfo, validateTestItemsOnMissingId){
  validateTestItemsOnMissingId = def(validateTestItemsOnMissingId, true);
  var initialMax = def(_.chain(allItemInfo)
                        .pluck('id')
                        .max()
                        .value(),
                        0
                      );
  
  function idIsNull(itemInfo){
    var result = !hasValue(itemInfo.id);
    return result;
  }
  
  var newMax = _.chain(allItemInfo)
                .filter(idIsNull)
                .reduce(setAndReturnId, initialMax)
                .value();
                
  if (validateTestItemsOnMissingId && (newMax !== initialMax)){
    validateTestItems()
  }
         
  ensure(newMax === initialMax, 'Script or restart Ids updated');
}

function setAndReturnId(currentMax, itemInfo){
  var nextId = currentMax + 1,
    path = itemInfo.path,
    name = itemInfo.name;
    
  var content = fileToString(path);
  content = updateScriptWithId(content, nextId, name);
  stringToFile(content, path);
  logError('Script file ' + name  + ' has been updated with id - If TestComplete does not auto-reload please <Right Click><Reload> this script from the project workspace.');
  return nextId;
}

function itemNames(namedObjects, sorted){
  var result = _.pluck(namedObjects, 'name');
  return sorted ? result.sort() : result;         
}

function testItemId(name, path){
  var content = fileToString(path);
  
  content = hasText(content, 'TEST_CONFIGURATION') ?
                              subStrAfter(content, 'TEST_CONFIGURATION') :
                              subStrAfter(content, 'RESTART_CONFIGURATION');
                              
  var result = subStrBetween(content, 'id', newLine());
  result = trimChars(trimWhiteSpace(result), [',',':']);
  result = _.isNaN(parseInt(result)) ? null: parseInt(result);
  return result;
}

function testItemIdEndPoint() {
  var id = testItemId('demo_Arrray_Data_Driven_Test', testDataFile('Demo_Excel_Data_Driven_Test.sj'));
  id = testItemId('SmartBearSampleRestart' , testDataFile('DoNothingRestart.sj'));
}

function chachedIds(currentFiles){

  var deletedFiles = _.chain(result)
                      .keys()
                      .difference(currentFiles)
                      .value();
                      
  return _.omit(result, deletedFiles);
}

function updateScriptWithId(content, nextId, scriptName){
  var ID_TOKEN = 'id:'
  var parts = bisect(content, ID_TOKEN);
  var prefix = parts[0];
  var suffix = parts[1];
  
  ensure(hasValue(prefix) && hasValue(suffix), 'Configuration declaration error - the string id was not found in the configuration of script: ' + 
                                                scriptName + ' as expected. This should be in the first row of the configuration');
  var idexOfComma = suffix.indexOf(','),
      idexOfNewLine = suffix.indexOf(newLine());
  var delim =  idexOfComma === -1 || idexOfComma <  idexOfNewLine ? ',' : newLine();
  
  suffix = ID_TOKEN + ' ' + nextId + delim + subStrAfter(suffix, delim);
  return prefix + suffix;
}

function updateScriptWithIdUnitTest() {
  var src = testDataString('scriptWithNoId.txt');
  src = updateScriptWithId(src, 123);
  checkContains(src, 'id: 123,');
}

function itemFromDataSource(arDataSource, item, id, runConfig){
  ensure(hasValue(arDataSource), 'A non-zero itration can only be specified for data driven tests');
  
    // change strings or objects to function predicates
  var itemFunc = _.isFunction(item) ? item:
                _.isObject(item) ? 
                makeIsEqualFunction(item):
                makeIsEqualFunction({id: item});

  var result = _.findIndex(arDataSource, itemFunc);   

  if (result < 0){
    logError('There is no item in the testItems list that matches the itemSelector in the testCaseEndPoint - see link in next log for available testItems');
    toTemp(arDataSource, 'Available Test Items');
    throwEx('There is no item in the testItems list that matches the itemSelector in the testCaseEndPoint');
  }  
  return result;
}

function makeIsEqualFunction(criteria){
  function equalsCriteria(obj){
     if (obj === criteria) return true; //avoid comparing an object to itself.
     for (var key in criteria) {
      if (!areEqual(criteria[key], obj[key])){
        return false;
      }
     }
     return true;
  }
  return equalsCriteria;
}

function makeStringMatchFunctionWithTrim(item){
  var searchString = trim(item);
  function stringMatches(str){
    return trim(str) === searchString;
  }
  return stringMatches;
}

function itemFromDataSourceUnitTest() {
  function dataSource(){
     return [1,2,3,4,5,6,7];
  }
  
  function item(params){
    return params > 5
  }
  
  var result = itemFromDataSource(dataSource(), item);
  checkEqual(5, result);
}

function scriptNameFromId(id){
  var result = runItemIdToNameMapWithDuplicateIdsRemoved()[id];
  ensure(hasValue(result), 'No test script of id: ' + id + ' found. Note this error can be caused by a test file not being named with _Test suffix or a restart not beign named with _Restart.');
  return result;
}

function scriptNameFromIdEndPoint() {
  var scriptName = scriptNameFromId(-5);
}

function convertToTestName(val){
    var parsedVal = parseInt(val);
    var result = _.isNaN(parsedVal) ?
            val :
            scriptNameFromId(parsedVal);
    return result;
}

function latestConfigFilePath(){
  return tempFile('latestConfig.json')   
}
  
function runFromConfig(runConfig, defaultRunConfigInfo, defaultTestConfigInfo, testFilters, simpleLogProcessingMethod,  testOverrideFunc, preTestRunFunction){
  ensure(hasValue(testFilters), 'testFilters undefined');
  preTestRunFunction = def(preTestRunFunction, doNothing);
  // save runConfig to last runConfig file
  var cfgString = objectToReadable(runConfig);
  if (!hasValue(runConfig.name)){
    logError('Run config has no "name" property - all run configs should be named', cfgString);
  }
  
  objectToFile(runConfig, latestConfigFilePath(), projectScriptFileEncoding());
  validateAndSetDefaultConfigProperties(runConfig, defaultRunConfigInfo, CONFIGURATION_TYPE.RUN_CONFIG);
  var targetBrowserName = runConfig.targetBrowserName;
  ensure(hasValue(targetBrowserName), 'targetBrowserName property must be included in the defaultRunConfigInfo');
  setTargetBrowserName(targetBrowserName); // For X-browser testing
  
  var testList = validateGenerateTestList(runConfig, testFilters, defaultTestConfigInfo);
  
  preTestRunFunction(runConfig, testList);
  runTestList(testList, runConfig, defaultTestConfigInfo, simpleLogProcessingMethod, testOverrideFunc);
}

var CONFIGURATION_TYPE = {
  RUN_CONFIG: 'RUN_CONFIG',
  TEST_CONFIG: 'TEST_CONFIG'
}

// updates ie mutates the run config
function validateAndSetDefaultConfigProperties(config, defaultConfig, configType,  wantThrow){
  wantThrow = def(wantThrow, isRunnningInInteractiveMode());
  

  var requiredProperties = def(defaultConfig.requiredProperties, []);
  var defaultConfigNoRequiredProps = _.omit(defaultConfig, 'requiredProperties')
  var permittedKeys = _.keys(defaultConfigNoRequiredProps).concat(requiredProperties);
  var actualKeys = _.keys(config);
  
  var errors = [];
  
  if (hasValue(requiredProperties)){
    var missingRequired = _.difference(requiredProperties, actualKeys);
    if (missingRequired.length > 0){
      errors.push('The following required properties have not been defined in the config file: ' + missingRequired.join(', ') + '.');
    }
  }
  
  var extraKeys = _.chain(actualKeys)
                     .difference(permittedKeys)
                     .without('path', 'name') // these are added by the framework
                     .value()
                      
  if (extraKeys.length > 0){
    errors.push('The following properties are present in the configuration which are neither in the ' +
    'required properties list or have defaults assigned: ' + arrayToString(extraKeys) +  
    '. You may need to update the default configuration object. ' +
    'To update a  defaultRunConfigInfo function in the TestRunner script ');
  }
    
  if (errors.length > 0){
    var errorPrefix = configType === CONFIGURATION_TYPE.RUN_CONFIG ? "Run Configuration" : "Test Configuration";
    var errorMessage = 
      errorPrefix + newLine() 
        + 'Configuration Errors Found: ' + newLine() 
        + arrayToString(errors) + newLine() + newLine() 
        + "-- Configuration Object --" + newLine()
        + objectToJson(config) + newLine() + newLine() 
        + "-- Default Configuration Object --" + newLine() 
        + objectToJson(defaultConfig);
     
    if (configType !== CONFIGURATION_TYPE.RUN_CONFIG) {
      errorMessage = errorMessage + newLine() + 'NOTE: CHECK THIS FILE IS NOT MISSING ITS REGISTRATION FUNCTION BLOCK AT THE BOTTOM OF THE FILE '+
                    '- MISSING REGISTRATION BLOCKS HAVE BEEN KNOWN TO CAUSE THIS ERROR'
    }
      
    if (wantThrow){
      throwEx(errorMessage);
    }
    else {
      logError(errorMessage);
    }
  }
  
  _.defaults(config, defaultConfigNoRequiredProps); 
  return config;
}

function validateAndSetDefaultConfigPropertiesEndPoint() {
  var config = {
    name: "configName"
  }
  
  var defaultConfig = {
    requiredProperties: ['name'],
    enabled: true
  }
  
  validateAndSetDefaultConfigProperties(config, defaultConfig, CONFIGURATION_TYPE.RUN_CONFIG);
  checkEqual({ name: "configName", enabled: true }, config);
  
  config = {
    enabled: false
  };
  
  expectDefect(1);
  validateAndSetDefaultConfigProperties(config, defaultConfig, CONFIGURATION_TYPE.RUN_CONFIG, false);
  endDefect();
  
  config = {
    name: "Hello",
    smoke: true,
    enabled: false
  };
  
  expectDefect(1);
  // smoke has no default
  validateAndSetDefaultConfigProperties(config, defaultConfig, CONFIGURATION_TYPE.RUN_CONFIG, false);
  endDefect();
  
    config = {
    smoke: true,
    other: null,
    enabled: false
  };
  
  expectDefect(1);
  // smoke, other has no default - no name
  validateAndSetDefaultConfigProperties(config, defaultConfig, CONFIGURATION_TYPE.RUN_CONFIG, false);
  endDefect();
  
  // should throw because being run interactive
  config = {
    enabled: false
  };
  expectDefect(1);
  validateAndSetDefaultConfigProperties(config, defaultConfig, CONFIGURATION_TYPE.RUN_CONFIG);
  
}



// gets last config or returns default runConfig object
function getLastRunConfig(){
  var fullPath = latestConfigFilePath();
  var result;
  if (aqFile.Exists(fullPath)) {
    var config = fileToString(latestConfigFilePath(), projectScriptFileEncoding());
    result = jsonToObject(config);
  }
  else {
    log('No last config file - using default');
    result = {};
  }
  return result;
}

function getId(scriptName){
  var testConfig = getConfig(scriptName);
  return testConfig.id;
}

function getIdEndPoint() {
  var testCases = getId('demo3Test');
  checkEqual([2, 3], testCases); 
}

//Calls test script function supresses exception when function does not exist
function callOptionalTestScriptFunction(configOrScriptName, functionName, params){
  var result = null;
  try {
    result = callTestScriptFunction.apply(null, _.toArray(arguments));
  }
  catch (e) {
    if (!isNoElementException(e)){
      throwEx(e.message);
    }
  }
  return result;
}

function callOptionalTestScriptFunctionEndPoint() {
  var result = callOptionalTestScriptFunction('demo_Test', 'testData', {});
  result = callOptionalTestScriptFunction('demo_Test', 'badFuncName', {});
}

function callTestScriptFunction(configOrScriptName, functionName, params){
  /*
    Calling test script functions has been factored into this function to simplify deprication of 
    TestRunner.CallMethod if and when it is needed - TestRunner.CallMethod is marked as Obsolite
  
    If it stops working will need to add testcase and restart methods as properties of all TestCase and 
    restart config objects by updating the register function as follows or similar:
  
    ;(function register(){
  
    function makeSafeCall(func){
        function safeCall(args){
          var result = null;
          var args = _.toArray(arguments);
          try {
            result = func.call(null, args); 
          }
          catch (e) {
            logError('something failed', objectToJson(e));
            result =  {
                        failed: true,
                        exception: e
                      };  
          }
          return result;
        }
        return safeCall;
      }
  
      TEST_CONFIGURATION.testCase = makeSafeCall(testCase);
      registerTestRunElement(TEST_CONFIGURATION);
    }())
  
    and changing exception handling to checking if (def(result, {}).failed) {... } else {...}
 
    Note as at TC10 - excptions are not handled properly when raised from functions in passed in from other units so the makeSafeCall code
    will need to be added to EVERY script / restart unit NOT a shared function because exception handling only works inside the same script
  
    This will also not show you a nice call stack on exception like using TestRunner.CallMethod - another alternative might be to let the 
    exception stop the test run then have a supervisor restart the testrun - this would require the current item be logged
  
    could also look at using a dynamically created Object driven test
  
    For now we stick with TestRunner.CallMethod because this is much simpler and gives us a full callstack 
  */
  var scriptName = _.isString(configOrScriptName) ? configOrScriptName : configOrScriptName.name; 
  scriptName = hasValue(scriptName) ? scriptName : scriptNameFromId(configOrScriptName.id);
  var complexName = scriptName + '.' + functionName;
  var args = _.toArray(arguments);
  args = args.length > 2 ? _.rest(args, 2) : [];
  
  // runner.Callmethod does not behave as a js function so we can't use apply
  switch (args.length) {
    case 0 : return Runner.CallMethod(complexName);
    case 1 : return Runner.CallMethod(complexName, args[0]);
    case 2 : return Runner.CallMethod(complexName, args[0], args[1]);
    case 3 : return Runner.CallMethod(complexName, args[0], args[1], args[2]);
    case 4 : return Runner.CallMethod(complexName, args[0], args[1], args[2], args[3]);
    case 5 : return Runner.CallMethod(complexName, args[0], args[1], args[2], args[3], args[4]);
    default:
      throwEx('callTestScriptFunction does not work with ' + args.length + ' parameters')
  }
}

function callTestScriptFunctionEndPoint() {
  callTestScriptFunction({name: 'demo_Hello_Test'}, 'testCase', {}, 0);
}

function rollover(scriptName, runConfig, paramStr){
  var config = getConfig(scriptName);
  callTestScriptFunction(config, 'close', runConfig, paramStr);
  callTestScriptFunction(config, 'rollover', runConfig, paramStr);
}

function rolloverIfNotHome(scriptName, runConfig, paramStr){
  var config = getConfig(scriptName);
  if (!callTestScriptFunction(config, 'isHome', runConfig, paramStr)){
    rollover(scriptName, runConfig, paramStr);
  }
}

function goHomeOrRestart(scriptName, runConfig, paramStr){
  var restartConfig = getConfig(scriptName);
  
  function atHome(){
    return callTestScriptFunction(restartConfig, 'isHome', runConfig, paramStr);
  }
    
  function goHome(){
    return callTestScriptFunction(restartConfig, 'goHome', runConfig, paramStr);
  }
    
  if (!atHome()){
    goHome();
  }
    
  if (!atHome()){
    logWarning('not at home after call to goHome - restarting trying again');
    callTestScriptFunction(restartConfig, 'close', runConfig, paramStr);
    goHome();
  }

  var result = atHome();
  if (!result){
    logError('Check restart script: ' + scriptName + ' application not in "home" state after a call to "close" and "goHome"');
  }

  return result;
}

function makeGoHomeFunction(scriptName, runConfig, paramStr){
  function goHome(){
    return goHomeOrRestart(scriptName, runConfig, paramStr);
  }
  return goHome;
}

function makeOnceOnlyRolloverFunction(scriptName, runConfig, restartParamStr, message){
  var hasRun = false;
  // will only run the first time it is called
  function rolloverOnce(){
    if (!hasRun){
      hasRun = true;
      logBold(message);
      rollover(scriptName, runConfig, restartParamStr);
    }
  }
  return rolloverOnce;                                       
}

function runTestList(testList, runConfig, defaultTestConfig, /* optional */ simpleLogProcessingMethod, /* optional */ runTestOverride){
  
  var simpleLogProcessingMethod = def(simpleLogProcessingMethod, defaultSimpleLogProcessing);
  
  var testParams = {
                    runConfig: runConfig,
                    defaultTestConfig: defaultTestConfig
                  }; 
  var rolloverFailed = false,
      restartName = '';
                
  function runThisTestItem(testItem){
    var scriptName = extractScriptName(testItem, scriptName, runConfig); 
    if(isRestart(scriptName)){
      restartName = scriptName;
      testParams = assignPreTestFunctions(testParams, testItem, restartName, runConfig);
      rolloverFailed = false;
    }
    else {
      if (rolloverFailed){
        logWarning('Skipping test: ' + scriptName + ' due to earlier rollover failure', logAttributes(null, true));
      }
      else {
        testParams.scriptName = scriptName;
        
        function resetRolloverrestartCommands(){
            /* 
              we want reset the restart (specifically rollover) function if a test 
              threw an exception so the rollover will run again prior to the next 
              test to ensure the environment is cleaned up
            */
            testParams = assignPreTestFunctions(testParams, testItem, restartName, runConfig); 
        }
        testParams.resetOnExceptionFunction = resetRolloverrestartCommands;
        var testOutCome = runTest(testParams);
     
        if (testOutCome.interactorError === ROLLOVER_FAIL()) {
          rolloverFailed = true;
        }
      }
    }
  }
  
  var testRunnerFunction = def(runTestOverride, runThisTestItem);
  
  var configToLog = _.clone(runConfig);
  logBold("====== Starting Test Run: " +  def(configToLog.name, 'Unnamed') + " ======", objectToReadable(configToLog));
  try {
    _.each(testList, testRunnerFunction);
   }
  finally {
    saveProcessSimplifiedLog(configToLog, simpleLogProcessingMethod);
  }
}

function assignPreTestFunctions(testParams, testItem, scriptName, runConfig){
  var startFuncs = makeStartFunctions(testItem, scriptName, runConfig);
  testParams.rollover = startFuncs.rolloverFunction;
  testParams.goHome = startFuncs.goHomeFunction;
  return testParams;
}

function makeStartFunctions(testItem, scriptName, runConfig){
  var restartParamStr = extractParams(testItem);
  goHomeFunction = makeGoHomeFunction(scriptName, runConfig, restartParamStr);
  rolloverFunction = makeOnceOnlyRolloverFunction(scriptName, 
                                              runConfig, 
                                              restartParamStr, 
                                              "====== Restarting: " + scriptName + " ======");
  return {
          goHomeFunction: goHomeFunction,
          rolloverFunction: rolloverFunction
        };
}


function runTest(testParams){
  var result = {
                  exception: false,
                  interactorError: null
               };
       
  function runTheTest(){
    var scriptName = testParams.scriptName;
    var testConfig = getConfig(scriptName);
    testConfig = validateAndSetDefaultConfigProperties(testConfig, testParams.defaultTestConfig, CONFIGURATION_TYPE.TEST_CONFIG);
    logStartOfTest(scriptName, testConfig, testParams.runConfig);
    var id = testConfig.id;
    ensure(hasValue(id), "No test id defined in " + scriptName);
    var itemParams = _.clone(testParams);
    itemParams.testConfig = testConfig;
    try {
      result.interactorError = runTestItemReturnInteractorUsingCall(itemParams);
    }
    catch (e) {
      var abortlevel = globalAbortLevel();
      if (hasText(abortlevel, ABORT_RUN_TOKEN())){
        logItalic('Aborting Test Run');
        throw(e);
      }
      else {
        resetGlobalAbortLevel();
      }
    }
    
  } 

  if (isRunnningInInteractiveMode()){
     runTheTest();
  }
  else {
    try {
      runTheTest();
    }
    catch (e) {
      result.exception = true;
          
     // we should not get ot here 
      logTestException(testParams.scriptName, testParams.id, e);
      popLogFoldersToLevel(1);
    }
    finally {
     Indicator.Clear();
    }
 
  }
  
  //ensure popped out in the case of 
  //data driven tests that throw exceptions
  _.each(_.range(10), popLogFolder);
  return result;
}

function logTestException(scriptName, id, e){
  logError(
        "Exception Encountered in: " + 
          scriptName + ' - id: ' + id  + ' - ' +
          objectToReadable(e), objectToReadable(e), 
          true);
  return true;
}

function testItems(testConfig, runConfig){
  var arDataSource = callOptionalTestScriptFunction(testConfig, 'testItems', runConfig);
  ensure(hasValue(arDataSource), 'Test case has no testItems function or the testItems function is not returning any data');
  var result = forceArray(arDataSource);
  if (result.length === 0){
    logError('NO TEST ITERATIONS HAVE BEEN RUN FOR A TEST INCLUDED IN THIS TEST RUN - SEE ADDITIONAL INFO FOR MORE DETAILS',
    'Although this test has been included in the test run there are no items being returned from the testItems function for this test run.' + newLine() +
    'This indicates either an error in the testItems function or there is a filter in the testItems function that is causing all items to be removed.' + newLine() +
    'E.g. If testItems are filtered on country and none of the items are included for the country of the current test run. In such a case the' + newLine() +
    'the TEST_CONFIGURATION should be amended such that the test case is not run as part of the test run (e.g. updating the countries property).' + newLine(2) +
    'These proplems can be investigated by running the testItemsEndPoint using the runConfig of the current test run.' + newLine(2) +
    objectToJson(runConfig)
    )
  }
  return result; 
}

function runTestItemReturnInteractorUsingCall(itemParams){
  // workaround for crappy exception handling
  return callTestScriptFunction('TestRunnerUtilsPrivate', 'runTestItemReturnInteractorError', itemParams);
}

function runTestItemReturnInteractorError(itemParams) {
  var testConfig = itemParams.testConfig,
      id = testConfig.id,
      name = testConfig.name,
      runConfig = itemParams.runConfig,
      index = -1;

  var arDataSource = testItems(testConfig, runConfig);
  validateTestItemsArray(arDataSource);
  
  var lastIndex = arDataSource.length - 1,
                  interactorError = null;
   
  var itemParams = _.clone(itemParams);
  itemParams.issuesReport = [];
                 
  function runParameterisedTestCase(item){
    index = index + 1;
    itemParams.index = index;
    itemParams.item = item;
    var itemResult = runTestItem(itemParams);
    if (index === lastIndex || hasValue(itemResult.interactorError)){
      if (index === lastIndex){
        popLogFoldersToLevel(1);
      }
      saveIssuesReport(name, id, itemParams.issuesReport); 
    }
    logBold(END_TEST_TOKEN());
    interactorError = itemResult.interactorError;
  }
  _.each(arDataSource, runParameterisedTestCase);
  return interactorError;
}

function idIsNull(item){
  return !hasValue(item.id);
}

function valMoreThanOne(keyVal){
  return keyVal[1] > 1;
}

function theKey(keyVal){
  return keyVal[0];
}

function validateTestItemsArray(arDataSource){
  var nullIds = _.filter(arDataSource, idIsNull);
  var nonUniqueIds = _.chain(arDataSource)
                      .countBy('id')
                      .pairs()
                      .filter(valMoreThanOne)
                      .map(theKey)
                      .value();
  
  var errorMsg = '';
  if (nullIds.length > 0) {
    errorMsg = 'One or more items in testItems have undefined ids - all testItems must have a non-null id property.'
  }
  
  if (nonUniqueIds.length > 0) {
    errorMsg = appendDelim(errorMsg, 
                            newLine(), 
                            'Non-unique ids in testItems: ' + nonUniqueIds.join(', ') + ' - test item ids must be unique within the testItems list');
  }
  
  ensure(!hasValue(errorMsg), errorMsg);
}

function validateTestItemsArrayEndPoint() {
  var items = [
             //   {id: null},
                {id: 1},
                {id: 2},
                {id: 3},
             //   {},
              //  {id: 3},
             //   {id: 4},
                {id: 4}
              ];
 
  validateTestItemsArray(items);
}

function issuesFileName(testName, id){
  return testName + issuesFileSuffix(id);
}

function issuesPath(testName, id){
  return logFilePath(issuesFileName(testName, id), true);
}

function saveIssuesReport(testName, id, issuesReport){
  var path = issuesPath(testName, id);
  var issues = issuesReport;
  var indent = '   ';
  var indentLength = indent.length;
  var issueTestName = testName + '_' + def(id, 'NO ID');
  
  if (issues.length === 0){
    log('No Issues: ' + issueTestName, null, logColourAttributes(ENUM_PASS()));
  }
  else {
    var issuesLines = objectToReadable(issues, indent).split(newLine());
  
    function isNonBracketWhiteSpace(str){
      return trimWhiteSpace(str) !== '' && trimWhiteSpace(str) !== '[';
    }
  
    function slice2Indents(str){
      return str.slice(indentLength * 2); 
    }
  
    issuesLines = _.chain(issuesLines)
                    .rest(_.findIndex(issuesLines, isNonBracketWhiteSpace))
                    .map(slice2Indents)
                    .initial() // trailling ]
                    .value();
  
    issuesLines = addSectionRowPadding(issuesLines);
    issuesLines = removeSummaryMarker(issuesLines, true);
    var issuesTxt = logDateHeader() + newLine(2) + issuesLines.join(newLine());
    
    logLink('Issues: ' + issueTestName, issuesTxt, path, logColourAttributes(ENUM_ERROR()));
    stringToFile(issuesTxt, path);
  }
}

function logStartOfTest(scriptName, testConfig, runConfig){
  var configInfoMessage = 'testConfig' +
    newLine() + 
    objectToJson(testConfig) +
    newLine() + 
    newLine() + 
    'runConfig' +
    newLine() + 
    objectToJson(runConfig);
  var folderMessage = "Test Case "+ testConfig.id + ": " + scriptName + ' - When ' + testConfig.when + ' then ' +  testConfig.then;
  var attr = Log.CreateNewAttributes();
  attr.Bold = true;
  Log.PushLogFolder(Log.CreateFolder(folderMessage, 
    aqString.Replace(folderMessage, ' - When', newLine() + 'When') + newLine() + newLine() + configInfoMessage,
    pmNormal, attr));
}

function makeTestItemsFunction(strDataSource){
  function testItems(runConfig){
    return worksheetToArray(strDataSource);
  }
  return testItems;
}

function TRUE_ALWAYS(){
  return true;  
}

function isNoElementException(e){
 return hasText(e.message, 'Unable to find the specified element.')
}

var folderDepth = 0;
function generalEvents_OnLogCreateNode(Sender, LogParams){
  folderDepth++;  
}

function generalEvents_OnLogCloseNode(Sender, LogParams){
  folderDepth--;    
}

function popLogFoldersToLevel(level){
 while (folderDepth > level) {
    popLogFolder()
  } 
}

function whenThenMessage(item, testConfig){
  var when, 
      then;
      
  if (hasValue(item) && hasValue(item.when)) {
    when = item.when;
    then = item.then;
  }
  else {
    when = testConfig.when;
    then = testConfig.then;
  }
  
  return 'When ' + when + ' then ' + then; 
}

function runTestItem(itemParams){
  popLogFoldersToLevel(1);
  
  var testConfig = itemParams.testConfig,
      runConfig = itemParams.runConfig, 
      index = itemParams.index, 
      item = itemParams.item, 
      id = testConfig.id,
      itemId = itemParams.item.id,
      name = testConfig.name;

  var message = name + " id: " + id;
  var detailMessage = "";
    
  if (hasValue(item)){
    message = message + ITEM_ID_TOKEN() + itemId;
    detailMessage = objectToReadable(item)
  }
  
  var logMessage = START_TEST_TOKEN() + message;
  
  Indicator.PushText(message);
  logBold('=== ' + logMessage + ' - ' + whenThenMessage(item, testConfig) + ' ===', detailMessage);
  try {
    var executeParams = _.omit(itemParams, 'testConfig');
    executeParams.scriptName = testConfig.name;
    executeParams.scriptId = testConfig.id;
     
    var result;
    try {
      result = executeDeferredLoggingTest(executeParams);
    }
    catch (e) {
      result = {
                 interactorError: 'Exception in test: ' + objectToJson(e)
                }
      logTestException(name, id, e);
      itemParams.resetOnExceptionFunction();
      var abortlevel = globalAbortLevel();
      if (hasText(abortlevel, ABORT_TEST_TOKEN()) || hasText(abortlevel, ABORT_RUN_TOKEN())){
        logItalic('Aborting Test');
        throw(e);
      }
    }
  }
  finally {
    popLogFoldersToLevel(2);
    Indicator.Clear();
  }
  return result;
}

function testListItems(){
  return TestCaseListUtils.testListItems();
}

function extractScriptNameAndParams(str){
  return bisect(str, ' ');
}

function extractParams(str){
  var result = extractScriptNameAndParams(str);
  return trim(result[1]);
}

function extractScriptName(str){
  var result = extractScriptNameAndParams(str);
  return trim(result[0]);
}

function extractScriptNameUnitTest() {
  var scriptText =  '//USEUNIT SmartBearSampleRestart'
  var result = extractScriptName(scriptText);
  checkEqual('SmartBearSampleRestart', result);
  
  scriptText =  '//USEUNIT SmartBearSampleRestart param1 param2'
  result = extractScriptName(scriptText);
  checkEqual('SmartBearSampleRestart', result);
}

function validateGenerateTestList(runConfig, testFilters, defaultTestConfigInfo){
  var arAllTestCaseItems = testListItems();
  validateTestItems(arAllTestCaseItems);
  

  var configInfo = '--- Run Config ---' + newLine() + objectToJson(runConfig) + newLine() + newLine() + '--- Test Items ---' +  newLine();
  log('Test Items Before PreAccept / Accept', configInfo + arAllTestCaseItems.join(newLine()));
 
  
  
  Indicator.PushText("Applying Test Filters");
  var filterResult = applyTestFilters(arAllTestCaseItems, testFilters, runConfig, defaultTestConfigInfo);
  var result = filterResult.items;
  var filterLog = filterResult.filterLog;
  log('Test Items After Applying Test Filters', configInfo + result.join(newLine()));
  
  var allFilters = _.map(testFilters, functionNameFromFunction).join(newLine());
  
  var filterMessage = FILTER_LOG_TOKEN() + ' ' + newLine(2) + 
                      '--- All Filters ---'  + newLine() + allFilters + newLine(2) +
                      FILTER_RESULTS_HEADER() + newLine() +
                                            filterLog.join(newLine());
                                                                               
  logBold('Filter Log', filterMessage);
  var filterLogFile = logFilePath('lastFilterLog.txt', true);
  stringToFile(filterMessage, filterLogFile);
  logLink("Filter log copied to: " + filterLogFile, filterLogFile);
  
  Indicator.PopText();
  

  Indicator.PushText("Removing duplicate restarts");
  result = removeDuplicateRestarts(result);
  log('Test Items After Remove Duplicate Restarts', configInfo + result.join(newLine()));
  Indicator.PopText();
  
  return result;
}



function fullFilterInfo(testFilters, filterLog){
  var filterNames = _.map(testFilters, functionNameFromFunction).join(newLine());
  return '***** All Filters *****' 
          + newLine() 
          + filterNames 
          + newLine(2) 
          + '***** Filter Results *****'
          + newLine()
          + filterLog;  
}

function getRestartAndParams(testConfig){
  var arAllTestItems = _.map(testListItems(), extractScriptNameAndParams);
  var testScript = scriptNameFromId(testConfig.id);
  
  function checkItem(memo, thisItem){
    if (memo.complete){
      return memo;
    }
    
    var thisScript = thisItem[0];
    if (!memo.priorToScript) {
      memo.priorToScript = testScript === thisScript;
    }
    else if (isRestart(thisScript)) {
      memo.complete = true;
      memo.restart = thisScript;
      memo.params = thisItem[1];
    }
    
    return memo;
  }
  
  var reduceResult = _.reduceRight(arAllTestItems, checkItem, {priorToScript: false, complete: false, restart: '', params: ''});
  
  // looks like the script might be missing
  if (!reduceResult.priorToScript){
    validateTestItems();
  }
  
  var result = {
                script: reduceResult.restart, 
                params: reduceResult.params
              };
  ensure(hasValue(result), 'No restart item found for: ' + testScript);
  return result;
}

function getRestartScriptAndParamsEndPoint() {
  var result = getRestartAndParams('DisableddemoTest');
  checkEqual('SmartBearSampleRestart', result);
}

function unitValidateGenerateTestList(){
  var result = validateGenerateTestList();
}

function isRestart(str){
  return hasText(str, 'Restart');
}

function applyTestFilters(testItems, testFilters, runConfig, defaultTestConfigInfo){
  var testCaseItems = testItems;
  var testList = runConfig.tests;
  
  var nameCache = {};
  function functionName(func){
    var result = nameCache[func];
    if (!hasValue(result)){
      var result = functionNameFromFunction(func);
      ensure(hasValue(result), 'testFilters list contains anonymous function. Only use named functions as a test filters: ' + result);
      nameCache[func] = result;
    }
    return result;
  }
  
  return _.reduce(testItems,
      function(result, testItem){
        var items = result.items;
        var filterLog = result.filterLog;
        var testScriptName = extractScriptName(testItem);
        
        if (isRestart(testScriptName)) {
          items.push(testItem);
        }
        else {
          var testConfig = getConfig(testScriptName);  
          validateAndSetDefaultConfigProperties(testConfig, defaultTestConfigInfo, CONFIGURATION_TYPE.TEST_CONFIG);
          
          function filterRejection(filterFunc){
            return !filterFunc(testScriptName, testConfig, runConfig);
          }
          
          var firstFailure = _.find(testFilters, filterRejection);
          if (hasValue(firstFailure)){
            filterLog.push(testConfig.id + ': ' + testScriptName + ' - Rejected: ' + functionName(firstFailure)); 
          }
          else {
            items.push(testItem);
            filterLog.push(testConfig.id + ': ' + testScriptName +  ' - Accepted');           }
        }
        return result;
      },
      {items: [], filterLog: []}
  )
}

function applyTestFiltersEndPoint() {
 
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



    var defaultTestConfigInfo = {
        requiredProperties:['id', 'when', 'then', 'owner'],
        enabled: true,
        demo: false,
        dataSource: null,
        country: 'All'
    };
    var runConfig = {name: 'test'};
    var filters = testFilters();
    var testItems = testListItems();
    var result = applyTestFilters(testItems, filters, runConfig, defaultTestConfigInfo);
  
    runConfig = {
                  name: 'test',
                  tests: [-1,-2],
                  demo: true
                };
    var result = applyTestFilters(testItems, filters, runConfig, defaultTestConfigInfo);
  }

function propsArrayToObject(props){
  var result = {},
  propName, propValue;
  _.each(props, function(str){
    str = trimChars(str, [',']);
    var bisected = bisect(str, ':');
    result[bisected[0]] = bisected[1];
  });
  return result;
}

function getConfig(testScriptName){
  var result = testRunItems()[testScriptName];
  return result;
}

function getConfigEndPoint(){
  var cfg = getConfig("demo_Hello_Test");
  delay(1);
}

function removeDuplicateRestarts(filteredTestCaseItems, isRestartOverride){
  var testCasesDuplicateRestartsRemoved = [];
  var thisItem, nextItem,
  pushed = false;
  isRestartOverride = def(isRestartOverride, isRestart);
  for(var counter = filteredTestCaseItems.length - 1; counter > -1; counter--){
    thisItem = filteredTestCaseItems[counter];
    if (!isRestartOverride(thisItem) || (!isRestartOverride(nextItem) && pushed)) {
      testCasesDuplicateRestartsRemoved.push(thisItem);
      pushed = true;
    }
    nextItem = thisItem;
  }
  var result = testCasesDuplicateRestartsRemoved.reverse();
  return result;
}


function testListItemNames(){
  var arAllTestCaseItems = testListItems();
  var arAllListedTestFileNames = _.chain(arAllTestCaseItems)
                                  .map(extractScriptName)
                                  .value();
  return arAllListedTestFileNames;
}

function validateTestItems() {
  Indicator.PushText("Validating test list");
  var testsAndRestartsInProject = _.pluck(testScriptsAndRestarts(), 'name');

  var listItems = testListItemNames();

  var missingInTestList = _.difference(testsAndRestartsInProject, listItems);
  var invalidNamesInList = _.difference(listItems, testsAndRestartsInProject);
  
  if (missingInTestList.length > 0 || invalidNamesInList.length > 0){
    var testListPath = scriptFilePath("TestCaseList");
    var testListContent = listContentAsArrayMinusHeader();

    // assuming if there are no params then we 
    // are running interactively so update files and throw
    // if invalid tests in list always throw because invalid restarts will cause huge issues
    // so simplest just to throw
    var wantException = isRunnningInInteractiveMode() || invalidNamesInList.length > 0;
    if (wantException){
      var correctionFragment = missingInTestList.length > 0 ?
                                'The following items are missing from the test list - remove this comment and ' +
                                'insert these test items in the correct place in the list' + newLine() + missingInTestList.join(newLine()) :
                                "";
      
      if (invalidNamesInList.length > 0) {
        correctionFragment = correctionFragment + newLine(2) +  'The following invalid test list items have been removed: ' + invalidNamesInList.join(newLine())
      }
       
      regenerateTestCaseListFile(testListContent, invalidNamesInList, correctionFragment, listItems, missingInTestList, testListPath);
      logError(correctionFragment + " - Correct the TestCaseList and run again. You may need to <Right Click><Reload> first");
      runItemIdToNameMapWithDuplicateIdsRemoved(false);
      throwEx('Test list or Id validation failed ~ see previous errors');
    }
    else {
      var message = "Incomplete TestCaseList - the following files are not in the list: " + missingInTestList.join(', ') + '.';
      Log.Error(message, message);
    }
  }
  Indicator.PopText();
}

// © John Walker 2013 – Permission for unrestricted use and modification granted within 
// THE-COMPANY and affiliated companies