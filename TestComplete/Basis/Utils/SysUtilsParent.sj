//USEUNIT SysUtilsGrandParent
//USEUNIT StringUtilsGrandParent
//USEUNIT _
//USEUNIT DateTimeUtils


// test state tokens
function END_TEST_TOKEN() {return "End Test"}
function START_TEST_TOKEN() {return "Start Test: "}
function ITEM_ID_TOKEN() {return " item id: "}
function DEFECT_EXPECTED_TOKEN() {return "Defect Expected: "}
function ACTIVE_TOKEN() {return " Active: "}
function END_DEFECT_EXPECTED_TOKEN() {return "End Defect Expected"}
function ABORT_ITERATION_TOKEN(){return SysUtilsGrandParent.ABORT_ITERATION_TOKEN();}
function ABORT_TEST_TOKEN(){return SysUtilsGrandParent.ABORT_TEST_TOKEN();}
function ABORT_RUN_TOKEN(){return SysUtilsGrandParent.ABORT_RUN_TOKEN();}

function mapRecords(rowsArrayObject, funcOrObjOfFuncsMatchingObjProps){

  ensure(_.isFunction(funcOrObjOfFuncsMatchingObjProps) || !_.isArray(rowsArrayObject), 'incorrect type - if sending an array to mapvalues the second argument must be a function');

  function executeObjFunc(rowObj, key){
    var thisFunc = _.isFunction(funcOrObjOfFuncsMatchingObjProps) ?  funcOrObjOfFuncsMatchingObjProps: funcOrObjOfFuncsMatchingObjProps[key];
    
    function mapThisItem(rowObjOrArrray, thisFunc){
      return  isPlainSingleDArray(rowObj)  ? _.map(rowObj, thisFunc) : mapRecords(rowObj, thisFunc);
    }
    
    return hasValue(thisFunc) ? mapThisItem(rowObj, thisFunc): rowObj;
  }

  return isPlainSingleDArray(rowsArrayObject) ? _.map(rowsArrayObject, funcOrObjOfFuncsMatchingObjProps) : 
                // must be nested array
                _.isArray(rowsArrayObject) ? _.map(rowsArrayObject, executeObjFunc) 
                : _.mapObject(rowsArrayObject, executeObjFunc);
}

function isPlainSingleDArray(obj){
  return _.isArray(obj) && (obj.length === 0 || !_.isArray(obj[0]));
}

function mapFields(rowsArrayObject, funcOrObjOfFuncsMatchingObjProps){

  ensure(_.isFunction(funcOrObjOfFuncsMatchingObjProps) || !_.isArray(rowsArrayObject), 'incorrect type - if sending an array to mapfields the second argument must be a function');

  function mapRows(rowsArray, func){
    function executePropFunc(row){
      return _.mapObject(row, func);
    }
    return _.map(rowsArray, executePropFunc);
  }

  function executeObjFunc(rowObj, key){
    var thisFunc = _.isFunction(funcOrObjOfFuncsMatchingObjProps) ?  funcOrObjOfFuncsMatchingObjProps: funcOrObjOfFuncsMatchingObjProps[key];
    
    function mapThisItem(rowObjOrArrray, thisFunc){
      return _.isArray(rowObjOrArrray) ? mapFields(rowObjOrArrray, thisFunc) : _.mapObject(rowObj, thisFunc);
    }
    
    return hasValue(thisFunc) ? mapThisItem(rowObj, thisFunc): rowObj;
  }

  return isPlainSingleDArray(rowsArrayObject)  ? mapRows(rowsArrayObject, funcOrObjOfFuncsMatchingObjProps) : 
                _.isArray(rowsArrayObject) ? _.map(rowsArrayObject, executeObjFunc) : _.mapObject(rowsArrayObject, executeObjFunc);
}

