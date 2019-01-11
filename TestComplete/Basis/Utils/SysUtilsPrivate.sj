//USEUNIT StringUtilsGrandParent
//USEUNIT SysUtilsGrandParent
//USEUNIT SysUtilsParent
//USEUNIT _
//USEUNIT EndPointLauncherUtils

function reorderProps(obj, propNames){
  var props = _.rest(_.toArray(arguments));
  var result = _.chain(obj)
                .pick(props)
                .defaults(obj)
                .value();
  return result;
}

function singleDefaultStep(target, defaults){
  var targDefined = !_.isUndefined(target); 
  
  if (!targDefined){
    if (isArrayDef(defaults)){
      var defaultBase = cloneDeep(defaults.defaultArray);
      var result = hasValue(defaultBase) && _.isArray(defaultBase) ? 
                          singleDefaultStep(defaultBase, defaults) : 
                          defaultBase;
      return result;
    }
    else {
      return cloneDeep(defaults);
    }
  }
  
  /* target defined and non object */
  else if (targDefined && !_.isObject(target)){
    return target;  
  }

  
  /* target defined and an array */
  else if (_.isArray(target)) {
    if (isArrayDef(defaults)){
      var itemDefault = cloneDeep(defaults.defaultArrayItem);
      function setDefaultsForItem(iTarg){
        return singleDefaultStep(iTarg, itemDefault);
      }
      return (hasValue(itemDefault)) ?
              _.map(target, setDefaultsForItem):
              target;      
    }
    else {
      return target;
    }
  }
  
  /* target defined and a normal object and defaults are a normal object */
  else if (!_.isArray(target) && 
              !_.isArray(defaults) && 
              !_.isFunction(target) && 
              !_.isFunction(defaults) && 
                _.isObject(target) && 
                _.isObject(defaults) && 
                !isArrayDef(defaults) 
                ){
    
    function defaultVal(val, key){
      return singleDefaultStep(val, defaults[key]) 
    }
    
    target = _.mapObject(target, defaultVal);
    
    var newKeys = _.difference(_.keys(defaults), _.keys(target));
    
    function addKeyVal(targ, key){
      targ[key] = singleDefaultStep(undefined, defaults[key])
      return targ;
    }
    return _.reduce(newKeys, addKeyVal, target);
  }
  
  /* target defined object and default is not an object */
  else {
    return target;
  }


}

function cloneDeep(obj){
  if (_.isArray(obj)){
    var base = _.map(_.range(obj.length), _.constant(undefined));
    function cloneItem(ignored, idx){
      return cloneDeep(obj[idx]);
    }
    return _.map(base, cloneItem);
  }
  else if (_.isFunction(obj)){
    return obj;
  }
  else if (_.isObject(obj)){
    return singleDefaultStep({}, obj)
  }
  else {
    return obj;
  }
}

function isArrayDef(obj){
  return _.isObject(obj) && !_.isArray(obj) && obj.isArrayDefObject;
}

function doNothing(){}

function unPackSeekInObjTrailingArgs(args){
  // arguments passed throughas arguments
  args = _.toArray(args);
  var boolArgs = _.filter(args, _.isBoolean),
      nonBoolArgs = _.reject(args, _.isBoolean);
      
  ensure(boolArgs.length === 2, 'invalid arguments passed in')
  
  return {
           returnFullInfo: boolArgs[0],
           wantAll: boolArgs[1],
           propSpecifiers: _.rest(nonBoolArgs) // first arg is target
         };
  

}

function unPackSeekInObjTrailingArgsEndPoint() {
  function callUnpack(){
    return unPackSeekInObjTrailingArgs(arguments);
  }
  
  
  var result = callUnpack({targ: 'ignored'}, 'prop1', 'propC', 'propGC', true);
      result = callUnpack({targ: 'ignored'}, 'prop1', 'propC', 'propGC', false);
      result = callUnpack({targ: 'ignored'}, 'prop1', 'propC', 'propGC');
      result = callUnpack({targ: 'ignored'}, 'prop1', true);
      result = callUnpack({targ: 'ignored'}, 'prop1');
}

