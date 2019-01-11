//USEUNIT SysUtilsParent
//USEUNIT SysUtilsPrivate
//USEUNIT StringUtilsParent
//USEUNIT _
//USEUNIT FileUtils
//USEUNIT DateTimeUtils

// func (recobj, wholeArray) => result
function mapRecords(rowsArrayObject, funcOrObjOfFuncsMatchingObjProps){
  return SysUtilsParent.mapRecords(rowsArrayObject, funcOrObjOfFuncsMatchingObjProps);
}

// func (val, key, wholeRecordObject) => result OR 
// obj {propName: // func (val, key) => result}
function mapFields(rowsArrayObject, funcOrObjOfFuncsMatchingObjProps){
  return SysUtilsParent.mapFields(rowsArrayObject, funcOrObjOfFuncsMatchingObjProps);
}

function sum(collectionOfNums){
  function sumItem(accum, val){
    return accum + def(val, 0);
  }
  return _.reduce(collectionOfNums, sumItem, 0);
}

function areEqualWithTolerance(expectedNumber, actualNumber, tolerance){
  return SysUtilsPrivate.areEqualWithTolerance(expectedNumber, actualNumber, tolerance);
}

function stringConvertableToNumber(val){
  return SysUtilsParent.stringConvertableToNumber(val);
}

function ARRAY_QUERY_ITEM_LABEL(){
  return SysUtilsPrivate.ARRAY_QUERY_ITEM_LABEL();
}

function fillArray(arrayLength, val){
  return _.times(arrayLength, _.constant(val));
}

/**

?????_NO_DOC_?????

== Params ==
arLeftSet: DATA_TYPE_?????_NO_DOC_????? -  Required -  DESCRIPTION_?????_NO_DOC_?????
arRightSet: DATA_TYPE_?????_NO_DOC_????? -  Required -  DESCRIPTION_?????_NO_DOC_?????
== Return ==
DATA_TYPE_?????_NO_DOC_????? - DESCRIPTION_?????_NO_DOC_?????
== Related ==
?????_NO_DOC_?????
**/
function setParts(arLeftSet, arRightSet){

  function intersect(ar1, ar2){
    var inIntersection = [],
        uniqueToFirst = [];
        
    function isInar2(item){
      function equalsTarg(ar2Item){
        return areEqual(ar2Item, item);
      }
      return _.find(ar2, equalsTarg)
    }
    
    function clasify(ar1Item){
      var pushTo = isInar2(ar1Item) ? inIntersection : uniqueToFirst;
      pushTo.push(ar1Item);
    }
    
    _.each(ar1, clasify);
    return [uniqueToFirst, inIntersection];
  }
  
  var leftCommon = intersect(arLeftSet, arRightSet),
      rightCommon = intersect(arRightSet, arLeftSet);
      
  
  return [leftCommon[0], leftCommon[1], rightCommon[0]];
}

/**

?????_NO_DOC_?????

== Params ==
targetHostName: DATA_TYPE_?????_NO_DOC_????? -  Required -  DESCRIPTION_?????_NO_DOC_?????
== Return ==
DATA_TYPE_?????_NO_DOC_????? - DESCRIPTION_?????_NO_DOC_?????
== Related ==
?????_NO_DOC_?????
**/
function hostNameIs(targetHostName){
  return sameText(Sys.HostName, targetHostName);
}

/**

?????_NO_DOC_?????

== Params ==
obj: DATA_TYPE_?????_NO_DOC_????? -  Required -  DESCRIPTION_?????_NO_DOC_?????
allowDuplicateKeyOverwrites: DATA_TYPE_?????_NO_DOC_????? -  Optional -  Default: false -  DESCRIPTION_?????_NO_DOC_?????
== Return ==
DATA_TYPE_?????_NO_DOC_????? - DESCRIPTION_?????_NO_DOC_?????
== Related ==
?????_NO_DOC_?????
**/
function flattenObj(obj, allowDuplicateKeyOverwrites){
  allowDuplicateKeyOverwrites = def(allowDuplicateKeyOverwrites, false);
  if (hasValue(obj)){
    var result = {}
    function flattenKey(val, key){
      ensure(allowDuplicateKeyOverwrites || !hasValue(result[key]), 'the key: ' + key + ' would appear more than once in the flattened object');
      result[key] = val;
    }
    mapObjectRecursive(obj, flattenKey);
  }
  else {
   result = obj;
  }
  return result 
}


/**

?????_NO_DOC_?????

== Params ==
mapName: DATA_TYPE_?????_NO_DOC_????? -  Required -  DESCRIPTION_?????_NO_DOC_?????
generatorFunction: DATA_TYPE_?????_NO_DOC_????? -  Required -  DESCRIPTION_?????_NO_DOC_?????
== Return ==
DATA_TYPE_?????_NO_DOC_????? - DESCRIPTION_?????_NO_DOC_?????
== Related ==
?????_NO_DOC_?????
**/
function valueTracker(mapName, generatorFunction){
  var hashMap = {};

  function newVal(key, nArgs){
    var args = _.toArray(arguments);
    ensure(isUndefined(hashMap[key]), 'Name for key: ' + key + ' already created in ' + mapName);
    var result = generatorFunction.apply(null, _.rest(args));
    hashMap[key] = result;
    return result;
  }

  function getVal(key){
    var result = hashMap[key];
    ensure(hasValue(result), 'No instance of value for key: ' + key + ' in ' + mapName);
    return result; 
  }

  function getOrNew(key, nArgs){
    var result = hashMap[key];
    return isUndefined(result) ? newVal.apply(null, _.toArray(arguments)) : result; 
  }

  return {
          getter: getVal,
          setter: newVal,
          getOrNew: getOrNew 
         };
}

