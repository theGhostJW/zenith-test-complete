//USEUNIT SysUtilsParent
//USEUNIT FileUtilsPrivate
//USEUNIT StringUtilsParent
//USEUNIT _


/** Module Info **

?????_NO_DOC_?????

**/




/**
Framework use only
**/
function ISSUES_FILE_SUFFIX() {
  return 'Issues.txt'; 
}

/**
Framework use only
**/
function issuesFileSuffix(id){
  return '_' + id + '_' + ISSUES_FILE_SUFFIX();
}

/**

?????_NO_DOC_?????

== Params ==
testDataFileNameNoPath: DATA_TYPE_?????_NO_DOC_????? -  Required -  DESCRIPTION_?????_NO_DOC_?????
== Return ==
DATA_TYPE_?????_NO_DOC_????? - DESCRIPTION_?????_NO_DOC_?????
== Related ==
?????_NO_DOC_?????
**/
function fileToTables(testDataFileNameNoPath, spaceCountToTab, wantAutotyping, excludedFieldsN, fieldTransformersN){
  var txt = testDataString(testDataFileNameNoPath),
      args = forceArray(txt, _.rest(_.toArray(arguments)));
  
  return stringToTables.apply(null, args);
}

/**

?????_NO_DOC_?????

== Params ==
testDataFileNameNoPath: DATA_TYPE_?????_NO_DOC_????? -  Required -  DESCRIPTION_?????_NO_DOC_?????
== Return ==
DATA_TYPE_?????_NO_DOC_????? - DESCRIPTION_?????_NO_DOC_?????
== Related ==
?????_NO_DOC_?????
**/
function fileToTable(testDataFileNameNoPath, spaceCountToTab, wantAutotyping, excludedFieldsN, fieldTransformersN){
  var txt = testDataString(testDataFileNameNoPath),
      args = forceArray(txt, _.rest(_.toArray(arguments)));
  
  return stringToTable.apply(null, args);
}

/**

Returns the parent directory of a file or folder path. If there is no parent then an empty string is returned.

== Params ==
path: String -  Required -  the target path
== Return ==
String - parent directory path
== Related ==
combine
**/
function parentDir(path){
  var result = '';
  if (hasValue(path)) {
    var idx = path.lastIndexOf('\\');  
    result = idx > -1 ? path.slice(0, idx) : '';
    result = hasText(result, '\\', true) ? result: '';
  }
  return result;
}



/**

Lists the files in a directory

== Params ==
parentFolder: String -  Required -  the path to the parent folder
searchPattern: String -  Optional -  Default: '*' - a file name filter (e.g. '*.exe', 'ver*.cs')
recursive: Boolean -  Optional -  Default: true - include subfolders in search
== Return ==
Array[String] - a list of file paths
== Related ==
eachFile, listFolders
**/
function listFiles(parentFolder, /* optional */ searchPattern,  /* optional */ recursive){
  return listFilesOrFolder(true, parentFolder, searchPattern, recursive);
}

/**

Lists the folders in a directory

== Params ==
parentFolder: String -  Required -  the path to the parent folder
searchPattern: String -  Optional -  Default: '*' - a folder name filter (e.g. '*Help')
recursive: Boolean -  Optional -  Default: true - include subfolders in search
== Return ==
Array[String] - a list of folder paths
== Related ==
eachFolder, listFiles
**/
function listFolders(parentFolder, /* optional */ searchPattern,  /* optional */ recursive){
  return listFilesOrFolder(false, parentFolder, searchPattern, recursive);
}

/**

Executes a function on each file path for each file in a parent folder

== Params ==
parentFolder: String -  Required -  the path to the parent folder
searchPattern: String -  Optional -  Default: '*' - a file name filter (e.g. '*.exe', 'ver*.cs')
recursive: Boolean -  Optional -  Default: true - include subfolders in search
fileFunction: function(filepath): no return value -  Required -  a function to be called on each file 
== Related ==
eachFolder, listFiles
**/
function eachFile(parentFolder, /* optional */ searchPattern,  /* optional */ recursive, fileFunction){
  eachFileOrFolder(true, parentFolder, /* optional */ searchPattern,  /* optional */ recursive, fileFunction);
}