function seekInObjArgs(argsArray, wantAll){
  if (!_.isBoolean(_.last(argsArray))){
    //default want all info to false
    argsArray.push(false);
  }
  argsArray.push(wantAll);
  return argsArray;
}

function seekInObjPriv(target, propNameStringsN, returnFullInfo, wantAll){

  var params =  unPackSeekInObjTrailingArgs(arguments),
                returnFullInfo = params.returnFullInfo,
                wantAll = params.wantAll,
                propSpecifiers = params.propSpecifiers;
                
  if (wantAll && propSpecifiers.length > 1){
    var privArgs = _.flatten([
                              [target], 
                              _.initial(propSpecifiers), 
                              [false, false]],
                              true // shallow
                              ),
    target = seekInObjPriv.apply(null, privArgs); 
    propSpecifiers = [_.last(propSpecifiers)];
  }
     
  var result = seekInObjBase(target, propSpecifiers, returnFullInfo, wantAll);
  
  function valueToValues(result){
    result.values = result.value;
    result = _.omit(result, 'value');
    return reorderProps(result, 'parent', 'values');
  }
  
  return (wantAll && isUndefined(result)) ? [] :
                                  wantAll && returnFullInfo ? _.map(result, valueToValues) : result;

}

function seekInObjBase(target, arPropSpecifiers, returnFullInfo, wantAll){
  if (!hasValue(target)) {
    return undefined;
  }
  
  ensure(!wantAll || arPropSpecifiers.length < 2, 'seekInObjBase invalid params');
  
  var seed =  {
               parent: target,
               value: undefined,
               key: null,
               address: ''
              };   
              
  function nextMatchingProp(accum, propSpec){
    if (!hasValue(accum)){
      return accum;
    }
    accum.parent = hasValue(accum.key) ? accum.parent[accum.key] : accum.parent;
    var result = findMatching(propSpec, accum, wantAll);
    return hasValue(result) ? result : undefined;
  }
     
  var result =  wantAll ? findMatching(arPropSpecifiers[0], seed, wantAll) : _.reduce(arPropSpecifiers, nextMatchingProp, seed);
  
  function getVal(result){
    return result.value;
  }
  return hasValue(result) ? 
                          returnFullInfo ? result :
                               wantAll ? _.map(result, getVal) : getVal(result):
                          result;
}


function makeMatchResultToResultFunction(searchInfo){
  return function matchResultToResult(matchResult){
     var address = searchInfo.address;
     return {
              parent: searchInfo.parent,
              value: matchResult.value,
              key: matchResult.key,
              address: address + (hasValue(address) ? '.' : '') + matchResult.key 
     };
  }
}

function findMatchingForNonArray(propSpec, searchInfo, wantAll){
  var arSearchTargets = forceArray(searchInfo),
      result = null;
      
  function matchesSpec(searchInfo){
    var matchResult = findMatchesPropSpec(searchInfo.parent, propSpec, wantAll);
    var found = hasValue(matchResult);
    if (found){
      var transFunc = makeMatchResultToResultFunction(searchInfo);
      result = wantAll ? _.map(matchResult, transFunc) : transFunc(matchResult); 
    }
    return found;
  }
  
  var matchingTarget;
  if (wantAll) {
    //result 
    _.filter(arSearchTargets, matchesSpec);
    var nextGen = nextGenOfProps(arSearchTargets);
    if (nextGen.length === 0){
      return result
    }
    else {
      var nextGenProps = findMatching(propSpec, nextGen, true);
      var combinedResult = _.flatten([result, nextGenProps], true); 
      return combinedResult;
    }
  }
  else { // single result
    matchingTarget = _.find(arSearchTargets, matchesSpec);
    if (hasValue(matchingTarget)){
      return result;
    }
    else { 
      return findForNextGen(arSearchTargets, propSpec, false).result;
    }
  }
}

function nextGenOfProps(arSearchTargets){
    return _.chain(arSearchTargets)
                  .map(childSearchItems)
                  .flatten()
                  .value(); 
}

