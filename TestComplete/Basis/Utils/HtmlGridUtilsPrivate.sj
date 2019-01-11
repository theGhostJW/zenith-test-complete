//USEUNIT WebUtils  
//USEUNIT StringUtils
//USEUNIT SysUtils
//USEUNIT CheckUtils
//USEUNIT StringUtils
//USEUNIT DataEntryUtils
//USEUNIT _

function cell(table, headerArray, valueArray){
  //verify arrays are correct
  ensure(headerArray.length === valueArray.length + 1, 'headerArray (colTitles) should have one more item than valueArray (col data)');
  var valueCol = _.reject(headerArray, startWithTild);
  ensure(valueCol.length === 1, 'there should be one and only one read column (without a ~)');
  
  //push an extra data item onto the values array so it passes validation (makes titles array and values array the same length)
  valueArray.push('???');
  
  var result = {Exists: false};
  function returnCell(cell){
    result = cell;
  }
  
  function findRowReturnCell(table, criteria, data){
    rowExecute(table, criteria, data, returnCell, false, false);
  }
  
  executeFunctionOnArrayRows(table, headerArray, valueArray, findRowReturnCell);
  
  return result;
}

//verifyOrSetGridRow(table, colTitles, row, verificationFunction);
function executeFunctionOnArrayRows(table, arrayArguments, rowFunction){
  var args = _.toArray(arguments);
  rowFunction = args[args.length - 1];
  // slice first and last params
  var arrayArgs = args.slice(1, args.length - 1);
  var colTitles = arrayArgs[0];
  var dataRows = arrayArgs.slice(1);
  
  function executeRowFunction(dataRow){
    var critData = getCriteriaDataObjectsFromArray(colTitles, dataRow);
    rowFunction(table, critData.criteria, critData.data);
  }
  
  _.each(dataRows, executeRowFunction);
}

function setGridRow(table, criteria, data){
  rowExecute(table, criteria, data, set);
}

function rowExecute(table, criteria, data, cellFunction, useInfoString, wantError){
  useInfoString = def(useInfoString, false);
  wantError = def(wantError, true)
  var colsProcessed = [];
  var lastRowIndex  = -1;
  var datakeys =  _.chain(data) 
                  .keys()
                  .map(lwrCaseTrimNoWhiteSpace)
                  .value();
  
  // run the cell function on each cell matched by a dataobject property
  function rowFunction(cell, colTitle, rowIndex, colIndex, arRowCells){
    if (cell.RowIndex !== lastRowIndex){
      colsProcessed = [];
      lastRowIndex = cell.RowIndex;
    }
    
    var lwrTitle =  lwrCaseTrimNoWhiteSpace(colTitle);
    var wantExecute = _.contains(datakeys, lwrTitle) && !_.contains(colsProcessed, lwrTitle);
    colsProcessed.push(lwrTitle);
    if (wantExecute){
      var value = data[lwrTitle];
      var message = (useInfoString ? "" : 'Cell function failed: ') + colTitle + ': row ' + rowIndex;
      cellFunction(cell, value, message);
    }
  }
  
  // find the matching row and then execute rowfunction for each cell
  var targetRow = seekRow(table, criteria, data);
  if (hasValue(targetRow)){
    eachCell(table, rowFunction, 0, targetRow);
  } 
  else if (wantError) {
    logError('No matching rows found:' + objectToJson(criteria));
  }
}

function startWithTild(str){
  return startsWith(str, '~');
}

function  getCriteriaDataObjectsFromArray(colTitles, colData){
  ensure(colTitles.length === colData.length, 'The length of the col titles and col data arrays are different')
  
  function removeTildPrefixAndLwr(str){
    var result = startWithTild(str) ? str.slice(1) : str;
    result = lwrCaseTrimNoWhiteSpace(result);
    return result;
  }
  
  function removeTildFromTuple0(tuple){
    var result = [removeTildPrefixAndLwr(tuple[0]), tuple[1]]
    return result;
  }
  
  var titleDataTuples = _.zip(colTitles, colData);
  var criteriaItems = _.chain(titleDataTuples).
              filter(function(tuple){return startWithTild(tuple[0])}).
              map(removeTildFromTuple0).
              value();
              
  var dataItems = _.chain(titleDataTuples).
              reject(function(tuple){return startWithTild(tuple[0])}).
              value();
              
  var dataResult = tuples2Object(dataItems);
  var criteriaItems = criteriaItems.length === 0 ? dataResult :  tuples2Object(criteriaItems);
  
  var result = {
    criteria: criteriaItems,
    data: dataResult
  };
  
  return result;
  
}