/**

Executes a function on each child folder in a parent folder

== Params ==
parentFolder: String -  Required -  the path to the parent folder
searchPattern: String -  Optional -  Default: '*' - a folder name filter (e.g. '*Help')
recursive: Boolean -  Optional -  Default: true - include subfolders in search
folderFunction: function(folderPath): no return value -  Required -  a function to be called on each folder path 
== Related ==
eachFile, listFolders
**/
function eachFolder(parentFolder, /* optional */ searchPattern,  /* optional */ recursive, folderFunction){
  eachFileOrFolder(false, parentFolder, /* optional */ searchPattern,  /* optional */ recursive, folderFunction)
}

/**

Given a file name will return a file name with the default extension if it does not already have one, otherwise will return the file name unchanged.

== Params ==
fileName: String -  Required -  the file name
extension: String -  Required -  the default extension
== Return ==
String - file name with defaulted extension
== Related ==
changeExtension
**/
function defaultExtension(fileName, extension){
  if (!hasValue(aqFileSystem.GetFileExtension(fileName))){
    extension = startsWith(extension, '.')? extension : '.' + extension;
    fileName = fileName + extension;
  }
  return fileName;
}


/**
Recursively deletes all the files in a directory without warning
== Params ==
dir: String -  Required - The directory to clear
**/
function clearDirectoy(dir){
  ensure(hasValue(dir), 'clearDirectoy - ' + dir + ' does not exist.');
  var fileIterator  = aqFileSystem.FindFiles(dir, '*', true);
  if (hasValue(fileIterator)){
    while (fileIterator.HasNext()){
      var thisFile = fileIterator.Next().Path;
      aqFileSystem.DeleteFile(thisFile)
    };
  }
  
  var folderIterator = aqFileSystem.FindFolders(dir, '*', true);
  if (hasValue(folderIterator)){
    while (folderIterator.HasNext()){
      var thisFile = folderIterator.Next().Path;
      aqFileSystem.DeleteFolder(thisFile)
    };
  }
}

/**

Saves an object to the temp directory as a Json file

== Params ==
obj: Object -  Required - the object to save
fileNameNoPath: String -  Required - the file name
wantWarning: Boolean - Optional - Default: true - log a warning when the file is written this defualts to false becuase this function is usually used in debugging and is intended to be removed
== Related ==
fromTemp, tempFile
**/
function toTemp(obj, fileBaseNoPath, wantWarning){
  wantWarning = def(wantWarning, true);
  fileNameNoPath = def(fileBaseNoPath, 'toTemp');
  fileNameNoPath = defaultExtension(fileNameNoPath, '.json');
  var path = tempFile(fileNameNoPath),
      content =  objectToJson(obj);
      
  content = addWarningIfRequired(fileNameNoPath, toTempCalls, wantWarning, content);    
      
  stringToFile(content, path);
  if (wantWarning){
    logWarningLink('Temp file written: ' + fileNameNoPath, path);
  }
}

/**

Converts an object to a readable text format and saves it to the framework temp directory. 
This can be usefull when debugging with large objects that are difficult to view in the debugger. 
Note there is no function to read this file back from disk so if such functionality is needed use [[toTemp]] which saves the object to
Json.

== Params ==
obj: Object -  Required - the target object
fileNameNoPath: the name of the file to save to -  Optional -  Default: 'toTempReadable.txt' - if a file without extension is provided the it will default to .txt
== Related ==
toTemp, objectToReadable, tempDir
**/
function toTempReadable(obj, fileNameNoPath, wantWarning){
  wantWarning = def(wantWarning, true);
  fileNameNoPath = defaultExtension(def(fileNameNoPath, 'toTempReadable'), '.txt');
  
  var content = objectToReadable(obj);
  content = addWarningIfRequired(fileNameNoPath, toTempReadableCalls, wantWarning, content);  
  
  toTempString(content, fileNameNoPath, false);
  if (wantWarning){
    logWarningLink('Temp file written: ' + fileNameNoPath, tempFile(fileNameNoPath));
  }
}

