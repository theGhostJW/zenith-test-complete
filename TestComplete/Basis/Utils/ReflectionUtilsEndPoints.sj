//USEUNIT ReflectionUtils
//USEUNIT FileUtils
//USEUNIT CheckUtils
//USEUNIT SysUtils

function scriptContentsUnitTest(){
 var result = scriptContents("SysUtilsEndPoints");
 check(hasText(result, 'scriptContentsUnitTest()'))
}

function scriptFilePathEndPoint(){
  var path = scriptFilePath("TestCaseList");
}

function testScriptFilesInProjectEndPoint(){
  var sw = HISUtils.StopWatch;
  sw.Start()
  var result = scriptFilesInProject();
  log(sw.Split());
  sw.Reset()
  result = scriptFilesInProject();
  log(sw.Split());
  result = scriptFilesInProject();
}


function scriptFilesInProjectFileEndPoint() {
 var result = scriptFilesInProjectFile(Project.FileName);
 check(result.length > 20);
}

function extendedScriptInfoEndPoint() {
  var docsTargetProject  = 'C:\\DocTarget\\Seed\\DemoProject\\DemoProject.mds'
  var result = extendedScriptInfo(docsTargetProject);
  result = objectToJson(result);
  stringToFile(result, 'C:\\parsedInfoPlusExamples.txt')
  check(result.length > 20);
}