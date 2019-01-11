//USEUNIT SysUtils
//USEUNIT CheckUtils
//USEUNIT DataEntryUtils
//USEUNIT _

function convertToDomTree(domElements) {
  var objectMap = arrayToObject(domElements, 'fullName');
  
  function nestUnderParent(parentObjectsAccum, propObj){
    if(_.has(objectMap, propObj.parentFullName)){
      parentObjectsAccum[propObj.parentName] = objectMap[propObj.parentFullName];
      parentObjectsAccum[propObj.parentName][propObj.name] = objectMap[propObj.fullName];
    } 
    return parentObjectsAccum; 
  }
  
  var parentObjects = _.reduce(domElements, nestUnderParent, {});
  
  function filterParentFullNameNotInFullNameObjectMap(propObj){
      return _.has(parentObjects, propObj.parentName);
  }
  
  var rootElements = _.reject(domElements, filterParentFullNameNotInFullNameObjectMap);
  return arrayToObject(rootElements, 'name');
}

function arrayToObject(arr, keyPropName){
  var propNames = _.pluck(arr, keyPropName);
  return _.object(propNames, arr);
}

function linkValid(linkedTestObj) {
  var link = linkedTestObj.href;
  var error = {message: '', description: ''};

  function errorEncountered(){
    hasValue(error.message);
  }

  try {
    var httpObj = getHttpResponse(link, error);
    if(!errorEncountered()) {
      status = httpObj.status;
      var responseText = httpObj.responseText;
      if (!(status === 200 || status === 302)){
        error.message = 'Unexpected status code: ' + status + ': ' + linkInfo;
        error.description = responseText;
      }
    }
  }
  catch (e) {
    error.message = 'Exception encountered while testing link: ' + link + ' - ' + e.description;
    error.description = 'Exception encountered while testing link: ' + link + newLine() + e.description + newLine() + e.message;
  }

  return {
          link: link,
          text: linkedTestObj.contentText,
          linkValid: !errorEncountered(),
          error: errorEncountered() ? error : null
         }
} 

function indent(line){ 
  line = trim(line);
  indentSpaces = line === '}' || line === '{'  ? '\t\t' : '\t\t\t' ;
  line = indentSpaces + line;
  return line;
}

function fixJsonIncLineSuffix(line, suffix){
  if (hasText(line, ':')){
    var items = bisect(line, '":');
    if (hasText(items[1], 'null')) {
      return items[0] + '": ' + 'params.' + suffix;
    }
    else {
      return trimChars(items[0], [' ', '"']) + ': ' + 'params.' + suffix;
    }
  }
  else {
    return line;
  }
}

function getClosestLabelWithText(dataObjectAndCordinates, searchSetInfo) {
  function closestLabel(closest, candidate){
    var distance = distanceLabelToDataObject(dataObjectAndCordinates, candidate, CLOSEST_TO_LABEL);
    if (hasValue(distance) && distance < closest.distance){
      closest.distance = distance;
      closest.label = candidate;
    }
    else if (hasValue(distance) && distance === closest.distance){
     var dataObject = dataObjectAndCordinates.object;
     if (!centrePassesThroughTarget(dataObjectAndCordinates, closest.label) && centrePassesThroughTarget(dataObjectAndCordinates, candidate)){
      closest.distance = distance;
      closest.label = candidate;
     }
    }
    return closest;
  }
  var result = _.reduce(searchSetInfo.labelsWithCoordinates, closestLabel, {label: null, distance: 10000000});
  return result.label;
}

function getSearchSetInfo(container, data, setFunctionOverride){
  // param kung fu
  var args = _.toArray(arguments);
  setFunctionOverride = _.find(args, _.isFunction);
  var hasContainer = hasValue(container) && hasValue(container.Exists);
  data = hasContainer ? data : container;
  container = hasContainer ? container : activePage();
  
  container = def(container, activePage());
  var objectsAndLabels = getDataObjectsAndLabelsWithCoordinates(container);

  var searchSetInfo = {
    data: data,
    labelsWithCoordinates: _.sortBy(objectsAndLabels.labelsWithCoordinates, textLengthTreatLabelsAsSpecial),
    dataObjectsWithCoordinates: objectsAndLabels.dataObjectsWithCoordinates,
    dataObjectsWithCoordinatesByIdStr: _.sortBy(objectsAndLabels.dataObjectsWithCoordinates, getIdStr),
    dataObjectsWithCoordinatesByObjIdentifier: _.sortBy(objectsAndLabels.dataObjectsWithCoordinates, getObjIdentifier),
    setFunction: def(setFunctionOverride, set)
  }
  
  return searchSetInfo;
}