/**

Zips all the files in a directory and saves the zip file to the same directory

== Params ==
sourceDir: String -  Required -  the target directory
fileMask: String -  Required -  a filter for the files to be zipped e.g. *.txt
destFileName: String -  Required -  the name of the resulting zip file 
== Return ==
string - the path of the resulting zip file
== Related ==
unzipAll
**/
function zipAll(sourceDir, fileMask, destFileName){
  var pathTo7Zip = SevenZipExePath(runTimeFile);
  var destFilePath = combine(sourceDir, destFileName);
  var command = ' a -tzip "' + destFilePath + '" "' + combine(sourceDir, fileMask) + '"';
  var exe = executeFile(pathTo7Zip, command);
  ensure(exe.ExitCode === 0, 'error while zipping - exit code: ' + exe.ExitCode);
  return destFilePath;
}

/**

Unzips all the contents of a zip file into the specified directory (uses 7za.exe)

== Params ==
path: String -  Required - The target zip file
destDirectory: String -  Required - the directory to unzip to (wil be created if does not exist)
**/
function unzipAll(path, destDirectory){
  var pathTo7Zip = SevenZipExePath(runTimeFile);
  ensure(hasValue(path), 'no path specified');
  ensure(hasValue(destDirectory), 'no destDirectory specified');
  ensure(aqFile.Exists(path), 'unzipAll - source file does not exist: ' + path);
  ensure(aqFile.Exists(destDirectory), 'destination directory does not exist: ' + destDirectory);
  var command = ' e ' + path + ' -o' + destDirectory + ' -y';
  var exe = executeFile(pathTo7Zip, command);
  ensure(exe.ExitCode === 0, 'error while unzipping - exit code: ' + exe.ExitCode);
}

/**

Given the name of a json file in the temp directory returns the contents as a JavaScript object 

== Params ==
fileNameNoPath: String -  Required -  the name of the json file
== Return ==
Object - the content of the file as a JavaScript object
== Related ==
toTemp, tempFile
**/
function fromTemp(fileNameNoPath, wantWarning){
 var theFile = defaultExtension(fileNameNoPath, '.json');
 if (def(wantWarning, true)){
  logWarning('reading from temp: ' + theFile);
 }
 return _.compose(jsonToObject, tempString)(theFile);
}

/**

reads a JSON file from disk and returns an object

== Params ==
filePath: String -  Required - path of JSON file
== Return ==
Object - object represented by the file
== Related ==
fromTestData, fromTemp
**/
function fileToObject(filePath){
 return _.compose(jsonToObject, fileToString)(filePath);
}

/**

Converts an object to JSON and saves it to file

== Params ==
object: Object -  Required - the target JavaScript object
filePath: String -  Required - the full path of the target file
== Related ==
toTemp, toTestData
**/
function objectToFile(object, filePath){
 stringToFile(objectToJson(object), filePath);
}

/**

Saves an object to the Testdata directory as a Json file

== Params ==
obj: Object -  Required - the object to save
fileNameNoPath: String -  Required - the file name
== Related ==
fromTestData, testDataFile
**/
function toTestData(obj, fileNameNoPath){
  stringToTestData(objectToJson(obj), defaultExtension(fileNameNoPath, '.json'));
} 

/**

Given the name of a json file in the TestData directory returns the contents as a JavaScript object 

== Params ==
fileNameNoPath: String -  Required -  the name of the json file
== Return ==
Object - the content of the file as a JavaScript object
== Related ==
toTestData, testDataFile
**/
function fromTestData(fileNameNoPath){
 return _.compose(jsonToObject, testDataString)(defaultExtension(fileNameNoPath, '.json'));
}

/**
Saves an array to a file. If the file already exists it will be overwritten
== Params ==
arr: [String] -  Required -  source file must be an array of strings
filePath: String -  Required -  the full path of the destination file
encoding: TestComplete file encoding -  Optional - Default: [[#projectScriptFileEncoding|projectScriptFileEncoding]] - one of ctANSI, ctUnicode, ctUTF8
== Related ==
stringToFile
**/
function arrayToFile(arr, filePath, /* Optional */ encoding){
  var arString = arr.join(newLine()); 
  return stringToFile(arString, filePath, encoding);
}