function getCriteriaDataObjectsFromArrayEndPoint() {
  function cellFuncTrue(cell, data, colTitle, rowIndex, colIndex){
    return true;
  }
  var colTitles, data, result;
  colTitles = ['Employee'         ,'~Message ID'  ,'~Date'                ,'Phone Number' ,'Message'];
  data =      ['Cooper, Sheldon'  ,cellFuncTrue    ,'11 Apr 2013 15:54:49'    ,'+61423222695'    ,'Hi Sheldon, Zigzag OFFERING shifts Caltech 0900-1400 Thu 11 Apr. Reply Y or N.'];
  result = getCriteriaDataObjectsFromArray(colTitles, data);
  
  colTitles = ['Employee', '~Message ID', '~Date', 'Phone Number', 'Message'];
  data = ['Cooper, Sheldon', '2516732', '11 Apr 2013 15:54:49', '+61423222695', 
   'Hi Sheldon, Zigzag OFFERING shifts Caltech 0900-1400 Thu 11 Apr. Reply Y or N.'];
  
  var result = getCriteriaDataObjectsFromArray(colTitles, data);
  
  colTitles = ['Employee', 'Message ID', 'Date', 'Phone Number', 'Message'];
  data = ['Cooper, Sheldon', '2516732', '11 Apr 2013 15:54:49', '+61423222695',
              'Hi Sheldon, Zigzag OFFERING shifts Caltech 0900-1400 Thu 11 Apr. Reply Y or N.'];
  result = getCriteriaDataObjectsFromArray(colTitles, data);
}

function tuples2Object(tuples){
  var result = {}
  _.each(tuples, function(tuple){
    var propName = lwrCaseTrimNoWhiteSpace(tuple[0]);
    var propVal = tuple[1];
    ensure(!_.isFunction(propVal), 'Passing function as a property in an array is not supported')
    result[propName] = propVal;
  });

  return result;
}

function tuples2ObjectEndPoint() {
  function hi(){
    return true;
  }
  var tup = ['name', hi];
  //tup[1]();
  var tups = [tup];
  
  var result = tuples2Object(tups);
  result[0]();

}

function lwrCasedKeysFromNameVal(critera){
  var pairs = _.pairs(critera);
  var lwrCaseCriteria = _.map(pairs, function(pair){return [lwrCaseTrimNoWhiteSpace(pair[0]), pair[1]]});
  var result = {}
  _.each(lwrCaseCriteria, function(pair){
            result[pair[0]] = pair[1]; 
            });
  return result;
}

function lwrCasedKeysFromNameValEndPoint() {
  var critera = {
    Name: 'jim Jamooche',
    date: aqDateTime.SetDateTimeElements(2013, 1, 5, 0, 0, 0),
    EMPTY: null,
    EMPTY_2: undefined
  };
  
  var expected = {
    name: 'jim Jamooche',
    date: aqDateTime.SetDateTimeElements(2013, 1, 5, 0, 0, 0),
    empty: null,
    empty_2: undefined
  };
  
  var actual = lwrCasedKeysFromNameVal(critera);
  // - CheckEqual not working with dates
  //checkEqual(expected, actual);

}


function eachCellSimple(table, rowCellFunction, /* optional */ skipCount, /* optional */ singleRowTarget){
  eachCellPrivate(table, rowCellFunction, skipCount, true, singleRowTarget);
}

function eachCell(table, rowCellFunction, /* optional */ skipCount, /* optional */ singleRowTarget){
  eachCellPrivate(table, rowCellFunction, skipCount, false, singleRowTarget);
}

