//USEUNIT StringUtils
//USEUNIT CheckUtils
//USEUNIT FileUtils


function lowerFirstEndPoint(){
  var input, result;

  input = null;
  result = lowerFirst(input);
  checkEqual(null, result);

  input = 'J';
  result = lowerFirst(input);
  checkEqual('j', result);

  input = ' J';
  result = lowerFirst(input);
  checkEqual(' J', result);

  input = 'JOHN';
  result = lowerFirst(input);
  checkEqual('jOHN', result);
}


function createGuidEndPoint() {
  log(createGuid(true));
  log(createGuid());
  log(createGuid(false));
}

function lwrFirstUnitTest() {
  checkEqual(null, lwrFirst(null));
  checkEqual('1', lwrFirst('1'));
  checkEqual('a', lwrFirst('a'));
  checkEqual('apple', lwrFirst('Apple'));
  checkEqual('aPPLE', lwrFirst('APPLE'));
}

function loadTemplateUnitTest() {
  var base = bigString(function(){
                /*
                given: {{given}},
                last: {{last}},
                gender: {{gender}},
                */
             });
             
  var expected = bigString(function(){
                /*
                given: John,
                last: Doe,
                gender: Male,
                */
             });
  
  /* Using a Value Object */
  var actual = loadTemplate(base, {
                                    given: 'John',
                                    last: 'Doe',
                                    gender: 'Male'
                                  }
                              ); 
  checkEqual(expected, actual);
  
  /* Using Positional Parameters */
  base = bigString(function(){
                /*
                given: {{0}},
                last: {{1}},
                gender: {{2}},
                */
             });
  
  var actual = loadTemplate(base, 'John', 'Doe', 'Male'); 
  checkEqual(expected, actual);     
}


function capFirstUnitTest() {
  var result = capFirst('a');
  checkEqual(result, 'A');
  result = capFirst('apple');
  checkEqual(result, 'Apple');
  result = capFirst('');
  checkEqual(result, '');
}

function padLeftUnitTest() {
  var result;  
 // result = padLeft("loremipsum", "PIE", 15);
 // checkEqual('PIEPIEPIEPIEPIEloremipsum', result);
  
  result = padLeft("text", " ", 8);
  checkEqual("    text", result);
   
  result = padLeft("myawesometext", "!", 20);
  checkEqual("!!!!!!!myawesometext", result);
  
  result = padLeft("aaaaa", "b", 6);
  checkEqual("baaaaa", result);
  
  result = padLeft("a", "b", 1);
  checkEqual("a", result);
  
  result = padLeft("aaaaaa", "b", 1);
  checkEqual("aaaaaa", result, 'No effect if pad len < str len');
}

function padRightUnitTest() {
  var result;  
  result = padRight("loremipsum", "PIE", 15);
  checkEqual('loremipsumPIEPIE', result);
  
  result = padRight("text", " ", 8);
  checkEqual("text    ", result);
   
  result = padRight("myawesometext", "!", 20);
  checkEqual("myawesometext!!!!!!!", result);
  
  result = padRight("aaaaa", "b", 6);
  checkEqual("aaaaab", result);
  
  result = padRight("a", "b", 1);
  checkEqual("a", result);
  
  result = padRight("aaaaaa", "b", 1);
  checkEqual("aaaaaa", result, 'No effect if pad len < str len');
}

function trimUnitTest(){
  var result = trim(' Hi ');
  checkEqual('Hi', result);
}

function repeatStringEndPoint() {
   var rslt = repeatString('!W', 3);
   checkEqual('!W!W!W', rslt);
}

function wildcardMatchUnitTest() {
  var subject = "demo_Array_Data_Driven_Test";
  var result = wildcardMatch(subject, "*Array*");
  check(result);
  
  subject = "The quick brown fox jumps over the lazy dog";
  result = wildcardMatch(subject, "Th*icK*b*ox*over the*dog");
  check(result);
 
  result = wildcardMatch(subject, "Th*icK*b*ox*over the*dog",  true);
  checkFalse(result);
 
  result = wildcardMatch(subject, "*fox*dog", true);
  check(result);
 
  result = wildcardMatch(subject, "*fox*brown");
  checkFalse(result);
 
  result = wildcardMatch(subject, "*abcd*");
  checkFalse(result);
 
  result = wildcardMatch(subject, subject);
  check(result);
  
  result = wildcardMatch(null, subject);
  checkFalse(result);
}

function stringToArrayUnitTest(){
  var arr, str, result;
  
  arr = ["A","B","C"];
  str = arrayToString(arr);
  result = stringToArray(str);
  checkEqual(arr, result);
  
  arr = [];
  str = arrayToString(arr);
  result = stringToArray(str);
  checkEqual(arr, result);
}