function getObjIdentifier(obj){
  return obj.object.ObjectIdentifier;
}

function getIdStr(obj){
  return obj.object.idStr;
}

/**
* modofoed from http://oli.me.uk/2013/06/08/searching-javascript-arrays-with-a-binary-search/
* Performs a binary search on the host array. This method can either be
* injected into Array.prototype or called with a specified scope like this:
* binaryIndexOf.call(someArray, searchElement);
*
* @param {*} searchElement The item to search for within the array.
* @return {Number} The index of the element which defaults to -1 when not found.
*/
function sortedIndexOfProp(arr, propName, searchElement) {
    var minIndex = 0;
    var maxIndex = arr.length - 1;
    var currentIndex;
    var currentElement;
    searchElement = trim(def(searchElement, ''));

    while (minIndex <= maxIndex) {
        currentIndex = (minIndex + maxIndex) / 2 | 0;
        currentElement = trim(def(arr[currentIndex].object[propName]));

        if (currentElement < searchElement) {
            minIndex = currentIndex + 1;
        }
        else if (currentElement > searchElement) {
            maxIndex = currentIndex - 1;
        }
        else {
            return currentIndex;
        }
    }
    return -1;
}

function linkArgs(passThroughArgs){
  var args = _.toArray(passThroughArgs);
  var criteria = {
    ObjectType: 'Link',
    contentText: args[args.length - 1]
  }
  args.splice(args.length - 1, 1, criteria);
  return args;
}

function click(obj){
  obj.Click();
}

function sliceAndApply(seekFunction, secondFunction, passThroughArgs, secondFunctionArgsCount, noAssert){
  passThroughArgs =_.toArray(passThroughArgs);
  var secondFunctionArgs = passThroughArgs.slice(passThroughArgs.length - secondFunctionArgsCount, passThroughArgs.length);
  var seekFunctionArgs = passThroughArgs.slice(0, passThroughArgs.length - secondFunctionArgsCount);
  var obj = seekFunction.apply(null, seekFunctionArgs);
  ensure(noAssert || hasValue(obj), 'Object does not exist');
  return secondFunction.apply(null, [obj].concat(secondFunctionArgs));
}


DATA_OBJECT_TO_RIGHT ='R';
DATA_OBJECT_TO_LEFT ='L';
DATA_OBJECT_ABOVE ='A';
DATA_OBJECT_BELOW = 'B';
CLOSEST_TO_LABEL = '*';

function setFormElement(lblTextorIdStr, value, searchSetInfo){
  var setFunction = searchSetInfo.setFunction,
    searchText =  trimWhiteSpace(lblTextorIdStr),
    labelsWithCoordinates = searchSetInfo.labelsWithCoordinates,
    dataObjectsWithCoordinates = searchSetInfo.dataObjectsWithCoordinates,
    dataObjectsWithCoordinatesByIdStr = searchSetInfo.dataObjectsWithCoordinatesByIdStr,
    dataObjectsWithCoordinatesByObjIdentifier = searchSetInfo.dataObjectsWithCoordinatesByObjIdentifier,
    directionModifier = getSearchModifier(searchText);
    
    
  searchText = directionModifier === CLOSEST_TO_LABEL 
                    ? searchText 
                    : searchText.substr(0, searchText.length - 2);
    
  var searchBits = _.reject(removeLineEndings(searchText).split('*'), function(str){return str === '';});
 
  var targetContainer;
  var idStrIdx = sortedIndexOfProp(dataObjectsWithCoordinatesByIdStr, 'idStr', lblTextorIdStr);
  if (idStrIdx > -1){
    targetContainer = dataObjectsWithCoordinatesByIdStr[idStrIdx];
  }
  else {
    var objIdentIdx = sortedIndexOfProp(dataObjectsWithCoordinatesByObjIdentifier, 'ObjectIdentifier', lblTextorIdStr);
    targetContainer = (objIdentIdx > -1) ? dataObjectsWithCoordinatesByObjIdentifier[objIdentIdx] : 
                        targetContainerFromLabelText(searchBits, directionModifier, labelsWithCoordinates, dataObjectsWithCoordinates);
  }

  if (hasValue(targetContainer)){
    if (_.isFunction(value)){
      value(targetContainer.object);
    }
    else {
      setFunction(targetContainer.object, value);
    }
  }
  else {
    logError('Failed to set form data form data for: '+ lblTextorIdStr); 
  }
}

