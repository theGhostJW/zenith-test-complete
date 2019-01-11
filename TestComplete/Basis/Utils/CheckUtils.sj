//USEUNIT SysUtils
//USEUNIT CheckUtilsPrivate
//USEUNIT FileUtils
//USEUNIT StringUtils
//USEUNIT StringUtilsParent
//USEUNIT _

/** Module Info **
CheckUtils provides functions related to checking and logging the results of checks
**/

function checkWithinTolerance(expectedNumber, actualNumber, tolerance, infoMessage){
  var passed = areEqualWithTolerance(expectedNumber, actualNumber, tolerance);
  var message = 'check witihn tolerance of: ' + trim(tolerance) + ' ' + (passed  ? getSuccessInfoMessage(expectedNumber, infoMessage) 
                        : getFailMessage(expectedNumber, actualNumber, infoMessage, ' '));
  return checkPrivate(passed, null, message);
}

/**

Checks if a UI object exists logs a checkpoint on success or an error on failure

==  Params ==
obj: Object - Required - the target object
message: String - Optional - Default: main check message - additional information to be logged
== Return ==
Boolean - returns true if the object exists
==  Related ==
checkExistsNot
**/
function checkExists(uiObj, messageStr){
  return check(uiObj.Exists, messageStr);
}

/**
Checks a UI object does not exist

see [[#checkExists|checkExists]] for details
==  Related ==
checkExists
**/
function checkExistsNot(uiObj, messageStr){
  return checkFalse(uiObj.Exists, messageStr);
}

/**

Compares two strings and uses diff viewer to show differences in log file if there are any

== Params ==
expected: String -  Required - the expected string
actual: String -  Required - the actual string
== Return ==
Boolean  - true if text is identical
== Related ==
checkTextAgainstTextFile
**/
function checkText(expected, actual){
  var expectedPath = tempFile('expected.txt');
  stringToFile(expected, expectedPath);
  checkTextAgainstTextFileFullPath(expectedPath, actual);
}

/**

Compares an actual String with the content of a text file in the TestData directory

== Params ==
testFileName: String -  Required -  the name of a file in the TestData directory
actualText: String -  Required -  the actual text
encoding: TestComplete file encoding -  Optional - Default: [[#projectScriptFileEncoding|projectScriptFileEncoding]] - one of ctANSI, ctUnicode, ctUTF8
== Return ==
Boolean  - true if text is identical
== Related ==
checkText
**/
function checkTextAgainstTextFile(testFileName, actualText, encoding){
  checkTextAgainstTextFileFullPath(testDataFile(testFileName), actualText, encoding)
}

/**
Compares two values and logs an error noting that expected does not equal expected if they differ. 
If the values are equal then a confirmation message is logged.
== Params ==
expected: Object -  Required -  expected value
actual: Object -  Required -  actual value
infoMessage: String - Optional - Default: main check message - additional info to be logged
== Return ==
Boolean - the result of the compare
== Related ==
check, checkFalse
**/
function checkEqual(expected, actual, infoMessage){
	var passed = areEqual(expected, actual);
	var message = passed  ? getSuccessInfoMessage(expected, infoMessage) 
                        : getFailMessage(expected, actual, infoMessage, ' ');
  var additionalInfo =  passed ? message : getFailMessage(expected, actual, infoMessage,  newLine());
  return checkPrivate(passed, null, message, additionalInfo);
}


/**
Checks if a string contains another
== Params ==
hayStack: String -  Required -  base string
needle: String - Required -  string to search for 
infoMessage: String -  Optional - Default: main check message - additional info logged
caseSensitive: Boolean - Optional - Default: false - case sensitive search
== Return ==
Boolean - outcome of applying the check, true if substring is present
== Related ==
hasText
**/
function checkContains(hayStack, needle, infoMessage, caseSensitive){
  // params kungfu
  if (arguments.length === 3 && _.isBoolean(infoMessage)){
    caseSensitive = infoMessage;
    infoMessage = '';
  }
  
  var found = hasText(hayStack, needle, caseSensitive);
  infoMessage = def(infoMessage, '');
  infoMessage = hasValue(infoMessage) ?  infoMessage + newLine() : '';
  infoMessage = infoMessage +
   'Looking for: ' + needle + newLine() + ' in ' + newLine() + hayStack; 
   
  var okFail = found ? 'OK' : 'Failed';
  var strNot = found ? '' : ' not';
  return check(found, infoMessage, 'Contains Check ' + okFail + ' - ' + needle + strNot + ' found.', 'Contains Check');
}

/**
Standardises line endings and replaces line endings with space then checks text fragments split on wild cards '*'

==  Params ==
expectedContent: String -  Required -  the expected string with wildcards separating segments to check
actualContent: String -  Required -  the target content to check
== Return ==
Boolean - returns true if all text segments are found
**/
function checkTextContainsFragments(expectedContent, actualContent){
  function standardisNewLines(str){
    str = standardiseLineEndings(str);
    str = replace(str, newLine() + ' ', ' ');
    str = replace(str, ' ' + newLine(), ' ');
    return replace(str, newLine(), ' ');
  }
  
  expectedContent = standardisNewLines(expectedContent);
  actualContent = standardisNewLines(actualContent); 
  
  function processFoundResult(fragment, remainder, found){
    var detailMessage = 'Looking for Fragment' + newLine() + fragment + newLine(2) + 'Looking In' + newLine() + remainder
    if (found){
      logCheckPoint('Text Fragment Found - ' + fragment, detailMessage);
    }
    else {
      logError('Text Fragment Not Found - ' + fragment, detailMessage);
    }
  }
  
  return StringUtilsParent.wildcardMatch(actualContent, expectedContent, true, true, processFoundResult);
}

/**

Performs the same check as [[checkTextContainsFragments]] but initially reads the string from a test data file and performs checks on string passed in directly

==  Params ==
testDataFileName: String -  Required -  the test file name (from the testData directory)
actualText: String -  Required -  the actual text to be checked
== Return ==
Boolean - returns true if all items in the expectedContent are found
**/
function checkTextContainsFragmentsFromFile(testDataFileName, actualText){
  var expectedFragments = testDataString(testDataFileName);
  return checkTextContainsFragments(expectedFragments, actualText);
}

/**
Checks if a condition is true and logs an error on failure or confirmation on success
== Params ==
condition: Boolean -  Required -  the condition under test
messageStr: String -  Optional - Default: main check message -  additional info in the case of a test failure
== Return ==
Boolean - outcome of applying the check
== Related ==
checkFalse
**/
function check(condition, messageStr, additionalInfo, prefixOverride){
  return checkPrivate(condition, prefixOverride, messageStr, additionalInfo);
}

/**
Checks if a condition is false and logs an error on failure or confirmation on success
== Params ==
condition: Boolean -  Required -  the condition under test
messageStr: String -  Optional -  Default: '' - text added to the main message
additionalInfo: String - Optional -  Default: main message string - text added to additional info log panel
prefixOverride: String - Optional -  Default: 'Check'- text at the start of the main log message "Check" by default
== Return ==
Boolean - true if the test passed i.e. the condition is false
== Related ==
check
**/
function checkFalse(condition, messageStr, additionalInfo, prefixOverride){
  return check(!condition, messageStr, additionalInfo, prefixOverride);
}


// © John Walker 2013 – Permission for unrestricted use and modification granted within 
// THE-COMPANY and affiliated companies