function findForNextGen(arSearchTargets, propSpec, wantAll){
  var nextGen = nextGenOfProps(arSearchTargets);             
  return {
    result: nextGen.length > 0 ? findMatching(propSpec, nextGen, wantAll): null,
    nextGen : nextGen
  }
}

function makeMatchesIndexFunc(targetIndex){
  return function matchesIndex(val, index){
    return targetIndex === index;
  } 
}

function ARRAY_QUERY_ITEM_LABEL(){
  return '[Array Query Item]';
}

function findMatchingForArray(propSpec, searchInfo, wantAll){
  var target = searchInfo.parent,
      address = def(searchInfo.address, '');
  
  ensure(_.isArray(target), 'using an array property search parameter but the underlying property is not an array: ' + searchInfo.key, objectToJson(searchInfo));
  ensure(propSpec.length === 1, 'array in property search parameter must have a length of one');
  
  var specVal = propSpec[0],
      finder = _.isNumber(specVal) ? makeMatchesIndexFunc(specVal) : specVal,
      resultIndex = _.findIndex(target, finder);
  
  return resultIndex > -1 ? {
                  parent: searchInfo.parent,
                  value: target[resultIndex],
                  key: resultIndex,
                  address: address + (hasValue(address) ? '.' : '') + ARRAY_QUERY_ITEM_LABEL()
               } : null;
}

function findMatching(propSpec, searchInfo, wantAll){
  return _.isArray(propSpec) ? 
            findMatchingForArray(propSpec, searchInfo, wantAll): 
            findMatchingForNonArray(propSpec, searchInfo, wantAll);
}


function findMatchingEndPoint() {
  var obj = {
              prop1: 'Prrrrop1',
              pr2: 'Prr2',
              child: {
                      cp1: 'child prop 1',
                      commonChildProp: 'ChildPropFrom 1'
              
                      },
              child2: {
                        cp2: 'child prop 2',
                        commonChildProp: 'ChildPropFrom 2'
                      }
            }
            
   var input = {
                parent: obj,
                address: ''
               },
       result = findMatching('prop1', input);
       
  result = findMatching('cp2', input);
  result = findMatching('commonChildProp', input);
  result = findMatching('common*', input);
  result = findMatching('notThere', input);

}

function childSearchItems(searchItem){
  var parent = searchItem.parent,
      address = searchItem.address;
    
    
  function pairToSearchItem(kvp){
    var key = kvp[0],
        val = kvp[1];
        
    return {
              parent: val,
              address: address + (hasValue(address) ? '.' : '') + key
           }
  
  } 
    
  return _.chain(parent)
          .pairs()
          .filter(valueIsObjNotArray)
          .map(pairToSearchItem)
          .value()

}

function childSearchItemsEndPoint() {
    var obj = {
              prop1: 'Prrrrop1',
              pr2: 'Prr2',
              child: {
                      cp1: 'child prop 1',
                      commonChildProp: 'ChildPropFrom 1'
              
                      },
              child2: {
                        cp2: 'child prop 2',
                        commonChildProp: 'ChildPropFrom 2'
                      }
            }
            
    var result = childSearchItems({
                                  parent: obj,
                                  address: ''
                                 });
}


function valKeyFuncToTupleFunc(valKeyFunc){
  return function tupleFunc(keyValArray){
    return valKeyFunc(keyValArray[1], keyValArray[0]);
  } 
}

function findMatchesPropSpec(obj, propSpec, wantAll){
  var matcher = valKeyFuncToTupleFunc(makeMathcherFunction(propSpec)),
      kvPairs = _.pairs(obj);
      
  function tupleToResult(tpl){
    return  {
      key: tpl[0],
      value: tpl[1]
    };
  }
  
  if (wantAll) {
    var resultTuples = _.filter(kvPairs, matcher);
    return hasValue(resultTuples) ? _.map(resultTuples, tupleToResult) : [];
  }
  else { 
    var resultTuple = _.find(kvPairs, matcher);
    return hasValue(resultTuple)? tupleToResult(resultTuple): undefined;
  }
}

