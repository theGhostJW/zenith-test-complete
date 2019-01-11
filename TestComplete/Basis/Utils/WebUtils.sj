//USEUNIT SysUtils
//USEUNIT WebUtilsPrivate
//USEUNIT StringUtils
//USEUNIT FileUtils
//USEUNIT DataEntryUtils
//USEUNIT CheckUtils
//USEUNIT _

/**

?????_NO_DOC_?????

== Params ==
container: DATA_TYPE_?????_NO_DOC_????? -  Required -  DESCRIPTION_?????_NO_DOC_?????
additionalPropNamesN: DATA_TYPE_?????_NO_DOC_????? -  Required -  DESCRIPTION_?????_NO_DOC_?????
depth: DATA_TYPE_?????_NO_DOC_????? -  Optional -  Default: ?????_NO_DOC_????? -  DESCRIPTION_?????_NO_DOC_?????
== Return ==
DATA_TYPE_?????_NO_DOC_????? - DESCRIPTION_?????_NO_DOC_?????
== Related ==
?????_NO_DOC_?????
**/
function sendWebRequest(url, httpMethod, requestBody, asynch, headers /*, userName, password */){
  asynch = def(asynch, false);
  var httpObj = Sys.OleObject("Microsoft.XMLHTTP"); // try later was "MSXML2.ServerXMLHTTP" revert to this if it does not work
  
  var httpVerbs = ['GET', 'POST', 'OPTIONS', 'HEAD', 'PUT', 'DELETE', 'TRACE', 'CONNECT'];
  ensure(_.contains(httpVerbs, httpMethod), httpMethod + ' is not a recognised web http method: ' + httpVerbs.join('; '));
  
  // not asynchronous
  httpObj.open(httpMethod, url, asynch  /*, userName, password*/ );
  
  headers = def(headers, {});
  
  function addHeader(val, key){
    httpObj.setRequestHeader(key, val);
  }
  _.each(headers, addHeader);
  
  log('Sending http request ('+ httpMethod +') to ' + url, 
    	'=== URL ===' + 
    	newLine() +
    	url +
    	newLine() +
    	'=== HTTP Method ===' + 
    	newLine() +
    	httpMethod +
    	newLine() +
    	'=== Request Headers ===' + 
    	newLine() +
    	(hasValue(headers) && _.keys(headers).length > 0 ? objectToJson(headers) : '---- No Headers ----') +
    	newLine() +
    	'=== Request Body ===' + 
    	newLine() + 
    	def(requestBody, '')
    	);
      httpObj.send(requestBody);
  return httpObj;
}

/**

?????_NO_DOC_?????

== Params ==
container: DATA_TYPE_?????_NO_DOC_????? -  Required -  DESCRIPTION_?????_NO_DOC_?????
additionalPropNamesN: DATA_TYPE_?????_NO_DOC_????? -  Required -  DESCRIPTION_?????_NO_DOC_?????
depth: DATA_TYPE_?????_NO_DOC_????? -  Optional -  Default: ?????_NO_DOC_????? -  DESCRIPTION_?????_NO_DOC_?????
== Return ==
DATA_TYPE_?????_NO_DOC_????? - DESCRIPTION_?????_NO_DOC_?????
== Related ==
?????_NO_DOC_?????
**/
function captureDOM(container, additionalPropNamesN, /* optional */ depth) {
  var args = _.toArray(arguments);
  depth = def(_.find(args, _.isNumber), 100000);
  args = _.reject(args, isNumber);
  
  var propArray = _.filter(args, _.isString);
  container = def(_.find(args, _.isObject), activePage());
  propArray = def(propArray, []);
             
  function readProps(uiObj){
    var result =  {
                    parent: hasValue(uiObj.parent) ? uiObj.parent.ObjectIdentifier : null,
                    parentFullName: hasValue(uiObj.parent) ? uiObj.parent.FullName : null,
                    parentName: hasValue(uiObj.parent) ? uiObj.parent.Name : null,
                    fullName: uiObj.FullName,
                    name: uiObj.Name,
                    objectIdentifier: uiObj.ObjectIdentifier,
                    screenTop: uiObj.ScreenTop,
                    visible: uiObj.Visible
                  };
                  
    function readUIObjProp(accum, prop){
      if (hasProperty(uiObj, prop)) {
        accum[prop] = uiObj[prop]
      }
      return accum
    }
    
    var additionalprops = _.reduce(propArray, readUIObjProp, {});
    return _.extend(result, additionalprops);
  }
  
  var domElemetFullNames = seekAll(container, {FullName: '*'}, depth);
                   
  var domElements = _.chain(domElemetFullNames)
                                .map(readProps)
                                .sortBy('screenTop')
                                .value();
  
  var result = convertToDomTree(domElements);
  return result;
}

/**

Reads basic information [hRef, text, if the link is valid, error code if the link is not valid] about all hyerlinks in a container to the apState.
  
== Params ==
container: Web Page Element -  Optional -  Default: activePage - the container
apState: Object -  Required -  the target apState object passed from the test case
readToPropertyName: String -  Optional -  Default: 'hyperLinkInfo' -  the name of the property to write to on the apState object
== Related ==
check_no_dead_links
**/
function readHyperlinkInfo(container, apState, readToPropertyName){
  var args = _.toArray(arguments);
  container = args.length > 0 && hasValue(args[0].Exists) ? container: null;
  apState = _.find(args, _.isObject);
  readToPropertyName = _.find(args, _.isString);

  readToPropertyName = def(readToPropertyName, 'hyperLinkInfo');
  container = def(container, activePage());
  var links = seekAll(container, {ObjectType: 'Link', Visible: 'True'});
  var result = _.map(links, linkValid);
  
  if (hasValue(apState)){
    apState[readToPropertyName] = result;
  }
  return result;
}

/**

Reads basic information [hRef, text, if the link is valid, error code if the link is not valid] about all hyerlinks in a container to the apState.
  
== Params ==
container: Web Page Element -  Optional -  Default: activePage - the container
apState: Object -  Required -  the target apState object passed from the test case
readToPropertyName: String -  Optional -  Default: 'hyperLinkInfo' -  the name of the property to write to on the apState object
== Related ==
check_no_dead_links
**/
function check_no_dead_links(apStatePropertyName){
  apStatePropertyName = def(apStatePropertyName, 'hyperLinkInfo');

  function check_no_dead_links(apState, item, runConfig){
    
    function linkValid(linkInfo){
      check(linkInfo.linkValid, 'Checking link valid' + linkInfo.text)
    }
    
    pushLogFolder('Checking Links Active');
    _.each(apState[apStatePropertyName], linkValid);
    popLogFolder();
  }
  
  return check_no_dead_links;
}


