//USEUNIT CheckUtils
//USEUNIT FileUtils
//USEUNIT StringUtils
//USEUNIT EndPointLauncherUtils

function fileToTableEndPoint() {
  var result;
    
  function yeaBoo(val, key, obj){
    return obj.id === 10 ? 10 : _.isBoolean(val) ? val ? 'Yea' : 'Boo' : val;
  }
  
  result = fileToTable("FileToTable.txt", false);
  toTemp(result, 'noParse');
  
  result = fileToTable("FileToTable.txt");
  toTemp(result, 'parseAll');
  
  result = fileToTable("FileToTable.txt", yeaBoo);
  toTemp(result, 'parseAllWithConverter');
  
  result = fileToTable("FileToTable.txt", 'dob', 'address');
  toTemp(result, 'dobAndAddressNotParsed');

  result = fileToTable("FileToTableGrouped.txt", false);
  toTemp(result, 'noParseGrouped');
  
  result = fileToTable("FileToTableGrouped.txt");
  toTemp(result, 'parseAllGrouped');
  
  result = fileToTable("FileToTablesWithDefect.txt");
  checkEqual('55/f', result[0].nonNum, 'should be string');
}

function fileToTablesEndPoint() {
  
  function yeaBooBool(val, key, obj){
    return _.isBoolean(val) ? val ? 'Yea' : 'Boo' : val;
  }
  
  function blahh(val, key, obj){
    return _.isString(val) ? val : 'BLAHHHH';
  }
  
  var result;
  result = fileToTables("FileToTables.txt", false);
  toTemp(result, 'noParse');
  
  result = fileToTables("FileToTables.txt");
  toTemp(result, 'parseAll');
  
  result = fileToTables("FileToTables.txt", yeaBooBool, blahh);
  toTemp(result, 'parseAllPlusConverters');
  
  result = fileToTables("FileToTables.txt", {directHitCases: yeaBooBool, secondaryMatch: blahh});
  toTemp(result, 'parseAllPlusMixedConverters');
  
  result = fileToTables("FileToTables.txt", 'dob', 'address');
  toTemp(result, 'dobAndAddressNotParsed');
  
  result = fileToTables("FileToTablesWithDoubleSpaces.txt", 0);
  toTemp(result, 'parseWithDoubleSpaces');
}

function zipAllEndPoint(){
  zipAll('C:\\TestCompleteLogs\\6_01_2016_3_46 PM_13_714', '*Issues.txt', 'issues.zip'); 
  zipAll('C:\\TestCompleteLogs\\6_01_2016_3_46 PM_13_714', '*NONE.txt', 'empty.zip'); 
}

function parentDirUnitTest() {
  var target = '';
  var result = parentDir(target);
  checkEqual('', result);
  
  target = 'C:\\automationFramework\\QuickStep\\NppPlugin.DllExport\\Properties\\file.txt';
  result = parentDir(target);
  checkEqual('C:\\automationFramework\\QuickStep\\NppPlugin.DllExport\\Properties', result);
  
  target = 'C:\\automationFramework\\QuickStep\\NppPlugin.DllExport\\Properties\\';
  result = parentDir(parentDir(target));
  checkEqual('C:\\automationFramework\\QuickStep\\NppPlugin.DllExport', result);
  
  target = 'C:\\automationFramework\\QuickStep\\NppPlugin.DllExport\\Properties\\file.txt';
  result = parentDir(parentDir(target));
  checkEqual('C:\\automationFramework\\QuickStep\\NppPlugin.DllExport', result);
  
  target = 'C:\\';
  result = parentDir(target);
  checkEqual('', result);
}

function toTempEndPoint() {
  var obj = {
    name1: 'Bill',
    name2: 'Ben',
    name3: 'Weed'
  };
  
  toTemp(obj, 'bnb');
  toTemp(obj, 'bnb-nolog', false);
  
  toTemp('bill', 'bill');
  toTemp('bill', 'bill-nolog', false);
  toTemp('bill', 'bill');
}


function toTempReadableEndPoint() {
  var obj = {
    name1: 'Bill',
    name2: 'Ben',
    name3: 'Weed'
  };
  
  toTempReadable(obj, 'bnb');
  toTempReadable(obj, 'bnb1');
}


function defaultExtensionUnitTest() {
  checkEqual('file.txt', defaultExtension('file.txt', '.csv'));
  checkEqual('file.txt', defaultExtension('file', '.txt'));
  checkEqual('file.txt', defaultExtension('file', 'txt'));
}

