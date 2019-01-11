//USEUNIT MainPrivate
//USEUNIT ReflectionUtils
//USEUNIT EndPointLauncherUtils
//USEUNIT SysUtils
//USEUNIT FileUtils
//USEUNIT StringUtils

/*
  // [CommonUnit]
var answer = 42;
function hello()
{
  Log.Message("Hello, world!");
}

module.exports.hello = hello;
module.exports.answer = answer;


// [MainUnit]
var common = require("CommonUnit");

function main()
{
  common.hello();
  Log.Message(common.answer);
}
  */
  
function allExtendedInfo(projectFilePath, arDoNotProcess){
  
  function projExInfo(scriptName){
    return extendedScriptInfo(projectFilePath, scriptName);
  }
  
  function isNoProcess(scriptName){
    return _.contains(arDoNotProcess, scriptName);
  }
  
  var scripts = scriptFilesInProject(projectFilePath),
      exInfo = _.chain(scripts)
                .pluck('name') 
                .reject(isNoProcess)
                .map(projExInfo)
                .value()
  
  return exInfo;
}

function DO_NOT_PROCESS(){
  return [];
}

jw =
function allExtendedInfoEndPoint() {
  toTemp(allExtendedInfo( TARGET_PROJECT_PATH(), DO_NOT_PROCESS()));
}

function generateJSProject(projectFilePath){
  var newProjectDir = forceDirectory(combine(tempDir(), aqFileSystem.GetFileNameWithoutExtension(projectFilePath))),
      tempProjectPath = combine(newProjectDir, aqFileSystem.GetFileName(projectFilePath));
}

function importsBlock(extentendedInfo){
  function requiresLine(unit){
    return lwrFirst(unit) + ' = require(\'' + unit + '\')';
  }
  return varBlock(extentendedInfo.uses, requiresLine, '\t/****** Imports *****/')
}

function importsBlockEndPoint() {
  var smpl = fromTemp('SampleInfo');
  toTempString(importsBlock(smpl));
}

function varBlock(arrNames, nameConverter, headerStr){
  var result =  _.map(arrNames, nameConverter);
  
  function secondaryLine(str){
    return '\t\t\t' + str;
  }
  
  if (result.length > 0){
    var firstRec = '\tvar ' + _.first(result),
        theRest = _.chain(result)
                    .rest()
                    .map(secondaryLine)
                    .value();
                    
    return newLine() + headerStr + newLine() + forceArray(firstRec, theRest).join(',' + newLine()) + ';' +  newLine(2);
  }
  else {
    return '';
  } 
}

function exportsBlock(extendedInfo){
  function makeExportLine(funcName){
    return 'module.exports.' + funcName + ' = ' + funcName;
  }
  return varBlock(_.pluck(extendedInfo.functions, 'name'), makeExportLine, '\t/****** Exports *****/');
}

function exportsBlockEndPoint(){
  toTempString(exportsBlock(fromTemp('SampleInfo')));
}


function extendedScriptInfoEndPoint(){
  toTemp(extendedScriptInfo(TARGET_PROJECT_PATH(), "CheckUtils"), 'SampleInfo');
}

function generateJSProjectEndPoint() {
  generateJSProject(TARGET_PROJECT_PATH());
}

function scriptPaths(projectFilePath){
  return scriptFilesInProjectFile(projectFilePath);
}

function scriptPathsEndPoint() {
  toTemp(scriptPaths(TARGET_PROJECT_PATH()));
}

function TARGET_PROJECT_PATH(){
  return "C:\\JavascriptFixer\\TestComplete\\Basis\\Seed\\DemoProject\\DemoProject.mds";
}

function exportsForScript(str){
 

}


/* creats stub documentation fro undocumented utils */

function initialDocStubForOutRightSeed(){
  var params = {}
  params.sourceProjectFilePath = null;
  params.destProjectFilePath = 'C:\\Automation\\TestComplete\\Basis\\Seed\\DemoProject\\DemoProject.mds';
  params.destDirOverride = null;
  mergeDocs(params);
}

function removeSomeWebUtils(summaryObjects){
  var webUtils = _.find(summaryObjects, function(sum){return sum.name === "WebUtils"});
  var funcNames =  _.chain(webUtils.functions)
                    .pluck('name')
                    .sort()
                    .value();
                    
  toTemp(funcNames, 'funcNames');
                    
  // var idxFrom = 0, idxTo = 10; compiles
  //var idxFrom = 0, idxTo = 33;  compiles
 // var idxFrom = 0, idxTo = 50; fails
 //   var idxFrom = 0, idxTo = 43; pass
   var idxFrom = 0, idxTo = 47; // failed
 // var idxFrom = 0, idxTo = 45; passed
 // var idxFrom = 0, idxTo = 46; passed
     
  var names = funcNames.slice(idxFrom, idxTo + 1);
  toTemp(names, 'filternames');
  
  function hasName(func){
    return _.contains(names, func.name);
  }
    
  webUtils.functions = _.filter(webUtils.functions, hasName);
  var postNames =  _.chain(webUtils.functions)
                    .pluck('name')
                    .sort()
                    .value();
                    

  toTemp(postNames, 'postFilternames');
}

function apiChmHelpStep1(){
  var summaryObjects = generateSummary('C:\\automationFramework\\TestComplete\\Basis\\Seed\\DemoProject\\DemoProject.mds');
  toTemp(summaryObjects, 'summaryObjects');
 // var summaryObjects = fromTemp('summaryObjects')
//  removeSomeWebUtils(summaryObjects);
 // toTemp(summaryObjects, 'summaryObjectsUpdated');
  generateApiHelp(summaryObjects);
}

function apiChmHelpStep2(){
  updateWorkingFiles(combine(tempDir(), 'API Help Generation', 'working'));
  log('Working files updated - now run [C:\\Windows\\Microsoft.NET\\Framework64\\v4.0.30319\\MSBuild.exe Build1xHelpFile.proj] from command line in temp\API Help Generation\working directory');
}


function generateCreoleDocPage(){
  MainPrivate.generateCreoleDocPage(
        'C:\\automationFramework\\TestComplete\\Basis\Seed\\DemoProject\\DemoProject.mds',
        'C:\\genDoc'
        );
}

function generateCreoleDocPageTEST(){
  MainPrivate.generateCreoleDocPage(
        'C:\\TCSysUtilsOld\\SUOld\\SysOld\\SysOld.mds',
        'C:\\genDoc'
        );
}

function generateUnderScoreWrapper(){
  MainPrivate.generateUnderScoreWrapper(); 
}



