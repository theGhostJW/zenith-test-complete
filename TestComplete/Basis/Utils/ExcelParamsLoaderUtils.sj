//USEUNIT _
//USEUNIT CheckUtils
//USEUNIT ExcelDataConnectionUtils
//USEUNIT ExcelParamsLoaderUtilsPrivate
//USEUNIT FileUtils
//USEUNIT ReflectionUtils
//USEUNIT StringUtils
//USEUNIT SysUtils


/** Module Info **

Provides a function to turn an Excel worksheet into an array

**/


/**

Loads sheet1 of an excel workbook in the TestData directory into an array of objects

See the Zenith Users' Guide: "Data Driven Testing Using Excel" for details 

== Params ==
excelFileNameNoPath: String -  Required -  the name of the spreadsheet in the testdata directory
validators: function or [functions] - Optional - Default: null - validator function(s) to be added to each testItem object
== Return ==
Object[] - An array of Objects representing the cells of the worksheet
== Related ==
DataConnection
**/
function worksheetToArray(excelFileNameNoPath, validators){
  var result = [];
  var driver = DataConnection(excelFileNameNoPath);
  var colCount = driver.colCount();
  
  function addRecAsObject(){
    var rec = {};
    for (var counter = 0; counter < colCount; counter++){
      var name = driver.name(counter);
      var val = driver.value(counter); 
      rec[name] = val
    }
    result.push(rec);
  }
  
  if (driver.first()){
    addRecAsObject();
    while (driver.next()) {
      addRecAsObject();
    }
  }
  
  result = nestChildRecs(result, validators);
  driver.close();
  return result;
}
