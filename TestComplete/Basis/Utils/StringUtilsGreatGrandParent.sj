//USEUNIT _

function standardiseLineEndings(str){
  var result = replace(str, '\n\r', '\n');
  result = replace(result, '\r\n', '\n');
  result = replace(result, '\r', '\n');
  return result;
}

function replace(baseStr, replaceTarget, replaceWith, caseSensitive){
  caseSensitive = caseSensitive || false;   
  return (baseStr === null || baseStr === undefined) ?  
          baseStr : 
          aqString.Replace(baseStr, replaceTarget, replaceWith, caseSensitive); 
}

// splits a string on the first delimiter returns two parts 
// EXCLUDING the delimiter
function bisect(strSource, delim){
  var delimLength = aqString.GetLength(delim), 
                    pos = aqString.Find(strSource, delim, 0),
                    srcLength = aqString.GetLength(strSource),
                    before, 
                    after;
   
  if (pos < 0){
    before = _.isUndefined(strSource) || _.isNull(strSource) ? "" : strSource;
    after = "";   
  }
  else {
    before = strSource.slice(0, pos); 
    after = (pos < srcLength - delimLength) ? 
              strSource.slice(pos + delimLength): 
              "";
  }
  
  return [before, after]
}

function subStrBefore(str, delim){
  var pos = aqString.Find(str, delim, 0);
  result = (pos < 0) ? '' : bisect(str, delim)[0];
  return result;   
}

function newLine(repeatCount){
  repeatCount = _.isUndefined(repeatCount) || _.isNull(repeatCount) ? 1 : repeatCount;
  return (new Array(repeatCount + 1)).join("\n")
}