/**

?????_NO_DOC_?????

== Params ==
obj: DATA_TYPE_?????_NO_DOC_????? -  Required -  DESCRIPTION_?????_NO_DOC_?????
propNames: DATA_TYPE_?????_NO_DOC_????? -  Required -  DESCRIPTION_?????_NO_DOC_?????
== Return ==
DATA_TYPE_?????_NO_DOC_????? - DESCRIPTION_?????_NO_DOC_?????
== Related ==
?????_NO_DOC_?????
**/
function reorderProps(obj, propNames){
  return SysUtilsPrivate.reorderProps.apply(null, _.toArray(arguments));
}

/**

?????_NO_DOC_?????

== Params ==
target: DATA_TYPE_?????_NO_DOC_????? -  Required -  DESCRIPTION_?????_NO_DOC_?????
propNameStringsN: DATA_TYPE_?????_NO_DOC_????? -  Required -  DESCRIPTION_?????_NO_DOC_?????
returnFullInfo: DATA_TYPE_?????_NO_DOC_????? -  Optional -  Default: false -  DESCRIPTION_?????_NO_DOC_?????
== Return ==
DATA_TYPE_?????_NO_DOC_????? - DESCRIPTION_?????_NO_DOC_?????
== Related ==
?????_NO_DOC_?????
**/
function seekInObj(target, propNameStringsN, returnFullInfo){   
  var args = seekInObjArgs(_.toArray(arguments), false);
  return hasValue(target) ? seekInObjPriv.apply(null, args) : undefined;
}

function seekAllInObj(target, propNameStringsN, returnFullInfo){
  var args = seekInObjArgs(_.toArray(arguments), true); 
  return hasValue(target) ? seekInObjPriv.apply(null, args) : []; 
}

/**

?????_NO_DOC_?????

== Params ==
target: DATA_TYPE_?????_NO_DOC_????? -  Required -  DESCRIPTION_?????_NO_DOC_?????
propNameStringsN: DATA_TYPE_?????_NO_DOC_????? -  Required -  DESCRIPTION_?????_NO_DOC_?????
value: DATA_TYPE_?????_NO_DOC_????? -  Required -  DESCRIPTION_?????_NO_DOC_?????
== Related ==
?????_NO_DOC_?????
**/
function setInObj(target, propNameStringsN, value){
  // mutates the object
  var seekArgs = _.initial(_.toArray(arguments)),
      value = _.last(_.toArray(arguments));
      
  // returnFullInfo: true
  seekArgs.push(true);
  
  var targetPropInfo = seekInObj.apply(null, seekArgs);
  if (!hasValue(targetPropInfo)){
    var propSpec = _.rest(_.initial(seekArgs)).join(', ');
    throwEx(
              'setInObj - Cannot find specified property: ' + propSpec,
              'Matching ' + propSpec + ' in ' + newLine() + objectToJson(target)
            );
  }
  targetPropInfo.parent[targetPropInfo.key] = value;
}

/**

?????_NO_DOC_?????

== Params ==
obj: DATA_TYPE_?????_NO_DOC_????? -  Required -  DESCRIPTION_?????_NO_DOC_?????
nDefaultObjs: DATA_TYPE_?????_NO_DOC_????? -  Required -  DESCRIPTION_?????_NO_DOC_?????
== Return ==
DATA_TYPE_?????_NO_DOC_????? - DESCRIPTION_?????_NO_DOC_?????
== Related ==
?????_NO_DOC_?????
**/
function defaultDeep(obj, nDefaultObjs){
  var args = _.toArray(arguments),
      defaults = _.rest(args);

  return _.reduce(defaults, singleDefaultStep, obj);
}

/**

?????_NO_DOC_?????

== Params ==
obj: DATA_TYPE_?????_NO_DOC_????? -  Required -  DESCRIPTION_?????_NO_DOC_?????
== Return ==
DATA_TYPE_?????_NO_DOC_????? - DESCRIPTION_?????_NO_DOC_?????
== Related ==
?????_NO_DOC_?????
**/
function cloneDeep(obj){
  return SysUtilsPrivate.cloneDeep(obj);
}

/**

?????_NO_DOC_?????

== Params ==
defaultArray: DATA_TYPE_?????_NO_DOC_????? -  Required -  DESCRIPTION_?????_NO_DOC_?????
defaultArrayItem: DATA_TYPE_?????_NO_DOC_????? -  Required -  DESCRIPTION_?????_NO_DOC_?????
== Return ==
DATA_TYPE_?????_NO_DOC_????? - DESCRIPTION_?????_NO_DOC_?????
== Related ==
?????_NO_DOC_?????
**/
function arrayDefs(defaultArray, defaultArrayItem){
  return {
          isArrayDefObject: true,
          defaultArray: defaultArray,
          defaultArrayItem: defaultArrayItem
  };
}