function textLengthTreatLabelsAsSpecial(obj){
  return obj.object.contentText.length + (obj.object.ObjectType === 'Label' ? -1 : 0)
}

function targetContainerFromLabelText(searchBits, directionModifier, labels, dataObjects){
  
  function matchText(str){
    return matchContentText(searchBits, str)
  }
  
  function contentTextMatches(lblObject){
    return matchText(lblObject.object.contentText);
  }
  
  // Note labels previously sorted by text length so will pick the match 
  //with the shortest label
  var targetLabel = _.find(labels, contentTextMatches);
  
  if (hasValue(targetLabel)) {
    return closestObject(targetLabel, dataObjects, directionModifier);
  }
  else {
    logError('Label object or idStr / ObjectIdentifier not found : ' + searchBits.join('*'));
    return null;
  }                  
}

function targetFromLabelTestEndPoint() {
  //assumes you are here: http://support.smartbear.com/samples/testcomplete10/weborders/Process.asp
  var container = seekByIdStr('ctl00_MainContent_fmwOrder');
  var lblsObjs = getDataObjectsAndLabelsWithCoordinates(container);
  var regEx = wildCardRegEx('Product:*');
  var obj = targetContainerFromLabelText(regEx, '*', lblsObjs.labels, lblsObjs.dataObjects);
  highlight(obj);
}

function closestObject(targetLabel, dataObjects, directionModifier){
  function chooseBestObject(bestSoFar, candidate){
    return nearestObject(targetLabel, directionModifier, candidate, bestSoFar); 
  }
  var result = _.reduce(dataObjects, chooseBestObject, null);
  return result;
}

function isCheckableObject(uiObject){
  return hasValue(uiObject) && (sameText(uiObject.ObjectType, 'Checkbox') || sameText(uiObject.ObjectType, 'RadioButton'));
}

function closestObjectEndPoint() {
  //assumes you are here: http://support.smartbear.com/samples/testcomplete10/weborders/Process.asp
  var uiObjectLabel = seekInPage({contentText:'MasterCard', ObjectType:'Label'});
  var mastercardlabel = addCoordinates(uiObjectLabel);
  var dataObjects = getDataObjectsAndLabelsWithCoordinates(activePage()).dataObjects;
  
  obj = closestObject(mastercardlabel, dataObjects, CLOSEST_TO_LABEL);
  highlight(obj);
  

  var productLabel = addCoordinates(Aliases.browser.pageWebOrders.formAspnetform.textnode);
  var obj = closestObject(productLabel, dataObjects, CLOSEST_TO_LABEL);
  highlight(obj);
}

function nearestObject(targetLabel, directionModifier, candidate, bestSoFar){  
  var distanceFromTarget = distanceLabelToDataObject(candidate, targetLabel, directionModifier);
  if (hasValue(distanceFromTarget) && (!hasValue(bestSoFar) || distanceFromTarget < bestSoFar.distanceFromTarget ||
      (distanceFromTarget === bestSoFar.distanceFromTarget && !bestSoFar.labelCentred))){
    candidate.distanceFromTarget = distanceFromTarget;  
    candidate.labelCentred = centrePassesThroughTarget(candidate, targetLabel, directionModifier);
    return candidate;
  }
  else {
    return bestSoFar;
  }
}

