//USEUNIT StringUtilsParent
//USEUNIT FileUtils
//USEUNIT SysUtilsGrandParent
//USEUNIT _

function extractScriptInfoArray(scriptFileObj, scriptDirectory, seekInObj){
  
  function isScript(item){
    return item._type === 'Script Unit'
  }
  
  function toScriptInfo(item){
    return {
            name: item._name,
            path: relativeToAbsolute(scriptDirectory, seekInObj(item, '_path'))
           };
  }
  
  var items = _.chain(seekInObj(scriptFileObj, 'child'))
                .filter(isScript)
                .map(toScriptInfo)
                .value();
                
  return items;
}

function getScriptNameFromScriptInfo(scriptInfo) {
  return scriptInfo.name;   
}

function getScriptPathFromScriptInfo(scriptInfo) {
  // scriptname: path
  return scriptInfo.path;   
}

function testFilesNamesOrPaths(singletonvarAlreadyCalculated, scriptInfoTransformer, getScriptFilesMethod){
  
 function calculateResult(){
  var allFiles = getScriptFilesMethod();
  return _.chain(allFiles)
    .filter(
      function(scriptInfo){
        var scriptName = getScriptNameFromScriptInfo(scriptInfo);
        return endsWith(scriptName, 'Test');
        }
      )
    .map(function(scriptInfo)
    {
      // scriptname: path
      return scriptInfoTransformer(scriptInfo); 
    }
    )
    .value();
  }
  
  return def(singletonvarAlreadyCalculated, calculateResult());
}

function jScriptUseUnits(arContent){

  function isuu(str){
     return startsWith(trim(str), '//USEUNIT');
  }
  
  function getUnitName(usesLine){
    var result = replace(trim(subStrAfter(usesLine, '//USEUNIT')), '\t', ' ');
    return hasText(result, ' ') ? subStrBefore(result, ' ') : result;
  }
  
  return _.chain(arContent)
          .filter(isuu)
          .map(getUnitName)
          .value()

}


function addFileInfo(filePathInfo){
  var message = 'parsing ' + filePathInfo.name
  Indicator.PushText(message);
  log(message);
  
  var result = filePathInfo,
      arFile = fileToArray(filePathInfo.path);
      
  result.uses = jScriptUseUnits(arFile);
  result.functions = functionInfoFromContent(filePathInfo, arFile);

  if (result.functions.length === 0  && !sameText(filePathInfo.name, 'testcaselist')){
    logError('file with no functions found (check and check file encoding): ' + filePathInfo.name);
  }
  
  
  log(message + ' complete');
  Indicator.PopText();
  return result;
}

var MULTI_LINE_COMMENT_START = '/*',
  MULTI_LINE_COMMENT_END = '*/',
  SINGLE_LINE_COMMENT_START = '//',
  TALKIE_MARK = "'",
  DOUBLE_TALKIE_MARK = '"',
  TALKIE_ESCAPE = '\\';

// - can use for debugging var logArray = [];