function stringConvertableToNumber(val){
    
  function isNumChars(str){

    function isDot(chr){
      return chr === '.';
    }
  
    var chrs = str.split(('')),
         dotCount = _.filter(chrs, isDot).length;
  
    return dotCount > 1 || startsWith(str, '.') || endsWith(str, '.') || startsWith(str, '0') && !startsWith(str, '0.') && !(str === '0') ? 
                  false :
                   _.chain(chrs)
                      .reject(isCommaWhiteSpaceDot)
                      .all(isIntChr)
                      .value();                  
  }

  function isIntChr(chr){
    var chCode = chr.charCodeAt(0);
    return chCode > 47 && chCode < 58;
  }

  function isCommaWhiteSpaceDot(chr){
    return _.contains([',', '\t', ' ', '.'], chr);
  }
  
  return hasValue(val) && isNumChars(val);
}

function forceArray(ags){

  function forceArraySingleVal(val){
    return isUndefined(val) ? [] :
            _.isArray(val) ? val : [val];
  }

  return _.chain(_.toArray(arguments))
          .map(forceArraySingleVal)
          .flatten(true)
          .value();
}

function jsonToObject(json, reviver){
 return JSON.parse(json, reviver);
}

function logAttributes(bold, italic){
  attr = Log.CreateNewAttributes();
  attr.Bold = def(bold, false);
  attr.Italic = def(italic, false);
  return attr;
}

function objectToJson(object, space, replacer){
  space = def(space, '  ');
  replacer = def(replacer, dateReplacer);
  return JSON.stringify(object, replacer, space);
}


/**

Logs a link (a wrapper around: Log.link)

== Params ==
mainMessage: String - Optional - Default: link - the main log message
additionalText: String - Optional - Default: mainMessage - the message that appears in additional information pane
link: String - Required - the link text
attributes: TestComplete LogAttributes - Optional - Default: default LogAttributes - see TestComplete help
== Return ==
obj: - A clone of the target object
== Related ==
toTempReadable
**/
function logLinkWithAttributes(mainMessage, additionalText, link, attributes){
  var args = _.chain(arguments)
               .toArray()
               .filter(hasValue)
               .value(),
      stringArgs = _.filter(args, _.isString),
      stringArgsLength = stringArgs.length;
  
  link = _.last(stringArgs);
  mainMessage = stringArgsLength > 1 ? stringArgs[0] : link,
  additionalText = stringArgsLength > 2 ? stringArgs[1] : mainMessage,
  attributes = args.length > stringArgsLength ? _.last(args): Log.CreateNewAttributes(); 
   
  Log.Link(link, mainMessage, additionalText, pmNormal, attributes);
}

function logLink(mainMessage, /* optional */ additionalText, link, /* optional */ msgWarnErrorEnum){
  /// param kunkfu
  var args = _.toArray(arguments);
  var lastArg = _.last(args);
  msgWarnErrorEnum = hasValue(fontColour(lastArg)) ? lastArg : null;
  // remove the enum from args
  args = hasValue(msgWarnErrorEnum) ? _.initial(args) : args;
  var attributes = logColourAttributes(def(msgWarnErrorEnum, ENUM_MESSAGE()));
  args.push(attributes);
  
  logLinkWithAttributes.apply(null, args);
}

function logWarningLink(message, link){
  logLink(message, link, ENUM_WARNING());
}

function logWarning(message, additionalInfo, attr){
  Log.Warning(message, def(additionalInfo, message), pmNormal, attr);
}

function executeFile(filePath, params, waitTillTerminated){
  params = def(params, "");
  waitTillTerminated = def(waitTillTerminated, true);
  
  var wscript = Sys.OleObject("WScript.Shell");
  var target = filePath + ' ' + params;
  log('Executing file: ' + target);
  var exe = wscript.Exec(target);

  if (waitTillTerminated)
  {
    while (exe.Status === 0)
    {
      delay(1000, "Waiting for " + filePath & " to finish")
    }
  }
  
  return exe;
}

function objectToReadable(obj, indent){
  return SysUtilsGrandParent.objectToReadable(obj, indent)
}

function logCheckPoint(messageText, /* optional */ additionalInformation,/* optional */ priority,/* optional */ attr,/* optional */ picture,/* optional */ folderID){
  SysUtilsGrandParent.logCheckPoint(messageText, additionalInformation, priority, attr, picture, folderID);
}

