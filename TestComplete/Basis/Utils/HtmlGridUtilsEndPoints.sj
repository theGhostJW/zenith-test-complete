//USEUNIT CheckUtils
//USEUNIT WebUtils
//USEUNIT HtmlGridUtils
//USEUNIT StringUtils

function readGridEndPoint(){
  var grid = seekInPage({IdStr: 'ctl00_MainContent_orderGrid'});
  var content = readGrid(grid);
  toTemp(content);
}


function cellEndPoint() {
  var grid = seekInPage({IdStr: 'ctl00_MainContent_orderGrid'});
  var targetCell = cell(
                      grid, ['~City',           'Name'],
                            ['Salmon Island']
                    );
  log(targetCell.contentText);
  
  targetCell = cell(
                      grid, ['~City',           'City'],
                            ['Salmon Island']
                    );
  log(targetCell.contentText);
}

function readCellEndPoint() {
  var table = seekInPage({IdStr: 'ctl00_MainContent_orderGrid'});      
  var name = readCell(table, ['~City',         'Name'],
                              ['Salmon Island']);
  checkEqual('Steve Johns', name);
}


function setGridEndPoint_SetSelectedCol() {
  var grid = seekInPage({IdStr: 'ctl00_MainContent_orderGrid'});            
  setGrid(grid, ['~Name'     , '' ],
                ['Steve Johns', true],
                ['Mark Smith',  true]
  );
  
    
  var table = seekInPage({IdStr: 'MasterPagecontentgridSMSHistory_ctl00'});
  verificationInfo = [
                          ['~messageID' ,'employee'       , 'date'],
                          ['999'        ,'Cooper, Sheldon', '11 Apr 2013 14:40:47'],
                          ['2516732'    ,'Cooper, Sheldon', '11 Apr 2013 15:54:49'],
                          ['2516729'    ,'Cooper, Sheldon', '11 Apr 2013 11:10:06']
                      ];
  setGrid(table, verificationInfo);
}

function eachCell_SmartBearEndPoint() {
  function cellTest(cell, colTitle, rowIndex, colIndex){
    if (colIndex === 0){
      log('=================')
    }
    log('Cell: ' + ' col Title: ' + colTitle + ' - ' + rowIndex + ', ' +  colIndex + ' Visible: ' + (cell.Height > 0) + ' Content text: ' + cell.ContentText);
 } 
 var table = seekInPage({IdStr: 'ctl00_MainContent_orderGrid'});
  // this should print the content texty of each cell
  eachCell(table, cellTest);
}

function eachCellEndPoint() {
  function cellTest(cell, colTitle, rowIndex, colIndex, arFullRow){
    if (colIndex === 0){
      log('=================')
    }
    log('Cell: ' + ' col Title: ' + colTitle + ' - ' + rowIndex + ', ' +  colIndex + ' Visible: ' + (cell.Height > 0) + ' Content text: ' + cell.ContentText);
 } 
  var table = seekInPage({IdStr: 'ctl00_MainContent_orderGrid'});
  eachCell(table, cellTest);
}

function eachCellSimpleEndPoint() {
  function cellTest(cell, rowIndex, colIndex, arFullRow){
      if (colIndex === 0){
        log('=================')
      }
      log('Cell: ' + rowIndex + ', ' +  colIndex + ' Visible: ' + (cell.Height > 0) + ' Content text: ' + cell.ContentText);
  } 
  
  var grid = seekInPage({IdStr: 'ctl00_MainContent_orderGrid'});
  eachCellSimple(grid, cellTest);
}

function cellTest(cell, colTitle, rowIndex, colIndex){
  if(sameText(colTitle, 'date')){
    log(colTitle + ' : ' + cell.InnerText);
  } 
  else {
    log(colTitle + ' : ' + colIndex);
  }
  
  var node = seek(cell, {ObjectTupe: 'TextNode'});
}