/**

Takes a containing object and generates setForm source code and saves it to the clipboard.
Both idStr and label text options are added to the resulting object so that the developer can mak a selection based on the quality of the idStr

== Params ==
container: UI Object - Required - a containing object such as a panel
data: Object - Optional - Default: null - an example data object. The properties of this object will be listed as a comment above the generated source code so they can be dragged into place  
== Related ==
setForm
**/
function setFormR(container, data){
  
  var searchSetInfo = getSearchSetInfo(container, data);
  
  function getId(candidate){
    return (hasValue(candidate) && _.isNaN(parseInt(candidate))) ? candidate : null;
  }
  
  function addMapToObject(accum, objAndCoordinates){
    var obj = objAndCoordinates.object; 
    var id = getId(obj.idStr) || getId(obj.ObjectIdentifier);
    if (hasValue(id)){
      accum[id] = "ID";
    }
    var closestLabelAndCoordinates = getClosestLabelWithText(objAndCoordinates, searchSetInfo);
    if (hasValue(closestLabelAndCoordinates)){
      var propName = trimWhiteSpace(closestLabelAndCoordinates.object.contentText);
      var newLineIndex = propName.indexOf(newLine());
      if (newLineIndex > -1){
        propName = propName.slice(0, newLineIndex); 
      }
      accum[propName] = null;
    }
    return accum;
  }

  function topLeft(obj){
    return (obj.top * 10000) + obj.left;
  }
  
  var result = _.chain(searchSetInfo.dataObjectsWithCoordinates)
                .sortBy(topLeft)
                .reduce(addMapToObject, {})
                .value();
                
  result = objectToJson(result).split(newLine());
  
  var len = result.length;
  function fixJson(line, lineIndex){
    var suffix = lineIndex > len - 4 ? ''  : ','
    return fixJsonIncLineSuffix(line, suffix);
  }
  
  result = _.chain(result)
              .map(fixJson)
              .map(indent)
              .value()
              .join(newLine());
   
  
  result = 'setForm(' + newLine() + result + newLine() +  '\t);';           
  if (hasValue(searchSetInfo.data)){
   var keys = _.keys(searchSetInfo.data);
   result = '\t/*' + 
                  newLine() + 
                  _.map(keys, indent).join(newLine()) + 
                  newLine() 
          + '\t*/' + newLine() + 
          '\t' + result;
  } 
  Sys.Clipboard = result;      
}

/**
Selects a tab in IE of an already opened browser
== Params ==
url: string - Required - the url on the target tab
== Return ==
Boolean - returns true if the page has been found
**/
function selectIETab(){
  var page = activePage().Parent.Page(url);
  var result = page.Exists;
  if (result){
    var locationName = page.LocationName;
    var browser = page.Parent;
    var tabButton = seek(browser, {ObjectType: 'TabButton', ObjectIdentifier: locationName}, 4);
    ensure(tabButton.Exists, 'selectIETab failed - tab not found')
    tabButton.Click();
  }
  return result;
}

/**
Returns the url of the active web page
== Return ==
String - returns the page url if the active page exists otherwise returns an empty string
== Related ==
activePage
**/
function activeUrl(){
  var page = activePage();
  var result = page.Exists ? page.URL : '';
  return result;
}

/**
Sets all the properties on a web page container (like a form or panel or page).

The data parameter is a JavaScript object where the key can be an idStr, an objectIdentifier of the editable data object or the text of a nearby label.

The function first searches for objects to set matching the idStr or objectIdentifier. If it can't find either of these it then searches for a label
whose text matches or contains the key then selects the closest data object.

== Params ==
container: Object - Optional - Default: [[#activePage|activePage]] - a container object (UI object) such as a form panel or page
data: Object - Required - a JavaScript object containing object identifier or label test: value to set, property value pairs (see above)
setFunctionOverride: function - Optional - Default: null - this function uses [[#set|set]] to set the target UI object. If there are
special requirements for setting an object then these can be encoded in an override function which will be called instead of set
== Related ==
set
**/
function setForm(container, data, setFunctionOverride){
  var searchSetInfo = getSearchSetInfo(container, data, setFunctionOverride)
  var data = searchSetInfo.data;
  
  function setObject(lblTextorIdStr){
    setFormElement(lblTextorIdStr, data[lblTextorIdStr], searchSetInfo);
  }

  _.chain(data)
              .keys(data)
              .each(setObject);
}

/**

Used in conjunction with setForm to override the default setter function for an individual field.
Often used to force the use of Keys in an input field rather than setting the input fields underlying
value directly when there is JavaScript on the page invoked by the OnKeyPress event.

== Params ==
value: String or Boolean - Required - the value the UI object is to be set to
setterFunction: function -  Required - function funcName(uiObj, val): no return value
== Return ==
function (UiObject): no return value - this is a function that sets the UI object to the value passed in as val in the setterFunction
== Related ==
setForm
**/
function withSetter(value, setterFunction){
  function specialSet(uiObj){
    setterFunction(uiObj, value);
  }
  return specialSet;
}

/**
Converts TestComplete browser index to name throws exception on invalid index
  Browsers.btIExplorer => iexplore
  Browsers.btFirefox => firefox
  Browsers.btChrome => chrome
  Browsers.btOpera => opera
  Browsers.btSafari => safari
== Params ==
idx: Integer - Required - TestComplete browser index
== Return ==
String - TC browser name
== Related ==
browserNameToIndex
**/
function browserIndexToName(idx){
  return WebUtilsPrivate.browserIndexToName(idx);
}


/**
Converts TestComplete browser name to index throws exception on invalid name (case sensitive)
  iexplore => Browsers.btIExplorer 
  firefox => Browsers.btFirefox 
  chrome => Browsers.btChrome
  opera => Browsers.btOpera
  safari => Browsers.btSafari
== Params ==
browserName: String - Required - tc browse name
== Return ==
Integer - TC browser index
== Related ==
browserIndexToName
**/
function browserNameToIndex(browserName){
  return WebUtilsPrivate.browserNameToIndex(browserName);
}

/**

Sets the target browser for the whole environment - this is used by the framework to set the target browser based on the runConfig and 
should not be called directly except by unit tests

== Params ==
browserName: String -  Required - the name of the browser type
== Related ==
targetBrowserName
**/
function setTargetBrowserName(targetBrowserName){
  WebUtilsPrivate.setTargetBrowserName(targetBrowserName);
}

/**
Returns the target browser name
== Return ==
String - the target browser name
== Related ==
setTargetBrowserName
**/
function targetBrowserName(){
  return WebUtilsPrivate.targetBrowserName();
}

/**
Returns the default browser type for the test run - e.g. firefox, chrome
== Return ==
String - TC browser name for test run e.g. firefox, chrome if this has not been set in the test run then the system default 
browser is returned.
== Related ==
setTargetBrowserName
**/
function targetBrowserIndex(){
  return browserNameToIndex(targetBrowserName());
}

/**
Saves a file in IE 9 and returns the path of the downloaded file. Assumes the save dialogue has already been invoked.
== Return ==
String - the path to the newly downloaded file
**/
function iESaveDownloadReturnPath(){
  iE9ClickSave();
  waitActivePage();
  var downloadPath = lastBrowserDownloadFile();
  return downloadPath;
}


/**
Clicks save on the IE9 download window - you probably should use [[#iESaveDownloadReturnPath|iESaveDownloadReturnPath]] instead.
== Related ==
iESaveDownloadReturnPath
**/
function iE9ClickSave(){
  var browserWindow = seek(Sys.Browser(), {ObjectType:"BrowserWindow"});
  
  var trys = 0;
  do {
    var saveWindow = seek(browserWindow, 
                                          {WndClass: 'Frame Notification Bar'},
                                          {
                                          WndClass: 'DirectUIHWND', 
                                          Name: 'Window("DirectUIHWND*)',
                                          VisibleOnScreen: 'True'});
    trys++;
    Delay(1000);
  
  } while (!saveWindow.Exists && trys < 10);
  ensure(saveWindow.Exists, 'Save window not found');
  
  // click save btn
  log('Clicking IE File Save Button');
  saveWindow.Click(saveWindow.Width - 155, saveWindow.Height - 24);
  
  // this is just to give the log time to capture the screen may
  // not be required
  Delay(3000);
  
  // click close button
  log('Clicking IE Close Window Button');
  saveWindow.Click(saveWindow.Width - 20, 24);
  waitActivePage();
}

