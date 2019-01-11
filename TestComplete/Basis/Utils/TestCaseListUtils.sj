//USEUNIT TestCaseListUtilsPrivate
//USEUNIT FileUtils
//USEUNIT _
//USEUNIT SysUtils


/** Module Info **

 Framework use only

**/



var testListItemsSingleton;

/**
 Framework use only
**/
function testListItems(){
  if (!hasValue(testListItemsSingleton)){
    testListItemsSingleton = testCaseListItems();
  }
  return testListItemsSingleton;
}

/**
 Framework use only
**/
function listContentAsArrayMinusHeader(){
  return TestCaseListUtilsPrivate.listContentAsArrayMinusHeader();
}

/**
 Framework use only
**/
function regenerateTestCaseListFile(testListContent, invalidNamesInList, footer, testListItems, missingInTestList, destPath){
  function addUseUnitPrefix(item){
    return '//USEUNIT ' + item;  
  }
  
  function isInvalid(line){
    var str = trimWhiteSpace(line);
    
    var result = false;
    if (isRestartOrTestCase(str)){
      str = firstWord(str);  
      result = _.contains(invalidNamesInList, str);
    }
    return result;
  }
  
  var units = _.chain(testListItems.concat(missingInTestList))
                .reject(isInvalid)
                .map(addUseUnitPrefix)
                .value()
                .join(newLine());
  
  var testItems = _.reject(testListContent, isInvalid)
                    .join(newLine());
  
  var content = units + newLine(2) +
                START_TOKEN() + newLine(2) +
                testItems + newLine(2) +
                footer;
                
  stringToFile(content, destPath);
}




