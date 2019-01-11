//USEUNIT SysUtilsParent
//USEUNIT StringUtilsGrandParent
//USEUNIT _


var toTempCalls = {},
    toTempReadableCalls = {},
    toTempStringCalls = {};


function addWarningIfRequired(fileName, prevCalls, wantWarning, baseStr){
  var result = wantWarning && hasValue(prevCalls[fileName]) ?
                    'WARNING THIS FILE (' + fileName + ') HAS BEEN OVERWRITTEN DURING EXECUTION. IF YOU ARE VIEWING ' +
                    'THIS FILE FROM A LINK IN THE TEST LOG FILE IT MAY NOT REFLECT CONTENT OF THE FILE WHEN WRITTEN ' + newLine() +
                    'TO AVOID THIS ERROR SUPPLY A DIFFERENT LOG FILE NAME WHEN CALLING THE toTemp / toTempReadable / toTempString FUNCTION' + newLine(2) + baseStr : baseStr;
  
  prevCalls[fileName] = true;
  return result;
}

function SevenZipExePath(runTimeFileFunc){
  var pathTo7Zip = runTimeFileFunc('7z.exe');
  ensure(aqFile.Exists(pathTo7Zip), 'zipAll - no 7 zip exe');
  return pathTo7Zip;
}

function listFilesOrFolder(isFile, folder, /* optional */ searchPattern,  /* optional */ recursive){
  var result = [];
  function addPath(path){
    result.push(path);
  }
  eachFileOrFolder(isFile, folder, searchPattern, recursive, addPath);
  return result;
}

function eachFileOrFolder(isFile, folder, /* optional */ searchPattern,  /* optional */ recursive, fileFolderFunc){
  // param KungFu
  // get rid of isFile getter form args
  var args = _.rest(_.toArray(arguments));
  var strArgs = _.filter(args, _.isString);
  folder = strArgs[0];
  ensure(aqFileSystem.Exists(folder), 'Folder does not exist: ' + folder);
  searchPattern = strArgs.length === 2 ? strArgs[1] : '*';
  fileFolderFunc = _.find(args, _.isFunction);
  ensure(hasValue(fileFolderFunc), 'no function passed in');
  recursive = def(_.find(args, _.isBoolean), true);
  
  var iterator = isFile ? aqFileSystem.FindFiles(folder, searchPattern, recursive)
                            : aqFileSystem.FindFolders(folder, searchPattern, recursive);
  if (hasValue(iterator)){
    while (iterator.HasNext()){
      var info = iterator.Next();
      fileFolderFunc(info.Path, info);
    }
  }
}

function childPath(baseDir, childDir, childDirFile){
  var dir = combine(baseDir, childDir)
  var result = forceSlash(dir)  
  result = childDirFile ? result + childDirFile : result;
  return result      
}

function combine(){
  var counter;
  var result = "";
  for (counter = 0; counter < arguments.length; counter += 1)
  { 
    result = counter === 0 ? result : forceSlash(result);
    result = result + arguments[counter]; 
  }
  
  return result;
}

function forceSlash(str){
  return aqFileSystem.IncludeTrailingBackSlash(str);
}

function specialFileString(fileNameNoPath, filePathFromNameFunction, encoding){
  encoding = def(encoding, projectScriptFileEncoding());
  var sourceDataPath = filePathFromNameFunction(fileNameNoPath);
  return aqFileSystem.Exists(sourceDataPath) ? fileToString(sourceDataPath, encoding): null;
}

function stringToSpecialFile(str, fileNameNoPath, filePathFromNameFunction, encoding, suppressOverwriteWarning){
  encoding = def(encoding, projectScriptFileEncoding());
  var destDataPath = filePathFromNameFunction(fileNameNoPath, false);
  stringToFile(str, destDataPath, encoding);
  return destDataPath;
}

// assumes row 1 is populated with data
function getDateColIndexes(sheet){
  return getColIndexesMatchingNumberFormat(sheet, isDateFormatString);
  
  // old code
  var result = [];
  var colCount = sheet.Columns.Count;
  maxCols = colCount > 100 ? 100 : colCount;
  for (var counter = 1; counter < maxCols; counter++){
    var colTitle =  sheet.Cells(1, counter).Text;
    if (!hasValue(colTitle)){
      break;
    }
    
    var firstCell = sheet.Cells(2, counter);
    var numberFormat = firstCell.NumberFormat;
    if (isDateFormatString(numberFormat)){
      result.push(counter);  
    }
  }
  return result;
}

function getTimeColIndexes(sheet){
  return getColIndexesMatchingNumberFormat(sheet, isTimeFormatString);
}

function getColIndexesMatchingNumberFormat(sheet, numberFormatPredicate){
  var result = [];
  var colCount = sheet.Columns.Count;
  maxCols = colCount > 100 ? 100 : colCount;
  for (var counter = 1; counter < maxCols; counter++){
    var colTitle =  sheet.Cells(1, counter).Text;
    if (!hasValue(colTitle)){
      break;
    }
    
    var firstCell = sheet.Cells(2, counter);
    var numberFormat = firstCell.NumberFormat;
    if (numberFormatPredicate(numberFormat)){
      result.push(counter);  
    }
  }
  return result;
}

function isTimeFormatString(str){
  return hasText(str, ':m') && hasText(str, 'h:');
}

function isDateFormatString(str){
  return hasText(str, 'yy') && hasText(str, 'mm');
}

function isDateFormatStringEndPoint() {
  var result = isDateFormatString('yyyy')
}