/**
Reads an array of strings from a text file
== Params ==
filePath: String -  Required -  the full file path
encoding: TestComplete file encoding - Optional - Default: [[#projectScriptFileEncoding|projectScriptFileEncoding]] - one of ctANSI, ctUnicode, ctUTF8
== Return ==
[String] - an array of strings
== Related ==
fileToString
**/
function fileToArray(filePath, encoding){
  function stringToArray(str){
    return hasValue(str) ? str.split(newLine()): [];
  }
  var fileString = fileToString(filePath, encoding);
  return stringToArray(fileString)
}

/**
Changes a relative to absolute path
== Params ==
baseDir: String -  Required -  the path to which the relative path is relative to
relativePath: String -  Required -  the relative path
== Return ==
String - the absolute path
**/
function relativeToAbsolute(baseDir, relativePath){
  function tokenise(path) {
    return aqFileSystem.ExcludeTrailingBackSlash(path).split("\\");
  }
  
  var pathParts = tokenise(relativePath),
  dirParts = tokenise(baseDir);
  
  var result;
  if (startsWith(relativePath, '\\')){
    // = Root + relpath eg '\\Utils' => c:\\Utils
    result = dirParts[0] + relativePath;  
  }
  else {
    var absPathParts = _.reject( 
      pathParts,
      function(part){
        return !aqString.Find(part, "..");
      });
    var drillUpCount = pathParts.length - absPathParts.length;
    var resultDirPartsCount = dirParts.length - drillUpCount;
    var resultBase = dirParts.slice(0, resultDirPartsCount);
    var arResult = resultBase.concat(absPathParts);
    result = arResult.join("\\"); 
  }
  return result;
}


/**
Changes a file extension
== Params ==
fileNameOrPath: String -  Required - old path
newExtIncludingDot: String -  Required - new extension  
== Return ==
String - new path with new extension
**/
function changeExtension(fileNameOrPath, newExtIncludingDot){
  var fileNoExt = aqFileSystem.GetFileNameWithoutExtension(fileNameOrPath);
  var result = fileNoExt + newExtIncludingDot;
  
  return hasText(fileNameOrPath, '\\') ? 
              aqFileSystem.GetFileFolder(fileNameOrPath) + result : 
              result;
}


/**
Provides a formatted date time string for appending to log files
== Return ==
String - e.g. 2015-9-19-18-16-5
== Related ==
logFilePathWithTimeStampSuffix
**/
function nowLogSuffix(){
  var now = aqDateTime.Now();
  return aqDateTime.GetYear(now) + '-' + 
    aqDateTime.GetMonth(now) + '-' + 
    aqDateTime.GetDay(now) + '-' + 
    aqDateTime.GetHours(now) + '-' +
    aqDateTime.GetMinutes(now) + '-' +
    aqDateTime.GetSeconds(now);
}

/**
Checks and returns the hard coded browser download dir C:\BrowserDownloads.
Throws an error if the directory does not exist. That would indicates incorrect configuration.
== Return ==
String - C:\BrowserDownloads
**/
function browserdDownLoadFolder(){
  var hardCodedDownloadDirectory = 'C:\\BrowserDownloads';
  ensure(aqFileSystem.Exists(hardCodedDownloadDirectory), 'Browsers must be configured to download to: ' + hardCodedDownloadDirectory);
  return hardCodedDownloadDirectory;
}

/**
Checks if a directory exists and creates it if it does not.
== Params ==
fullDirPath: String -  Required -  If this path does not exists it will be created
**/
function forceDirectory(fullDirPath){
  if (!aqFileSystem.Exists(fullDirPath)){
    aqFileSystem.CreateFolder(fullDirPath)
  }
  return fullDirPath;
}


/**
Returns path to file in temp directory and creates the temp directory if it does not already exist
== Params ==
fileNameNoPath: String -  Required -  the file name
== Return ==
String - the full path
== Related ==
tempDir
**/
function tempFile(fileNameNoPath){
  var parentDir = tempDir();
  forceDirectory(parentDir);
  var result = combine(parentDir, fileNameNoPath);
  return result;
}

