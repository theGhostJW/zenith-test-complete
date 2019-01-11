//USEUNIT SysUtilsParent
//USEUNIT StringUtilsGrandParent
//USEUNIT _
//USEUNIT EndPointLauncherUtils


function autoType(arrayOrObjectofArrays, nExcludedProps){
  var args = _.toArray(arguments),
      exFields = _.rest(args);
  
  function autoTypeSingleArrayWithExclusions(arr){
    var args = forceArray([arr], exFields); 
    return autoTypeArray.apply(null, args);
  }
  
  function autoTypeArrayWithExclusions(arr){
    
    if (arr.length > 0 && _.isArray(arr[0])){
      // handle sections e.g TestData/FileToTableGrouped.txt
      return _.map(arr, autoTypeSingleArrayWithExclusions);
    }
    else {
      return autoTypeSingleArrayWithExclusions(arr);
    }
  }
  
  return _.isArray(arrayOrObjectofArrays) ? 
            autoTypeArrayWithExclusions(arrayOrObjectofArrays) :
             _.isObject(arrayOrObjectofArrays) ? 
                _.mapObject(arrayOrObjectofArrays, autoTypeArrayWithExclusions):
                 throwEx('autoType must be applied to arrays or an object of arrays');

}

function autoTypeArray(arr, nExcludedProps){

  var arExcluded = _.rest(_.toArray(arguments));
  
  function nullDotProps(obj){
    return dotToNulls(obj, arExcluded)
  }
  
  var result = _.map(arr, nullDotProps);
  
  function validateParsers(parsers, obj){
    
    function compatitableParser(remainingParsers, key){
      function canParse(parser){
        var result =  parser.canParse(obj[key]);
        return result;
      }
      return _.filter(remainingParsers, canParse);
    }
  
    var result = _.mapObject(parsers, compatitableParser);
    return result;
  }
  
  if (result.length > 0){
    var parsers = _.mapObject(result[0], _.constant(allParsers()));
    var validParsers = _.reduce(result, validateParsers, parsers);
    
    function firstOrNull(arr){
      return arr.length > 0 ? arr[0] : null;
    }
    validParsers = _.mapObject(validParsers, firstOrNull);
    
    function parseFields(obj){
      function parseField(val, key){
        var psr = validParsers[key];
        return _.isNull(psr) || _.contains(arExcluded, key) ? val : psr.parse(val);
      }
      return _.mapObject(obj, parseField);
    }
    
    result = _.map(result, parseFields);
  }
      
  return result;
}

function isEmpty(val){
  return _.isNull(val) || _.isUndefined(val);
}

function allParsers(){
  return _.map(
               [
                  boolParser(), 
                  // check for date first
                  dateTimeParser(),
                  numberParser()
                ],
               wrapParser
             );
}

function wrapParser(parser){
  return {
    name: parser.name, 
    canParse: function(val){
                      return isEmpty(val) || _.isString(val) && parser.canParse(val);
                    },
    parse:  function(val){
                      return isEmpty(val) || !_.isString(val) ? val : parser.parse(val);
                    }
  };
}

function boolParser(){
  var BOOL_CHARS = ['Y', 'N', 'T', 'F'];
  
  function parse(val){
     return _.contains(['Y', 'T'], val);
  }
  
  function canParse(val){
    return _.contains(BOOL_CHARS, val);
  }
  
  return {
      name: 'boolParser', 
      canParse: canParse,
      parse: parse
  }
}

function boolParserEndPoint() {
  chkEq(boolParser().parse('Y'), true);
  
  chkEq(boolParser().parse('F'), false);
  
  chkEq(boolParser().canParse('F'), true);
  
  chkEq(boolParser().canParse(1), false);
}

function numberParser(){

  function parse(val){
     return val.search('.') > -1 ? parseFloat(val): parseInt(val);
  }
  
  function canParse(val){
    return stringConvertableToNumber(val);
  }
  
  return {
      name: 'numberParser', 
      canParse: canParse,
      parse: parse
  }
}