/**

?????_NO_DOC_?????

== Params ==
obj: DATA_TYPE_?????_NO_DOC_????? -  Required -  DESCRIPTION_?????_NO_DOC_?????
func: DATA_TYPE_?????_NO_DOC_????? -  Required -  DESCRIPTION_?????_NO_DOC_?????
== Return ==
DATA_TYPE_?????_NO_DOC_????? - DESCRIPTION_?????_NO_DOC_?????
== Related ==
?????_NO_DOC_?????
**/
function mapObjectRecursive(obj, func){

  function mapObjectRecursivePrivate(obj, func, baseAddress){
    function recursiveFunc(value, key,  baseObj){
      return _.isArray(value) || !_.isObject(value) || _.isFunction(value)  ? 
                                  func(value, key, baseObj, baseAddress): 
                                  mapObjectRecursivePrivate(value, func, appendDelim(baseAddress, '.', key));
    }
    var result = _.mapObject(obj, recursiveFunc);
    return result;
  }
  
  return mapObjectRecursivePrivate(obj, func);
}


function reduceObjectRecursive(obj, func, accum){
  // func(accum, value, key, baseObj, baseAddress)
  var thisAccum = accum;
  function executeFunc(value, key, baseObj, baseAddress){
    thisAccum = func(thisAccum, value, key, baseObj, baseAddress);
  }
  
  mapObjectRecursive(obj, executeFunc);
  return thisAccum;
}