/**
Performs exactly the same functions as seekByIdStr but highlights the object and container on screen. Used for debugging.
See [[#seekByIdStr|seekByIdStr]] for details
== Related ==
seekByIdStr
**/
function seekByIdStrh(/* optional */ browserName, /* optional */ objOrPredicate1toN, /* optional */ timeoutMs, /* optional */ maxDepth, idStr){
  var args = spliceProperty(arguments, 'idStr');
  return seekByPropertyPrivate(args, true);
}

/**
Finds a web page object by idString property

See [[#seekInPage|seekInPage]] for more details on parameters
== Params ==
optionalSeekInPageParams: various - Optional - Default: see [[#seekInPage|seekInPage]] -  all the parameters used by [[#seekInPage|seekInPage]] can be used as a prefix to the following required parameters
idStr: String -  Required - the idStr of the target object
== Return ==
UI Object - a UI Object or a stub object with Exists property set to false
== Related ==
seek, seekInPageh, seekByIdStr, seekByIdStrh, setByPropertyh, setByIdStr, seekByObjectIdentifier, seekByObjectIdentifierh, setByIdStrh, setByObjectIdentifier, setInPage, setInPageh, setByObjectIdentifier,
setByObjectIdentifierh, seekByProperty, seekByPropertyh, readInPage, readInPageh, readByProperty, readByPropertyh, readByIdStr, readByIdStrh, readByObjectIdentifier, readByObjectIdentifierh,
clickInPageh, clickByProperty, clickByPropertyh, clickByIdStrh, clickByObjectIdentifier, clickByObjectIdentifierh, setByProperty, clickLink, clickLinkh
**/
function seekByIdStr(/* optional */ browserName, /* optional */ objOrPredicate1toN, /* optional */ timeoutMs, /* optional */ maxDepth, idStr){
  var args = spliceProperty(arguments, 'idStr');
  return seekByPropertyPrivate(args, false);
}

/**
Sets an object within the active web page that matches a given idStr to the specified value

See [[#seekInPage|seekInPage]] for more details on parameters
== Params ==
optionalSeekInPageParams: various - Optional - Default: see [[#seekInPage|seekInPage]] -  all the parameters used by [[#seekInPage|seekInPage]] can be used as a prefix to the following required parameters
idStr: String -  Required -  the idStr of the target object
value: String -  Required -  the value to set the target object to
== Return ==
Boolean - returns true if the object has been set or false if the object is not handled by the set function (logs an error if the object is not set)
== Related ==
set, seek, seekInPageh, seekByIdStr, seekByIdStrh, setByIdStr, seekByObjectIdentifier, seekByObjectIdentifierh, setByIdStrh,
setByObjectIdentifier, setInPage, setInPageh, setByObjectIdentifier, setByObjectIdentifierh,seekByProperty, seekByPropertyh, readInPage, readInPageh, 
readByProperty, readByPropertyh, readByIdStr, readByIdStrh,
readByObjectIdentifier, readByObjectIdentifierh, clickInPageh, clickByProperty, clickByPropertyh, clickByIdStrh, clickByObjectIdentifier,
clickByObjectIdentifierh, setByProperty, clickLink, clickLinkh
**/
function setByIdStr(/* optional */ browserName, /* optional */ objOrPredicate1toN, /* optional */ timeoutMs, /* optional */ maxDepth, idStr, value){
  return sliceAndApply(seekByIdStr, set, arguments, 1);
}


/**
Performs exactly the same functions as [[setByIdStr]] but highlights the object and container on screen. Used for debugging.

See [[#setByIdStr|setByIdStr]] for details
== Related ==
setByIdStr
**/
function setByIdStrh(/* optional */ browserName, /* optional */ objOrPredicate1toN, /* optional */ timeoutMs, /* optional */ maxDepth, idStr, value){
  return sliceAndApply(seekByIdStrh, set, arguments, 1);
}

/**
Sets an object within the active web page that matches a given objectIdentifer to the specified value

See [[#seekInPage|seekInPage]] for more details on parameters
== Params ==
optionalSeekInPageParams: various - Optional - Default: see [[#seekInPage|seekInPage]] -  all the parameters used by [[#seekInPage|seekInPage]] can be used as a prefix to the following required parameters
objectIdentifier: String -  Required -  the ObjectIdentifier of the target object
value: String -  Required -  the value to set the target object to
== Return ==
Boolean - returns true if the object has been set or false if the object is not handled by the set function (logs an error if the object is not set)
== Related ==
set, seek, seekInPageh, seekByIdStr, seekByIdStrh, setByIdStr, seekByObjectIdentifier, seekByObjectIdentifierh, setByIdStrh,
setByObjectIdentifier, setInPage, setInPageh, setByObjectIdentifier, setByObjectIdentifierh, seekByProperty, seekByPropertyh, readInPage, readInPageh, readByProperty, readByPropertyh, readByIdStr, readByIdStrh,
readByObjectIdentifier, readByObjectIdentifierh, clickInPageh, clickByProperty, clickByPropertyh, clickByIdStrh, clickByObjectIdentifier,
clickByObjectIdentifierh, setByProperty, clickLink, clickLinkh
**/
function setByObjectIdentifier(/* optional */ browserName, /* optional */ objOrPredicate1toN, /* optional */ timeoutMs, /* optional */ maxDepth, objectIdentifier, value){
  return sliceAndApply(seekByObjectIdentifier, set, arguments, 1);
}


/**
Performs exactly the same functions as [[setByObjectIdentifier]] but highlights the object and container on screen. Used for debugging.

== Related ==
setByIdStr
**/
function setByObjectIdentifierh(/* optional */ browserName, /* optional */ objOrPredicate1toN, /* optional */ timeoutMs, /* optional */ maxDepth, idStr, value){
  return sliceAndApply(seekByObjectIdentifierh, set, arguments, 1);
}

/**
Performs exactly the same functions as seekByObjectIdentifier but highlights the object and container on screen. Used for debugging.

See [[#seekByObjectIdentifier|seekByObjectIdentifier]] for details
== Related ==
seekByObjectIdentifier
**/
function seekByObjectIdentifierh(uiIdStr, container, maxDepth, timeoutMs){
  var args = spliceProperty(arguments, 'ObjectIdentifier');
  return seekByPropertyPrivate(args, true);
}

/**
Finds a web page object by objectIdentifier property.

See [[#seekInPage|seekInPage]] for more details on parameters
== Params ==
optionalSeekInPageParams: various - Optional - Default: see [[#seekInPage|seekInPage]] -  all the parameters used by [[#seekInPage|seekInPage]] can be used as a prefix to the following required parameters
objectIdentifier: String -  Required - the objectIdentifier of the target object
== Return ==
UI Object - a UI Object or a stub object with Exists property set to false
== Related ==
seek, seekInPageh, seekByIdStr, seekByIdStrh, setByPropertyh, setByIdStr, seekByObjectIdentifierh, setByIdStrh, setByObjectIdentifier, setInPage, setInPageh, setByObjectIdentifier,
setByObjectIdentifierh, seekByProperty, seekByPropertyh, readInPage, readInPageh, readByProperty, readByPropertyh, readByIdStr, readByIdStrh, readByObjectIdentifier, readByObjectIdentifierh,
clickInPageh, clickByProperty, clickByPropertyh, clickByIdStrh, clickByObjectIdentifier, clickByObjectIdentifierh, setByProperty, clickLink, clickLinkh
**/
function seekByObjectIdentifier(/* optional */ browserName, /* optional */ objOrPredicate1toN, /* optional */ timeoutMs, /* optional */ maxDepth, objectIdentifier){
  var args = spliceProperty(arguments, 'ObjectIdentifier');
  return seekByPropertyPrivate(args, false);
}