function functionInfoFromContent(filePathInfo, arFile){
  var result = [];
  
  // state info
  var 
    currentLine = -1,
    startCommentDelim = '',
    stringLiteralDelim = '',
    inEscapedStringLiteral = false,
    inFunction = false,
    currentFunctionText = '',
    currentFuncInfo = null,
    functionBracesOpenned = false,
    inSubFunction = false
    subFunctionBraceDepth = 0,
    functionHasResult = false,
    bracesDepth = 0,
    path = filePathInfo.path, 
    last9JsChars = '';
  
  function inComment(){
    return hasValue(startCommentDelim); 
  }
  
  function inBraces(){
    return bracesDepth > 0; 
  }
  
  function inStringLiteral(){
    return hasValue(stringLiteralDelim);  
  }
  
  function parseLine(line){
    currentLine++;
    // - can use for debugging logArray.push(currentLine + ': '+ bracesDepth + ' - ' + line)
    var trimmedLine = trim(line);
        
    if (startCommentDelim === SINGLE_LINE_COMMENT_START){
      startCommentDelim = '';
      last9JsChars = '';
    }
    
    if (!inFunction && !inStringLiteral() && !inBraces() && !inComment() && startsWith(trimmedLine, 'function ') ){
      funcInfo = newBasicFunctionInfo(trimmedLine, currentLine);
      result.push(funcInfo);
      currentFuncInfo = funcInfo;
      functionBracesOpenned = false;
      inFunction = true;
      functionHasResult = false;
    }
    else if (inFunction && !inStringLiteral() && !inComment() && bracesDepth === 1 && hasText(trimmedLine, 'def(')){
      updateDefaultParamsInfo(currentFuncInfo, trimmedLine);
    }
    parseChars(line);
  }
  
  
  function toggleInStringLiteral(delim){
    if (delim === TALKIE_MARK || delim === DOUBLE_TALKIE_MARK){
      if (inStringLiteral()){
        if (stringLiteralDelim === delim && !inEscapedStringLiteral){
          stringLiteralDelim = '';  
        }
      }
      else { // not in literal
        stringLiteralDelim = delim;
        last9JsChars = '';
      }
    }
  }
  
  function parseChars(line){
    var length = line.length;
    var lastChar = '';
    
    for (var counter = 0; counter < length; counter++){
      var thisChar = line.charAt(counter);
      var last2Chars = lastChar + thisChar;
      if (inComment()) {
        if (startCommentDelim === MULTI_LINE_COMMENT_START && last2Chars === MULTI_LINE_COMMENT_END){
          startCommentDelim = '';
        }
      } 
      else {
      if (!inStringLiteral() && last2Chars === MULTI_LINE_COMMENT_START || last2Chars === SINGLE_LINE_COMMENT_START){
          startCommentDelim = last2Chars;
          last9JsChars = '';
      }
      else if (inStringLiteral()){
        switch (thisChar) {
            case TALKIE_ESCAPE: inEscapedStringLiteral = !inEscapedStringLiteral;
              break;
          
            case TALKIE_MARK: 
              toggleInStringLiteral(TALKIE_MARK);
              inEscapedStringLiteral = false; 
              break;
            
            case DOUBLE_TALKIE_MARK: 
              toggleInStringLiteral(DOUBLE_TALKIE_MARK);
              inEscapedStringLiteral = false; 
              break;
            
            default: 
              inEscapedStringLiteral = false; 
          }
        }
        else if (thisChar === '{'){
          functionBracesOpenned = true;
          if (inSubFunction){
            subFunctionBraceDepth++;
          }
          bracesDepth++
        }
        else if (thisChar === '}'){
          bracesDepth--;
          if (inSubFunction){
            subFunctionBraceDepth--;
            if (subFunctionBraceDepth === 0){
              inSubFunction = false; 
            }
          }
          ensure(bracesDepth > -1, 'Parsing error non matching braces: ' + path + ': ' + currentLine); 
        }
        else {
          toggleInStringLiteral(thisChar);
        }
     }
     
     if (inFunction && !inStringLiteral() && inBraces() && !inComment() && functionBracesOpenned){
        last9JsChars = last9JsChars + thisChar;
        last9JsChars = last9JsChars.slice(-9); 
        if (!inSubFunction && (sameText(last9JsChars, 'function ') || sameText(last9JsChars, 'function('))){
          inSubFunction = true;  
        } 
      
        if (!inSubFunction){
          returnCandidate = last9JsChars.slice(0, 7);
          if (returnCandidate === 'return '){
            functionHasResult = true;
          }
        }
     }
     
     if (inFunction){
      currentFunctionText = currentFunctionText + thisChar;
      if (bracesDepth === 0 && functionBracesOpenned){
        inFunction = false;
        functionBracesOpenned = false;
        currentFuncInfo.functionText = currentFunctionText;
        currentFuncInfo.hasResult = functionHasResult,
        currentFunctionText = '';
      }
     }
     lastChar = thisChar;
    }
  }
  
  _.each(arFile, parseLine);
  
  return result;
}

