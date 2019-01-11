//USEUNIT ReflectionUtilsPrivate
//USEUNIT SysUtilsParent
//USEUNIT FileUtils
//USEUNIT StringUtilsParent
//USEUNIT StringUtils
//USEUNIT _
//USEUNIT XmlToJsonUtils

/** Module Info **
Provides convention base functions for reading script information from the script and project file themselves.
Framework and tool use only
**/


/**
Given the name of a script within a project returns the full text contents to the script (*.sj) file
Used for reflection type functions by the framework. 
== Params ==
scriptName: String -  Required -  script name (no extension)
== Return ==
String - the contents of the script file as text
**/
function scriptContents(scriptName){
  var scriptPath = scriptFilePath(scriptName)
  var arResult = fileToArray(scriptPath, projectScriptFileEncoding());
  return arResult;
}

/**
Given the name of a script within a project returns the full path to the script (*.sj) file
Used for reflection type functions by the framework. 
== Params ==
scriptName: String -  Required -  script name (no extension)
== Return ==
String - the full file path
**/
function scriptFilePath(scriptName){
 var arFiles = scriptFilesInProject();
 var fileItem = _.find(arFiles,
  function(item){
    return scriptName === item.name;
    }
 );
 ensure(!_.isUndefined(fileItem), "Script not in project: " + scriptName);
 return fileItem.path;
}


var filesInProject;
/**
Returns a set of file info objects representing every script (.sj) file contained in the project
from which the script is being called. Used by the framework.
== Return ==
FileInfo objects - an array of objects with a two properties property {
                                                                      fileName: 
                                                                      filePath:
                                                                      }
== Related ==
testFilesInProject
**/ 
function scriptFilesInProject(){
 if (_.isUndefined(filesInProject)){
   filesInProject = scriptFilesInProjectFile(Project.FileName);
 } 
 return filesInProject;
}

var testScriptFilesInProject;
/**
Returns the names of every test script (i.e. test case (*Test.sj) file contained in the project
from which the script is being called. Used by the framework.
== Return ==
[String] - an array of script names (no extension e.g. [InventoryTest, PaymentTest])
== Related ==
testFilePathsInProject
**/
function testFilesInProject(){
  testScriptFilesInProject = testFilesNamesOrPaths(testScriptFilesInProject, getScriptNameFromScriptInfo, scriptFilesInProject);
  return testScriptFilesInProject;
}

var testScriptFilePathsInProject;
/**
Returns the file paths of every test script (i.e. test case (*Test.sj) file contained in the project
from which the script is being called. Used by the framework.
== Return ==
[String] - an array of script full file paths
== Related ==
testFilesInProject
**/
function testFilePathsInProject(){
  testScriptFilePathsInProject = testFilesNamesOrPaths(testScriptFilePathsInProject, getScriptPathFromScriptInfo, scriptFilesInProject);
  return testScriptFilePathsInProject;
}


/**
Lists the script files in the project
== Params ==
projectFilePath: String - the path of the project file (*.mds)
== Return ==
[FileInfo objects] - an array of objects with a single property {fileName: filePath}
representing all the script files referenced by the project
== Related ==
extendedScriptInfo
**/ 
function scriptFilesInProjectFile(projectFilePath){
  var basePath = aqFileSystem.GetFileFolder(projectFilePath);
  // Presuming standard file structure would have to parse project file 
  // if you wanted to allow for non stanard file structure
  // see earlier versions of this function if this is an issue
  // parsing of project file was removed to speed up
  var scriptFilePath = combine(basePath, "Script\\Script.tcScript");
  var scriptDirectory = aqFileSystem.GetFileFolder(scriptFilePath);
  ensure(aqFileSystem.Exists(scriptFilePath), 'Script file does not exist: ' + scriptFilePath);
  var scriptFileObj = xmlToObject(fileToString(scriptFilePath));
  var arResult = extractScriptInfoArray(scriptFileObj, scriptDirectory, seekInObj);
  //_.reduce(arProjectFiles, makeAddScriptFunction(scriptDirectory), []);
  return arResult;
}


/**
Returns detailed information by parsing each script in the target project intended for use with tools such as the documentation tool
== Params ==
projectFilePath: String -  Required -  the full file path to the project
== Return ==
[sriptInfo objects] - an array detailed script info object 
== Related ==
scriptFilesInProjectFile
**/
function extendedScriptInfo(projectFilePath, scriptName){
  
  function isTargetScript(script){
    return !hasValue(scriptName) || sameText(scriptName, script.name);
  }
  
  var result =  _.chain(scriptFilesInProjectFile(projectFilePath))
                  .filter(isTargetScript)
                  .map(addFileInfo)
                  .value();
   
  // mutates function objects - adds examples   
  log('skipping examples');            
  //linkFunctionsToExamples(result);
  
  if (hasValue(scriptName)){
    ensure(result.length === 1, 'There should be one and only one file matching: ' + scriptName + ' there is: ' + result.length);
    result = result[0]; // return a singlton if only one script requested
  }

  return result;
}

/**
Returns true if the string matches the conventions for naming a public script
== Params ==
scriptName: String -  Required -  Script name
== Return ==
Boolean - true if target is a public script name
== Related ==
isPublicScript
**/
function isPublicScriptName(scriptName){
  return ReflectionUtilsPrivate.isPublicScriptName(scriptName);
}

/**
Performs the same function as [[#isPublicScriptName|isPublicScriptName]] on a scriptInfo object.
isPublicScriptName is simply applied to the scriptInfo.name property.
See [[#isPublicScriptName|isPublicScriptName]] for details
== Related ==
isPublicScriptName
**/
function isPublicScript(scriptInfo){
  return isPublicScriptName(scriptInfo.name);
}


/**
Returns true if the string matches the conventions for naming an endpoint or unit test
== Params ==
scriptName: String -  Required -  Script name
== Return ==
Boolean - true if a target is an endpoint or unit test
== Related ==
isPublicScript
**/
function isEndPointOrUnitTestName(str){
  return ReflectionUtilsPrivate.isEndPointOrUnitTestName(str);
}