function distanceLabelToDataObject(candidate, targetLabel, directionModifier){
   function veritcalOverlap(targetLabel, candidate){
    return pointsOverlap(candidate.top, candidate.bottom, targetLabel.top, targetLabel.bottom);
  }
  
  function pixToRight(candidate, targetLabel){
    return targetLabel.right <= candidate.left && veritcalOverlap(targetLabel, candidate) ? 
           candidate.left - targetLabel.right: null;
  }
  
  function pixToLeft(candidate, targetLabel){
    return targetLabel.left >= candidate.left /* using .left not .right because some labels envelop their control esp clickable controls */ && veritcalOverlap(targetLabel, candidate) ?
         max(targetLabel.left - candidate.right, 0) : null;
  }
  
  function horizontalOverlap(targetLabel, candidate){
    return pointsOverlap(candidate.left, candidate.right, targetLabel.left, targetLabel.right);
  }
  
  function pixAbove(candidate, targetLabel){
    return targetLabel.top >= candidate.bottom  && horizontalOverlap(targetLabel, candidate) ?
          targetLabel.top - candidate.bottom: null;
  }
  
  function pixBelow(candidate, targetLabel){
    return targetLabel.bottom <= candidate.top && horizontalOverlap(targetLabel, candidate) ?
         candidate.top - targetLabel.bottom: null;
  }
  
  var distanceFromTarget;
  switch (directionModifier) {
    case DATA_OBJECT_ABOVE:
      distanceFromTarget = pixAbove(candidate, targetLabel); 
      break;
  
    case DATA_OBJECT_BELOW:
      distanceFromTarget =  pixBelow(candidate, targetLabel); 
      break;
      
    case DATA_OBJECT_TO_RIGHT:
      distanceFromTarget = pixToRight(candidate, targetLabel); 
      break;
      
    case DATA_OBJECT_TO_LEFT:
      distanceFromTarget = pixToLeft(candidate, targetLabel); 
      break;
     
    case CLOSEST_TO_LABEL:
      distanceFromTarget = def(pixToRight(candidate, targetLabel), pixBelow(candidate, targetLabel));
         

      // only look to left of label if chkbox or radio
      if (isCheckableObject(candidate.object)){ 
        var pixLeft = pixToLeft(candidate, targetLabel);
        if (hasValue(pixLeft) && (!hasValue(distanceFromTarget) || pixLeft < distanceFromTarget) ){
          distanceFromTarget = pixLeft;   
        } 
      }                    
      break;
    
    default:
      throwEx('Unknown directionModifier: ' + directionModifier)
      break;
  }
  
  return distanceFromTarget;
}

function centrePassesThroughTarget(candidate, targetLabel, directionModifier){ 

  if (directionModifier === DATA_OBJECT_ABOVE || directionModifier === DATA_OBJECT_BELOW) {
    result = targetLabel.horizontalCentre < candidate.right && targetLabel.horizontalCentre > candidate.left;
  } 
  else if (directionModifier === DATA_OBJECT_TO_RIGHT || directionModifier === DATA_OBJECT_TO_LEFT) {
    result = targetLabel.verticalCentre > candidate.top && targetLabel.verticalCentre < candidate.bottom;
  }
  else {
    result = centrePassesThroughTarget(candidate, targetLabel, DATA_OBJECT_TO_LEFT) || centrePassesThroughTarget(candidate, targetLabel, DATA_OBJECT_ABOVE) ;
  }
  
  return result;
}

function isLabelLikeObject(uiObj){
  var objectType = uiObj.ObjectType;
  var LABEL_LIKE_OBJECTS = ['Label', 'TextNode', 'Cell', 'Panel'];
  return _.contains(LABEL_LIKE_OBJECTS, objectType);
}

function getDataObjectsAndLabelsWithCoordinates(container){
  var dataObjects = [];
  var labels = [];
  
  function classifyObjects(obj){
    if (isLabelLikeObject(obj) &&  hasValue(obj.contentText)){
      labels.push(addCoordinates(obj));
    }
    else if (isSettable(obj) && !(obj.ObjectType === 'Cell')){
      dataObjects.push(addCoordinates(obj));
    }
  }    

  var uIObjects = seekAll(container, {
              Visible: 'True'
           });
           
  _.each(uIObjects, classifyObjects);
    
  return {
    dataObjectsWithCoordinates: dataObjects,
    labelsWithCoordinates: labels
  }

}