function listFilesEndPoint() {
  var dir = testDataFile('', false);
 
  logBold('=== All ===');
  log(arrayToString(listFiles(dir)));
  
  logBold('=== Non Recursive ===');
  log(arrayToString(listFiles(dir, false)));
  
  logBold('=== *.x* ===');
  log(arrayToString(listFiles(dir, '*.x*')));
}

function listFoldersEndPoint() {
  var dir = aqFileSystem.GetFileFolder(aqFileSystem.Path);
 
  logBold('=== All ===');
  log(listFolders(dir).join(newLine()));
  
  logBold('=== Non Recursive ===');
  log(listFolders(dir, false).join(newLine()));
  
  logBold('=== *ata* ===');
  log(listFolders(dir, '*ata*').join(newLine()));
}

function eachFileEndPoint() {
  var dir = testDataFile('', false);
 
  function logIt(path, info){
    log(path + ' - ' + info.Name)
  } 
  
  logBold('=== All ===');
  eachFile(dir, logIt);
  
  logBold('=== Non Recursive ===');
  eachFile(dir, logIt, false);
  
  logBold('=== *.x* ===');
  eachFile(dir, logIt, '*.x*');
}

function eachFolderEndPoint() {
  var dir = aqFileSystem.GetFileFolder(aqFileSystem.Path);
 
  function logIt(path, info){
    log(path + ' - ' + info.Name)
  } 
  
  logBold('=== All ===');
  eachFolder(dir, logIt);
  
  logBold('=== Non Recursive ===');
  eachFolder(dir, logIt, false);
  
  logBold('=== *ata* ===');
  eachFolder(dir, logIt, '*ata*');
}

function unzipAllUnitTest() {
  var source = testDataFile('test.zip');;
  var dest =  tempDir();
  clearDirectory(dest);
  unzipAll(source, dest);
  
  var count = 0;
  var fileIterator  = aqFileSystem.FindFiles(dest, '*', true);
  if (hasValue(fileIterator)){
    while (fileIterator.HasNext()){
      count++;
      fileIterator.Next();
    };
  }
  
  checkEqual(3, count);
  
}

function fromTestDataUnitTest() {
  var path = testDataFile('testDataObj.json', false);
  aqFileSystem.DeleteFile(path);
  
  var expected = {
    ini: 1,
    mini: 2,
    mo: 5  
  };
  
  toTestData(expected, 'testDataObj');
  actual = fromTestData('testDataObj');
  checkEqual(expected, actual);
  
  aqFileSystem.DeleteFile(path);
}

function fromTempUnitTest() {
  var path = tempFile('testDataObj.json', false);
  aqFileSystem.DeleteFile(path);
  
  var expected = {
    ini: 1,
    mini: 2,
    mo: 5  
  };
  
  toTemp(expected, 'testDataObj');
  actual = fromTemp('testDataObj.json');
  checkEqual(expected, actual);
  
  aqFileSystem.DeleteFile(path);
}


function arrayToFileUnitTest(){
  var fileName, arr, result;
  fileName = tempFile("Test.txt");
  
  arr = ["A","B","C"];  
  arrayToFile(arr, fileName);
  result = fileToArray(fileName);
  checkEqual(arr, result);
  
  arr = []; 
  arrayToFile(arr, fileName);
  result = fileToArray(fileName);
  checkEqual(arr, result);  
}


function clearBrowserDownloadsEndPoint() {
  clearBrowserDownloadsDirectory();
}

function changeExtensionEndPoint() {
  var result = changeExtension('C:\\blahh.xls', '.txt')
  checkEqual('C:\\blahh.txt', result);
  
  result = changeExtension('blahh.xls', '.txt')
  checkEqual('blahh.txt', result);
}

function logFilePathWithTimeStampSuffixEndPoint() {
  var result = logFilePathWithTimeStampSuffix('myLog.xls')
}

function logsDirPathEndPoint(){
  var result;
  result = logsDirPath();
  checkEqual(result, 'C:\\TestCompleteLogs');
  
  result = logsDirPath(false);
  checkEqual(result, 'C:\\TestCompleteLogs');
  
  result = logsDirPath(true);
  /* should bring back the sub directory of the log files for this run eg : C:\TestCompleteLogs\11_05_2013_1_58 PM_31_1 */
  checkContains(result, 'C:\\TestCompleteLogs\\');
}