/**
Seeks an object within the active page matching a single property value.

See [[seekInPage]] for more details on parameters
== Params ==
optionalSeekInPageParams: various - Optional - Default: see [[#seekInPage|seekInPage]] -  all the parameters used by [[#seekInPage|seekInPage]] can be used as a prefix to the following required parameters
searchPropertyName: String -  Required - The property name to search for
searchPropertyValue: String -  Required - the value of the property
== Return ==
UI Object - a UI Object or a stub object with Exists property set to false
== Related ==
seek, seekInPage, seekInPageh, seekByIdStr, seekByIdStrh, setByPropertyh, setByIdStr, seekByObjectIdentifier, seekByObjectIdentifierh, 
setByIdStrh, setByObjectIdentifier, setInPage, setInPageh, setByObjectIdentifier, setByObjectIdentifierh,
seekByPropertyh, readInPage, readInPageh, readByProperty, readByPropertyh, readByIdStr, readByIdStrh, readByObjectIdentifier, readByObjectIdentifierh,
clickInPageh, clickByProperty, clickByPropertyh, clickByIdStrh, clickByObjectIdentifier, clickByObjectIdentifierh, setByProperty, clickLink, clickLinkh
**/
function seekByProperty(/* optional */ browserName, /* optional */ objOrPredicate1toN, /* optional */ timeoutMs, /* optional */ maxDepth, searchPropertyName, searchPropertyValue){
  return seekByPropertyPrivate(arguments, false)
}


/**
Performs exactly the same functions as seekByProperty but highlights the object and container on screen. Used for debugging.

See [[#seekByProperty|seekByProperty]] for details
== Related ==
seekByProperty
**/
function seekByPropertyh(/* optional */ browserName, /* optional */ objOrPredicate1toN, /* optional */ timeoutMs, /* optional */ maxDepth, searchPropertyName, searchPropertyValue){
  return seekByPropertyPrivate(arguments, true)
}

// -- modified from TC help copyright message below does not apply
/**
Determines if the current browser is !FireFox
== Params ==
browser: Browser -  Required -  TestComplete Browser object
== Return ==
Boolean - true if the browser if !FireFox
**/
function isMozilla(browser){
  return (aqString.Find(browser.FullName, 'Process("firefox"', 0, false) !=-1);
}


// -- modified from TC help copyright message below does not apply
/**
Clicks the <Back> button on the main web page
== Params ==
browserName: [[http://support.smartbear.com/viewarticle/29898/|BrowserName]] -  Required -  one of *, iexplore, firefox or chrome 
**/
function pageBack(browserName){
  var browser = browserFromName(browserName); 
  var page = activePage(browserName);
  if (isMozilla(browser)){
    page.back();
  }  
  else { 
    page.GoBack();
  }
}

/**
Returns an array of objects that match the single propValsObj provided searching down to the specified depth.

This function is a wrapper around the TestComplete [[http://support.smartbear.com/viewarticle/55098/|FindAllChildren]] function.

== Params ==
propValsObj: Criteria -  Required - a criteria object {propertyName: properyVal}
depth: Number -  Optional - Default: null (fully recursive) - how many layers down to search for the items
refresh: Boolean - Optional - Default: true - specifies if the cached object tree will be refreshed and the search repeated if the object is not found
waitPage:  
== Return ==
Array - an array of matching objects
**/
function seekAllInPage(propValsObj, /* optional */ depth, /* optional */ refresh, /* optional */ waitPage){
  function findChildFunc(page, propValsMap, searchDepth, wantRefresh){
    return seekAll(page, propValsMap, searchDepth, wantRefresh);
  }
  return executeFindChildFunc(findChildFunc, propValsObj, depth, refresh, waitPage);
}

/**
gets the email string from a mailto link
== Params ==
href: String - Required - the href ie web link
== Return ==
String - the email address string
**/
function extractMailToFromHref(href){
  href = def(href,'');
  href = aqString.Trim(aqString.ToLower(href));
  var result = subStrAfter(href,':');
  if (hasText(result, '?')) {
    result = subStrBefore(result, '?');
  } 
  return result;
}

/**
A constant - returns the TestComplete IE browser name - iexplore
== Return ==
String - iexplore
== Related ==
BROWSER_NAME_FIREFOX, BROWSER_NAME_CHROME, BROWSER_NAME_DEFAULT, BROWSER_NAME_OPERA, BROWSER_NAME_SAFARI
**/
function BROWSER_NAME_IE(){
  return WebUtilsPrivate.BROWSER_NAME_IE(); 
}


/**
A constant - returns the TestComplete IE browser name - opera
== Return ==
String - opera
== Related ==
BROWSER_NAME_FIREFOX, BROWSER_NAME_CHROME, BROWSER_NAME_DEFAULT, BROWSER_NAME_IE, BROWSER_NAME_SAFARI
**/
function BROWSER_NAME_OPERA(){
  return WebUtilsPrivate.BROWSER_NAME_OPERA(); 
}

/**
A constant - returns the TestComplete IE browser name - safari
== Return ==
String - safari
== Related ==
BROWSER_NAME_FIREFOX, BROWSER_NAME_CHROME, BROWSER_NAME_DEFAULT, BROWSER_NAME_IE, BROWSER_NAME_OPERA
**/
function BROWSER_NAME_SAFARI(){
  return WebUtilsPrivate.BROWSER_NAME_SAFARI(); 
}

/**
A constant - returns the TestComplete FireFox browser name - firefox
== Return ==
String - firefox
== Related ==
BROWSER_NAME_CHROME, BROWSER_NAME_IE, BROWSER_NAME_DEFAULT, BROWSER_NAME_OPERA, BROWSER_NAME_SAFARI
**/
function BROWSER_NAME_FIREFOX(){
  return WebUtilsPrivate.BROWSER_NAME_FIREFOX(); 
}

/**
A constant - returns the TestComplete Chrome browser name - chrome
== Return ==
String - chrome
== Related ==
BROWSER_NAME_FIREFOX,  BROWSER_NAME_DEFAULT, BROWSER_NAME_OPERA, BROWSER_NAME_SAFARI
**/
function BROWSER_NAME_CHROME(){
  return WebUtilsPrivate.BROWSER_NAME_CHROME(); 
}

/**
A constant - returns the TestComplete running (default) browser name - '*'
== Return ==
String - '*'
== Related ==
BROWSER_NAME_FIREFOX, BROWSER_NAME_CHROME
**/
function BROWSER_NAME_DEFAULT(){
  return WebUtilsPrivate.BROWSER_NAME_DEFAULT(); 
}