/**
The temp directory - where test data gets copied - this directory is not checked in to version control
== Return ==
String - temp
== Related ==
tempFile 
**/
function tempDir(){
  var folderName = "Temp";
  var result = suiteChildPath(folderName);
  forceDirectory(result);
  return result;
}

/**
Returns the path to the test data folder 
== Return ==
String - the folder path
== Related ==
testDataFile
**/
function testDataPath(){
  return projectChildPath("TestData");      
}

/**
Returns the path to the path to the runtime files folder this is where executable are stored by convention
== Return ==
String - see above
== Related ==
runTimeFile
**/
function runTimeFilesPath(){
  var folderName = 'RunTimeFiles',
  result = '';
  var path = Project.Path;
  var folderInfo = aqFileSystem.GetFolderInfo(path);
  do {
    var folderInfo = folderInfo.ParentFolder;
    if (!hasValue(folderInfo)){
      break;
    }
    path = folderInfo.Path;
    var resultCandidate = combine(path, folderName);
    if (aqFileSystem.Exists(resultCandidate)){
      result = resultCandidate;
      break;
    }
  } while (!hasValue(result));
  
  
  ensure(hasValue(result), 'Cannot find the folder: ' + folderName + ' - this folder needs to be created as a sibling directory to the "Utils" directory.');
  return result;      
}

/**

Returns the parent folder of a folder

== Params ==
childFolder: String -  Required -  child folder path
== Return ==
String - the path of the parent folder
**/
function parentFolder(childFolder){
  var folderInfo = aqFileSystem.GetFolderInfo(childFolder);
  return folderInfo.ParentFolder.Path;
}

/**
returns the full path of a run time file- i.e. a file in the RunTimeFiles directory
== Params ==
fileNameNoPath: String -  Required -  file name without the path
== Return ==
String - the full file path
== Related ==
runTimeFilesPath
**/
function runTimeFile(fileNameNoPath){
  return combine(runTimeFilesPath(), fileNameNoPath);
}

/**
Returns the location of the testComplete logs folder - by convention C:\TestCompleteLogs
== Return ==
String - C:\TestCompleteLogs
wantLatestLogSubDirectory: Boolean - Optional - Default: false - false: uses root test complete log directory, 
true: uses latest sub directory which will be the directory of the current log file 
== Related ==
logFilePath
**/
function logsDirPath(wantLatestLogSubDirectory){
  var result = 'C:\\TestCompleteLogs';
  forceDirectory(result);
  if (wantLatestLogSubDirectory){
    var subFolderDate = 0;
    var subFolderName = ''
    var folders = aqFileSystem.FindFolders(result, '*')
    while (hasValue(folders) && folders.HasNext()) {
      var thisFolder = folders.Next();
      var thisDate = thisFolder.DateCreated;
      if (thisDate > subFolderDate){
        subFolderName = thisFolder.Name;
        subFolderDate = thisDate;
      }
    }
    result = combine(result, subFolderName); 
  }
  return result;      
}

/**
Returns the full path of a log file of a given name
== Params ==
fileNameNoPath: String -  Required -  the file name
wantLatestLogSubDirectory: Boolean - Optional - Default: false - false: uses root test complete log directory, 
true: uses latest sub directory which will be the directory of the current log file 
== Return ==
String - full log path
== Related ==
logsDirPath, logFilePathWithTimeStampSuffix
**/
function logFilePath(fileNameNoPath, wantLatestLogSubDirectory){
  var result = combine(logsDirPath(wantLatestLogSubDirectory), fileNameNoPath);
  return result;      
}

/**
Performs the same function as [[#logFilePath|logFilePath]] but appends a timestamp to the log file name.
See [[#logFilePath|logFilePath]] for details
== Related ==
logFilePath
**/
function logFilePathWithTimeStampSuffix(fileNameNoPath, wantLatestLogSubDirectory){
  var ext = aqFileSystem.GetFileExtension(fileNameNoPath);
  ext = hasValue(ext) ? '.' + ext : ext;
  var fileNameNoPathOrExt = aqFileSystem.GetFileNameWithoutExtension(fileNameNoPath);
  var result = logFilePath(fileNameNoPathOrExt + '-' + nowLogSuffix() + ext, wantLatestLogSubDirectory);
  return result;      
}