function dateTimeParser(){

  // assumes null and str check already done
  function isNumber(str){
    var els = str.split('');
    function isNumChar(chr){
      return chr.charCodeAt(0) > 47 && chr.charCodeAt(0) < 58;
    }
    
    var nonNums = _.reject(els, isNumChar);
    return nonNums.length < 2;
  }

  function parse(val){
     return val.search(':') > -1 ? aqConvert.StrToDateTime(val) : aqConvert.StrToDate(val);   
  }
  
  function canParse(val){
    result = false;
    
    try {
      parse(val);
      result = true;  
    }
    catch (e) {
      if (e.message !== 'The string cannot be parsed.'){
        throw(e);
      }
    }

    return result && !isNumber(val);
  }
  
  return {
      name: 'dateTimeParser', 
      canParse: canParse,
      parse: parse
  }
}

function dotToNulls(obj, arExcluded){
  function dotToNull(val, key){
    return val === '.' && !_.contains(arExcluded, key) ? null : val;
  }
  return _.mapObject(obj, dotToNull);
}

function chkEq(object, other){
  if (_.isEqual(object, other) || GetVarType(object) === 7 && aqDateTime.Compare(object, other) === 0){
    Log.Checkpoint('Equal')
  }
  else {
    Log.Error('NOT Equal');
  }
}

function repeatString(str, count){
  //base on https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/repeat
  str = def(str, '');
  if (count < 0) {
    throw new RangeError('repeat count must be non-negative');
  }
  if (count == Infinity) {
    throw new RangeError('repeat count must be less than infinity');
  }
  count = Math.floor(count);
  if (str.length == 0 || count == 0) {
    return '';
  }
  // Ensuring count is a 31-bit integer allows us to heavily optimize the
  // main part. But anyway, most current (august 2014) browsers can't handle
  // strings 1 << 28 chars or longer, so:
  if (str.length * count >= 1 << 28) {
    throw new RangeError('repeat count must not overflow maximum string size');
  }
  var rpt = '';
  for (;;) {
    if ((count & 1) == 1) {
      rpt += str;
    }
    count >>>= 1;
    if (count == 0) {
      break;
    }
    str += str;
  }
  return rpt;
}


function stringToTables(txt, spaceCountToTab, wantAutotyping, excludedFieldsN){
  var result = splitOnPropName(txt),
      params = unpackStrToTableParams(_.toArray(arguments));
  
  function objectify(val, key){
    var result = linesToObjects(val, key, params.spaceCountToTab);
    return params.wantAutoTyping ? autoType.apply(null, forceArray([result], params.excludedFieldsN)) : result;
  }
  
  result = _.mapObject(result, objectify);
  return applyFunctions(result, params);
}

function stringToTable(txt, spaceCountToTab, wantAutotyping, excludedFieldsN){
  var params = unpackStrToTableParams(_.toArray(arguments));
  var result = linesToObjects(standardiseSplit(txt), "", params.spaceCountToTab);
  result =  params.wantAutoTyping ? autoType.apply(null, forceArray([result], params.excludedFieldsN)) : result;
  return applyFunctions(result, params);
}

function applyFunctions(result, params) {
  function callFunc(accum, thisFuncOrObject){
    return mapFields(accum, thisFuncOrObject);
  }
  return _.reduce(params.postProcessFunctions, callFunc, result);
}

function unpackStrToTableParams(arArgs){
  var result =
               {
                txt: _.first(arArgs),
                spaceCountToTab: def(_.find(arArgs, _.isNumber), 2),
                wantAutoTyping: def(_.find(arArgs, _.isBoolean), true),
                postProcessFunctions: _.filter(arArgs, _.isObject),
                excludedFieldsN: _.chain(_.rest(arArgs))
                                    .reject(_.isBoolean)
                                    .reject(_.isNumber)
                                    .reject(_.isObject)
                                    .value()
                };
                                             
  return result;
}

