//USEUNIT FileUtils
//USEUNIT CheckUtils
//USEUNIT SysUtils
//USEUNIT StringUtils
//USEUNIT _

/** Module Info **
This object provides a wrapper around an Excel Data connection - sourced and modified from TestComplete help.
**/


/**
This object provides a wrapper around an Excel Data connection - sourced and modified from TestComplete help.
The TestComplete version of this does not convert dates correctly
== Params ==
excelFileNameNoPath: String -  Required - Excel file name no path - file will be searched for in TestData directory
dataSheetName: String -  Optional -  Default: Sheet1 -  the data sheet to open
wantFileCopy: Boolean -  Required -  if true the file will be copied to the Tempfolder before it is opened
== Return ==
Custom Connection object - used by framework
**/
function DataConnection(excelFileNameNoPath, /* optional */ dataSheetName, wantFileCopy){
  function forceExcelExtension(excelFileNameNoPath){
    var extension = aqFileSystem.GetFileExtension(excelFileNameNoPath); 
    return extension ? excelFileNameNoPath : excelFileNameNoPath + ".xlsx";
  }
  
  // constructor invocation required
  if(false === (this instanceof DataConnection)) {
    return new DataConnection(excelFileNameNoPath, dataSheet);
  }
  
  ensure(!hasText(excelFileNameNoPath, ' '), 'Excel data file detected with a space in the name: ' + excelFileNameNoPath + ' - spaces are not supported in data file names. Please rename this file');
  var excelFileNameNoPathWithExtension = forceExcelExtension(excelFileNameNoPath),
  excelFilePath = wantFileCopy ? copyTestFile(excelFileNameNoPathWithExtension): testDataFile(excelFileNameNoPathWithExtension),
  dataSheet = dataSheetName ? dataSheetName : "Sheet1",
  constr = 'Provider=Microsoft.ACE.OLEDB.12.0;Data Source="' + excelFilePath + '";Extended Properties="Excel 12.0;HDR=Yes;IMEX=1"';
   
  // create the connection
  var connection = new ActiveXObject('ADODB.Connection');
  connection.ConnectionString = constr;
  connection.Open();
  
  // create recordset
  var query = 'Select * from [' + dataSheet + '$]';    
  var recordSet = new ActiveXObject('ADODB.RecordSet');
  recordSet.Open(query, connection);
  
  // assign properties
  this.connection = connection;
  this.recordSet = recordSet;
  
  this.colCount = function(){
    return this.recordSet.Fields.Count;
  }
  
  this.close = function(){
    this.recordSet.close();
    this.connection.close();   
  };
  
  this.eof = function(){
    return this.recordSet.EOF;
  };
  
  this.next = function(){
    this.recordSet.MoveNext();
    return !this.recordSet.EOF && !this.recordSet.BOF;
  };
  
  this.first = function(){
    this.recordSet.MoveFirst();
    return !this.recordSet.EOF && !this.recordSet.BOF;
  };
  
  this.value = function(fieldIndexOrName){
    return this.recordSet.Fields(fieldIndexOrName).Value;
  };
  
  this.name = function(fieldIndexOrName){
    return this.recordSet.Fields(fieldIndexOrName).Name;
  };
  
  // returns data type enum http://msdn.microsoft.com/en-us/library/windows/desktop/ms675318%28v=vs.85%29.aspx
  this.dataType = function(fieldIndexOrName){
    return this.recordSet.Fields(fieldIndexOrName).Type;
  };
  
  this.matchesSearchCriteria = function matchesSearchCriteria(lookUpNameVals){
    // return true is matches the criteria or 
    // if no criteria entered always return true
    var that = this;
    var result = hasValue(lookUpNameVals) ? _.chain(lookUpNameVals)
      .pairs()
      .all(function(pair){return driverValueEquals.call(that, pair)})
      .value() : true;
    return result;
  };
  
  function driverValueEquals(fieldNameValuePair){
    var result;
    var objVal = fieldNameValuePair[1];
    var driverVal = this.value(fieldNameValuePair[0]);
    return areEqual(objVal, driverVal);
  }
  
  function locatePrivate(reset, lookUpNameVals, index){
    index = def(index, 0);
    if(reset){
      this.first(); 
    }
    var result = false;
    var thisIndex = -1;
    while (!this.eof()){
      if (this.matchesSearchCriteria(lookUpNameVals)){
        thisIndex++; 
        if (thisIndex === index) {
          result = true;
          break;
        } 
      }
      this.next();
    } 
    return result;
  }
  
  this.locate = function(lookUpNameVals, /* optional */ index){
    return locatePrivate.call(this, true, lookUpNameVals, index);
  } 
  
  this.locateNext = function(lookUpNameVals){
    return locatePrivate.call(this, false, lookUpNameVals, 1);
  }  
}

// © John Walker 2013 – Permission for unrestricted use and modification granted within 
// THE-COMPANY and affiliated companies