function findMatchesPropSpecEndPoint() {
  var obj = {
              prop1: 'Prrrrop1',
              pr2: 'Prr2'
            }
            
  var result = findMatchesPropSpec(obj, 'prop1', false);
  result = findMatchesPropSpec(obj, 'pr*', false);
  result = findMatchesPropSpec(obj, '*2', false);
  result = findMatchesPropSpec(obj, 'notthere', false);
}

function makeMathcherFunction(propSpec){
  if (_.isFunction(propSpec)){
    return propSpec; 
  }
  else if (_.isObject(propSpec)){
    return makePropertyComparerFunction(propSpec);
  }
  else if (_.isString(propSpec)) {
    return function matchesSpec(val, key){
      return hasText(propSpec, '*', true) ? wildcardMatch(key, propSpec) : key === propSpec;
    }
  }
  else {
    throwEx('Invlaid poperty specification: must be a function, object or string');
  }
}

function makePropertyComparerFunction(propSpec){
  return function matchesSpec(val, key){
    return propMatchesValues(val, propSpec);
  }
}

function propMatchesValues(candidate, propSpec){
  function matchesSpecProp(result, matchVal, matchKey){
    if (!result){
      return result;
    }
    var actual = candidate[matchKey];
    return result && (
      areEqual(matchVal, actual) || wildcardMatch(actual, matchVal)
    ); 
  }
  return _.reduce(propSpec, matchesSpecProp, true)
}

function propMatchesValuesEndPoint() {
  function check(result){
    if (result){
      logCheckPoint('check');
    }
    else {
      logError('check');
    }
  }
  
  var eg = {
              given: 'Che',
              family: 'Guvera'
            };
            
  var spec = {
                given: 'Che',
                family: 'Guvera'
              };
  var result = propMatchesValues(eg, spec);
  check(result);
  
  spec =  {
                given: 'Ch*',
                family: 'G*a'
              };
  result = propMatchesValues(eg, spec);
  check(result);
  
  spec =  {
                given: '*p*',
                family: 'G*a'
              };
  result = propMatchesValues(eg, spec);
  check(!result);
}

function areEqualWithTolerance(expectedNumber, actualNumber, tolerance){
  ensure(_.isNumber(tolerance) && tolerance >= 0 && tolerance < 1, 'tolerance must be numeric and greater or equal to zero and less than one');
  
  var deemedEqual = areEqual(actualNumber, expectedNumber, false);
  
  function parseNumIfPossible(val){
    return !_.isNumber(val) && stringConvertableToNumber(val) ? parseFloat(val) : val;
  }

  if (!deemedEqual){  
    var expectedNumberConverted = parseNumIfPossible(expectedNumber),
        actualNumberConverted = parseNumIfPossible(actualNumber);

    if (_.isNumber(actualNumberConverted) && _.isNumber(expectedNumberConverted)){
      var diff = Math.abs(actualNumberConverted - expectedNumberConverted);
      // 0.10 !== 0.10 in javascript :-( work around
      // deemedEqual = diff <= tolerance will not work
      deemedEqual = !(diff > (tolerance + 0.0000000000000001));
    }
  }
  return deemedEqual;
}

function areEqual(expected, actual, useTolerance){
  useTolerance = def(useTolerance, true);
  
  function asString(val){
    return  !hasValue(val) ? val :
            _.isString(val) ? val :
            _.isFunction(val.toString) ? val.toString():
            val; 
  }
  
  var result;
  if (!result) {
    if (xOr(hasValue(expected), hasValue(actual))) {
      result = false;
    } else if (expected === null && actual === null){
      result = true;
    } else if (xOr(_.isString(expected), _.isString(actual))) {
      return asString(expected) === asString(actual);
    } else if (_.isArray(expected) && _.isArray(actual)){
      return arraysEqual(expected, actual);
    } else if (_.isObject(expected) && _.isObject(actual)){
      return objectsEqual(expected, actual);
    } else if (useTolerance && _.isNumber(expected) && _.isNumber(actual)) {
      return areEqualWithTolerance(expected, actual, 0)
    } else {
      var varType = GetVarType(actual);
      switch (varType){
        case 7: // Date
          result = aqDateTime.Compare(expected, actual) === 0;
          break;

        default:
          result = _.isEqual(expected, actual);
          break;
      }
    }
    return result;
  }
}