/**
Returns the path to a file in a sub-folder at the same level of the active TestComplete project file
== Params ==
childDir: String -  Required -  the sub directory name
childDirFile: String -  Required -  the file name no path
== Return ==
String - the full file path
== Related ==
suiteChildPath
**/
function projectChildPath(childDir, childDirFile){
  return childPath(Project.Path, childDir, childDirFile);       
}

/**
Returns the path to a file in a sub-folder at the same level of the active TestComplete suite file
== Params ==
childDir: String -  Required -  the sub directory name
childDirFile: String -  Required -  the file name no path
== Return ==
String - the full file path
== Related ==
projectChildPath
**/
function suiteChildPath(childDir, childDirFile){
  return childPath(ProjectSuite.Path, childDir, childDirFile);    
}

/**
Returns the full path of a file in the system Temp directory of a file of a given name
== Params ==
fileNameNoPath: String -  Required -  the file name
wantThrowIfNotExist: Boolean -  Optional -  Default: false -  throws exception if the file uis not found
== Return ==
String - the full file path
== Related ==
tempDir
**/
function systemTempFile(fileNameNoPath, wantThrowIfNotExist){
  wantThrowIfNotExist = def(wantThrowIfNotExist, false);
  var result = combine(systemTempDir(), fileNameNoPath);
  ensure(!wantThrowIfNotExist || aqFile.exists(result), "File does not exist");
  return result; 
}

/**
Combines file path parts into one file path
== Params ==
pathParts: String* - Required -  a variable number of path elements
== Return ==
String - the full path
== Related ==
forceSlash
**/
function combine(){
  return FileUtilsPrivate.combine.apply(this, arguments);
}

/**
Returns the system temp path 
== Return ==
String - the system temp directory path
== Related ==
tempFile
**/
function systemTempDir(){
  return Sys.OSInfo.TempDirectory
}

/**
Appends a backSlsh to a string if it does not end in a string already. [[#combine|combine]] is usually a
better function to use
== Params ==
str: String -  Required -  the target string
== Return ==
String - a string with a slash
== Related ==
combine
**/
function forceSlash(str){
  return FileUtilsPrivate.forceSlash(str);
}

/**
Copies a file from the source path to the BOTH the testcomplete logs directory and the subdirectory that represents the current 
testcomplete log (the most recently created sub-directory). This makes the files easy to find and also easy for a CI system to 
include in a zipped directory.
== Params ==
sourceFileFullPath: String -  Required - the full path to the source file
**/
function copyToLogAddDateStamp(sourceFileFullPath){
  ensure(aqFile.Exists(sourceFileFullPath));
  var fileNameNoPath = aqFileSystem.GetFileName(sourceFileFullPath);
  
  var destPath = logFilePathWithTimeStampSuffix(fileNameNoPath, true);
  var rootDestPath = logFilePathWithTimeStampSuffix(fileNameNoPath, false);
  copyFile(sourceFileFullPath, destPath);
  copyFile(sourceFileFullPath, rootDestPath);
}

/**
Deletes all the files in the browser download directory
== Related ==
browserdDownLoadFolder
**/
function clearBrowserDownloadsDirectory(){
  Indicator.PushText('Clearing Browser Downloads: ' + browserdDownLoadFolder());
  clearDirectory(browserdDownLoadFolder());
  Indicator.PopText();
}



/**
Recursively deletes all the files in a directory without warning
== Params ==
dir: String -  Required - The directory to clear
**/
function clearDirectory(directoryPath){
  Indicator.PushText('Clearing Directory: ' + directoryPath);
  ensure(hasValue(directoryPath));
  
  var fileIterator  = aqFileSystem.FindFiles(directoryPath, '*', true);
  if (hasValue(fileIterator)){
    while (fileIterator.HasNext()){
      var thisFile = fileIterator.Next().Path;
      aqFileSystem.DeleteFile(thisFile)
    };
  }
  
  var folderIterator = aqFileSystem.FindFolders(directoryPath, '*', true);
  if (hasValue(folderIterator)){
    while (folderIterator.HasNext()){
      var thisFile = folderIterator.Next().Path;
      aqFileSystem.DeleteFolder(thisFile)
    };
  }
  Indicator.PopText();
}