function eachObjectRecursive(obj, func){

  function executeFunc(value, key, baseObj, baseAddress){
    func(value, key, baseObj, baseAddress);
  }
  
  mapObjectRecursive(obj, executeFunc);
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
function logLink(mainMessage, additionalText, link, attributes){
  var args = _.toArray(arguments),
      stringArgs = _.filter(args, _.isString),
      stringArgsLength = stringArgs.length;
  
  link = _.last(stringArgs);
  mainMessage = stringArgsLength > 1 ? stringArgs[0] : link,
  additionalText = stringArgsLength > 2 ? stringArgs[1] : mainMessage,
  attributes = args.length > stringArgsLength ? _.last(args): Log.CreateNewAttributes(); 
   
  Log.Link(link, mainMessage, additionalText, pmNormal, attributes);
}

/**
 Framework use only
**/
function TEST_SUMMARY_PREFIX(){
  return "=== Test Summary for ";
}

/**
 Framework use only
**/
function ABORT_ITERATION_TOKEN(){return SysUtilsParent.ABORT_ITERATION_TOKEN();}

/**
 Framework use only
**/
function ABORT_TEST_TOKEN(){return SysUtilsParent.ABORT_TEST_TOKEN();}

/**
 Framework use only
**/
function ABORT_RUN_TOKEN(){return SysUtilsParent.ABORT_RUN_TOKEN();}

/**

Converts an object to a readable text format . 
This can be usefull for generating readable logs. 

== Params ==
obj: Object -  Required -  the target object
indent: String - Optional -  Default: '\t' - the string to use for indenting child properties in result string
functionNamesOnly: Boolean -  Optional -  Default: true -  list function names rather than whole function source code
== Return ==
String - A readable string representing the object
== Related ==
toTempReadable
**/
function objectToReadable(obj, indent, functionNamesOnly){
  return SysUtilsParent.objectToReadable(obj, indent);
}

/**
Given a function returns its name

== Params ==
func: function -  Required -  a function
== Return ==
String - the name of the passed in function
**/
function functionNameFromFunction(func){
  var str = func.toString();
  return trim(subStrBetween(str, 'function', '('));
}

/**

performs a logical Xor

== Params ==
val1: Boolean -  Required -  first Boolean value
val2: Boolean -  Required -  second Boolean value
== Return ==
Boolean - returns true if XOr is true
**/
function xOr(val1, val2){
  return SysUtilsPrivate.xOr(val1, val2);
}


/**
Returns true if TestComplete is running in interactive (development) mode.

Note this assumes the user has have opened TestComplete then opened a project suite from within TestComplete.
If TestComplete is opened by double clicking a project or project suite file in windows explorer then this function will incorrectly return false

== Return ==
Boolean - true if in interactive mode and item opened from within TestComplete
**/
function isRunnningInInteractiveMode() {
  return BuiltIn.ParamCount() < 2;
}


/**
Splits an array into an array of chunks of a specified size + any items remaining in the last sub array
[[http://stackoverflow.com/questions/8495687/split-array-into-chunks]]
== Params ==
arr: Array -  Required - The source array
len: Integer -  Required - Chunk Size
== Return ==
arr: Array - an array of arrays in chunked size + remainder in the last array
**/
function chunk (arr, len) {
  // http://stackoverflow.com/questions/8495687/split-array-into-chunks
  var chunks = [],
      i = 0,
      n = arr.length;

  while (i < n) {
    chunks.push(arr.slice(i, i += len));
  }

  return chunks;
}

/**
Returns the index of an item in an array where a predicate function returns true. If you need the item itself (not the index) use
unederscore's find function: _.find.

/**

Given a (child) UI object will find the first (closest) parent (e.g. web form or panel that matches the property values provided)

== Params ==
childObject: Object -  Required - the base parented UI object
parentPropValsObj: Object -  Required - a criteria object with property name / values
refresh: Boolean - Optional - Default: true - whether to refresh the TestComplete object cache if the the search fails
== Return ==
Object - A UI object or stub object containing a single Exists property that is set to false
**/
function seekParent(child, criteriaObject, refresh){
  var arPropNames = _.keys(criteriaObject); 
  // workaround for underscore issues when values() does not work directly
  var arPropValues = _.chain(criteriaObject)
                      .values()
                      .value();
                      
  var nullObject = {Exists: false};
  
  function getResult(thisChild){
    if (!hasValue(thisChild)){
       return nullObject;
    } else if (thisChild.Find(arPropNames, arPropValues).Exists){
      return thisChild;
    }
    else {
      return getResult(thisChild.parent)
    }
  }
  
  return getResult(child);
}


/**
Performs the same function as seekParent but highlights the result - used for debugging
== Related ==
seekParent
**/
function seekParenth(child, criteriaObject, refresh){
  var result = seekParent(child, criteriaObject, refresh);
  highlight(result);
  return result;
}


/**
A demo method that does nothing - useful to make code self documenting when calling higher order functions
**/
function doNothing(){}

/**
A wrapper for [[http://support.smartbear.com/viewarticle/31874/|Log.PushLogFolder]]
== Params ==
message: String - Required - the message for the log folder
additionalInfo: String - Optional - Default: message - text to go into additional info for the log
bold: Boolean - Optional - Default: true - whether the title of the log folder is to be bolded
italic: Boolean - Optional - Default: false - whether the title of the log folder is to be Italicised
 **/
function pushLogFolder(message, additionalInfo, bold, italic){
  bold = def(bold, true);
  italic = def(italic, false);
  additionalInfo = def(additionalInfo, message);
  var attr = Log.CreateNewAttributes();
  attr.Bold = bold;
  attr.Italic = italic;
  Log.PushLogFolder(Log.CreateFolder(message, additionalInfo, pmNormal, attr));
}

/**
A wrapper around [[http://support.smartbear.com/viewarticle/26629/|Log.PopLogFolder]]
**/
function popLogFolder(){
  Log.PopLogFolder();
}

/**
Generates a Json string from a JavaScript object - a wrapper around JSON.stringify in Json2Utils
== Params ==
object: Object - Required - The object to be transformed to Json
space: Sting - Optional - Default: ' ' - an optional parameter that specifies the indentation
          of nested structures. If it is overridden with a blank string the text will
          be packed without extra white-space. If it is a number,
          it will specify the number of spaces to indent at each
          level. If it is a string (such as '\t' or '&nbsp;'),
          it contains the characters used to indent at each level.
replacer: function / String[] - Optional - Default: null - an optional parameter that determines how object
          values are stringified for objects. It can be a function or an array of strings.
== Return ==
String - Json representation of an object
== Related ==
jsonToObject
**/
function objectToJson(object, space, replacer){
  return SysUtilsParent.objectToJson(object, space, replacer);
}

/**
Parses Json to produce a JavaScript object - a wrapper around JSON.parse in Json2Utils
== Params ==
json: String -  Required - The string to be parsed
reviver: The optional reviver parameter is a function that can filter and
            transform the results. It receives each of the keys and values,
            and its return value is used instead of the original value.
            If it returns what it received, then the structure is not modified.
            If it returns undefined then the member is deleted.
== Return ==
Object - the object parsed from the json string 
== Related ==
objectToJson
**/
function jsonToObject(json, reviver){
  reviver = def(reviver, dateReviver);
  return SysUtilsParent.jsonToObject(json, reviver);
}

/**
Checks a UI object for the existence of a property
== Params ==
uiObject: Object -  Required - the target UI object
== Return ==
Boolean - Returns true if the property exists on the object
**/
function hasProperty(uiObject, propertyName){
  var result = false;
  // regular UI object
  var isRegularUIObject = false;
  var message;
  try {
    var result = IsSupported(uiObject, propertyName);
    isRegularUIObject = true;
  }
  catch (e) {
    message = e.message;
    ensure(hasText(message, "object doesn't support"));
  }
  
  // cells in grid do not support wait property 
  // so just try to access the object property directly
  if (!isRegularUIObject){
    var propVal = uiObject[propertyName];
    result = propVal !== undefined;
  }
  return result;
}

/**
Calls Sys.HighlightObject(uiObject) - see [[http://support.smartbear.com/viewarticle/32466/|TestComplete help]] for details
== Params ==
uiObject: Object -  Required - the target UI object
**/
function highlight(uiObject){
  SysUtilsPrivate.highlight(uiObject);
}


/**
waitRetry provides generic retry scaffolding. The function the isCompleteFunction is executed followed by the retryFuction and then
a delay for retryPauseMs. This continues until isCompleteFunction or timeoutMs is reached. 
== Params ==
isCompleteFunction: function(): Boolean -  Required - the function that tests if the desired end state has been reached
retryFuction: function(): void - Optional - An action to perform after each check e.g. refreshing a page
timeoutMs: Int - Optional - Default: 10000 - how long to wait before stopping retries
retryPauseMs: Int - Optional - Default: 1000 - how long to pause between retries
indicatorMessage: String -  Optional - the text for the indicator. If left blank there will be no indicator message. 
== Return ==
Boolean - Returns true is the event being waited on has occurred i.e. the isCompleteFunction has returned true before the time-out period has expired 
**/
function waitRetry(isCompleteFunction, /* optional */ retryFuction, /* optional */ timeoutMs, /* optional */ retryPauseMs, /* optional */ indicatorMessage){
  return SysUtilsPrivate.waitRetry(isCompleteFunction, retryFuction, timeoutMs, retryPauseMs, indicatorMessage);
}


/**
A constant.

Simply returns the chosen file encoding for the project - is hard coded to this value. This return value needs to be set to be 
the same as found in TestComplete project configuration <Tools><Project Properties><Units Encoding>. If this is incorrect reflection type
functions - such as reading the test case list will fail. ANSI - is the recommended encoding.

This constant is used as the default encoding in any functions that read or write to files.
== Return ==
Test Complete file encoding - aqFile.ctANSI in the default implementation
== Related ==
stringToFile, fileToString, arrayToFile, fileToArray
**/
function projectScriptFileEncoding(){return SysUtilsParent.projectScriptFileEncoding()}

/**
Terminates all instances of IE.
**/
function terminateInternetExplorer(){
  terminateProcess('iexplore');
}

/**
Logs a warning that a function is not implemented. Used as a reminder to finish something.
== Params ==
functionName: String -  Optional -  Default: 'FUNCTION' -  the function name for the log message
**/
function notImplementedWarning(functionName){
  logWarning(def(functionName,'FUNCTION') + ' NOT IMPLEMENTED');
}

/**
Turns on full call stack logging when ever there is a Message, Warning, Checkpoint or
event logged: see [[http://support.smartbear.com/viewarticle/27724/|TestComplete Help]] for details
on CallStackSettings
**/
function fullyEnableCallStack(){
  callStack = Log.CallStackSettings;
  callStack.EnableStackOnMessage = true;
  callStack.EnableStackOnWarning = true;
  callStack.EnableStackOnError = true;
  callStack.EnableStackOnCheckpoint = true;
  callStack.EnableStackOnEvent = true;
}


/**
Used with X or Y co-ordinates to calculate if 2 UI objects overlap either horizontally or vertically

==  Params ==
lowerBound1: Integer -  Required -  object1 lower bound
upperBound1: Integer -  Required -  object1 upper bound
lowerBound2: Integer -  Required -  object2 lower bound
upperBound2: Integer -  Required -  object2 upper bound
== Return ==
Boolean - returns true if bounds overlap
**/
function liesWithin(target, lowerBound, upperBound){
  return (target >= lowerBound && target <= upperBound);
}


/**

Checks if any of the bounds overlap. E.g. the tops and bottoms of two panels

== Params ==
lowerBound1: Integer -  Required -  e.g. the top (y value) of panel 1
upperBound1: Integer -  Required -  e.g. the bottom (y value) of panel 1
lowerBound2: Integer -  Required -  e.g. the top (y value) of panel 2
upperBound2: Integer -  Required -  e.g. the bottom (y value) of panel 1
== Return ==
Boolean - returns true if the bounds overlap
**/
function pointsOverlap(lowerBound1, upperBound1, lowerBound2, upperBound2){
  return  liesWithin(lowerBound1, lowerBound2, upperBound2) ||
          liesWithin(upperBound1, lowerBound2, upperBound2) ||
          liesWithin(lowerBound2, lowerBound1, upperBound1) ||
          liesWithin(upperBound2, lowerBound1, upperBound1);
}

/**
One of the most important functions in the framework. Allows you to find a UI object contained by another.
If one object or predicate is provided then seek will do a breath first search within the provided container of
all its child objects and return the first that matches the search criteria. If more than one criteria is
provided then seek will find an object matching the first search criteria, then search within this object
for an object matching the second search criteria an so on.

Search criteria can be either a simple criteria object e.g. {ObjectType: 'CheckBox', Visible: 'True'}
or a search predicate i.e. a function that takes a UI object as a parameter and returns true or false.

Note that criteria objects must use strings as values: e.g. Visible: 'True' â€“ and wild cards can be
used in string matching so Visible: 'T*e' would also find visible objects.

Note: The implementation of this function heavily utilises the
TestComplete [[http://support.smartbear.com/viewarticle/31663/|FindAllChildren]] method.

== Params ==
container: a UI object -  Required - a UI container such as a panel or web page
objOrPredicate1toN: Criteria -  Required -  a criteria object or a function used to specify the object
timeoutMs: Number -  Optional - Default: 10000 - how long to keep retrying for if the object is not found
maxDepth: Number -  Optional - Default: null - how many layers down to search for an item. E.g. If you are searching a panel with a depth of 1 it will search for all items in the panel and all items contained with it's direct children and no further. If this parameter is omitted then the search will be exhaustive i.e. fully recursive, all elements in the DOM will be inspected before the search fails.  
== Return ==
A UI Object matching the search criteria or a stub object with Exists property false
== Related ==
seekh, seekAll
**/
function seek(container, objOrPredicate1toN, timeoutMs, maxDepth){
  return findChildNested(arguments, false);
}

/**
Performs the exact same role as seek but highlights every matching object during the search.
See [[#seek|seek]] for details.
== Params ==
see [[#seek|seek]]
== Return ==
A UI Object matching the search criteria or a stub object with Exists property false
== Related ==
seek, seekAll
**/
function seekh(container, objOrPredicate1toN, timeoutMs, maxDepth){
  return findChildNested(arguments, true);
}


/**
Does the necessary translation for JScript for the testComplete FindAllChildren method. Criteria are passed in as a
JScript object {{{ e.g. {ObjectType: 'CheckBox', Visible: 'True'} }}} instead of arrays as in TestComplete. Also
search depth is defaulted to 100000 so full search is done by default.

See [[http://support.smartbear.com/viewarticle/31663/|TestComplete FindAllChildren]]
== Params ==
testObjOrAliasStr: UI Object or Alias -  Required - the parent object
propValsObj: JScript Object -  Required -  Criteria object as described above
depth: Int -  Optional -  Default: 10000 - how deep to search through the object hierarchy
refresh: Boolean -  Optional -  Default: true - whether to refresh the UI object cache before searching
== Return ==
An array of all UI Objects that match the criteria provided
== Related ==
seek, seekh
**/
function seekAll(testObjOrAliasStr, propValsObj, /* optional */ depth, /* optional */ refresh) {
  return SysUtilsPrivate.seekAll(testObjOrAliasStr, propValsObj, depth, refresh);
}

/**
A wrapper around [[http://support.smartbear.com/viewarticle/27181/|TestComplete Log.Error]]
== Params ==
message: String -  Required -  the main log message
additionalInfo: String -  Optional -  additional information if not provided the message is re-written to the 
additional information panel
attr: [[http://support.smartbear.com/viewarticle/31152/|TestComplete Log Attributes]] -  Optional -  see TestComplete help
== Related ==
log, logWarning
**/
function logError(message, additionalInfo, /* optional */ attr){
  SysUtilsParent.logError(message, additionalInfo, pmNormal, attr);
}

/**
A wrapper around [[http://support.smartbear.com/viewarticle/28693/|WaitAliasChild]]
Note this wrapper requires the alias  to be passed in as a string
== Params ==
aliasString: String -  Required -  the string representing the alias address
timeout: Int -  Optional -  Default: 10000 -  how long to keep retrying in milliseconds
throwExceptionOnFail: Boolean -  Optional -  Default: false -  whether to throw an exception on fail
== Return ==
 	A tested object - A mapped object 
**/
function waitAlias(aliasString, /* optional */ timeout, /* optional */ throwExceptionOnFail){
  // param kung fu
  if (_.isBoolean(timeout)){
    throwExceptionOnFail = timeout;
    timeout = null;
  }
  
  throwExceptionOnFail = def(throwExceptionOnFail, false);
  timeout = def(timeout, 10000);
  
  var result = Aliases;
  var parts = aliasString.split(".");
  
  // trim aliases if required
  if (sameText(parts[0], "Aliases")) {
    parts = parts.slice(1); 
  }
  
  for (var counter = 0; counter < parts.length; counter++){
    if(result.Exists) {
      // allow for parent object to be destroyed between finding one component and tyhe next
      try {
        result = result.WaitAliasChild(parts[counter], timeout);
      }
      catch (e) {
        var notFound = 'does not have a child with the name'
        if (!hasText(e.message, notFound) && !hasText(e.description, notFound)){
          throwEx(e.description, e.message);
        }
        result = {Exists: false};
      }
    }
    if(!result.Exists) {
      break; 
    }
  }
  
  if(throwExceptionOnFail && !result.Exists) {
    throwEx('waitAlias: ' + aliasString + ' does not exist');
  }
  
  return result;
}

/**
A wrapper around [[http://support.smartbear.com/viewarticle/30387/|TestComplete Log.Checkpoint]]
== Params ==
message: String -  Required -  the main log message
additionalInfo: String -  Optional -  additional information if not provided the message is re-written to the additional information view
priority: TestComplete log priority -  Optional -  Default: pmNormal -  the priority to display in the log
attr: [[http://support.smartbear.com/viewarticle/31152/|TestComplete LogAttributes]] - Optional - Default: normal attributes - see [[http://support.smartbear.com/viewarticle/30387/|TestComplete Log.Checkpoint]]
picture: String -  Optional -  Default: '' - see [[http://support.smartbear.com/viewarticle/30387/|TestComplete Log.Checkpoint]]
folderID: Int -  Optional -  Default: -1 - see [[http://support.smartbear.com/viewarticle/30387/|TestComplete Log.Checkpoint]]
== Related ==
log, logWarning, logError
**/
function logCheckPoint(messageText, /* optional */ additionalInformation,/* optional */ priority,/* optional */ attr,/* optional */ picture,/* optional */ folderID){
 SysUtilsParent.logCheckPoint(messageText, additionalInformation, priority, attr, picture, folderID);
}

/**
Logs a message in italic - see [[#log|log]]
== Params ==
message: String -  Required -  the log message
additionalInfo: String -  Optional -  Default: the main message - additional information will copy main message here if empty
== Related ==
log, logBold, logError, logWarning
**/
function logItalic(message, /* optional */ additionalInfo){
  var attr = Log.CreateNewAttributes();
  attr.Italic = true;
  log(message, additionalInfo, attr);
}

/**
Logs a message in bold - see [[#log|log]]
== Params ==
message: String -  Required -  the log message
additionalInfo: String -  Optional -  Default: the main message - additional information will copy main message here if empty
== Related ==
log, logItalic, logError, logWarning
**/
function logBold(message, additionalInfo){
  var attr = Log.CreateNewAttributes();
  attr.Bold = true;
  log(message, additionalInfo, attr);
}

/**
Logs a message. A wrapper around [[http://support.smartbear.com/viewarticle/33325/|TestComplete Log.Message]]
== Params ==
message: String -  Required -  the log message
additionalInfo: String -  Optional -  Default: the main message - additional information will copy main message here if empty
attr: [[http://support.smartbear.com/viewarticle/31152/|TestComplete LogAttributes]] - Optional - Default: normal attributes - log test attributes
== Related ==
logBold, logItalic, logError, logWarning
**/
function log(message, additionalInfo, /* optional */ attr){
  SysUtilsParent.log(message, additionalInfo, /* optional */ attr)
}


/**
Logs a warning. A wrapper around [[http://support.smartbear.com/viewarticle/30259/|TestComplete Log.Warning]]
== Params ==
message: String -  Required -  the log message
additionalInfo: String -  Optional -  Default: the main message - additional information will copy main message here if empty
attr: LogAttributes - see TestComplete help
== Related ==
logBold, logItalic, logError, logWarning
**/
function logWarning(message, additionalInfo, attr){
  SysUtilsParent.logWarning(message, additionalInfo, attr);
}

/**

A simple constructor function for the most common LogAttributes

== Params ==
bold: Boolean -  Optional -  Default: false -  if the log item is to be bold
italic: Boolean -  Optional -  Default: false -   if the log item is to be italic
== Return ==
TestComplete LogAttributes [[https://support.smartbear.com/viewarticle/73298/|TestComplete Help LogAttributes]] - LogAttributes used to set common properties of a TestComplete log items
**/
function logAttributes(bold, italic){
  return SysUtilsParent.logAttributes(bold, italic);
}



/**

Logs a link (a wrapper around: Log.link)

== Params ==
mainMessage: String - Optional - Default: link - the main log message
additionalText: String - Optional - Default: mainMessage - the message that appears in additional information pane
link: String - Required - the link text
attributes: TestComplete LogAttributes - Optional - Default: default LogAttributes - see TestComplete help
**/
function logLinkWithAttributes(mainMessage, additionalText, link, attributes){
  SysUtilsParent.logLinkWithAttributes(mainMessage, additionalText, link, attributes);
}

/**

Tests for equality. JavaScript === does not always yield the expected result for data types such as objects 
and DateTime. In the case of Strings this function will coerce a Number to a String when comparing a String with a non-String.

== Params ==
expected: Object -  Required -  object to compare 1
actual: Object -  Required -   object to compare 2
== Return ==
Boolean - true if objects are equal
**/
function areEqual(expected, actual){
  return SysUtilsPrivate.areEqual(expected, actual);
}

/**
Determines if object is null or undefined
== Params ==
arg: Object  -  Required -  object to test
== Return ==
Boolean - true if is null or undefined
== Related ==
def, isNullEmptyOrUndefined
**/
function isNullOrUndefined(arg)
{
  return SysUtilsParent.isNullOrUndefined(arg);
}

/**
Determines if object is null, undefined or an empty string
== Params ==
arg: Object  -  Required -  object to test
== Return ==
Boolean - true if is null, undefined or an empty string
== Related ==
def, isNullOrUndefined
**/
function isNullEmptyOrUndefined(arg){
  return SysUtilsParent.isNullEmptyOrUndefined(arg);
}
  
/**
Determines if an object has a value - an object is deemed NOT to have a value if the object: is null, is undefined, is an empty string or
is an object with an Exists property and that property is false. Otherwise the object is deemed to have a value.
== Params ==
arg: Object -  Required -  target object
== Return ==
Boolean - true if has a value as defined above
== Related ==
exists, isNullEmptyOrUndefined
**/
function hasValue(arg){
  return SysUtilsParent.hasValue(arg)
}


/**
Returns value of the Exists property if the object has an Exists property 
else returns true - use hasValue to check if defined or empty && exists
== Params ==
arg: Object -  Required -  target object
== Return ==
Boolean - true if exists
== Related ==
hasValue, isNullEmptyOrUndefined
**/
function exists(arg){
  return SysUtilsParent.exists(arg);
}

/**
Terminates all instances of a process of a given name
== Params ==
processName: String -  Required - name of the process to terminate
**/
function terminateProcess(processName){
  var process = Sys.WaitProcess(processName);
  while (process.Exists) {
    terminateProcessInstance(process);
    var process = Sys.WaitProcess(processName);
  } 
}

/**
Executes an executable file such as an *.exe or a *.bat. Optionally waits until the process finishes. 
== Params ==
filePath: String -  Required -  exe path
params: string -  Optional -  Default: "" - command line params
waitTillTerminated: Boolean -  Optional -  Default: true -  delay script until finished execution
== Return ==
object.Exec - gives access to StdIn, StdOut, StdErr streams. This result is usually not used
**/
function executeFile(filePath, params, waitTillTerminated){
  return SysUtilsParent.executeFile(filePath, params, waitTillTerminated);
}

/**
Determines if a process of a given name exists
== Params ==
processName: String -  Required - the process name
== Return ==
Boolean - whether the process exists
== Related ==
terminateProcess
**/
function processExists(processName){
  var process = Sys.WaitProcess(processName);
  return process.Exists;
}


/**

Logs a defect expectation. The framework can then use this information to determine if an error encountered is expected or not.
This information is used when generating the final log summary.

== Params ==
defectID: String -  Required -  an Id usually from the bug tracking system
active: if the bug is still present or has been fixed -  Optional -  Default: true -  change this to false when a bug is fixed
== Related ==
endDefect
**/
function expectDefect(defectID, active){
  Log.Message(DEFECT_EXPECTED_TOKEN() + defectID + ACTIVE_TOKEN() + def(active, "True"));
}


/**

Marks the end of a defect expectation

== Related ==
expectDefect
**/
function endDefect(){
  Log.Message(END_DEFECT_EXPECTED_TOKEN());
}

/**

Returns the first argument that is not null or undefined. If all arguments are null or undefined then the last argument is returned.
This is the way optional params are defaulted e.g. waitTime = def(waitTime, 0). Note that empty stings are NOT overridden by the default value. This is by design.

== Params ==
arg: Object - Required - the target object
defaultVal: Object - Required - the value to return if arg is null or undefined
== Return ==
Object - see description above
== Related ==
isNullOrUndefined
**/
function def(arg, defaultVal) {
  return SysUtilsParent.def.apply(null, _.toArray(arguments));
}

/**
Throws an exception but logs an error first. This can make the exception easier to trace in the call stack when reviewing a log file
== Params ==
errorMessage: String -  Required -  main exception message
detailMessage: String -  Optional - Default: errorMessage -  detail description
== Related ==
ensure
**/
function throwEx(errorMessage, detailMessage, abortLevel){
  SysUtilsParent.throwEx(errorMessage, detailMessage, abortLevel);
}

/**
Checks a condition and throws an exception if the condition is not met. This will terminate the test case when the condition is false in a test run
== Params ==
condition: Boolean -  Required -  the condition to met
message: String -  Required -  the exception message when the condition check fails
== Related ==
throwEx
**/
function ensure(condition, message, abortLevel) {
  SysUtilsParent.ensure(condition, message, abortLevel); 
}

/**

Forces an object to an array

== Params ==
val: AnyType -  Required -  the item to be forced into an array if it is not already
== Return ==
Array[AnyType] - the item wrapped in an array if it is a single value and just returns the value if it is already an array
**/
function forceArray(val){
  var args = _.toArray(arguments);
  return SysUtilsParent.forceArray.apply(null, args);
}


// NEVER DO THIS THIS IS ONLY HERE AS A BODGE
// JSCRIPT EXCEPTION HANDLING DOES NOT WORK PROPERLY
// AT TIME OF WRITING
/**
 Framework use only do not use this function
**/
function globalAbortLevel(){
  // yes its a global variable
  return SysUtilsGrandParent.globalAbortLevel;
}

// NEVER DO THIS THIS IS ONLY HERE AS A BODGE
// JSCRIPT EXCEPTION HANDLING DOES NOT WORK PROPERLY
// AT TIME OF WRITING
/**
 Framework use only do not use this function
**/
function resetGlobalAbortLevel(){
  // yes its a global variable
  return SysUtilsParent.resetGlobalAbortLevel();
}

/**
 Framework use only do not use this function
**/
function RED(){
  return SysUtilsParent.RED();
}

/**
 Framework use only do not use this function
**/
function GREEN(){
  return SysUtilsParent.GREEN();
}

/**
 Framework use only do not use this function
**/
function YELLOW(){
  return SysUtilsParent.YELLOW();
}

/**
 Framework use only do not use this function
**/
function ENUM_ERROR(){
  return SysUtilsParent.ENUM_ERROR();  
}

/**
 Framework use only do not use this function
**/
function ENUM_WARNING(){
  return SysUtilsParent.ENUM_WARNING();    
}

/**
 Framework use only do not use this function
**/
function ENUM_MESSAGE(){
  return SysUtilsParent.ENUM_MESSAGE();  
}

/**
 Framework use only do not use this function
**/
function ENUM_PASS(){
  return SysUtilsParent.ENUM_PASS();  
}

/**
 Framework use only do not use this function
**/
function fontColour(statusEnum){
  return SysUtilsParent.fontColour(statusEnum);
}

/**
 Framework use only do not use this function
**/
function logColourAttributes(statusEnum){
  return SysUtilsParent.logColourAttributes(statusEnum);
}

// © John Walker 2013 – Permission for unrestricted use and modification granted within 
// THE-COMPANY and affiliated companies