function splitOnPropName(txt){
  ensure(!isNullOrUndefined(txt), 'text null or undefined');
  
  var lines = standardiseSplit(txt);
  
  function buildSection(accum, line){
    if (hasText(line, '::')){
      var prop = subStrBefore(line, '::');
      ensure(!hasValue(accum[prop]), 'Duplicate property names in text');
      accum.result[prop] = [];
      accum.active = accum.result[prop];
    }
    else if (hasValue(accum.active)){
      accum.active.push(line);
    }
    return accum;
  }
  
  return _.reduce(lines, buildSection, {result: {}, active: null}).result;
}

function standardiseSplit(txt){
  return standardiseLineEndings(txt).split(newLine());
}

function makeSplitTrimFunction(spaceCountToTab){
  function tabReplace(txt){
    return spaceCountToTab < 1 ? txt : replace(txt, '  ', '\t');
  }

  function splitLine(line){
    return dedupeTabSpaces(line).split('\t');
  }  

  function trimElements(elems){
    return _.map(elems, trim);
  }
    
  return function splitTrim(str){
    return _.compose(trimElements, splitLine, tabReplace)(str);
  }
}

function isGroupDivider(line){
  return hasText(line, '----');
}

function pushGroup(accum){
  accum.groups.push([]);
  accum.activeGroup = _.last(accum.groups);
}
   
function headerAndRemainingLines(lines, spaceCountToTab){

  function filterLine(accum, line){

    if (accum.done){
      return accum;
    }

    if (accum.started){
      if (isGroupDivider(line)){
        pushGroup(accum);
      }
      else if (hasValue(trim(line))){
        accum.nullLineEncountered = false;
        accum.activeGroup.push(line);
      }
      else {
        // use double blank to signal done so can use blank lines for formatting
        if (accum.nullLineEncountered){
          accum.done = true;
          accum.nullLineEncountered = false;
        }
        else {
          accum.nullLineEncountered = true;
        }
      }
    }
    else if (isGroupDivider(line)){
      accum.started = true;
      accum.props = makeSplitTrimFunction(spaceCountToTab)(accum.lastLine);
      pushGroup(accum);
    }
    else {
      accum.lastLine = line;
    }
    return accum;
  }

  var propsAndLines = _.reduce(lines, filterLine, {
                                            groups: [],
                                            activeGroup: null,
                                            props: null,
                                            lastLine: '',
                                            started: false,
                                            done: false,
                                            nullLineEncountered: false
                                          });
                                          
  return {
      header: propsAndLines.props,
      groups: propsAndLines.groups
  };
  
}

function makeArrayToObjectsFunction(errorInfo, spaceCountToTab, header){
  return function arrayToObjects(lines){
    function makeObjs(accum, fields, idx){
      ensure(header.length === fields.length, errorInfo + ' row no: ' + idx + 
                                            ' has incorrect number of elements expect: ' + header.length +
                                            ' actual is: ' + fields.length,
                                            'property names' +  newLine() +
                                            header.join(', ') +  newLine() +
                                            'fields' +  newLine() +
                                            fields.join(', ')
                                          );
      function addProp(accum, prpVal){
        accum[prpVal[0]] = prpVal[1];
        return accum;
      } 

      function makeRecord(){
       return _.chain(header)
                .zip(fields)
                .reduce(addProp, {})
                .value();
      }                                        
      accum.push(makeRecord());
      return accum;
    }
      
    return _.chain(lines)
              .map(makeSplitTrimFunction(spaceCountToTab))
              .reduce(makeObjs, [])
              .value();
  }
}

function linesToObjects(lines, errorInfo, spaceCountToTab){
  spaceCountToTab = def(spaceCountToTab, 2);
  errorInfo = def(errorInfo, "");
  
  var headAndLines = headerAndRemainingLines(lines, spaceCountToTab),
      header = headAndLines.header,
      groups = headAndLines.groups,
      arrToObjs = makeArrayToObjectsFunction(errorInfo, spaceCountToTab, header),
      result = _.map(groups, arrToObjs); 
     
   return result.length === 1 ? result[0] : result;                                    
}