/**
Exports sheet 1 of an Excel file in the TestData directory to csv in temp directory
== Params ==
dataFileNameNoDir: String -  Required -  the Excel file name
== Return ==
String - the path of the newly created file
**/
function exportToCSV(dataFileNameNoDir){
  var source = testDataFile(dataFileNameNoDir);
  var dest = tempFile(dataFileNameNoDir);
  dest = changeExtension(dest, '.csv');
  var app = Sys.OleObject("Excel.Application");
 // try {
    app.DisplayAlerts = false;
    var source = source;
    var book = app.Workbooks.Open(source);
    var sheet = book.Sheets('Sheet1');

    
    // force reset date format otherwise the csv file 
    // comes across with US date format
    var dateColIndexes = getDateColIndexes(sheet);
    _.each(dateColIndexes,
     function(colIndex) {
      sheet.Columns(colIndex).NumberFormat = "dd/mm/yyyy"
     });
     
     // force reset time format otherwise the csv file 
    // comes across h:mm not hh:mm
    var timeColIndexes = getTimeColIndexes(sheet);
    _.each(timeColIndexes,
     function(colIndex) {
      sheet.Columns(colIndex).NumberFormat = "hh:mm"
     });

    //6 === 'CSV Comma Delimited (*.csv) '
    sheet.SaveAs(dest, 6);
   //} finally {
    app.Quit();
 // }
  return dest;
}

/**
Returns the newest file in the browser download directory
== Return ==
String - the full file path
== Related ==
browserdDownLoadFolder
**/
function lastBrowserDownloadFile(){
  var iterator = aqFileSystem.FindFiles(browserdDownLoadFolder(), '*', true);
  var result;
  if (hasValue(iterator)){
    var resultFile;
    while (iterator.HasNext()){
      aFile = iterator.Next();
      resultFile = !hasValue(resultFile) ?  aFile :
                                aFile.DateCreated > resultFile.DateCreated ? aFile : resultFile;
    }
    result = resultFile.Path;
  }
  else {
    result = null;
  }
  return result;
}


/**
Copies a file from source to dest overwriting any existing file with the same name.
Logs an error if it fails
== Params ==
src: String -  Required -  Source file path
dest: String -  Required - Dest file path
== Return ==
Boolean - true is copied successfully
**/
function copyFile(src, dest){
  var copyResult = aqFileSystem.CopyFile(src, dest, false);
  if (copyResult) {
    log('File Copied: ' + src + ' => ' + dest);
  }
  else {
    logError('File Copy Failed: ' + src + ' => ' + dest);
  }
  return copyResult; 
}

/**
Copies a file of a given name from the test data to temp directory
== Params ==
sourceFileNameNoPath: String -  Required -  source file name
destFileNameNoPath: String -  Optional - Default: sourceFileNameNoPath  -  override for the destination file name
== Return ==
String - the destination file full path
== Related ==
testDataFile, tempFile 
**/
function copyTestFile(sourceFileNameNoPath, destFileNameNoPath){
  var src = testDataFile(sourceFileNameNoPath),
  destFileName = destFileNameNoPath ? destFileNameNoPath : sourceFileNameNoPath,
  dst = tempFile(destFileName),
  copyResult = aqFileSystem.CopyFile(src, dst, false);
  ensure(copyResult, "Copy test file failed " + src + " => " + dst + " - Check source file exists and dest file is not read only");  
  return dst
}


/**

Returns an object from a JSON file in the framework Mocks directory

== Params ==
fileNameNoPath: String -  Required -  name of the file to load
== Return ==
Object - the mock object represented by the file
== Related ==
fromTemp
**/
function mockFile(fileNameNoPath){
  var result = projectChildPath("Mocks", fileNameNoPath);
  return result;
}