function eachCellPrivate(table, rowCellFunction, skipCount, useSimple, singleRowTarget){
  ensure(table.ObjectType === 'Table', 'Calling a table function on a non table object.');
  skipCount = def(skipCount, useSimple ? 0 : 1);
  var arRows = allTableCells(table, !useSimple);
  
  if (!useSimple){
    colTitles = _.map(arRows[0], function(cell){return cell.contentText;})
  }

  function eachCell(arRowCells, indexInArray){
    _.each(arRowCells, function(cell){
                          colIndex = cell.columnIndex;
                          if (useSimple){
                            rowIndex = cell.rowIndex;
                            rowCellFunction(cell, rowIndex, colIndex, arRowCells);
                          }
                          else {
                            rowIndex = indexInArray; // visible rows
                            var colTitle = colTitles[colIndex];
                            rowCellFunction(cell, colTitle, rowIndex, colIndex, arRowCells);
                          }
                          });
  };
  

  if (hasValue(singleRowTarget)){
    targetIndex = singleRowTarget.length > -1 ? singleRowTarget[0].RowIndex : -1;
    
    function rowIndexSameAsTarget(arTheseCols){
      var result = -1,
      idx = -1;
      _.each(arTheseCols, function(item){
        idx++;
        if (result < 0 && item.length > 0){
          var firstCell = item[0];
          result = firstCell.RowIndex === targetIndex ? idx : result;
        };
      });
      return result;
    }
    
    var visRowIndex = rowIndexSameAsTarget(arRows);
    eachCell(singleRowTarget, visRowIndex);
  } 
  else {
    var rowCount = arRows.length;
    // rows zero indexed so start at skip count
    for (var i = skipCount; i < rowCount; i++){
      var arRowCells = arRows[i];
      eachCell(arRowCells, i);
    }
  }
}

function allTableCells(table, filterVisible){
  var cells = table.FindAllChildren('ObjectType', 'Cell', 1);
  cells =(new VBArray(cells)).toArray();
  cells = _.chain(cells)
    .filter(function (cell){return !filterVisible || cell.Visible && cell.Height > 0})
    .sortBy(function(cell){return cell.RowIndex})
    .groupBy(function(cell){return cell.RowIndex}) 
    .map(function (arr){return _.sortBy(arr, function(cell){return cell.ColumnIndex;})})
    .value();
  return cells;
}

function getColTitles(table){
  var titleCells = table.rows.item(0).cells;
  var cellCount = titleCells.length;
  var result = {}
  var counter = 0;
  _.each(titleCells, function(cell){
     var cellTitle = cell.innerText;
     result[counter] = cellTitle;
     counter++;
    });
    
  return result;
} 

/// OLD 


function getColTitlesEndPoint(){
  var table = testTable();
  var result = getColTitles(table);
  checkEqual(result[5], 'Pay Level')
}       

function getIndexFunctionPairs(mixedMap, table){
  function colNameToIndex(colNameOrIndex){
    return colNameToIndexWithTable(colNameOrIndex, table);  
  }
  
  var colIds = _.chain(mixedMap).
                    keys(mixedMap).
                    map(colNameToIndex).
                    value();
  
  
  var functions = _.values(mixedMap);
  var result = _.zip(colIds, functions);                   
  return result;
}

function colNameToIndexWithTable(colNameOrIndex, table){
  var colIndex = parseInt(colNameOrIndex);
  result = _.isNaN(colIndex) ?
          colIndexFromColName(colNameOrIndex, table) :
          colIndex;
  return result;
}


function matchCellTitle(title1, title2){
  function process(str){
    var result =  aqString.Trim(str)
    result = aqString.Replace(result, ' ', ''); 
    return result
  }
  return sameText(process(title1), process(title2));
}
  
function colIndexFromColName(colNameOrIndex, table){
  var titleCells = table.rows.item(0).cells;
  var cellCount = titleCells.length;
  var result = -1;
    
  for (var counter = 0; counter < cellCount; counter++){
    var cell = titleCells.item(counter);
    var cellTitle = cell.innerText;
    if (matchCellTitle(cellTitle, colNameOrIndex)) {
      result = counter;  
      break;
    }   
  }
  ensure(result > -1, 'No column found for cdolum tittle: ' + colNameOrIndex);
  return result;
}

function testTable(){
  return seekByIdStr('MasterPagecontentradGridPayDetails_ctl00');
}

function getIndexFunctionPairsMapEndPoint() {
  function hello(){log('Hi')}
  function seeYa(){log('seeYa')}
 
  var mixedMap = {
    0: null,
    Date: hello,
    End: null,
    Start: hello,
    Department: seeYa
  }
  
  
  var table = testTable();
  var result = getIndexFunctionPairs(mixedMap, table);
  
  function applyFunction(pair){
    var cellIndex = pair[0],
    cellFunction = pair[1];
    
    if(hasValue(cellFunction)){
      cellFunction();
    }
  
  }
  _.each(result, applyFunction);
}

function lwrCaseTrimNoWhiteSpace(str){
  return hasValue(str) ? 
              aqString.ToLower(str.replace(/\s/g, "")) :
              '';
}