function objectsEqual(expected, actual){
  
  function valEqualsActual(accum, expectedVal, expectedKey){
    return !accum ? accum : areEqual(expectedVal, actual[expectedKey]);
  }
  
  return _.allKeys(expected).length === _.allKeys(actual).length ?
              _.reduce(expected, valEqualsActual, true) : false;
}

function arraysEqual(expected, actual){
  function elementsEqual(pair){
    return areEqual(pair[0], pair[1]);
  }
  return expected.length === actual.length ? 
                                            _.chain(expected)
                                              .zip(actual)
                                              .all(elementsEqual)
                                              .value() : 
                                              
                                            false;
}

function xOr(val1, val2){
  return (val1 || val2) && !(val1 && val2);
}

function valueIsObjNotArray(pair){
  var val = pair[1];
  return !_.isArray(val) && _.isObject(val);
}   

var baseTransLogFileNameSuffix = 0;
function baseTransLogFileName(){
 return 'defo' + aqConvert.DateTimeToFormatStr(now(), '%y-%m-%d-%H-%M-%S_' + (++baseTransLogFileNameSuffix))
}
  
function nonArrayObject(val){
  return _.isObject(val) && !_.isArray(val)
}

function arrayDefault(target, arrayDefObj){
  var defaultArray = arrayDefObj.defaultArray,
      defaultArrayItem = arrayDefObj.defaultArrayItem,
      result = isUndefined(target) ? cloneArray(defaultArray) : target;
  
  function defaultItem(subTarg){
    return defaultSingleObjectRecursive(subTarg, defaultArrayItem);
  }
  
  return _.isArray(target) ? _.map(target, defaultItem) : target;
}

function terminateProcessInstance(process){
  var timeout = 10;
  var tryCount = 0;
  do {
    if (process.Exists){
      process.Terminate();
      tryCount = tryCount + 1;
    }
    
    if (process.Exists) {
      Delay(1000, "Waiting for process: " & processName & " to terminate.");
    } 
    else {
      break;
    }
  }  while (tryCount < timeout)


   if (process.Exists){
      throwEx("Failed to teminate process: " & processName & " after a rest period of: " & timeout & " seconds.");
   } 
}

function waitRetry(isCompleteFunction, /* optional */ retryFuction, /* optional */ timeoutMs, /* optional */ retryPauseMs, /* optional */ indicatorMessage){
  //Super param KungFu
  indicatorMessage = _.find(arguments, _.isString);
  var nums = _.filter(arguments, _.isNumber);
  timeoutMs = nums.length > 0 ? nums[0]: 10000;
  retryPauseMs = nums.length > 1 ? nums[1] : 0;
  var retryFuction = _.isFunction(retryFuction) ? retryFuction : doNothing;
  
  var stopWatch = HISUtils.StopWatch;
  stopWatch.Start();
  var complete = false;
  do {
    complete = isCompleteFunction();
    var finished = complete || stopWatch.Split() > timeoutMs;
    if (!finished){
      Delay(retryPauseMs, indicatorMessage);  
      retryFuction();
    }
  } while (!finished);
  
  return complete;
}

function highlight(uiObject){
  Sys.HighlightObject(uiObject);
}

function depthFromContainer(child, container, curretDepth){
  var result = def(curretDepth, 0);
  ensure(hasValue(child), 'depthFromContainer - child object is not contained by the container');
  return child.FullName === container.FullName ? result : depthFromContainer(child.Parent, container, result + 1);
}
  