function dedupeTabSpaces(str){
  var result = replaceWithTabs(str, '\t ');
  result = replaceWithTabs(result, '\t\t');
  return result;
}

function replaceWithTabs(str, strToReplace, lastLength){
  lastLength = def(lastLength, 0);
  str = replace(str, strToReplace, '\t');
  var len = str.length;
  return len === lastLength ? str : replaceWithTabs(str, strToReplace, len);
}

function createGuid(withHyphens){
  return StringUtilsGrandParent.createGuid(withHyphens);
}

function appendDelim(str1, delim, str2){
  str1 = def(str1, "");
  delim = def(delim, ""); 
  str2 = def(str2, ""); 
  
  var result;   
  if (str1 === "" || str2 === ""){
    result = str1 + str2;
  } 
  else {
    result = str1 + delim + str2;
  }
  
  return result
}

function standardiseLineEndings(str){
  return StringUtilsGrandParent.standardiseLineEndings(str);
}

function replace(baseStr, replaceTarget, replaceWith, caseSensitive){
  return StringUtilsGrandParent.replace(baseStr, replaceTarget, replaceWith, caseSensitive);
}

function wildcardMatch(target, pattern, caseSensitive, checkForAll, processFragmentResult){
  return StringUtilsGrandParent.wildcardMatch(target, pattern, caseSensitive, checkForAll, processFragmentResult);
}

function trimChars(str, arChars){
  return StringUtilsGrandParent.trimChars(str, arChars);
}

function trimWhiteSpace(str){
  return hasValue(str) ? str.replace(/(^\s+|\s+$)/g,'') : '';
}

function subStrBetween(str, startDelim, endDelim, wantTrimWhiteSpace){
  wantTrimWhiteSpace = def(wantTrimWhiteSpace, true);
  var result = subStrAfter(str, startDelim);
  result = subStrBefore(result, endDelim);
  if (wantTrimWhiteSpace) {
    result = trimWhiteSpace(result);
  }
  return result;
}


function stringToFile(str, filePath, encoding){
  StringUtilsGrandParent.stringToFile(str, filePath, encoding);
}

function startsWith(str, preFix) {
  return StringUtilsGrandParent.startsWith(str, preFix);
}

function upperCase(str){
  return aqString.ToUpper(str); 
}

function lowerCase(str){
  return aqString.ToLower(str); 
}

function sameText(str1, str2, caseSensitive)
{ 
  function compareTheStrings(str1, str2){
    if (!caseSensitive) {
      str1 = lowerCase(str1);
      str2 = lowerCase(str2);
    }
    return str1 === str2;
  }
  
  caseSensitive = def(caseSensitive, false);
  var nullResult = !((str1 === null) ^ (str2 === null));
  var result;
  if (nullResult)
  {
    result = (!str1 && !str2) || compareTheStrings(str1, str2);
  }
  else
  {
    result = false;
  }
 
  return result
}

function endsWith(str, suffix) {
  return StringUtilsGrandParent.endsWith(str, suffix);
}

function hasText(hayStack, needle, caseSensitive)
{
  return StringUtilsGrandParent.hasText(hayStack, needle, caseSensitive);
}

function fileToString(filePath, encoding){
  return StringUtilsGrandParent.fileToString(filePath, encoding)
}

function newLine(repeatCount){
  return StringUtilsGrandParent.newLine(repeatCount);
}

// splits a string on the first delimiter returns two parts 
// EXCLUDING the delimiter
function bisect(strSource, delim){
  return StringUtilsGrandParent.bisect(strSource, delim);
}

function subStrBefore(str, delim){
  return StringUtilsGrandParent.subStrBefore(str, delim);
}

function subStrAfter(str, delim){
  ensure(arguments.length === 2, 'subStrAfter - 2 arguments required');
  return StringUtilsGrandParent.subStrAfter(str, delim);
}

function trim(str){
  return StringUtilsGrandParent.trim(str);
}

// © John Walker 2013 – Permission for unrestricted use and modification granted within 
// THE-COMPANY and affiliated companies