function arrayToStringUnitTest(){
  var arr
  arr = Array("A","B", 1)
  
  var result
  result = arrayToString(arr)
  checkEqual("A" + newLine() + "B" + newLine() + "1", result)
  
  arr = Array("A","", 1) 
  result = arrayToString(arr)
  checkEqual("A" + newLine() + "" + newLine() + "1", result) 
  
  arr = Array("","B", 1) 
  result = arrayToString(arr)
  checkEqual("" + newLine() + "B" + newLine() + "1", result) 
}

function subSteBetweenEndPoint() {
  var thisStr = 'automation is great fun'
  var result = subStrBetween(thisStr, 'is', 'fun');
  checkEqual('great', result)
}

function bigStringEndPoint() {
  var expected =  'This is our last' + newLine() +
    'goodbye' + newLine() +
    'I hate' + newLine() +
    newLine() +
    'to see the love..'
  
  var bs = bigString(function(){
  /*
    This is our last
    goodbye 
    I hate
    
    to see the love..
  */
  });
  
  checkEqual(expected, bs);
  
  bs = bigString(function(){
  /*This is our last
    goodbye 
    I hate
    
    to see the love..*/
  });
  
  checkEqual(expected, bs);
}


function standardiseLineEndingsUnitTest() {
  var base = '\r\n \n \r \r \n\r';
  var expected = '\n \n \n \n \n';
  var result = standardiseLineEndings(base);
  checkEqual(expected, result);
}

function replaceUnitTest() {
  var base = 'the quick brown fox jumps over the lazy Brown dog';
  var result;
  result = replace(base, 'brown', 'red');
  checkEqual('the quick red fox jumps over the lazy red dog', result);
  
  result = replace(base, 'brown', 'red', true);
  checkEqual('the quick red fox jumps over the lazy Brown dog', result);
}

function newLineUnitTest(){
  var result = newLine();
  checkEqual('\n', result);
  
  result = newLine(5);
  checkEqual('\n\n\n\n\n', result);
  
  result =  "Hello" + newLine() + "World";
  checkEqual("Hello\nWorld", result);
  
  result =  "Hello" + newLine(2) + "World";
  checkEqual("Hello\n\nWorld", result);
}

function subStrBetweenEndPoint() {
   var result;
   result = subStrBetween('[Hi]', '[', ']');
   checkEqual('Hi', result);
   
   result = subStrBetween('[Hi' + newLine() + ']', '[', ']');
   checkEqual('Hi', result);
   
   result = subStrBetween('[Hi' + newLine() + ']', '[', ']', false);
   checkEqual('Hi' + newLine(), result);
   
   result = subStrBetween('', '[', ']', false);
   checkEqual('', result);
   
   /* Missing Delimiters */
   result = subStrBetween('[Hi' + newLine(), '[', ']', false);
   checkEqual('', result);
   
   result = subStrBetween('Hi' + newLine() + ']', '[', ']', false);
   checkEqual('', result);
   
   result = subStrBetween('Hi', '[', ']', false);
   checkEqual('', result);
}

function trimWhiteSpaceEndPoint() {
  var result;
  result = trimWhiteSpace(' hi ');
  checkEqual('hi', result);
  
  result = trimWhiteSpace( newLine() + ' hi ' + '\r');
  checkEqual('hi', result);
  
  result = trimWhiteSpace('');
  checkEqual('', result);
  
  result = trimWhiteSpace(null);
  checkEqual('', result);
}

function stringToTimeStampedLogFileEndPoint(){
  stringToTimeStampedLogFile('any old text', 'myFile.txt');
  // file created : C:\TestCompleteLogs\myFile-2013-5-11-14-45-29.txt
  // file created  in current log folder:  C:\TestCompleteLogs\11_05_2013_2_46 PM_46_421\myFile-2013-5-11-14-46-47.txt
}

function upperCaseEndPoint() {
  checkEqual('HELLO', upperCase('hEllo'))
}

function lowerRemoveSpacesUnitTest() {
  var str = 'FLy Me to the moon'
  checkEqual('flymetothemoon', lowerRemoveSpacesTrim(str));
}

function trimCharsUnitTest(){
  var trimAr = ['a','b','}'];
  var target = 'aabcccdf}b';
  target = trimChars(target, trimAr);
  checkEqual(target, 'cccdf');
  
  target = '{B80F3702-696A-4757-ABF1-5725A65E8C22}';
  trimAr = ['{','}'];
  target = trimChars(target, trimAr);
  
  /* should throw exception */
  trimAr = ['', newLine()];
  var target = ' ';
  target = trimChars(target, trimAr);
} 

function startsWithUnitTest()
{
  check(startsWith("str", "st"));
  check(startsWith("str", ""));
  check(startsWith("", ""));
  
  checkFalse(startsWith("", "S"));
  checkFalse(startsWith("str", "S"));
}