/**

Finds a single web page that is the immediate child of the active  browser.
== Params ==
browserName: [[http://support.smartbear.com/viewarticle/29898/|BrowserName]]|  -  Optional -  Default: '*' -  *, iexplore, firefox, chrome
waitPage: Boolean - Optional - Default: false - whether to wait for the page to load
timeoutMs: Int - Optional - Default: 10000 - how long to wait for the page to load (if waitPage is true)
== Return ==
[[http://support.smartbear.com/viewarticle/30861/|Page Object]] - The web page on tab 0
== Related ==
activeBrowser
**/
function activePage( /* optional */ browserName,  /* optional */ waitPage, /* optional */ timeoutMs){
  return WebUtilsPrivate.activePage(browserName, waitPage, timeoutMs);
}

/**
seekInPage is the base function for all web page seek function (such as [[#seekByProperty|seekByProperty]], [[#seekByIdStr|seekByIdStr]], [[#seekByObjectIdentifier|seekByObjectIdentifier]]) and "seek and do"
type functions (such as [[#setByObjectIdentifier|setByObjectIdentifier]], [[#readByIdStr|readByIdStr]]).

seekInPage is massively overloaded ased on the types of the arguments - 

browserName: If the first parameter is a string it is assumed to be the browserName. 

container: If the first object in the parameter list contains an Exists property then it is assumed to be a container object - seekInpage then behaves exactly
like [[#seek|seek]]. If there is no object like this provided as a parameter then the [[#activePage|activePage]] is used (hence the function name: seekInPage). 

objOrPredicate1toN: All objects that don't contain an Exists property or functions are assumed to be property criteria objects or predicate function. So if
this function was invoked with one criteria object, a function and then another criteria object the function would find the first object
within the container that matches the first criteria object. It would then search within this object for a child object that matches the
predicate function. It would then search within this object for an object that matches the last criteria object. There can be any number of
criteria objects/predicates but there must be at least one.

timeoutMs: The first number is assumes to be a time-out. This is roughly how long the function will keep refreshing and looking for a UI item before it fails.
The actual timeout could be longer than that specified by this parameter. For example if a massive web page was searched for an item that did not match the search
criteria it might take 20 seconds to loop through the page once. Even if a timeoutMs was set to 3000 the function would still run for at least 20000 ms looping through
one item of searching the page before checking if the timeout has expired. If this number is omitted.

maxDepth: If two numbers are provided then the second number specifies how many layers down to search for an item. E.g. If you are searching a panel with a depth of
1 it will search for all items in the panel and all items contained with it's direct children and no further. If this parameter is omitted
then the search will be exhaustive i.e. fully recursive, all elements in the DOM will be inspected before the search fails. To specify this parameter you must also
specify the timeoutMs.

== Params ==
browserName: [[http://support.smartbear.com/viewarticle/29898/|BrowserName]]  -  Optional -  Default: [[#targetBrowserName|targetBrowserName]] - see explanation above
container: a UI object - Optional - a UI container - see explanation above
objOrPredicate1toN: Criteria -  Required - one or many criteria object(s) or a function(s) used to specify the object
timeoutMs: Number -  Optional - Default: 10000 - how long to keep retrying for if the object is not found
maxDepth: Number -  Optional - Default: null (fully recursive) - how many layers down to search for an item. E.g. If you are searching a panel with a depth of
1 it will search for all items in the panel and all items contained with it's direct children and no further. If this parameter is omitted
then the search will be exhaustive i.e. fully recursive, all elements in the DOM will be inspected before the search fails.  
== Return ==
Object - A UI Object matching the search criteria or a stub object with Exists proprty false
== Related ==
seek, seekInPage, seekInPageh, seekByIdStr, seekByIdStrh, setByIdStr, seekByObjectIdentifier, seekByObjectIdentifierh, setByIdStrh,
setByObjectIdentifier, setInPage, setInPageh, setByObjectIdentifier, setByObjectIdentifierh, seekByProperty, seekByPropertyh, readInPage, readInPageh, readByProperty, readByPropertyh, readByIdStr, readByIdStrh,
readByObjectIdentifier, readByObjectIdentifierh, clickInPageh, clickByProperty, clickByPropertyh, clickByIdStrh, clickByObjectIdentifier,
clickByObjectIdentifierh, setByProperty, clickLink, clickLinkh
**/
function seekInPage(/* optional */ browserName, objOrPredicate1toN, /* optional */ timeoutMs, /* optional */ maxDepth){
  return webSeek(arguments, false);
}

/**
Performs the same function as [[#seekInPage|seekInPage]] but highlights containers, objects as they are found. used for debugging.

See [[#seekInPage|seekInPage]] for more details on parameters
== Related ==
seekInPage
**/
function seekInPageh(/* optional */ browserName, objOrPredicate1toN, /* optional */ timeoutMs, /* optional */ maxDepth){
  return webSeek(arguments, true);
}


/**
Finds an object using [[#seekInPage|seekInPage]] and sets the object found to the given value

See [[#seekInPage|seekInPage]] for more details on parameters
== Params ==
optionalSeekInPageParams: various - Optional - Default: see [[#seekInPage|seekInPage]] -  all the parameters used by [[#seekInPage|seekInPage]] can be used as a prefix to the following required parameters
value: String -  Required -  the value to set the target object to
== Return ==
Boolean - returns true if the object has been set or false if the object is not handled by the set function (logs an error if the object is not set)
== Related ==
seek, seekInPage, seekInPageh, seekByIdStr, seekByIdStrh, setByIdStr, seekByObjectIdentifier, seekByObjectIdentifierh, setByIdStrh,
setByObjectIdentifier, setInPage, setInPageh, setByObjectIdentifier, setByObjectIdentifierh, seekByProperty, seekByPropertyh, readInPage, readInPageh, readByProperty, readByPropertyh, readByIdStr, readByIdStrh,
readByObjectIdentifier, readByObjectIdentifierh, clickInPageh, clickByProperty, clickByPropertyh, clickByIdStrh, clickByObjectIdentifier,
clickByObjectIdentifierh, setByProperty, clickLink, clickLinkh
**/
function setInPage(/* optional */ browserName, objOrPredicate1toN, /* optional */ timeoutMs, /* optional */ maxDepth, value){
  return sliceAndApply(seekInPage, set, arguments, 1);
}


/**
Finds an object using [[#seekInPage|seekInPage]] and returns the data value of the object (e.g. the value of the checked property for a checkbox or the contentText of a label)

See [[#seekInPage|seekInPage]] for more details on parameters
== Params ==
optionalSeekInPageParams: various - Optional - Default: see [[#seekInPage|seekInPage]] -  all the parameters used by [[#seekInPage|seekInPage]] can be used as a prefix to the following required parameters
== Return ==
Object - The data value of the found object
== Related ==
seek, seekInPage, seekInPageh, seekByIdStr, seekByIdStrh, setByIdStr, seekByObjectIdentifier, seekByObjectIdentifierh, setByIdStrh,
setByObjectIdentifier, setInPage, setInPageh, setByObjectIdentifier, setByObjectIdentifierh, seekByProperty, seekByPropertyh, readInPage, readInPageh, readByProperty, readByPropertyh, readByIdStr, readByIdStrh,
readByObjectIdentifier, readByObjectIdentifierh, clickInPageh, clickByProperty, clickByPropertyh, clickByIdStrh, clickByObjectIdentifier,
clickByObjectIdentifierh, setByProperty, clickLink, clickLinkh
**/
function readInPage(/* optional */ browserName, objOrPredicate1toN, /* optional */ timeoutMs, /* optional */ maxDepth){
  return sliceAndApply(seekInPage, read, arguments, 0);
}