function addCoordinates(obj){
  var result = {
    object: obj,
    top: obj.ScreenTop,
    bottom: obj.ScreenTop + obj.Height,
    left: obj.ScreenLeft,
    right: obj.ScreenLeft +  obj.Width
  }
  result.verticalCentre = (result.top + result.bottom) / 2;
  result.horizontalCentre = (result.left + result.right) / 2;
  return result;
}


function wildCardRegEx(lblTextorIdStr){
  return new RegExp(aqString.Replace(lblTextorIdStr, '*', '.+'), 'i');
}

function matchContentText(searchBits, txt){
  // IE can put wierd invisible line endings in labels 
  return _.reduce(searchBits, function(rslt, subStr){return rslt && hasText(txt, subStr, true)}, true)
}

function removeLineEndings(str){
  var str = standardiseLineEndings(str);
  str = replace(str, '\n', ' ');
  return str;
}

function getSearchModifier(str){
  var result = CLOSEST_TO_LABEL;
  str = trim(str);
  str = str.toUpperCase();
  var len = str.length;
  if (len > 2 && str.charAt(len - 2) === '~'){
    var candidate = str.substr(len-1,1);
    if (_.contains([DATA_OBJECT_TO_RIGHT, DATA_OBJECT_TO_LEFT, DATA_OBJECT_ABOVE, DATA_OBJECT_BELOW], candidate)){
      result = candidate;
    }
  } 
  return result;
}

function getSearchModifierEndPoint() {
  var result = getSearchModifier('')
  checkEqual('*', result);
  
  result = getSearchModifier('hello')
  checkEqual('*', result);
  
  result = getSearchModifier('hel~lo')
  checkEqual('*', result);
  
  result = getSearchModifier('hell~o')
  checkEqual('*', result);
  
  result = getSearchModifier('hell~l')
  checkEqual(LEFT(), result);
  
  result = getSearchModifier('hell~R')
  checkEqual(RIGHT(), result);
  
  result = getSearchModifier('hell~A')
  checkEqual(ABOVE(), result);
  
  result = getSearchModifier('hell~B')
  checkEqual(BELOW(), result);
}

function spliceProperty(argumentsPassedThrough, propertyName){
  var args = _.toArray(argumentsPassedThrough);
  args.splice(-1, 0, propertyName);
  return args;
}

function seekByPropertyPrivate(args, highlight){
  var args = _.toArray(args);
  var searchPropertyValue = args.pop();
  var searchPropertyName = args.pop();
  var criteria = {};
  criteria[searchPropertyName] = searchPropertyValue;
  
  var numCount = _.reduce(args, incrementIfNumber, 0);
  if (numCount === 0){
    args.push(criteria);
  }
  else {
    args.splice(-1 * (numCount), 0, criteria);
  }
  return webSeek(args, highlight);
}

function incrementIfNumber(accum, arg){
  return _.isNumber(arg) ? accum + 1 : accum;
}


function seekByIdStrPrivate(uiIdStr, container, maxDepth, timeoutMs, wantHighlight){
  container = def(container, activePage());
  var result = seekh(container, {idStr: uiIdStr}, maxDepth, timeoutMs);
  return result;
}

function defaultBrowser(){
  return btFirefox;
}

function getHttpResponse(link, error) {
  var httpObj = Sys.OleObject("MSXML2.XMLHTTP");
  // not asynchronous
  httpObj.open("GET", link, true);
  httpObj.send();

  var waitCounter = 0;
  while (httpObj.readyState !== 4 && waitCounter < 100){
    Delay(100, 'Waiting for http response from: ' + link);
    waitCounter++;
  }
      
  var isReady = httpObj.readyState === 4; 
  if (!isReady){
    error.message = messagePrefix + " timed out.";
  }

  return httpObj;
}

function getHttpResponseEndPoint() {
  var error = {};
  var link = 'http://travel.cosmostours.com.au/2013/booking-and-services/journeys-club';
  var result = getHttpResponse(link, error);
  delay(1);
}