function stringToFileUnitTest()
{
  var readBack, path;
  path = tempDir() + "Test.txt";
  stringToFile("This is a test", path);
  readBack = fileToString(path); 
  checkEqual("This is a test", readBack);
}

function appendDelimUnitTest()
{
  var str1, str2, delim, result
  str1 = "Hello"
  delim = " "
  str2 = "World" 
  result = appendDelim(str1, delim, str2)
  checkEqual("Hello World", result)
  
  str1 = ""
  delim = " "
  str2 = "World" 
  result = appendDelim(str1, delim, str2)
  checkEqual("World", result)
  
  str1 = "Hello"
  delim = " "
  str2 = "" 
  result = appendDelim(str1, delim, str2)
  checkEqual("Hello", result)
  
  str1 = "Hello"
  delim = null
  str2 = "World" 
  result = appendDelim(str1, delim, str2)
  checkEqual("HelloWorld", result)
}

function hasTextUnitTest()
{
  var needle, hayStack, result;
  
  needle = "John";
  hayStack = "i am johnie";
  result = hasText(hayStack, needle, true); 
  checkFalse(result);
  
  needle = "John";
  hayStack = "Johnie";
  result = hasText(hayStack, needle); 
  check(result);
  
  needle = "John";
  hayStack = "johnie";
  result = hasText(hayStack, needle); 
  check(result);
  
  needle = "";
  hayStack = "johnie";
  result = hasText(hayStack, needle); 
  checkFalse(result);
}

function hasTextEndPoint()
{
  // should throw exception
  hasText(null, 1); 
  hasText(1, null); 
}


function bisectUnitTest()
{
  var str, pre, post, result;
  
  str = "Hello Cool World";
  result = bisect(str, ",");
  checkEqual("Hello Cool World", result[0]);
  checkEqual("", result[1]);
  
  str = "The quick brown fox jumps";
  result = bisect(str, "e");
  checkEqual("Th", result[0]);
  checkEqual(" quick brown fox jumps", result[1]);
  
  str = "The quick brown fox jumps";
  result = bisect(str, "s");
  checkEqual("The quick brown fox jump", result[0]);
  checkEqual("", result[1]);
  
  str = "The quick brown fox jumps";
  result = bisect(str, "T");
  checkEqual("", result[0]);
  checkEqual("he quick brown fox jumps", result[1]);
  
  str = "The quick brown fox jumpsz";
  result = bisect(str, "sz");
  checkEqual("The quick brown fox jump", result[0]);
  checkEqual("", result[1]);
  
  str = "The quick brown fox jumps";
  result = bisect(str, "");
  checkEqual("The quick brown fox jumps", result[0]);
  checkEqual("", result[1]);
    
  str = "";
  result = bisect(str, "");
  checkEqual("", result[0]);
  checkEqual("", result[1]);
   
  str = '<Prp name="relpath" type="S" value="..\\..\\Utils\\FileUtils.sj"/>';
  result = bisect(str, 'value="');
  checkEqual('<Prp name="relpath" type="S" ', result[0]);
  checkEqual('..\\..\\Utils\\FileUtils.sj"/>', result[1]);
}

function subStrBeforeUnitTest(){
  var result;
  result = subStrBefore("", ",");
  checkEqual("",result);
   
  result = subStrBefore(",Gee wilikers me kent", ",");
  checkEqual("",result);
   
  result = subStrBefore("Gee wilikers me kent,", ",");
  checkEqual("Gee wilikers me kent", result);
   
  result = subStrBefore("Gee wilikers, Mr Kent", ",");
  checkEqual("Gee wilikers", result);
  
  result = subStrBefore("[Hi", "]");
  checkEqual("", result);
}

function subStrAfterUnitTest(){
   var result;
   result = subStrAfter("", ",");
   checkEqual("",result);
   
   result = subStrAfter(",Gee wilikers me kent", ",");
   checkEqual("Gee wilikers me kent",result);
   
   result = subStrAfter("Gee wilikers me kent,", ",");
   checkEqual("", result);
   
  result = subStrAfter("Gee wilikers, Mr Kent", ",");
  checkEqual(" Mr Kent", result);
   
  result = subStrAfter("[Hi", "]");
  checkEqual("", result);
}

function fileToStringUnitTest(){
  var result = fileToString(testDataFile("TestText.txt")); 
  check(aqString.Contains(result, "Unit"));
}

function sameTextUnitTest()
{
  var result = sameText(null,null);
  check(result);
  
  result = sameText("","");
  check(result);
  
  result = sameText("Hi","hI");
  check(result);
  
  result = sameText("Hi","hI", true);
  checkFalse(result);
  
  var result = sameText("hi",null);
  checkFalse(result);
  
  result = sameText("Hi","Hii");
  checkFalse(result);
}

// © John Walker 2013 – Permission for unrestricted use and modification granted within 
// THE-COMPANY and affiliated companies 