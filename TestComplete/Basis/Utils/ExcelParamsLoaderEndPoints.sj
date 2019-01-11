//USEUNIT ExcelParamsLoaderUtils
//USEUNIT CheckUtils
//USEUNIT SysUtils
//USEUNIT FileUtils

function worksheetToArrayEndPoint(){
  function sayHi(obj){
    log('HI ' + obj.id);
  }
  var result = worksheetToArray('SimpleTestData.xlsx', sayHi);
  toTemp(result, 'SimpleTestData.json');

  result = worksheetToArray('DataClassGenTest.xlsx', sayHi);
  _.each(result, sayHi);
  toTemp(result, 'excelLoader.json');
}