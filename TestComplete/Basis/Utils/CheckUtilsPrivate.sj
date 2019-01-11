//USEUNIT SysUtils
//USEUNIT FileUtils
//USEUNIT StringUtils
//USEUNIT _

function checkPrivate(condition, mainMessagePrefix, messageStr, additionalInfo){
  messageStr = def(messageStr, '');
	var fail = false;
	var mainMessage;
	var conditionNull = isNullEmptyOrUndefined(condition);
  mainMessagePrefix = def(mainMessagePrefix, "Check");
	
  if (isNullEmptyOrUndefined(condition)){
		mainMessage = "Condition is null empty string or undefined - " + mainMessagePrefix;
		fail = true;
	}
	else {
    var titlePrefix = hasValue(messageStr) ? mainMessagePrefix + ' - ' : mainMessagePrefix;
    mainMessage = titlePrefix + messageStr;
    var lineIdx = mainMessage.indexOf('\n'); 
    if (lineIdx > -1){
      mainMessage = mainMessage.slice(0, lineIdx) + ' ...';
    }
    
    if (!hasValue(additionalInfo)){
      additionalInfo = hasValue(messageStr) ? mainMessagePrefix + '\n' : mainMessagePrefix;
      additionalInfo = additionalInfo + messageStr;
    }
    
		fail = !condition;
	}
  
	if (fail){
	  Log.Error(mainMessage, additionalInfo);
	}
  else {
    logCheckPoint(mainMessage, additionalInfo);
  }
  return !fail;
}

// document later may oly work with ansi files
function checkTextAgainstTextFileFullPath(testFilePath, actualText, fileEncoding){
  fileEncoding = def(fileEncoding, projectScriptFileEncoding());
  
  function setFileInStore(storeName, filePath){
    try {
      Files.Remove(storeName);
      Files.Add(filePath,storeName);
    }
    catch (ex) {
      if (hasText(ex.message, "'Files' is undefined")){
        throwEx(
          'Calling checkTextAgainstTextFile in a project where there is no <Stores>.<Files> defined.' + newLine() +
          'Ensure a Stores item is added to the project and a Files item is added to Stores to correct this problem.' + newLine() +
          'checkTextAgainstTextFile depends on <Stores><Files>.'); 
      }
      throwEx(ex.message, ex.description);
    }
  }
  
  var expectedStoreName = 'expected';
  var actualStoreName = 'actual';
  
  var expectedTxt = fileToString(testFilePath, fileEncoding);
  expectedTxt = standardiseLineEndings(expectedTxt);
  var modifiedFilePath = tempFile('ExpectedTxtCompare.txt');
  stringToFile(expectedTxt, modifiedFilePath);
  setFileInStore(expectedStoreName, modifiedFilePath);
  
  var actualPath = tempFile(actualStoreName + '.txt');
  actualText = standardiseLineEndings(actualText);
  stringToFile(actualText, actualPath);
  setFileInStore(actualStoreName, actualPath);
  
  pushLogFolder('Text Compare - ' + testFilePath, 
      '========= EXPECTED =========' + newLine() + 
      expectedTxt + newLine(2) + '========= ACTUAL =========' + newLine() + actualText);
  try {
    var result = Files.Items(expectedStoreName).Check(actualStoreName);
  }
  finally {
    popLogFolder();
  }
  
  
  return result;
}

function getSuccessInfoMessage(expected, infoMessage){
    infoMessage = def(infoMessage, '');
    var result;
    if (_.isObject(expected)) {
      result = 'Object Verified: ' + newLine() + objectToJson(expected);    
    }
    else {
      result = expected + ' verified';     
    } 
    
  return hasValue(infoMessage) ? infoMessage  + ' - ' + result : result;
}


function getFailMessage(expected, actual, additionalMsgStr, delim){
  function toStr(obj){
    return _.isObject(obj) ? objectToJson(obj): obj;
  }
  
 	var msgBase = "Expected:" + delim + toStr(expected) + (delim === newLine() ? delim + delim: delim) + "did not equal Actual:" + delim + toStr(actual);
	var failMessage = additionalMsgStr ? additionalMsgStr + '.' + delim +  msgBase : msgBase; 
  return failMessage;
}