function webSeek(passThroughArguments, wantHighlight){
 /// /* optional */ browserName, objOrPredicate1, objOrPredicate2, objOrPredicate3, objOrPredicate4, objOrPredicate5, objOrPredicate6, objOrPredicate7, maxDepth, timeoutMs
  /// param KungFu
 
  var args = _.toArray(passThroughArguments);
  var browserName;
  if (_.isString(args[0])){
    browserName = args[0];
    args = args.slice(1);
  }
  else {
    browserName = targetBrowserName();
  }

  // assume if args 0 is has an exists property
  // it is a web element - so we just pass through to seek
  var containerProvided = hasValue(args[0].Exists);
  var seekFunction = wantHighlight ?  seekh : seek;
 
  var result = null;
  if (containerProvided){
    result = seekFunction.apply(null, args);
  }
  else {
    var numericAndNonNumeric = _.partition(args, _.isNumber);
    var numbers = numericAndNonNumeric[0];
    var nonNumbers = numericAndNonNumeric[1];
   
    var numLength = numbers.length;
    var timeout = numLength > 0 ? numbers[0] : 10000;
    var depth = numLength > 1 ?  numbers[1] : 100000;
   
    // seek with zero timeout
    seekArgs = nonNumbers.concat([0, depth]);
    function findObjInActivePage(){
      var container = activePage(browserName);
      args = [container].concat(seekArgs);
      result = seekFunction.apply(null, args);
      return result.Exists;
    }
   
    waitRetry(findObjInActivePage, timeout);
  }
  return result;
}

function browserFromName(browserName){
  browserName = def(browserName, targetBrowserName());
  return Sys.WaitBrowser(browserName); 
}

// checks a link object prior to call to get
// returns true is ok to continue with get
// updates error object if the url object is invalid
// error has message + decription
function defaultlinkPreCheckFuncFunction(linkObj, error) {
  var result = true;
  return result;
}

function highLightLinkLogError(linkObj, error){
  var folderID = Log.CreateFolder('One of the following logs should have the broken link highlighted for error: ' + error.message, 'The included logs will be the same but only some will have the link highlighted in the screen shot.');
  Log.PushLogFolder(folderID);
  
  var asyncObj = Runner.CallObjectMethodAsync(Sys, "HighlightObject", linkObj, 40);
  do {
    logError(error.message, error.description);
  }
  while (!asyncObj.Completed);
  Log.PopLogFolder();
}


function highLightLinkLogErrorEndPoint() {
  var linkObj = Aliases.browser.pageAvalonHowToBook_1.formCountryform.panelPageWrapper.panelMainContainer.panelOuterContainer.panelInnerContainer.panelContent.panelRightCol.linkAvalonWaterwaysGroupEnquiryF;
  var error = {message: 'It Failed'};
  highLightLinkLogError(linkObj, error);
}

function BROWSER_NAME_IE(){
  return 'iexplore'; 
}

function BROWSER_NAME_FIREFOX(){
  return 'firefox'; 
}

function BROWSER_NAME_CHROME(){
  return 'chrome'; 
}

function BROWSER_NAME_OPERA(){
  return 'opera'; 
}

function BROWSER_NAME_SAFARI(){
  return 'safari'; 
}


function BROWSER_NAME_DEFAULT(){
  return browserIndexToName(defaultBrowser()); 
}

function browserNameIndexMap(){
  return {
    iexplore: Browsers.btIExplorer,
    firefox: Browsers.btFirefox,
    chrome: Browsers.btChrome,
    opera: Browsers.btOpera,
    safari: Browsers.btSafari
  }
}

function browserIndexToName(idx){
  var map = _.invert(browserNameIndexMap());
  var result = map[idx];
  ensure(hasValue(result), 'Invalid browser index');
  return result;
}

function browserIndexToNameUnitTest() {
  var result = browserIndexToName(Browsers.btChrome);
  checkEqual('chrome', result);
}

function browserNameToIndex(browserName){
  var map = browserNameIndexMap();
  var result = map[browserName];
  ensure(hasValue(result), 'Invalid browser name: ' + browserName);
  return result;
}

function browserNameToIndexUnitTest() {
  var result = browserNameToIndex('safari');
  checkEqual(Browsers.btSafari, result);
}

var targetBrowserNameVar;
function setTargetBrowserName(targetBrowserName){
  // validates browser name
  browserNameToIndex(targetBrowserName);
  return targetBrowserNameVar = targetBrowserName; 
}