function findChildNested(passedThroughArgs, wantHighlight){
  // Super param kungFu
  // convert to array slice off container
  var args = _.toArray(passedThroughArgs);
  var container = args[0];
  var args = args.slice(1);
  // all other objects are criteria objects
  var criteriaObjects = _.filter(args, _.isObject);
  var timeoutMs, maxDepth;
  
  var arNumberArgs = _.filter(args, _.isNumber);
  switch ( arNumberArgs.length ) {
    case 0:
      // maxDepth null means ignore
      timeoutMs = 10000;
      maxDepth = null;
      break;
  
    case 1:
      timeoutMs = arNumberArgs[0];
      maxDepth = null;
      break;
    
    case 2:
      timeoutMs = arNumberArgs[0];
      maxDepth = arNumberArgs[1];
      break;
  
    default:
      throwEx('findChildNested - inavlid arguments too many numbers');
  }
  
  // maxDepth null means ignore
  var depthAllowable = maxDepth;
  var result = {Exists: false};
  
  function tryFindChild(){
    if (container.Exists){
      container.Refresh();
      var currentUiObject = null;
    
      for (var counter = 0; counter < criteriaObjects.length; counter++){
        if (counter === 0){
          currentUiObject = container;
        }
    
        var thisObjOrFunc = criteriaObjects[counter];
        var uiObjValid = hasValue(currentUiObject);
        var testObjValid = hasValue(thisObjOrFunc);
        if (uiObjValid && testObjValid){
          currentUiObject = getNextChild(currentUiObject, thisObjOrFunc, wantHighlight, depthAllowable);
          if (hasValue(depthAllowable) && hasValue(currentUiObject)){
            var depthOfObject = depthFromContainer(currentUiObject, container);
            depthAllowable = maxDepth - depthOfObject;
            if (depthAllowable < 0){
              currentUiObject = null;
              break; 
            }
          }
        } 
        else {
          break;
        }
      }
  
      if (hasValue(currentUiObject)){
        result = currentUiObject;
      }
    }
    return result.Exists;
  }
  
  waitRetry(tryFindChild, timeoutMs);
  
  return result;
}

function getNextChild(container, filterObjOrFunc, wantHighlight, maxDepth){
  var result;
  if (_.isFunction(filterObjOrFunc)){
    result = findChildMatchingPredicate(container, filterObjOrFunc, maxDepth);
  } 
  else {
  
    // new way still not performant so diabled
    var newWay = false; 
    if (newWay) {
      var arPropNames = _.keys(filterObjOrFunc); 
      var arPropValues = _.values(filterObjOrFunc); 
      
      function isTarget(testObj){
        testObj = _.isString(testObj) ? waitAlias(testObj) : testObj;
        var resultObj = testObj.Find(arPropNames, arPropValues, 0, true);
        var result = resultObj.Exists;
        return result;
      }
      
      result = findChildMatchingPredicate(container, isTarget, maxDepth);
    }
    else {
      result = findChild(container, filterObjOrFunc, maxDepth);
    }
    
    
  }
  
  if (!isNullOrUndefined(result) && wantHighlight){
    highlight(result);
  }
  return result;
}

//var StopWatch = HISUtils.StopWatch;
//var StopWatch2 = HISUtils.StopWatch;

function findChildMatchingPredicate(container, filter, maxDepth){
  var candidates = [container];
  var result = null;
  // null maxdepth means ignore depth
  var depthAllowable = maxDepth;
  do {
  // Starts the time counter
 // StopWatch.Start();
    if (hasValue(depthAllowable) && depthAllowable < 1){
      break;
    }
    candidates = takeNextGenerationOfObjects(candidates); 
 // StopWatch.Stop();
 // Log.Message('Candidatte Time: ' + StopWatch.ToString());
  
  // test only
// var len = 0;
 // _.each(candidates, function(obj){len++});
 // Log.Message('Generation Length: ' + len);
  // 
    
 // StopWatch2.Start();
    result = _.find(candidates, filter);
    depthAllowable = hasValue(depthAllowable) ? depthAllowable - 1 : depthAllowable;
 // StopWatch2.Stop();
//  Log.Message('Candidatte Filter Time: ' + StopWatch2.ToString());
   
  }
  while (isNullOrUndefined(result) && candidates.length > 0);
  return result;
}