/**
Performs the same function as [[#readInPage|readInPage]] but highlights containers, objects as they are found. Used for debugging.


See [[#readInPage|readInPage]] for more details on parameters
== Related ==
readInPage
**/
function readInPageh(/* optional */ browserName, objOrPredicate1toN, /* optional */ timeoutMs, /* optional */ maxDepth){
  return sliceAndApply(seekInPageh, read, arguments, 0);
}


/**
Seeks an object within the active page matching a single property value and returns the default data property of the object

See [[#seekInPage|seekInPage]] for more details on parameters
== Params ==
optionalSeekInPageParams: various - Optional - Default: see [[#seekInPage|seekInPage]] -  all the parameters used by [[#seekInPage|seekInPage]] can be used as a prefix to the following required parameters
searchPropertyName: String -  Required - The property name to search for
searchPropertyValue: String -  Required - the value of the property
== Return ==
Object - the default data property of the object found
== Related ==
seek, seekInPage, seekInPageh, seekByIdStr, seekByIdStrh, setByIdStr, seekByObjectIdentifier, seekByObjectIdentifierh, setByIdStrh,
setByObjectIdentifier, setInPage, setInPageh, setByObjectIdentifier, setByObjectIdentifierh, seekByProperty, seekByPropertyh, readInPage, readInPageh, readByProperty, readByPropertyh, readByIdStr, readByIdStrh,
readByObjectIdentifier, readByObjectIdentifierh, clickInPageh, clickByProperty, clickByPropertyh, clickByIdStrh, clickByObjectIdentifier,
clickByObjectIdentifierh, setByProperty, clickLink, clickLinkh
**/
function readByProperty(/* optional */ browserName, /* optional */ objOrPredicate1toN, /* optional */ timeoutMs, /* optional */ maxDepth, searchPropertyName, searchPropertyValue){
  return sliceAndApply(seekByProperty, read, arguments, 0);
}

/**
Performs the same function as [[#readByProperty|readByProperty]] but highlights containers, objects as they are found. Used for debugging.


See [[#readByProperty|readByProperty]] for more details on parameters
== Related ==
readByProperty
**/
function readByPropertyh(/* optional */ browserName, /* optional */ objOrPredicate1toN, /* optional */ timeoutMs, /* optional */ maxDepth, searchPropertyName, searchPropertyValue){
  return sliceAndApply(seekByPropertyh, read, arguments, 0);
}



/**
Finds a web page object by idString property and returns it's default data value.

See [[#seekByIdStr|seekByIdStr]] for more details on parameters
== Params ==
optionalSeekInPageParams: various - Optional - Default: see [[#seekInPage|seekInPage]] -  all the parameters used by [[#seekInPage|seekInPage]] can be used as a prefix to the following required parameters
idStr: String -  Required - the idStr of the target object
== Return ==
Object - The default data property of the object
== Related ==
seek, seekInPage, seekInPageh, seekByIdStr, seekByIdStrh, setByIdStr, seekByObjectIdentifier, seekByObjectIdentifierh, setByIdStrh,
setByObjectIdentifier, setInPage, setInPageh, setByObjectIdentifier, setByObjectIdentifierh, seekByProperty, seekByPropertyh, readInPage, readInPageh, readByProperty, readByPropertyh, readByIdStr, readByIdStrh,
readByObjectIdentifier, readByObjectIdentifierh, clickInPageh, clickByProperty, clickByPropertyh, clickByIdStrh, clickByObjectIdentifier,
clickByObjectIdentifierh, setByProperty, clickLink, clickLinkh
**/
function readByIdStr(/* optional */ browserName, /* optional */ objOrPredicate1toN, /* optional */ timeoutMs, /* optional */ maxDepth, idStr){
  return sliceAndApply(seekByIdStr, read, arguments, 0);
}

/**
Performs the same function as [[#readByIdStr|readByIdStr]] but highlights containers, objects as they are found. Used for debugging.


See [[#readByIdStr|readByIdStr]] for more details on parameters
== Related ==
readByIdStr
**/
function readByIdStrh(/* optional */ browserName, /* optional */ objOrPredicate1toN, /* optional */ timeoutMs, /* optional */ maxDepth, idStr){
  return sliceAndApply(seekByIdStrh, read, arguments, 0);
}


/**
Finds a web page object by ObjectIdentifier property and returns it's default data value.

See [[seekInPage]] for more details on parameters
== Params ==
optionalSeekInPageParams: various - Optional - Default: see [[seekInPage]] -  all the parameters used by [[#seekInPage|seekInPage]] can be used as a prefix to the following required parameters
objectIdentifier: String -  Required - the ObjectIdentifier of the target object
== Return ==
Object - The default data property of the object
== Related ==
seek, seekInPage, seekInPageh, seekByIdStr, seekByIdStrh, setByIdStr, seekByObjectIdentifier, seekByObjectIdentifierh, setByIdStrh,
setByObjectIdentifier, setInPage, setInPageh, setByObjectIdentifier, setByObjectIdentifierh, seekByProperty, seekByPropertyh, readInPage, readInPageh, readByProperty, readByPropertyh, readByIdStr, readByIdStrh,
readByObjectIdentifier, readByObjectIdentifierh, clickInPageh, clickByProperty, clickByPropertyh, clickByIdStrh, clickByObjectIdentifier,
clickByObjectIdentifierh, setByProperty, clickLink, clickLinkh
**/
function readByObjectIdentifier(/* optional */ browserName, /* optional */ objOrPredicate1toN, /* optional */ timeoutMs, /* optional */ maxDepth, objectIdentifier){
  return sliceAndApply(seekByObjectIdentifier, read, arguments, 0);
}

/**
Performs the same function as [[#readByObjectIdentifier|readByObjectIdentifier]] but highlights containers, objects as they are found. Used for debugging.


See [[#readByObjectIdentifier|readByObjectIdentifier]] for more details on parameters
== Related ==
readByObjectIdentifier
**/
function readByObjectIdentifierh(/* optional */ browserName, /* optional */ objOrPredicate1toN, /* optional */ timeoutMs, /* optional */ maxDepth, objectIdentifier){
  return sliceAndApply(seekByObjectIdentifierh, read, arguments, 0);
}


/**
Finds an object within the active page and clicks on it

== Params ==
optionalSeekInPageParams: various - required - Default: see [[#seekInPage|seekInPage]] -  params are the same as [[#seekInPage|seekInPage]]
== Related ==
seekInPage
**/
function clickInPage(/* optional */ browserName, objOrPredicate1toN, /* optional */ timeoutMs, /* optional */ maxDepth){
  return sliceAndApply(seekInPage, click, arguments, 0);
}

/**
Performs the same function as [[#clickInPage|clickInPage]] but highlights containers, objects as they are found. Used for debugging.

See [[#clickInPage|clickInPage]] for more details on parameters
== Related ==
clickInPage
**/
function clickInPageh(/* optional */ browserName, objOrPredicate1toN, /* optional */ timeoutMs, /* optional */ maxDepth){
  return sliceAndApply(seekInPageh, click, arguments, 0);
}