function newBasicFunctionInfo(trimmedLine, currentLine){
  var name = subStrAfter(trimmedLine, 'function ');
  name = subStrBefore(name, '(');
  name = trim(name);
  
  var params = getParams(trimmedLine);
  
  return {
    name: name,
    lineNo: currentLine,
    params: params
  }
}

function getParams(functionDeclarationLine){
  var result = subStrAfter(functionDeclarationLine, '(');
  result = subStrBefore(result, ')');
  if (hasValue(result)){
    result = result.split(',');
    result = _.map(result, paramStrToInfo);
  }
  else {
    result = [];
  }
  return result;  
}

function paramStrToInfo(paramStr){
  var isMarkedAsOptional = hasText(paramStr, 'optional');
  if (hasText(paramStr, '*/')){
    paramStr = subStrAfter(paramStr, '*/');
  }
  paramStr = trim(paramStr);
  
  return {
    name: paramStr,
    markedOptional: isMarkedAsOptional,
    defaultVal: null
  }
}

function updateDefaultParamsInfo(functionInfo, defLine){
  defLine = trim(defLine);
  defLine = subStrAfter(defLine, 'def(');
  defLine = trimChars(defLine, [' ',';',')']);
  
  var nameVal = _.map(defLine.split(','), trim);
  var params = functionInfo.params;
  var param = _.find(params, function(param){return param.name === nameVal[0]});
  if (hasValue(param)){
    param.defaultVal = nameVal[1];
  }
}

function getFunctionsAddScriptName(module){
  var result = module.functions;
  _.each(result, function(funcInfo){funcInfo.scriptName = module.name})
  return result;
}

function isPublicScriptName(scriptName){
  return !endsWith(scriptName, 'Test') &&
         !endsWith(scriptName, 'Parent') &&
         !endsWith(scriptName, 'Private') &&
         !sameText(scriptName, 'TestCaseList')  &&
         !endsWith(scriptName, 'EndPoints') &&
         !endsWith(scriptName, 'Restart') &&
         !sameText(scriptName, 'Main')
}

function isInPublicScript(func){
  var scriptName = func.scriptName;
  return isPublicScriptName(scriptName);
}

function isEndPointOrUnitTestName(functionName){
  return endsWith(functionName, 'UnitTest') || endsWith(functionName, 'EndPoint');
}

function isEndPointOrUnitTest(func){
  var functionName = func.name;
  return isEndPointOrUnitTestName(functionName);
}
  
function linkFunctionsToExamples(syntaxTree){
  var functions = _.chain(syntaxTree)
                    .map(getFunctionsAddScriptName)
                    .flatten()
                    .value();
  
  var documentationCandidates = _.filter(functions, isInPublicScript);
  
  var docCandidates = _.filter(functions, isInPublicScript);
  var exampleCandidates = _.filter(functions, isEndPointOrUnitTest);
  
  function addExamples(func){
   
    var funcName = func.name;
    Indicator.PushText('Linking Examples: ' + funcName);
     
    function isEndPointorUnitTestOfSameName(exmplFunc){
      var egName = exmplFunc.name;
      return sameText(egName, funcName + 'unittest') ||
        sameText(egName, funcName + 'endpoint') ||
        (startsWith(egName + '_') && (endsWith('UnitTest') || endsWith('EndPoint')));
    }
    
    var examples = _.chain(exampleCandidates)
                      .filter(isEndPointorUnitTestOfSameName)
                      .map(function(item){return item.functionText})
                      .value();
    
    if (hasValue(examples) && examples.length > 0){
      func.examples = examples;
    }
    else {
      func.examples = [];
    }
    
    Indicator.PopText();
  }
  
  _.each(docCandidates, addExamples);

}