function logError(message, additionalInfo, /* optional */ attr){
  SysUtilsGrandParent.logError(message, additionalInfo, attr);
}

function projectScriptFileEncoding(){return SysUtilsGrandParent.projectScriptFileEncoding();}

function log(message, /* optional */ additionalInfo, /* optional */ attr){
  additionalInfo = _.isObject(additionalInfo) ? 
                                                objectToReadable(additionalInfo): 
                                                additionalInfo;
  SysUtilsGrandParent.log(message, additionalInfo, attr);
}

function ensure(condition, message, abortLevel) {
  SysUtilsGrandParent.ensure(condition, message, abortLevel);
}

function def(arg, defaultVal) {
  return SysUtilsGrandParent.def.apply(null, _.toArray(arguments));
}

function hasValue(arg)
{
 return SysUtilsGrandParent.hasValue(arg);
}

function isNullOrUndefined(arg){
  return SysUtilsGrandParent.isNullOrUndefined(arg);
}

function isNullEmptyOrUndefined(arg){
  return SysUtilsGrandParent.isNullEmptyOrUndefined(arg);
}

// Returns value of the Exists property if the object has an Exists property 
// else returns true - use hasValue to check if defined or empty && exists
function exists(arg)
{ 
 return SysUtilsGrandParent.exists(arg);
}

function throwEx(errorMessage, detailMessage, abortLevel){
  SysUtilsGrandParent.throwEx(errorMessage, detailMessage, abortLevel);
}

// NEVER DO THIS THIS IS ONLY HERE AS A BODGE
// JSCRIPT EXCEPTION HANDLING DOES NOT WORK PROPERLY
// AT TIME OF WRITING
function globalAbortLevel(){
  // yes its a global variable
  return SysUtilsGrandParent.globalAbortLevel;
}

function resetGlobalAbortLevel(){
  // yes its a global variable
  return SysUtilsGrandParent.globalAbortLevel = null;
}

/**
 Framework use only do not use this function
**/
function ENUM_ERROR(){
  return 'error';  
}

/**
 Framework use only do not use this function
**/
function ENUM_WARNING(){
  return 'warning';    
}

/**
 Framework use only do not use this function
**/
function ENUM_MESSAGE(){
  return 'message';    
}

/**
 Framework use only do not use this function
**/
function ENUM_PASS(){
  return 'pass';  
}

/**
 Framework use only do not use this function
**/
function RED(){
  return rgb(225, 0, 0);
}

/**
 Framework use only do not use this function
**/
function GREEN(){
  return rgb(0, 153, 0);
}

/**
 Framework use only do not use this function
**/
function YELLOW(){
  return rgb(255,255,0)
}

/**
 Framework use only do not use this function
**/
function BLACK(){
  return rgb(0, 0, 0);
}

function correctRgbComponent(component){
  component = aqConvert.VarToInt(component);
  if (component < 0)
    component = 0;
  else
    if (component > 255)
      component = 255;
  return component;
}

function rgb(r, g, b){
  r = correctRgbComponent(r);
  g = correctRgbComponent(g);
  b = correctRgbComponent(b);
  return r | (g << 8) | (b << 16);
}

/**
 Framework use only do not use this function
**/
function logColourAttributes(statusEnum){
  var attr = logAttributes(false, false);
  if (statusEnum === ENUM_WARNING()){
    attr.BackColor = YELLOW();
  }
  attr.FontColor = fontColour(statusEnum);
  return attr;
}



/**
 Framework use only do not use this function
**/
function fontColour(statusEnum){
  var colourMap = {}
  colourMap[ENUM_ERROR()] = RED();
  colourMap[ENUM_WARNING()] = BLACK();
  colourMap[ENUM_PASS()] = GREEN();
  return colourMap[statusEnum]; 
}

// © John Walker 2013 – Permission for unrestricted use and modification granted within 
// THE-COMPANY and affiliated companies

