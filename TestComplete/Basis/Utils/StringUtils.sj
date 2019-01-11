//USEUNIT StringUtilsParent
//USEUNIT SysUtils
//USEUNIT FileUtils
//USEUNIT _
//USEUNIT StringUtilsPrivate

function autoType(arrayOrObjectofArrays, nExcludedProps){
  var args = _.toArray(arguments);
  return StringUtilsParent.autoType.apply(null, args);
}


/**

?????_NO_DOC_?????

== Params ==
txt: DATA_TYPE_?????_NO_DOC_????? -  Required -  DESCRIPTION_?????_NO_DOC_?????
== Return ==
DATA_TYPE_?????_NO_DOC_????? - DESCRIPTION_?????_NO_DOC_?????
== Related ==
?????_NO_DOC_?????
**/
function stringToTables(txt, wantAutotyping, excludedFieldsN){
  var args = forceArray(_.toArray(arguments), autoType);
  return StringUtilsParent.stringToTables.apply(null, args);
}

/**

?????_NO_DOC_?????

== Params ==
txt: DATA_TYPE_?????_NO_DOC_????? -  Required -  DESCRIPTION_?????_NO_DOC_?????
== Return ==
DATA_TYPE_?????_NO_DOC_????? - DESCRIPTION_?????_NO_DOC_?????
== Related ==
?????_NO_DOC_?????
**/
function stringToTable(txt, wantAutotyping, excludedFieldsN){
  var args = forceArray(_.toArray(arguments), autoType);
  return StringUtilsParent.stringToTable(args);
}

/**

Loads a base template string substituting variables from the params. 
If the second parameter is an object, then the object property names will be replaced by the object values in the base string.
If the second parameter is not an object (e.g a string or number) then position indexes minus 1 of the parameters will be used in the 
string replacement. So {{0}} in the base string would be replaced by the second parameter, {{1}} by the third etc. 

== Params ==
base: String -  Required - the base string including {{property names or positional markers}}
params: Object or String / Number - Required - the value(s) used to fill the object in  
== Return ==
String - a copy of the base object with values replaced
**/
function loadTemplate(base, params){

  function makeObjFromArgs(args){
    var values = _.rest(args),
        keys = _.range(values.length),
        result = _.object(keys, values);
    return result;
  }
  
  function replaceTemplateItem(accum, value, key){
    return replace(accum, '{{' + key + '}}', def(value, ""));
  }

  params = _.isObject(params) ? 
                                    params : 
                                    makeObjFromArgs(_.toArray(arguments));
                                    
  var result = _.reduce(params, replaceTemplateItem, base);
  return result;
}



/**

Capitalises the first character of a string.

== Params ==
str: String -  Required - the target string
== Return ==
String - target string, first letter capitalised
**/
function capFirst(str){
  return hasValue(str) ? str.charAt(0).toUpperCase() + str.slice(1): str;
}

/**

?????_NO_DOC_?????

== Params ==
str: DATA_TYPE_?????_NO_DOC_????? -  Required -  DESCRIPTION_?????_NO_DOC_?????
== Return ==
DATA_TYPE_?????_NO_DOC_????? - DESCRIPTION_?????_NO_DOC_?????
== Related ==
?????_NO_DOC_?????
**/
function lowerFirst(str){
  return (hasValue(str)) ? lowerCase(str.slice(0, 1)) + str.slice(1) : str; 
}

/**

Right pads a string to a given length. If the string is already the given length or longer then the origional string is returned

== Params ==
str: String -  Required -  the target string
fillChar: String -  Required - a single char string used to pad character
len: Integer -  Required -  the desired string length
== Return ==
String - the str padded to a length of len with fillchar
**/
function padRight(str, fillChar, len) {
  // based on http://jsfiddle.net/4mHW9/52/
  var result = str + fillStr(str, fillChar, len);
  return result;
}

/**

Left pads a string to a given length. If the string is already the given length or longer then the origional string is returned

== Params ==
str: String -  Required -  the target string
fillChar: String -  Required - a single char string used to pad character
len: Integer -  Required -  the desired string length
== Return ==
String - the str padded to a length of len with fillchar
**/
function padLeft(str, fillChar, len) {
  // based on http://jsfiddle.net/4mHW9/52/
  var result = fillStr(str, fillChar, len) + str;
  return result;
}

/**

Repeats a string a given number of times 

== Params ==
str: String -  Required -  the string to repeat
count: Integer -  Required -  the number of times to repeat the string
== Return ==
String - the target string repeated count times
**/
function repeatString(str, count){
	return StringUtilsParent.repeatString(str, count);
}