function takeNextGenerationOfObjects(arContainers){
  /* This didn't work
  var result = [];
  var length = arContainers.length;
  for (var counter = 0; counter < length; counter++){
    var childObj = arContainers[counter];
    
    var chldName = childObj.FullName;
    if (chldName === 'Sys.Browser("iexplore").Page("https://secure.rosterlive.net/SignIn.aspx")'){
      delay(1);
    }
    
    if(isNullOrUndefined(childObj)){
      continue;
    }
    var childCount = childObj.ChildCount;
    for (var childCounter = 0; childCounter < childCount; childCounter++){
      var STR_DELETE_ME = childObj.Child(childCounter).FullName;
      if (STR_DELETE_ME === 'Sys.Browser("iexplore").Page("https://secure.rosterlive.net/SignIn.aspx").Form("formSignIn")') {
        delay(1);
      }
        result.push(childObj.Child(childCounter));   
    }  
  }
  return result;*/
  
  //This seems to work
  var result = [];
  var length = arContainers.length;
  for (var counter = 0; counter < length; counter++){
    var childObj = arContainers[counter];
    if(isNullOrUndefined(childObj)){
      continue;
    }
    var allChildren = seekAll(childObj, {FullName:'*'}, 1);
   result.push.apply(result, allChildren);
  }
  return result;
  
//  THIS WORKS BUT IS SLOW
//  return _.chain(arContainers)
//        .filter(function(obj){return !isNullOrUndefined(obj)})
//        .map(function(uiObj){return seekAll(uiObj, {FullName:'*'}, 1)})
//        .flatten()
//        .value(); 

}


// Does the necessary translation fo jscript of
// tc method FindChild - also replaces depth so full search is done by default
function findChild(testObjOrAliasStr, propValsObj, /* optional */ depth, /* optional */ refresh) {
  var DEFAULT_DEPTH = 20000;
  depth = def(depth, DEFAULT_DEPTH);
   
  function findChild(testObject, arPropNames, arPropValues, depth, refresh) {
    var result = testObject.FindChild(arPropNames, arPropValues, depth, refresh);
    return result; 
  } 
  
  return findInChildrenShared(findChild, testObjOrAliasStr, propValsObj, depth, refresh);
}

// Does the necessary translation fo jscript of
// tc method FindAllChildren  - also replaces depth so full search is done by default
function seekAll(testObjOrAliasStr, propValsObj, /* optional */ depth, /* optional */ refresh) {
  depth = def(depth, 20000);
  function findAll(testObject, arPropNames, arPropValues, depth, refresh) {
    var resultVbArray = testObject.FindAllChildren(arPropNames, arPropValues, depth, refresh);
    var result = (new VBArray(resultVbArray)).toArray();
    return result;  
  }
  
  return findInChildrenShared(findAll, testObjOrAliasStr, propValsObj, depth, refresh);
}

// Does the necessary translation fo jscript of
// tc method FindAllChildren
function findInChildrenShared(childFunc, testObjOrAliasStr, propValsObj, /* optional */ depth, /* optional */ refresh) {
  /* 
    === Defaults same as for TestComplete ==
      Depth [in]    Optional    Integer Default value: 1    
      Refresh [in]  Optional    Boolean Default value: True
  */ 
  depth = def(depth, 10000);
  refresh = def(refresh, true);
  
  var arPropNames = _.keys(propValsObj); 
  // workaround for underscore issues when values() does not work directly
  var arPropValues = _.chain(propValsObj)
                      .values()
                      .value(); 
  
  var testObj = _.isString(testObjOrAliasStr) ? waitAlias(testObjOrAliasStr) : testObjOrAliasStr;
  var result = childFunc(testObj, arPropNames,arPropValues, depth, refresh);
  return result;
}

// © John Walker 2013 – Permission for unrestricted use and modification granted within 
// THE-COMPANY and affiliated companies