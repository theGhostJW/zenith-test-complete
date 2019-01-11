//USEUNIT ReflectionUtils
//USEUNIT StringUtils
//USEUNIT SysUtils
//USEUNIT CheckUtils
//USEUNIT _
//USEUNIT ReflectionUtils
//USEUNIT FileUtils

function START_TOKEN(){
  return "/***** Test Case List ****";
}

function listContentAsArrayMinusHeader(){
  var testCaseListStr = testCaseListAsString();
  var list = subStrAfter(testCaseListStr, START_TOKEN());
  ensure(hasValue(list), START_TOKEN() + " must appear at the top of the TestCaseList - it appears to be missing in:" + newLine() + testCaseListStr);
  list = trimWhiteSpace(list);
  list = list.split(newLine());
  list = _.map(list, indent);
  return list;
}

function listContentAsArrayMinusHeaderEndPoint() {
  toTempString(listContentAsArrayMinusHeader().join(newLine()), 'testList.txt');
}

function indent(item){
  item = trimWhiteSpace(item);
  return isRestart(item)  ? item 
                          : isTest(item)
                            ? '\t' + item 
                            : item;
}

function testCaseListAsString(){
  var testListPath = scriptFilePath("TestCaseList");
  var testCaseListAsString = fileToString(testListPath, projectScriptFileEncoding());
  return testCaseListAsString;
}

function testCaseListItems(testCaseListStr){
  var list = listContentAsArrayMinusHeader();
  var result = _.chain(list)
                  .map(trimWhiteSpace)
                  .filter(isRestartOrTestCase)
                  .value();
  return result;
}

function isTest(trimmedStr){
  return endsWith(trimmedStr, '_Test')
}

function isRestartOrTestCase(trimmedStr){
  return isTest(trimmedStr) || isRestart(trimmedStr);
}

function firstWord(trimmedStr){
  return hasText(trimmedStr, ' ') ? subStrBefore(trimmedStr, ' ') : trimmedStr;   
}

function isRestart(trimmedStr){
  var result = false;
  if (hasText(trimmedStr, 'restart')){
    var unitName = firstWord(trimmedStr); 
    result = endsWith(unitName, 'Restart');
  }
  return result;
}

function testCaseListItemsEndPoint() {
  var testCaseListStr = testDataString('testcCseListEg.sj');
  var result = testCaseListItems(testCaseListStr); 
  checkEqual(10, result.length);
}