/**

Converts a string to upper case

== Params ==
str: String -  Required -  target string
== Return ==
String - target string converted to upper case
== Related ==
lowerCase
**/
function upperCase(str){
  return StringUtilsParent.upperCase(str);
}

/**

Converts a string to lower case

== Params ==
str: String -  Required -  target string
== Return ==
String - target string converted to lower case
== Related ==
upperCase
**/
function lowerCase(str){
  return StringUtilsParent.lowerCase(str);
}

/**

Lower cases the first character of a string.

== Params ==
str: String - Required - the target string
== Return ==
String - target string, first letter lower cased
**/
function lwrFirst(str){
  return hasValue(str) ? str.charAt(0).toLowerCase() + str.slice(1): str;
}

/**
Creates an array form a string by splitting on "\n" - newLine returns an empty array if str is null
== Params ==
str: String -  Required - source string
== Return ==
[String] - an array of strings
== Related ==
newLine, arrayToString
**/
function stringToArray(str){
  return hasValue(str) ? str.split(newLine()): [];
}


/**
Creates a string form an array by joining on "\n" - newLine
== Params ==
str: [String] -  Required - an array of strings
== Return ==
[String] - the result string
== Related ==
newLine, arrayToString
**/
function arrayToString(arr){
  return arr.join(newLine()); 
}

/**

Checks if a string matches a given pattern using * wildcards

== Params ==
target: String -  Required - the string to be tested
pattern: String -  Required - the wildcard pattern to match
caseSensitive: Boolean -  Optional - Default: false - case sensitive match
== Return ==
Boolean - returns true if all segments in the pattern are found
**/
function wildcardMatch(target, pattern, caseSensitive){            
  return StringUtilsParent.wildcardMatch(target, pattern, caseSensitive, false, doNothing);
}

/**

Open source code
 
http://www.bennadel.com/blog/1504-Ask-Ben-Parsing-CSV-Strings-With-Javascript-Exec-Regular-Expression-Command.htm

This will parse a delimited string into an array of
arrays. The default delimiter is the comma, but this
can be overridden in the second argument.

==  Params ==
strData: String - the csv data - Required - String
strDelimiter: String -  Optional: Default: ',' - the delimeter
**/
function csvToArray( strData, strDelimiter ){
 	// Check to see if the delimiter is defined. If not,
		// then default to comma.
		strDelimiter = (strDelimiter || ",");

		// Create a regular expression to parse the CSV values.
		var objPattern = new RegExp(
			(
				// Delimiters.
				"(\\" + strDelimiter + "|\\r?\\n|\\r|^)" +
				// Quoted fields.
				"(?:\"([^\"]*(?:\"\"[^\"]*)*)\"|" +
				// Standard fields.
				"([^\"\\" + strDelimiter + "\\r\\n]*))"
			),
			"gi"
			);


		// Create an array to hold our data. Give the array
		// a default empty first row.
		var arrData = [[]];

		// Create an array to hold our individual pattern
		// matching groups.
		var arrMatches = null;


		// Keep looping over the regular expression matches
		// until we can no longer find a match.
		while (arrMatches = objPattern.exec( strData )){

			// Get the delimiter that was found.
			var strMatchedDelimiter = arrMatches[ 1 ];

			// Check to see if the given delimiter has a length
			// (is not the start of string) and if it matches
			// field delimiter. If id does not, then we know
			// that this delimiter is a row delimiter.
			if (
				strMatchedDelimiter.length &&
				(strMatchedDelimiter != strDelimiter)
				){
				// Since we have reached a new row of data,
				// add an empty row to our data array.
				arrData.push( [] );
			}


			// Now that we have our delimiter out of the way,
			// let's check to see which kind of value we
			// captured (quoted or unquoted).
			if (arrMatches[ 2 ]){
				// We found a quoted value. When we capture
				// this value, unescape any double quotes.
				var strMatchedValue = arrMatches[ 2 ].replace(
					new RegExp( "\"\"", "g" ),
					"\""
					);
			} else {
				// We found a non-quoted value.
				var strMatchedValue = arrMatches[3];
			}
			// Now that we have our value string, let's add
			// it to the data array.
			arrData[ arrData.length - 1 ].push( strMatchedValue );
		}

		// Return the parsed data.
		return( arrData );
}


/**
Allows the use of multi-line strings in JavaScript by parsing a trojan function and pulling out the embedded comments.

Note: trims whitespace from every line before returning the string. There is a code template for this function included with the templates that are installed with the framework.

== Params ==
trojanFunction: function -  Required - A function containing a multi-line string as a comment
== Return ==
String - a multi-line string
**/
function bigString(trojanFunction) {
  var result = trojanFunction.toString();
  result = subStrAfter(result, '{');
  result = trimWhiteSpace(result);
  result = result.substr(0, result.length - 2);
  result = trimWhiteSpace(result);
  result = result.substr(2, result.length - 4);
  result = standardiseLineEndings(result);
  result = trimWhiteSpace(result);
  result = result.split(newLine());
  result = _.map(result, function(line){return trimWhiteSpace(line);});
  return result.join(newLine());
}