function runTimeFileEndPoint() {
  var result = runTimeFile('myExe.exe');
}

function tempFileEndPoint() {
  var result = tempFile('AFile.txt');
}

function nowLogSuffixEndPoint(){
  var result = nowLogSuffix();
  /* e.g.  2015-9-19-18-16-5 */
}

function relativeToAbsoluteEndPoint(){
  var relativePath = "\\Utils\\FileUtils.sj",
  basePath = Project.Path;
  var result = relativeToAbsolute(basePath, relativePath);
  checkEqual('C:\\Utils\\FileUtils.sj', result,  'if starts with backslas should start from root');
 
  relativePath = "..\\..\\Utils\\FileUtils.sj",
  basePath = Project.Path;
  var result = relativeToAbsolute(basePath, relativePath);
}

// depends on suite directory
function suiteChildPathEndPoint()
{
  var suitePath = "C:\\Automation\\ManilaPrep\\";
  checkEquals(suitePath, suiteChildPath(""));
  
  suitePath = "C:\\Automation\\ManilaPrep\\dir\\";
  checkEquals(suitePath, suiteChildPath("dir"));
  
  suitePath = "C:\\Automation\\ManilaPrep\\dir\\testFile.txt";
  checkEquals(suitePath, suiteChildPath("dir","testFile.txt"));
}


function combineUnitTest(){
  var path = combine("C:", "Demo", "Data");
  checkEqual('C:\\Demo\\Data', path);
}

function forceSlashUnitTest(){
  var str = "";
  str = forceSlash(str);
  
  str = "c:\\dir"
  str = forceSlash(str);
  
  str = "c:\\dir\\"
  str = forceSlash(str);
}

function systemTempFileEndPoint() {
  aqFile.WriteToTextFile(systemTempFile("Test.txt"), "fdfd", aqFile.ctUnicode , true);
  var result = systemTempFile("MissingtempFile.txt");
  result = systemTempFile("Test.txt");
  /* should throw */
  result = systemTempFile("MissingTestFile.txt", true);  
}

function copyToLogAddDateStampEndPoint() {
  var testFile = tempFile('test.txt');
  stringToFile('ddfsd', testFile);
  copyToLogAddDateStamp(testFile);
  // C:\TestCompleteLogs\test-2013-5-11-14-26-48.txt
  // in latest log directory = C:\TestCompleteLogs\11_05_2013_2_28 PM_05_301\test-2013-5-11-14-26-48.txt
}

function copyTestFileEndPoint() {
  var fileName = 'testDb.s3db';
  var testFileDesPath = combine(tempDir(), fileName);
  aqFileSystem.DeleteFile(testFileDesPath)
  var result = copyTestFile(fileName);
  check(aqFile.exists(testFileDesPath))
  checkEqual(testFileDesPath, result)
}

function exportToCSVEndPoint() {
  exportToCSV('SWEAP-Variation-Export.xlsx');
}

// depends on suitedirectory
function testDataFileEndPoint(){
  var suitePath = "C:\\Automation\\ManilaPrep\\";
  checkEquals(suitePath + "TestData\\", testDataFile());
  var expected = "C:\\Automation\\ManilaPrep\\TestData\\test.txt";
  checkEquals(expected, testDataFile("test.txt"));
}

function testDataStringUnitTest() {
  var str = 'ffdfdsfdsfdsfdf',
  path = testDataFile('testTxt.txt', false);
  stringToFile(str, path);
  var actual = testDataString('testTxt.txt');
  checkEqual(str, actual);
  aqFileSystem.DeleteFile(path);
}



function newExcelDriverUnitTest(){
  var driver = newExcelDriver("SimpletestData");
  checkEqual("Janice", driver.Value(0));
  DDT.CloseDriver(driver.Name)
}

function toTempStringUnitTest() {
  var fileName = 'strToActiveTest.txt';
  var content = 'dsfdfsd';
  toTempString(content, fileName);
  var readBack = tempString(fileName);
  checkEqual(readBack, content);
  aqFileSystem.DeleteFile(tempFile(fileName));
}

function stringToTestDataUnitTest() {
  var fileName = 'strToTestDatTest.txt';
  var content = 'dsfdfsd';
  stringToTestData(content, fileName);
  var readBack = testDataString(fileName);
  checkEqual(readBack, content);
  aqFileSystem.DeleteFile(testDataFile(fileName));
}