function lwrCaseTrimNoWhiteSpaceUnitTest() {
  var result = lwrCaseTrimNoWhiteSpace(null);
  checkEqual('', result);
  
  result = lwrCaseTrimNoWhiteSpace(' HELLo  cooL worlD  ');
  checkEqual('hellocoolworld', result);
}

function seekRow(table, criteria, data){
  var lwrCaseCriteria = lwrCasedKeysFromNameVal(criteria);
  var criteraKeys = _.keys(lwrCaseCriteria);
  
  var currentRow = -1,
  result = null,
  criteriaCount = _.keys(lwrCaseCriteria).length - _.functions(lwrCaseCriteria).length,
  matchCount = 0,
  rowFail = false;
  
  var wantLogging = false;
  if (wantLogging){
    logBold('Seek Criteria ', objectToJson(criteria));
  }
  
  var checkedCols = [];
  function matchCell(cell, colTitle, rowIndex, colIndex, arFullRow){
    if (hasValue(result)){
      return;
    }
    
    if(currentRow !== rowIndex){
      if(wantLogging){
        logBold('checking row index: ' + rowIndex)
      }
      currentRow = rowIndex;
      matchCount = 0;
      checkedCols = []
      rowFail = false;  
    }
    
    if (!rowFail){
      var lwrTitle = lwrCaseTrimNoWhiteSpace(colTitle);
      lwrTitle = def(lwrTitle, '');
      
      if(wantLogging){
        log('Col Title: ' + lwrTitle);
      }
    
      // only check first col of name
      if (!_.contains(checkedCols, lwrTitle)){
        if (_.contains(criteraKeys, lwrTitle)){
          checkedCols.push(lwrTitle);
          var cellFunction = lwrCaseCriteria[lwrTitle + 'function'];
          cellFunction = def(cellFunction, cellEquals);
          var expected = lwrCaseCriteria[lwrTitle];
          var valsMatch = cellFunction(cell, expected, colTitle, rowIndex, colIndex, arFullRow);
        
          if (valsMatch){
            matchCount++;
            
            if(wantLogging){
              log(lwrTitle + ' expected: ' + expected + ' matches criteria');
            }
            
            if (matchCount === criteriaCount){
              result = arFullRow;
              if(wantLogging){
                logBold('Match Found');
              }
            }
          }
          else {
            if(wantLogging){
              log(lwrTitle + ' expected: ' + expected + ' DID NOT match criteria');
            }
            rowFail = true;
          }
        }
      }
    }
    else if(wantLogging){
      log('Col Title: ' + lwrTitle + ' not in criteria');
    }
  }
                
  eachCell(table, matchCell);
  return result;                    
}


function seekRowEndPoint(){
  var table = seekInPage({IdStr: 'MasterPagecontentgridSMSHistory_ctl00'});
  var row = seekRow(table, {messageId: '2516730'});
  checkEqual('11 Apr 2013 14:18:26', row[3].ContentText);
  
  
  row = seekRow(table, {messageId: '9999'});
  checkEqual(row, null);

  row = seekRow(table, 
                  {Message: 'Hi Sheldon, Zigzag OFFERING shifts Caltech 0900-1400 Thu 11 Apr. Reply Y or N.',
                  phoneNumber: '+61423222695'});
  checkEqual('2516733', row[2].ContentText);
  
  row = seekRow(table, 
                  {date: '11 Apr 2013 15:54:49',
                  phoneNumber: '+61423222695'});
  checkEqual('2516732', row[2].ContentText);
  
  function areEqualFunc(cell, data, colTitle, rowIndex, colIndex, fullRow) {
    var result = cell.ContentText === '11 Apr 2013 15:54:49';
    if (result){
      log('Cell: ' + ' col Title: ' + colTitle + ' - ' + rowIndex + ', ' +  colIndex + ' Visible: ' + (cell.Height > 0) + ' Content text: ' + cell.ContentText);
    }
    return result;
  }
  
  row = seekRow(table, 
                  {date: '11 Apr 2013 15:54:49',
                  dateFunction: areEqualFunc});
  checkEqual('2516732', row[2].ContentText);
  
  function neverEqual(cell, data, colTitle, rowIndex, colIndex, fullRow) {
    return false;
  }
  
  row = seekRow(table, 
                  {date: '11 Apr 2013 15:54:49',
                  dateFunction: neverEqual});
  checkEqual(null, row);
  
}


function cellEquals(cell, data, colTitle, rowIndex, colIndex, fullRow, /* optional */ readFunction){
  readFunction = def(readFunction, read);
  var actual = readFunction(cell);
  return areEqual(data, actual);
}