/**
A wrapper around the [[http://support.smartbear.com/viewarticle/31498/|TestComplete AQString.Replace]] but reverses the default
caseSensitivivity - replace is case insensitive by default (AQString.Replace) is case sensitive. 
== Params ==
baseStr: String - Required - the string to perform the replacement on
replaceTarget: String - Required - sub-string for which all instances will be replaced
replaceWith: String - Required - sub-string to replace these instances with
caseSensitive: Boolean - Optional -  Default: false - case sensitivity of search for replacement candidates
== Return ==
String: the baseStr with all instances replaced
**/
function replace(baseStr, replaceTarget, replaceWith, caseSensitive){
  return StringUtilsParent.replace(baseStr, replaceTarget, replaceWith, caseSensitive);
}

/**
Changes all line endings (\r, \r\n \n\r, \n) in a string to \n. This is useful when doing string compares
== Params ==
str: String - Required - the target string
== Return ==
String - a new string with standardised line endings
**/
function standardiseLineEndings(str){
  return StringUtilsParent.standardiseLineEndings(str);
}

/**
Saves string to BOTH the TestComplete logs directory and the subdirectory that represents the current TestComplete log (the most 
recently created sub-directory). This makes the files easy to find and also easy for a CI system to include in a zipped directory. 
== Params ==
str: String -  Required - the string to save
logFileNmNoPathOrTimeStamp: String -  Required - the file name to save the string to
**/
function stringToTimeStampedLogFile(str, logFileNmNoPathOrTimeStamp, wantLatestLogSubDirectory){
  var dest = logFilePathWithTimeStampSuffix(logFileNmNoPathOrTimeStamp, false);
  var destInChild = logFilePathWithTimeStampSuffix(logFileNmNoPathOrTimeStamp, true);
  log('Saving string to: ' + dest)
  stringToFile(str, dest);
  log('Saving string to: ' + destInChild);
  stringToFile(str, destInChild);
}


/**
returns a GUID
== Return ==
String - the GUID
**/
function createGuid(withHyphens){
  return StringUtilsParent.createGuid(withHyphens);
}

/**
returns a GUID truncated
== Return ==
String - the GUID
**/
function createGuidTruncated(maxLength){
  var result = createGuid();
  if (result.length > maxLength){
    result = replace(result, '-', '');  
  }
  
  if (result.length > maxLength){
    result = result.substr(0, maxLength);  
  }
  return result;
}


/**
A wrapper around the [[http://support.smartbear.com/viewarticle/28278/|TestComplete AQString.Trim]]
== Params ==
str: String -  Required - the target string
== Return ==
String - the trimmed string
== Related ==
trimChars
**/
function trim(str){
  return StringUtilsParent.trim(str)
}

/**
Trims empty spaces, returns and line feeds
== Params ==
str: String -  Required - the target string
== Return ==
String - the trimmed string
== Related ==
trimChars, trim
**/
function trimWhiteSpace(str){
  return StringUtilsParent.trimWhiteSpace(str);
}

/**
lower cases and removes all spaces from a string
== Params ==
str: String -  Required - the target string
== Return ==
String - lower case string with spaces removed
**/
function lowerRemoveSpacesTrim(str){
  str = aqString.ToLower(str);
  str = aqString.Replace(str, ' ' , '');
  str = aqString.Trim(str);
  return str;
}

/**
Trims specified chars from front and end of a string
== Params ==
str: String -  Required - the target string
arChars: [String] -  Required - the chars to trim
== Return ==
String - the trimmed string
== Related ==
trim
**/
function trimChars(str, arChars){
  return StringUtilsParent.trimChars(str, arChars);
}

/**
Determines if a string starts with another
== Params ==
str: String -  Required - the base string
prefix: String -  Required -  the string we are looking to start with
== Return ==
Boolean - see above
== Related ==
endsWith
**/
function startsWith(str, prefix) {
  return StringUtilsParent.startsWith(str, prefix);
}

/**
Determines if a string ends with another
== Params ==
str: String -  Required - the base string
suffix: String -  Required -  the string we are looking to end with
== Return ==
Boolean - see above
== Related ==
startsWith
**/
function endsWith(str, suffix) {
  return StringUtilsParent.endsWith(str, suffix);
}

