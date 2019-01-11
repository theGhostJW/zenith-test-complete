//USEUNIT SysUtilsGrandParent
//USEUNIT StringUtilsGreatGrandParent
//USEUNIT _
function trim(str){
  return aqString.Trim(str);
}

function wildcardMatch(target, pattern, caseSensitive, checkForAll, processFragmentResult){
  if (!hasValue(target)){
    return false;
  }
  
  processFragmentResult = def(processFragmentResult, function(){});
  checkForAll = def(checkForAll, true);
  caseSensitive = def(caseSensitive, false);
  
  if (!caseSensitive){
    target = aqString.ToLower(target);
    pattern =  aqString.ToLower(pattern);
  }
 
  function findNextPattern(accum, fragment){
    if (!checkForAll && !accum.result){
      return accum;
    }
   
    // make forgiving with spaces
    fragment = trim(fragment);
    var result = {};
    var remainder = accum.remainder;
    var idx = remainder.indexOf(fragment);
   
    var found = (idx > -1);
    processFragmentResult(fragment, remainder, found);
    
    result.result = accum.result && found;
    result.remainder = found ? remainder.slice(idx + fragment.length) : remainder;
    
    return result;
  }
 
  var result = _.chain(pattern.split('*')) 
                  .filter(hasValue) // ignore empty strings in pattern
                  .reduce(findNextPattern, {result: true, remainder: target})
                  .value();
                 
  return result.result;
}

function createGuid(withHyphens){
  withHyphens = def(withHyphens, true);
  var scriptLet = Sys.OleObject("Scriptlet.TypeLib");
  var guid = aqString.Trim(scriptLet.GUID);
  // appears to be a weird non printed character at the end of guid randomly so slice at bracket
  // instead of trimchars
  var endBracket = guid.indexOf('}');
  var result = guid.slice(0, endBracket); 
  result = result.slice(1);
  if (!withHyphens){
    result = replace(result, '-');
  }
  return result;
}


function standardiseLineEndings(str){
  return StringUtilsGreatGrandParent.standardiseLineEndings(str);
}

function replace(baseStr, replaceTarget, replaceWith, caseSensitive){
  return StringUtilsGreatGrandParent.replace(baseStr, replaceTarget, replaceWith, caseSensitive)
}

function startsWith(str, preFix) {
  return str.indexOf(preFix) === 0;
}

function stringToFile(str, filePath, encoding){
  var writeSuccess = aqFile.WriteToTextFile(filePath, str, def(encoding, projectScriptFileEncoding()), true);
  if (!writeSuccess){
    throwEx('Failed to write to File - ' + filePath);
  }
}

function trimChars(str, arChars)
{
  if(_.contains(arChars, '')){
     throwEx('Empty string pased in to trimChars char array - you cannot trim an empty string')
  }
  
  function inTrim(char) {
    return _.contains(arChars, char);
  }
  
  while (inTrim(str.substr(0, 1))){
    str = str.substr(1);
  }
 
  var result = '';
  var trimFinished = false;
  for (var counter = str.length - 1; counter > -1; counter--) {
    var thisChar = str.charAt(counter);
    if (trimFinished || !inTrim(thisChar)){
      result = thisChar + result;
      trimFinished = true; 
    }
  }
  return result;
}

function newLine(repeatCount){
  return StringUtilsGreatGrandParent.newLine(repeatCount);
}

function fileToString(filePath, encoding){
  encoding = def(encoding, projectScriptFileEncoding());
  ensure(aqFileSystem.Exists(filePath), 'fileToString - file does not exist: ' + filePath);
  return aqFile.ReadWholeTextFile(filePath, encoding); 
}

function endsWith(str, suffix) {
  return str.indexOf(suffix, str.length - suffix.length) !== -1;
}

function hasText(hayStack, needle, caseSensitive){
  return SysUtilsGrandParent.hasText(hayStack, needle, caseSensitive);
}

// splits a string on the first delimiter returns two parts 
// EXCLUDING the delimiter
function bisect(strSource, delim){
  return StringUtilsGreatGrandParent.bisect(strSource, delim);
}

function subStrBefore(str, delim){
  return StringUtilsGreatGrandParent.subStrBefore(str, delim);   
}

function subStrAfter(str, delim){
  var result = bisect(str, delim);
  return result[1];   
}