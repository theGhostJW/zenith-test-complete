//USEUNIT StringUtils
//USEUNIT SysUtils
//USEUNIT _


/** Module Info **
Provides a handful of functions for working with Excel - see also [[#ExcelDataConnection|ExcelDataConnection]] and
the built in framework facilities for data driving tests
**/



/**
Terminates all Excel processes
== Related ==
terminateProcess
**/
function TerminateExcelProcess(){
  terminateProcess('EXCEL');
}

/**
Returns the number of sheets in an Excel workbook
== Params ==
path: String -  Required -  the full path to the Excel data file
== Return ==
Int - the number of worksheet in the excel workbook
**/
function getSheetCount(path){
  var app = Sys.OleObject("Excel.Application");
  result = -999;
  try {
    app.DisplayAlerts = false;
    var book = app.Workbooks.Open(path);
    result = book.Worksheets.Count;
  } finally {
    app.Quit();
  }
  return result;
}


/**
Converts  worksheet values as tab delimited string
Good for quick simple data validation
== Params ==
path: String -  Required -  full path to the excel file
sheet: String -  Required -  Excel worksheet tab name
startCol: String -  Required -  Col letter to start reading from A to Z only supported
startRow: Int  -  Required -  Row No start reading from
endCol: String -  Required -  Col letter to end reading at
endRow: Int -  Required -  Row No end reading at
== Return ==
String - the text of the cells
**/
function getSheetValuesAsString(path, sheet, startCol, startRow, endCol, endRow){
  log('Terminating all excel processes');
  TerminateExcelProcess();
  var app = Sys.OleObject("Excel.Application");
  result = '';
  app.DisplayAlerts = false;
  var book = app.Workbooks.Open(path);
  var sheet = book.Sheets(sheet);

  ensure((startCol.length === 1) && (startCol.length === 1), 'Only columns A to Z supported');
  var startColNo = colNo(startCol),
  endColNo = colNo(endCol);
    
  var colCount = sheet.Columns.Count;
  ensure(colCount >= endColNo && startColNo > 0, 'Column index out of range');
  var rowCount = sheet.Rows.Count;  
  ensure(rowCount >= endRow && startRow > 0, 'Row Index out of range');
  
  for (var counter = startRow; counter <= endRow; counter++){
    var rowSting = '';
    for (var cellCounter = startColNo; cellCounter <= endColNo; cellCounter++){
       var text = def(sheet.Cells(counter, cellCounter).Text, ' ');
       rowSting = appendDelim(rowSting, '\t | ', text);
    }
    result = appendDelim(result, newLine(), rowSting);
  }
  app.Quit();
  return result;
}

/**
Converts a column char to an index A - Z.. 
== Params ==
colChar: String -  Required -  A..Z or AA, AB ...
== Return ==
Int - the column no
**/
function colNo(colChars){
  function colCharToColNo(colChar){
    colChar = aqString.ToUpper(colChar);
    return colChar.charCodeAt(0) - 64;
  }
  
  function accum(mem, newChar){
    var baseNo = colCharToColNo(newChar);
    var toAdd = baseNo * Math.pow(26, mem.position);
    var result = {
      result: mem.result + toAdd,
      position: mem.position + 1
    };
    return result;
  }
  
  var sourceChars = colChars.split('');
  var result  = _.reduceRight(sourceChars, accum, {result: 0, position: 0});
  
  return result.result;
}