/**
Seeks an object within the active page matching a single property value and clicks it

See [[#seekInPage|seekInPage]] for more details on parameters
== Params ==
optionalSeekInPageParams: various - Optional - Default: see [[#seekInPage|seekInPage]] -  all the parameters used by [[#seekInPage|seekInPage]] can be used as a prefix to the following required parameters
searchPropertyName: String -  Required - The property name to search for
searchPropertyValue: String -  Required - the value of the property
== Related ==
seek, seekInPage, seekInPageh, seekByIdStr, seekByIdStrh, setByIdStr, seekByObjectIdentifier, seekByObjectIdentifierh, setByIdStrh,
setByObjectIdentifier, setInPage, setInPageh, setByObjectIdentifier, setByObjectIdentifierh, seekByProperty, seekByPropertyh, readInPage, readInPageh, readByProperty, readByPropertyh, readByIdStr, readByIdStrh,
readByObjectIdentifier, readByObjectIdentifierh, clickInPageh, clickByProperty, clickByPropertyh, clickByIdStrh, clickByObjectIdentifier,
clickByObjectIdentifierh, setByProperty, clickLink, clickLinkh
**/
function clickByProperty(/* optional */ browserName, /* optional */ objOrPredicate1toN, /* optional */ timeoutMs, /* optional */ maxDepth, searchPropertyName, searchPropertyValue){
  return sliceAndApply(seekByProperty, click, arguments, 0);
}

/**
Performs exactly the same functions as [[clickByProperty]] but highlights the object and container on screen. Used for debugging.

== Related ==
clickByProperty
**/
function clickByPropertyh(/* optional */ browserName, /* optional */ objOrPredicate1toN, /* optional */ timeoutMs, /* optional */ maxDepth, searchPropertyName, searchPropertyValue){
  return sliceAndApply(seekByPropertyh, click, arguments, 0);
}



/**
Seeks an object within the active page with a matching Idstr and clicks it

See [[#seekInPage|seekInPage]] for more details on parameters
== Params ==
optionalSeekInPageParams: various - Optional - Default: see [[#seekInPage|seekInPage]] -  all the parameters used by [[#seekInPage|seekInPage]] can be used as a prefix to the following required parameters
idStr: String -  Required - The idStr to search for
== Related ==
clickInPage
**/
function clickByIdStr(/* optional */ browserName, /* optional */ objOrPredicate1toN, /* optional */ timeoutMs, /* optional */ maxDepth, idStr){
  return sliceAndApply(seekByIdStr, click, arguments, 0);
}

/**
Performs exactly the same functions as [[clickByIdStr]] but highlights the object and container on screen. Used for debugging.

== Related ==
clickByIdStr
**/
function clickByIdStrh(/* optional */ browserName, /* optional */ objOrPredicate1toN, /* optional */ timeoutMs, /* optional */ maxDepth, idStr){
  return sliceAndApply(seekByIdStrh, click, arguments, 0);
}


/**
Seeks an object within the active page with a matching clickByObjectIdentifier and clicks it

See [[#seekInPage|seekInPage]] for more details on parameters
== Params ==
optionalSeekInPageParams: various - Optional - Default: see [[#seekInPage|seekInPage]] -  all the parameters used by [[#seekInPage|seekInPage]] can be used as a prefix to the following required parameters
ObjectIdentifier: String -  Required - The ObjectIdentifier to search for
== Related ==
seek, seekInPage, seekInPageh, seekByIdStr, seekByIdStrh, setByIdStr, seekByObjectIdentifier, seekByObjectIdentifierh, setByIdStrh,
setByObjectIdentifier, setInPage, setInPageh, setByObjectIdentifier, setByObjectIdentifierh, seekByProperty, seekByPropertyh, readInPage, readInPageh, readByProperty, readByPropertyh, readByIdStr, readByIdStrh,
readByObjectIdentifier, readByObjectIdentifierh, clickInPageh, clickByProperty, clickByPropertyh, clickByIdStrh, clickByObjectIdentifier,
clickByObjectIdentifierh, setByProperty, clickLink, clickLinkh
**/
function clickByObjectIdentifier(/* optional */ browserName, /* optional */ objOrPredicate1toN, /* optional */ timeoutMs, /* optional */ maxDepth, objectIdentifier){
  return sliceAndApply(seekByObjectIdentifier, click, arguments, 0);
}

/**
Performs the same function as [[#clickByObjectIdentifier|clickByObjectIdentifier]] but highlights containers, objects as they are found. Used for debugging.


See [[#clickByObjectIdentifier|clickByObjectIdentifier]] for more details on parameters
== Related ==
clickByObjectIdentifier
**/
function clickByObjectIdentifierh(/* optional */ browserName, /* optional */ objOrPredicate1toN, /* optional */ timeoutMs, /* optional */ maxDepth, objectIdentifier){
  return sliceAndApply(seekByObjectIdentifierh, click, arguments, 0);
}



/**
Performs the same function as [[#setInPage|setInPage]] but highlights containers, objects as they are found. Used for debugging.


See [[#setInPage|setInPage]] for more details on parameters
== Related ==
setInPage
**/
function setInPageh(/* optional */ browserName, objOrPredicate1toN, /* optional */ timeoutMs, /* optional */ maxDepth, value){
  return sliceAndApply(seekInPageh, set, arguments, 1);
}

/**
Seeks an object within the active page matching a single property value and sets its default data value

See [[#seekInPage|seekInPage]] for more details on parameters
== Params ==
optionalSeekInPageParams: Various - Optional - Default: see [[seekInPage]] - all the parameters used by [[#seekInPage|seekInPage]] can be used as a prefix to the following required parameters
searchPropertyName: String -  Required - The property name to search for
searchPropertyValue: String -  Required - the value of the property
objectValue: Object -  Required - the value to set the object to
== Related ==
seek, seekInPage, seekInPageh, seekByIdStr, seekByIdStrh, setByIdStr, seekByObjectIdentifier, seekByObjectIdentifierh, setByIdStrh,
setByObjectIdentifier, setInPage, setInPageh, setByObjectIdentifier, setByObjectIdentifierh, seekByProperty, seekByPropertyh, readInPage, readInPageh, readByProperty, readByPropertyh, readByIdStr, readByIdStrh,
readByObjectIdentifier, readByObjectIdentifierh, clickInPageh, clickByProperty, clickByPropertyh, clickByIdStrh, clickByObjectIdentifier,
clickByObjectIdentifierh, setByProperty, clickLink, clickLinkh
**/
function setByProperty(/* optional */ browserName, /* optional */ objOrPredicate1toN, /* optional */ timeoutMs, /* optional */ maxDepth, searchPropertyName, searchPropertyValue, objectvalue){
  return sliceAndApply(seekByProperty, set, arguments, 1);
}


/**
Finds a link with matching content text and clicks it

See [[#seekInPage|seekInPage]] for more details on parameters
== Params ==
optionalSeekInPageParams: Various - Optional - Default: see [[#seekInPage|seekInPage]] -  all the parameters used by [[#seekInPage|seekInPage]] can be used as a prefix to the following required parameters
linkContentText: String -  Required - The content text to find
== Related ==
seek, seekInPage, seekInPageh, seekByIdStr, seekByIdStrh, setByIdStr, seekByObjectIdentifier, seekByObjectIdentifierh, setByIdStrh,
setByObjectIdentifier, setInPage, setInPageh, setByObjectIdentifier, setByObjectIdentifierh, seekByProperty, seekByPropertyh, readInPage, readInPageh, readByProperty, readByPropertyh, readByIdStr, readByIdStrh,
readByObjectIdentifier, readByObjectIdentifierh, clickInPageh, clickByProperty, clickByPropertyh, clickByIdStrh, clickByObjectIdentifier,
clickByObjectIdentifierh, setByProperty, clickLink, clickLinkh
**/
function clickLink(/* optional */ browserName, /* optional */ objOrPredicate1toN, /* optional */ timeoutMs, /* optional */ maxDepth, linkContentText){
  var args = linkArgs(arguments);
  return sliceAndApply(seekInPage, click, args, 0);
}

