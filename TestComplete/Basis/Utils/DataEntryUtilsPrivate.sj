//USEUNIT SysUtils
//USEUNIT StringUtils

function read(uiObj, wantRead){
  wantRead = def(wantRead, true);
  var result = undefined;
  var objectType = uiObj.ObjectType;
    switch (objectType) {
      case 'Cell': result = readGridCell(uiObj);
        break;
       
      case 'Label': 
      case 'Panel': 
      case 'TextNode': result = uiObj.contentText;
        break;
        
      case 'Textbox': result = uiObj.Text;
        break;
        
      case 'Select' : result = uiObj.wText;
        break;  
       
      case 'Textarea' : result = uiObj.contentText;
        break; 
      
      case 'Checkbox' :
      case 'RadioButton': result = uiObj.Checked;
        break;    
  
      default:
        if (wantRead){
          logError(objectType + ' - not handled by read function');
        }
    }
    return wantRead ? result : result !== undefined ;
}

function readEndPoint() {
  var cell = seekInPage({idStr: 'MasterPagecontentradGridLeave_ctl00'},{Name: 'Cell(1, 1)'})
  var result = read(cell);
  log(result);
}

function setCell(cell, value){
  var result =  setRosterLiveCombo(cell, value) ||
                setChildObjectValue(cell, value, 'Select') ||
                setChildObjectValue(cell, value, 'Checkbox') ||
                setChildObjectValue(cell, value, 'Textbox'); 
  
  if (!result) {
    logError('setCell - unhandled data entry cell when setting cell: ' + cell.Name + ' to value ' +  value);
  }
  return result;
}


function isReadable(obj) {
  return read(obj, false);
}
    
function readGridCell(cell){
  var result;
  if (cell.ChildCount === 0) {
    result = cell.contentText;
  }
  else {
    var childObj = seek(cell, isReadable, 0);
    if (childObj.Exists){
      return read(childObj);
    }
    else {
      result = cell.contentText;
    }
  }
  return result;
}

function readGridCellEndPoint() {
  // http://downloads.smartbear.com/samples/testcomplete10/WebOrders/
  var cell = Sys.Browser("firefox").Page("http://downloads.smartbear.com/samples/testcomplete10/WebOrders/").Form("aspnetForm").Table(0).Cell(0, 1).Panel(1).Panel(2).Table("ctl00_MainContent_orderGrid").Cell(2, 0);
  highlight(cell);
  var result = readGridCell(cell);
}

function setCellEndPoint() {
  // add employee timesheet
  var parentCell = seekInPage({IdStr: 'MasterPagecontentradAddGrid_ctl00'},{name: 'Cell(1, 3)'})
  setCell(parentCell, "900");
}

function setChildObjectValue(cell, value, objectType){
  var edit = seek(cell, 0, {ObjectType: objectType, Visible: 'True'});
  var result = edit.Exists;
  if (result){
    set(edit, value);
    log(objectType + ' set to: ' + value);
  }
  return result;
}

function isSettable(uiObj){
  return set(uiObj, 'ignored', 'ignored', false);
}

// can act either to test if an object is setaable or to set it
// based on the value of wantSet
function set(uiObj, value, errorMessage, wantSet){
  var objectType = uiObj.ObjectType;
  var wantSet = def(wantSet, true);
  result = true;
  switch (objectType) {
    case 'Cell': if (wantSet) setCell(uiObj, value);
      break;
     
    case 'PasswordBox': 
    case 'Textbox':  if (wantSet) uiObj.SetText(value);
      break;
      
    case 'Select':  if (wantSet) uiObj.ClickItem(value);
      break;
  
    case 'Checkbox': if (wantSet) uiObj.ClickChecked(value);
      break;
      
    case 'RadioButton': if (wantSet) uiObj.checked = value; 
      break;
    
  
  default:
    result = false;
    if (wantSet){
      logError(objectType + ' - not handled by set function ' + def(errorMessage,''))
    };
  }
  return result;
}

function getDropDownLink(parentCell){
  var dropDown = seek(parentCell, 0, {ObjectType: 'Link', IdStr: '*_Arrow'});
  return dropDown;
}

function setRosterLiveCombo(parentCell, textToSelect){
  var dropDown = getDropDownLink(parentCell);
  var result = dropDown.Exists;
  if (result){
    dropDown.Click();  
    var panel = seekInPage({ObjectType: 'Form'}, {ChildCount: '1', ObjectType: 'Panel', IdStr: '*_DropDown', contentText: '*' + textToSelect + '*'});
    var textNode = seek(panel, 0, {ObjectType: 'TextNode', contentText: textToSelect});   
    if (textNode.Exists){
      textNode.Click();
       log('Combo set to: ' + textToSelect);
    } 
    else {
      logError('Item not found in list: ' + textToSelect);
    }
  }
  return result;
}

function setRosterLiveComboEndPoint() {
  // add employee timeshaeet
  var parentCell = seekInPage({IdStr: 'MasterPagecontentradAddGrid_ctl00'},{name: 'Cell(1, 2)'})
  setRosterLiveCombo(parentCell, "Tue, Apr 23");
  
  // expect error
  setRosterLiveCombo(parentCell, "Tue, Apr 30");
}


function isRosterLiveCombo(parentCell) {
  var dropDown = getDropDownLink(parentCell);
  return dropDown.Exists
}