function targetBrowserName(){
  var result = def(targetBrowserNameVar, browserIndexToName(defaultBrowser()));
  return result;
}

function activePage(browserName, waitPage, timeoutMs){
  var args = _.toArray(arguments);
  browserName = _.find(args, _.isString);
  waitPage = _.find(args, _.isBoolean);
  timeoutMs = _.find(args, _.isNumber);
  
  browserName = def(browserName, targetBrowserName());
  waitPage = def(waitPage, false);
  var result = {Exists: false};
  
  function findThePage(){
    var browser = Sys.WaitBrowser(browserName); 
    if (browser.Exists) {
      var page = seek(
        browser,
        {
          ObjectType: 'Page', 
          Visible: true,
          Name: 'Page*' // firefox has a wierd UIPage this eliminates that
        },  0 /* retry period */, /*depth*/ 1 );

       var pageFound = hasValue(page);
       if (pageFound) {
        result = page;
        if (waitPage){
          result.Wait();
        }
       }
      return pageFound;       
    }
  }
  
  var found = waitRetry(findThePage, timeoutMs);
  return result;
}

function activePageEndPoint() {
  var page = activePage();
  Sys.HighlightObject(page);
}


function verifyLinkedObject(linkedTestObj, linkPreCheckFuncFunction, responseTextCheckFunc) {
  var link = linkedTestObj.href;
  var messagePrefix = "Link: " + link + ': '
  var error = {message: '', description: '', hasError: function(){return hasValue(error.message)}}
  try
  {
    responseTextCheckFunc = def(responseTextCheckFunc, defaultresponseTextCheckFunc);
    linkPreCheckFuncFunction = def(linkPreCheckFuncFunction, defaultlinkPreCheckFuncFunction);
    var wantLinkCheck = linkPreCheckFuncFunction(linkedTestObj, error);
    var status = wantLinkCheck ? '' : 'No Status Code - Link Precheck Determined Not to Check Link - ';
    
    if (wantLinkCheck) {
      var httpObj = getHttpResponse(link, error)
      if(!error.hasError()) {
        status = httpObj.status; 
        var responseText = httpObj.responseText; 
        verifyStatusCode(status, messagePrefix, responseText, responseTextCheckFunc, error);
      }
    }
   }
  catch (e)
  {
    error.message = 'Exception encountered while testing link: ' + link + ' - ' + e.description;
    error.description = 'Exception encountered while testing link: ' + link + newLine() + e.description + newLine() + e.message;
  }

  result = !error.hasError();
  if (result) {
    logCheckPoint(messagePrefix + ' is valid - status code: ' + status, responseText);
  } else {
    highLightLinkLogError(linkedTestObj, error);
  }
} 


function executeFindChildFunc(findChildFunc, propValsObj, /* optional */ depth,  /* optional */ refresh, /* optional */ waitPage) {
  depth = def(depth, 10000);
  refresh = def(refresh, true);
  var page = activePage(null, waitPage);
  return findChildFunc(page, propValsObj, depth, refresh);
}

function verifyStatusCode(status, linkInfo, responseText, responseTextCheckFunc, error){
  switch (status)
  {
    case 200: // OK 
    case 302: // Found
    if (!responseTextCheckFunc(responseText))
    {
      error.message = linkInfo + 'response text failed check.';
      error.description = responseText;
    }

    break;
  
    default: {
      error.message = 'Unexpected status code: ' + status + ': ' + linkInfo;
      error.description = responseText;
    }
  }
}

function defaultresponseTextCheckFunc(responseText){
  var result = hasValue(responseText);
  if (!result) {
    logError(link + ' failed - no reponse text')
  }
  return result;
}

function verifyStatusCodeEndPoint(){ 
 var error = {};
 verifyStatusCode(0, 'blahh', 'response text', defaultresponseTextCheckFunc, error);
 
 error = {};
 verifyStatusCode(200, 'blahh', 'response text', defaultresponseTextCheckFunc, error);
 Delay(1);
}

// © John Walker 2013 – Permission for unrestricted use and modification granted within 
// THE-COMPANY and affiliated companies



