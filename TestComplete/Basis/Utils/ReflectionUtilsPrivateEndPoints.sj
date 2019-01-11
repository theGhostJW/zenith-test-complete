//USEUNIT StringUtilsParent
//USEUNIT CheckUtils
//USEUNIT ReflectionUtilsPrivate
//USEUNIT FileUtils
//USEUNIT SysUtils
//USEUNIT _

function linkFunctionsToExamplesEndPoint(){
  var demo = testDataFile('parsedInfo.txt');
  demo = fileToString(demo);
  
  var utilsInfo = jsonToObject(demo);
  linkFunctionsToExamples(utilsInfo);
  demo = objectToJson(utilsInfo);
  stringToFile(demo, 'C:\\fileInfo.txt');
  // all functions should be found
}


function updateDefaultParamsInfoEndPoint(){
  var params = [
    {
    name: 'p1',
    markedOptional: false,
    defaultVal: null
   },
   {
    name: 'p2',
    markedOptional: false,
    defaultVal: null },
    {
     name: 'p3',
     markedOptional: false,
     defaultVal: null},
    {
     name: 'p4',
     markedOptional: false,
     defaultVal: 'Hi There'}
  ];
  
  var functionInfo = {
    name: 'func',
    params: params 
  }
  
  updateDefaultParamsInfo(functionInfo, 'def(p1,1)');
  updateDefaultParamsInfo(functionInfo, 'def(p3,false);');
  updateDefaultParamsInfo(functionInfo, 'def(p4,"Hello");');
  
  checkEqual('1', params[0].defaultVal);
  checkEqual(null, params[1].defaultVal);
  checkEqual('false', params[2].defaultVal);
  checkEqual('"Hello"', params[3].defaultVal);
}

function getParamsEndPoint(){
  var func = 'function shouldBeListed2(param1, /* optional */ param2)';
  var result = getParams(func);

  func = 'function shouldBeListed2()';
  result = getParams(func);
  checkEqual([], result);
  
  func = 'function shouldBeListed2(lonely)';
  result = getParams(func);
}

function functionInfoEndPoint() {
  // need to point this at the correct path for test to work
  var  filePathInfo = {path: '..\\temp\\TestScript1.sj'};
  var result = functionInfoFromContent(filePathInfo, fileToArray(testDataFile('TestScript1.sj')));
  var funcNames = _.map(result, function(item){return item.name});
  var expected = ['testScriptFuncSimple', 'testScriptFuncParams', 'testScriptFuncParamsNested', 'testScriptFuncParamsNestedReturns',
                  'shouldBeListedNestedBlocks', 'shouldBeListed', 'shouldBeListedNestedBlocks2',
                  'shouldBeListed2']
  checkEqual(expected, funcNames);
  
  var returningFuncs =  _.filter(result, function(item){return item.hasResult});
  checkEqual(2, returningFuncs.length);
  
  filePathInfo = {path: 'C:\\SourceCode\\TestComplete\\Basis\\Utils\\StringUtils.sj'};
  result = functionInfoFromContent(filePathInfo, filePathInfo);
  
}
