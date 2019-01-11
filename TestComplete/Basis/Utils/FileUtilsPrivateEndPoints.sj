//USEUNIT SysUtils
//USEUNIT FileUtils

function getDateColIndexesEndPoint() {
  var path = testDataFile('Timesheet-Import-EndPoint-Only.xlsx');
  
  var app = Sys.OleObject("Excel.Application");
  try {
    var book = app.Workbooks.Open(path);
    var sheet = book.Sheets('Sheet1');
    var result = getDateColIndexes(sheet);
    var result2 = getTimeColIndexes(sheet);
    delay(1);
  } finally {
    app.Quit();
  }
}
