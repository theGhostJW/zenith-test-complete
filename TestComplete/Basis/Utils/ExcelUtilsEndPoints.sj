//USEUNIT ExcelUtils
//USEUNIT SysUtils
//USEUNIT CheckUtils
//USEUNIT FileUtils

function getSheetsUnitTest() {
  var path = testDataFile('DataClassGenTest.xlsx');
  var result = getSheetCount(path);
  checkEqual(1, result);
}

function colNoEndPoint() {
  var result = colNo('A');
  checkEqual(1, result);
  
  result = colNo('EP');
  checkEqual(146, result);
}