/**
Returns the path to a test data file
== Params ==
fileNameNoPath: String -  Required -  file name
ensureExists: Boolean -  Optional -  Default: true - whether to throw an exception if the file does not exist
== Return ==
String - the file path
== Related ==
testDataPath
**/
function testDataFile(fileNameNoPath, ensureExists){
  var result = projectChildPath("TestData", fileNameNoPath);
  var fileExists = aqFileSystem.exists(result);
  ensure(!def(ensureExists, true) || fileExists, "testDataFile - target file does not exist: " + result);
  return result;
}

/**
Returns the content of a test data file (in the test data dir) as a string
== Params ==
fileNameNoPath: String -  Required -  the file name
encoding: TestComplete file encoding -  Optional - Default: [[#projectScriptFileEncoding|projectScriptFileEncoding]] - one of ctANSI, ctUnicode, ctUTF8
== Return ==
String - the text content of the file
== Related ==
testDataFile
**/
function testDataString(fileNameNoPath, encoding){
  return specialFileString(defaultExtension(fileNameNoPath, '.txt'), testDataFile, encoding);
}

/**
Returns the content of a file in the conventional temp directory as a string

== Params ==
fileNameNoPath: String -  Required - tempFile name no path
encoding: TestComplete file encoding -  Optional: [[#projectScriptFileEncoding|projectScriptFileEncoding]] - one of ctANSI, ctUnicode, ctUTF8
== Return ==
String - the content of the file
== Related ==
tempFile
**/
function tempString(fileNameNoPath, encoding){
  return specialFileString(defaultExtension(fileNameNoPath, '.txt'), tempFile, encoding);
}


/**

Save a string to a file in the conventional temp directory

== Params ==
str: String -  Required - The source string to be saved
fileNameNoPath: String -  Required - the file name of the target file  - no path
encoding: TestComplete file encoding -  Optional: [[#projectScriptFileEncoding|projectScriptFileEncoding]] - one of ctANSI, ctUnicode, ctUTF8
??suppressOverwriteWarning??
== Related ==
tempFile
**/
function toTempString(str, fileNameNoPath, wantWarning, encoding){
  fileNameNoPath = def(fileNameNoPath, 'toTempString.txt');
  var fileName = defaultExtension(fileNameNoPath, 'txt');
  wantWarning = def(wantWarning, true);
  content = addWarningIfRequired(fileName, toTempStringCalls, wantWarning, str);  
  if (wantWarning){
    logWarningLink('Temp file written: ' + fileName, tempFile(fileName));
  }
  return stringToSpecialFile(content, fileName, tempFile, encoding);
}

/**

Save a string to a file in the conventional TestData directory

== Params ==
str: String -  Required - The source string to be saved
fileNameNoPath: String -  Required - the file name of the target file  - no path
encoding: TestComplete file encoding -  Optional: [[#projectScriptFileEncoding|projectScriptFileEncoding]] - one of ctANSI, ctUnicode, ctUTF8
??suppressOverwriteWarning??
== Related ==
testDataFile
**/
function stringToTestData(str, fileNameNoPath, encoding, suppressOverwriteWarning){
  suppressOverwriteWarning = def(suppressOverwriteWarning, false);
  return stringToSpecialFile(str, fileNameNoPath, testDataFile, encoding, suppressOverwriteWarning);
}


/**
Returns the timestamp of a test data file - used by the framework
== Params ==
fileNameNoPath: String -  Required -  the file name
== Return ==
DateTime - the last modified time of the file
== Related ==
fileLastModified
**/
function testDataFileLastModified(fileNameNoPath){
  var testFile = testDataFile(fileNameNoPath, false);
  return fileLastModified(testFile);
}

/**
Returns the timestamp of a  file of a given path
== Params ==
path: String -  Required -  target file path
== Return ==
DateTime - the last modified time of the file
== Related ==
testDataFileLastModified
**/
function fileLastModified(path) {
  ensure(aqFileSystem.exists(path), "target file does not exist: " + path);
  var fileInfo = aqFileSystem.GetFileInfo(path);
  return fileInfo.DateLastModified
}

// © John Walker 2013 – Permission for unrestricted use and modification granted within 
// THE-COMPANY and affiliated companies





