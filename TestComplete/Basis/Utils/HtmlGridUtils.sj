//USEUNIT CheckUtils
//USEUNIT WebUtils
//USEUNIT SysUtils
//USEUNIT HtmlGridUtilsPrivate
//USEUNIT DataEntryUtils


/** Module Info **
Provides functions to facilitate interactions with HTML grids (tables).
**/


/**
Performs the same function as [[#cell|cell]] but returns the value from that cell using the default or an override read function 
== Params ==
table: HTML grid -  Required -  the parent grid
headerArray: [String] -  Required -  an array of header titles used to look up
valueArray: [String] -  Required -  an array of values used in look up
readFunction: function(cell): Object - Optional - Default: [[#read|read]] - an override read function that takes a cell and returns an Object
== Return ==
String - the value of the found cell or null if the cell is not found
== Related ==
cell
**/
function readCell(table, headerArray, valueArray, /* optional */ readFunction){
  readFunction = def(readFunction, read); 
  var theCell = cell(table,  headerArray, valueArray);
  return theCell.Exists ? readFunction(theCell) : undefined;
}


/**
Returns a single cell in a grid as specified in the headerArray, valueArray the first array which is the column titles the second of which is the searched for values.
E.g ['~First Name', '~Surname', 'ID'], ['John', 'Doe'] - Note that all but one column title is prefaced by a tilde (lookup columns). 
The example would be used to find the ID cell for First Name: John, Surname: Doe. 
== Params ==
table: HTML grid -  Required -  the parent grid
headerArray: [String] -  Required -  an array of header titles used to look up
valueArray: [String] -  Required -  an array of values used in look up
== Return ==
Cell - If not found a stub object with a single Exists property is returned : Exists = false
== Related ==
readCell
**/
function cell(table, headerArray, valueArray){
  return HtmlGridUtilsPrivate.cell(table, headerArray, valueArray);
}


/**
Sets a standard grid. Use arrays of strings the first array being the column titles. If a column title is prefaced by a tilde 
then the column will be used as a look up column and the other columns will be verified against the values provided.

== Params ==
table: HTML grid -  Required -  the parent grid
twoDArrayCoTitlesTop: [String, String] -  Required -  an array ofString arrays of equal size
**/
function setGrid(table, headerArray, valueArrays){
  var args = _.toArray(arguments);
  args.push(setGridRow);
  executeFunctionOnArrayRows.apply(null, args);
}

/**
Fires singleRowCell function for each cell of a grid function (cell, colTitle, rowIndex, colIndex, arRowCells)
filtering for visible cells & height > 1 starts on row index 1 - normally the col title row is row 0
row index will be index of visible row which may differ from true rowIndex (cell.RowIndex)
== Params ==
table: HTML Grid -  Required -  the parent grid
rowCellFunction: function  -  Required -  a function that will be fired for each cell function (cell, colTitle, rowIndex, colIndex, arRowCells)
data: Object -  Required -  arbitary data that will be passed back into the rowCellFunction
skipCount: Int -  Optional -  Default: 1 -  how many rows to skip - the default is to skip the column headers
== Related ==
eachCellSimple
**/
function eachCell(table, rowCellFunction, /* optional */ rowSkipCount){
  HtmlGridUtilsPrivate.eachCell(table, rowCellFunction, rowSkipCount);
}


/**
Fires singleRowCell function for each cell function (cell, rowIndex, colIndex, arRowCells)
No filtering starts on row index 0 - normally the col title rows.
This can be used for tables that are not normally structured. It is a fall back when other functions cannot be used.
Works the same as [[#eachCell|eachCell]] but does not provide column titles to the passed in function. 
See [[#eachCell|eachCell]] for details.
== Related ==
eachCell
**/
function eachCellSimple(table, rowCellFunction, /* optional */ rowSkipCount){
  HtmlGridUtilsPrivate.eachCellSimple(table, rowCellFunction, rowSkipCount);
}

/**

Reads every cell of an HTML grid into an array of objects

== Params ==
table: HTML Grid -  Required -  the grid to read
== Return ==
Object[] - an array of objects where each row is an object and each column title is the property name (or col index if the column is untitled) and column value as the property value
== Related ==
eachCell
**/
function readGrid(table){
  var row = null;
  var result = []
  var lastRowIndex = -1;
  function addField(cell, colTitle, rowIndex, colIndex, arRowCells){
    if (lastRowIndex !== rowIndex){
      row = {};
      result.push(row);
      lastRowIndex = rowIndex;
    }
    row[def(colTitle, colIndex)] = read(cell);
  }
  eachCell(table, addField);
  return result
}

/**
A string function used specifically for matching column titles. Lower-cases and deletes spaces in a column title
== Params ==
str: String -  Required -  the target string
== Return ==
String - see above
**/
function lwrCaseTrimNoWhiteSpace(str){
  return HtmlGridUtilsPrivate.lwrCaseTrimNoWhiteSpace(str);
}


// © John Walker 2013 – Permission for unrestricted use and modification granted within 
// THE-COMPANY and affiliated companies


