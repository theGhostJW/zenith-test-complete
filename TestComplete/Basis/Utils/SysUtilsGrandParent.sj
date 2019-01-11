//USEUNIT _
//USEUNIT StringUtilsGreatGrandParent
//USEUNIT ToReadableUtils

function ABORT_ITERATION_TOKEN(){return 'Abort Iteration'}
function ABORT_TEST_TOKEN(){return 'Abort Test'}
function ABORT_RUN_TOKEN(){return 'Abort Test Run'}

function objectToReadable(obj, indent){
  return TOREADABLE.stringify(obj, null, def(indent, '   '));
}

function ensure(condition, message, abortLevel) {
  if (!condition){
    throwEx("Ensure Failure: " + message, abortLevel);
  }
}

function projectScriptFileEncoding(){return aqFile.ctANSI}

function logCheckPoint(messageText, /* optional */ additionalInformation,/* optional */ priority,/* optional */ attr,/* optional */ picture,/* optional */ folderID){
  // same defaults as TestComplete
  additionalInformation = def(additionalInformation, messageText);
  priority = def(priority, pmNormal);
  attr = def(attr, Log.CreateNewAttributes());
  picture = def(picture, '');
  folderID = def(folderID, -1);
  Log.Checkpoint(messageText, additionalInformation, priority, attr, picture, folderID)
}

function logError(message, additionalInfo, /* optional */ attr){
  additionalInfo = def(additionalInfo, message);
  if (hasValue(attr)) {
    Log.Error(message, additionalInfo, pmNormal, attr);
  } 
  else {
    Log.Error(message, additionalInfo);
  }
}

function log(message, /* optional */ additionalInfo, /* optional */ attr){
  additionalInfo = def(additionalInfo, message);
  if (hasValue(attr)) {
    Log.Message(message, additionalInfo, pmNormal, attr);
  } 
  else {
    Log.Message(message, additionalInfo);
  }
}

function hasValue(arg){
  var isDefined = !isNullEmptyOrUndefined(arg);
  if (isDefined){
    return exists(arg);
  } 
  else {
    return false;
  }
}

// Returns value of the Exists property if the object has an Exists property 
// else returns true - use hasValue to check if defined or empty && exists
function exists(arg){ 
  var existProperty = true;
  var doesExist = true;
  try {
    doesExist = arg.Exists; 
  }
  catch (e) {
    existProperty = false;
    var message = e.message;
    var expectedError = (message === "Object doesn't support this property or method") || 
                        hasText(message, 'does not exist') ||
                        hasText(message, 'is null') && hasText(message, 'exists');
    if (!expectedError){
      throwEx("exists - unexpected failure: " + e.message);
    }
  }
 
  if (existProperty && !isNullEmptyOrUndefined(doesExist)) {
    return doesExist;
  }
  else {
    // any object with no exists property is deemed to exist 
    // use hasValue to check if defined or empty or has false exists property
    return true;
  }
}

function def(arg, defaultVals) {
  var args = _.toArray(arguments);
  var lastArg = args.length === 0 ? undefined : args[args.length - 1]; // wierd errors with this: if using _.last(args);
  var result = _.find(args, notNullorUndefined);
  return notNullorUndefined(result) ? result : lastArg;
}

function notNullorUndefined(arg){
  return !isNullOrUndefined(arg);
}

function isNullOrUndefined(arg){
  return (typeof arg === 'undefined') || arg === null;
}

function isNullEmptyOrUndefined(arg){
  return isNullOrUndefined(arg) || arg === '';
}

// NEVER DO THIS THIS IS ONLY HERE AS A BODGE
// JSCRIPT EXCEPTION HANDLING DOES NOT WORK PROPERLY
// AT TIME OF WRITING
var globalAbortLevel = null;
function throwEx(errorMessage, detailMessage, abortLevel){
  var args = _.toArray(arguments);
  function isAbortLevel(str){
    return _.contains([ABORT_ITERATION_TOKEN(), ABORT_TEST_TOKEN(), ABORT_RUN_TOKEN()], str)
  }
  abortLevel = def(_.find(args, isAbortLevel), ABORT_ITERATION_TOKEN());
  globalAbortLevel = abortLevel;
  args = _.reject(args, isAbortLevel);
  errorMessage = def(args.length > 0 ? args[0] : "", "");
  detailMessage = def(args.length > 1 ? args[1]: "", "");
  Log.Error("Exception - " + errorMessage, detailMessage);
  throw new Error ("Exception - " + errorMessage + ' - ' + detailMessage);
}

function hasText(hayStack, needle, caseSensitive){
  caseSensitive = def(caseSensitive, false);
  hayStack = def(hayStack, '');
  
  if (!hasValue(hayStack)){
    return false;
  }
  
  if (!caseSensitive){
    needle = aqString.ToLower(needle); 
    hayStack = aqString.ToLower(hayStack);
  }
  
  return aqString.Find(hayStack, needle) > -1;
}

// © John Walker 2013 – Permission for unrestricted use and modification granted within 
// THE-COMPANY and affiliated companies