/**
Returns two strings separated by a delimiter. If either string is null or empty the none null or empty string will be returned 
without the delimiter. Consider using the JavaScript join function instead for joining a series of strings. 
== Params ==
str1: String -  Required - the base string
delim: String -  Optional -  Default: "" -  the delimiter
str2: String -  Required - the base string
== Return ==
String - a new string -see above
**/
function appendDelim(str1, delim, str2){
  return StringUtilsParent.appendDelim(str1, delim, str2);
}

/**
Determines if one string is contains another. Does the haystack contain the needle?
== Params ==
hayStack: String -  Required - the base string
needle: String -  Required -  String
caseSensitive: Boolean -  Optional -  Default: false - by default case is ignored
== Return ==
Boolean - true if the hayStack contains the needle
== Related ==
sameText
**/
function hasText(hayStack, needle,  /* optional */ caseSensitive){
  /* caseSensitive - defaults to false */
  return StringUtilsParent.hasText(hayStack, needle, caseSensitive);
}

/**
Saves a string to a file. If the file already exists then it is overwritten with the new file
== Params ==
str: String -  Required - the source string
filePath: String -  Required -  the target path
encoding: TestComplete file encoding -  Optional: [[#projectScriptFileEncoding|projectScriptFileEncoding]] - one of ctANSI, ctUnicode, ctUTF8
== Related ==
projectScriptFileEncoding
**/
function stringToFile(str, filePath, encoding){
  StringUtilsParent.stringToFile(str, filePath, encoding);
}


/**
Splits a string on the first delimiter returns two parts EXCLUDING the delimiter. If the delimiter does is not found then the whole 
string is returned as the before part of the result.
== Params ==
strSource: String -  Required - the base string
delim: String -  Required -  the string to split on
== Return ==
Arrray[string] - [before, after]
== Related ==
subStrBefore, subStrAfter, subStrBetween
**/
function bisect(strSource, delim){
  return StringUtilsParent.bisect(strSource, delim);
}

/**
Returns the subStr before but EXCLUDING the delimiter. If the delimiter does is not found then an empty string is returned.
== Params ==
str: String -  Required - the base string
delim: String -  Required -  the delimiter
== Return ==
String - see above
== Related ==
subStrAfter, bisect, subStrBetween
**/
function subStrBefore(str, delim){
  return StringUtilsParent.subStrBefore(str, delim);
}


/**
Returns the subStr between two delimiters EXCLUDING the delimiters. If either delimiter does is not found then an or they are in 
the incorrect order then an empty string is returned. The result is trimmed of white-space by default.
== Params ==
str: String -  Required - the base string
startDelim: String -  Required -  the first delimiter, the char before start of the result string
endDelim: String -  Required -  the delimiter, the char after the end of the result string
wantTrimWhiteSpace: Boolean - Optional - Default: true - the result will have white space trimmed if true
== Return ==
String - see above
== Related ==
subStrBefore, subStrAfter, bisect
**/
function subStrBetween(str, startDelim, endDelim, wantTrimWhiteSpace){
  return StringUtilsParent.subStrBetween(str, startDelim, endDelim, wantTrimWhiteSpace);
}

/**
Returns the subStr after and EXCLUDING the delimiter. If the delimiter does is not found then an empty string is returned.
== Params ==
str: String -  Required - the base string
delim: String -  Required -  the delimiter
== Return ==
String - see above
== Related ==
subStrBefore, bisect
**/
function subStrAfter(str, delim){
  return StringUtilsParent.subStrAfter(str, delim);
}

/**
Returns the text content of a file
== Params ==
filePath: String -  Required -  the full file path
encoding: TestComplete file encoding -  Optional: [[#projectScriptFileEncoding|projectScriptFileEncoding]] - one of ctANSI, ctUnicode, ctUTF8
== Return ==
String - the text content of the file
== Related ==
stringToFile
**/
function fileToString(filePath, encoding){
  return StringUtilsParent.fileToString(filePath, encoding);
}

/**
A constant. Returns one or more new line characters: "\n"
== Params ==
repeatCount: Integer -  Optional -  Default: 1 - whether to compare with case sensitivity
== Return ==
String - "\n"
**/
function newLine(repeatCount){
  return StringUtilsParent.newLine(repeatCount);
}

/**
Determines if two strings are equal - case insensitive by default
== Params ==
str1: String -  Required -  first string to compare
str2: String -  Required -  second string to compare
caseSensitive: Boolean -  Optional -  Default: false - whether to compare with case sensitivity
== Return ==
Boolean - see above
== Related ==
hasText
**/
function sameText(str1, str2, /* optional */ caseSensitive){
  /* caseSensitive - defaults to false */
  return StringUtilsParent.sameText(str1, str2, caseSensitive);
}

// © John Walker 2013 – Permission for unrestricted use and modification granted within 
// THE-COMPANY and affiliated companies