/**
Performs the same function as [[#clickLink|clickLink]] but highlights containers, objects as they are found. Used for debugging.


See [[#clickLink|clickLink]] for more details on parameters
== Related ==
clickLink
**/
function clickLinkh(/* optional */ browserName, /* optional */ objOrPredicate1toN, /* optional */ timeoutMs, /* optional */ maxDepth, linkContentText){
  var args = linkArgs(arguments);
  return sliceAndApply(seekInPageh, click, args, 0);
}

/**
Performs the same function as [[#setByProperty|setByProperty]] but highlights containers, objects as they are found. Used for debugging.

See [[#setByProperty|setByProperty]] for more details on parameters
== Related ==
setByProperty
**/
function setByPropertyh(/* optional */ browserName, /* optional */ objOrPredicate1toN, /* optional */ timeoutMs, /* optional */ maxDepth, searchPropertyName, searchPropertyValue, objectvalue){
  return sliceAndApply(seekByPropertyh, set, arguments, 1);
}

/**
Pauses execution until the main active web page is loaded - i.e. all Ajax is complete. This is a useful function for preventing a
script interacting with objects before they are loaded. see [[http://support.smartbear.com/viewarticle/31432/|TestComplete Wait method]]
== Params ==
browserName: [[http://support.smartbear.com/viewarticle/29898/|BrowserName]]  -  Optional -  Default: '*' -  *, iexplore, firefox, chrome
timeoutMs: Int - Optional - Default: 10000 - max time to wait for page load
**/
function waitActivePage( /* optional */ browserName, /* optional */ timeoutMs){
  return activePage(browserName, true, timeoutMs);
}


/**
Closes the specified browser
== Params ==
browserName: [[http://support.smartbear.com/viewarticle/29898/|BrowserName]]|  -  Optional -  Default: '*' -  *, iexplore, firefox, chrome
**/
function closeBrowser( /* optional */ browserName){ 
  browserName = def(browserName, targetBrowserName());
  var browser = Sys.WaitBrowser(browserName);
  var result = browser.Exists;
  if (result) {
    browser.Close();
    closeIEMultTabsWarning();
    if (browser.Exists){
      browser.Terminate();
    }
    // keep closing until all closed
    closeBrowser(browserName);
  }
}


/**
Closes the IE multi tabs open warning if it exists - used in close browser function
== Related ==
closeBrowser
**/
function closeIEMultTabsWarning()
{
  var closeTabsButton = waitAlias("Aliases.browser.dlgInternetExplorer.btnCloseAllTabs", 1000);
  if (closeTabsButton.Exists) {
    closeTabsButton.ClickButton();
  }
}

/**
A constant. The default browser to be used - currently IE but can be changed to suite the site. see Also [[http://support.smartbear.com/viewarticle/27184/|Checking Current Browser]]
== Return ==
Int - btIExplorer
== Related ==
goUrl, reopenBrowser
**/
function defaultBrowser(){
  return WebUtilsPrivate.defaultBrowser();
}

/**
Opens a browser and navigates to the specified url.
== Params ==
url: String -  Required -  the url
waitTime: Int - Optional - Default: 10000 - the maximum time to wait for the page (ms)
browserItem: Int -  Optional -  Default: [[#defaultBrowser|targetBrowserIndex()]] -  the index of the current browser
== Related ==
defaultBrowser
**/
function goUrl(url, /* optional */ waitTime, /* optional */ browserItem){
  browserItem = def(browserItem, targetBrowserIndex());
  var browser = Sys.WaitBrowser(browserIndexToName(browserItem));
  var browserItem = Browsers.Item(browserItem);
  if (browser.Exists){
    browserItem.Navigate(url, waitTime)
  }
  else {
    browserItem.Run(url, waitTime);  
    var browserWindow = seek(Sys.Browser(), {ObjectType:"BrowserWindow"});
    browserWindow.Maximize();
  }
}

/**
Closes and re-opens the browser at the specified url
== Params ==
url: String -  Required -  the url
browserItem: Int -  Optional -  Default: [[defaultBrowser]] -  the index of the current browser
== Related ==
defaultBrowser
**/
function reopenBrowser(url, /* optional */  waittimeout, /* optional */ browserItem){
  browserItem = def(browserItem, targetBrowserItem());
  var browserName = browserIndexToName(browserItem);
  closeBrowser(browserName);
  goUrl(url, waittimeout, browserItem);
}

// the following is based on testcomplete help copyright message at the bootom of this file does not apply to 
// this function
/**
Finds all visible broken links within a container
== Params ==
container: web UI Object -  Required -  the container to search for links
linkPreCheckFuncFunction: a predicate function -  Optional -  return false from this function to skip link checking
responseTextCheckFunc: a response check function -  Required -  a function used to check the response return false to fail the test
== Related ==
findMainPageBrokenLinks
**/
function findBrokenLinks(container, linkPreCheckFuncFunction, responseTextCheckFunc){
  // Obtains the links
  var links = seekAll(container, {Name: 'Link*', VisibleOnScreen: 'True'});
  
  var linksCount = links.length;
  
  if (linksCount > 0)
  {
    // Searches for broken links
    for (var counter = 0; counter < linksCount; counter++)
    {
      var linkObj = links[counter];
      verifyLinkedObject(linkObj, linkPreCheckFuncFunction, responseTextCheckFunc);
    }
  }
}

/**
Same as [[#findBrokenLinks|findBrokenLinks]] but searches main web page i.e. tabindex 0.
See [[#findBrokenLinks|findBrokenLinks]] for details
== Related ==
findBrokenLinks
**/
function findMainPageBrokenLinks(linkPreCheckFuncFunction, responseTextCheckFunc){
  var page = activePage();
  findBrokenLinks(page, linkPreCheckFuncFunction, responseTextCheckFunc);
}

/**
Returns the active browser of the specified type

== Params ==
browserName: String -  Optional - Default: targetBrowserName - the name of the browser type
== Return ==
Object - UI Object - the browser or a stub object fith a false Exists property
== Related ==
activePage
**/
function activeBrowser(browserName){
  return Sys.WaitBrowser(def(browserName, targetBrowserName()));
}


/**
Returns the active browser if there is one or the default browser
== Params ==
browserIndex: Int -  Optional -  the index of the browser type : btIExplorer, btFireFox, btChrome
== Return ==
[[http://support.smartbear.com/viewarticle/32178/|BrowserInfo]] - browser info see linked information
== Related ==
defaultBrowser
**/
function activeBrowserInfo(browserIndex){
  var browserInfo = hasValue(browserIndex) ? 
                  Browsers.Item(browserIndex) :
                  def(Browsers.CurrentBrowser, Browsers.Item(targetBrowserIndex()));
  return browserInfo;
}

// © John Walker 2013 – Permission for unrestricted use and modification granted within 
// THE-COMPANY and affiliated companies






