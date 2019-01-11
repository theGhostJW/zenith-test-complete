//USEUNIT CheckUtils
//USEUNIT FileUtils
//USEUNIT StringUtils

function checkWithinToleranceUnitTest() {
  var result;
  result = checkWithinTolerance(null, null, 0.1);
  check(result);
  
  expectDefect('expect false');
  result = checkWithinTolerance(undefined, null, 0.1);
  endDefect();
  checkFalse(result);
  
  result = checkWithinTolerance('Hello', 'Hello', 0.1);
  check(result);
  
  result = checkWithinTolerance(1, 1.1, 0.1);
  check(result);
  
  result = checkWithinTolerance(1, '1.1', 0.1);
  check(result);
  
  expectDefect('falsy test');
  result = checkWithinTolerance(1, '1.001', 0.0009);
  endDefect();
  checkFalse(result);
}

function checkTextContainsFragmentsEndPoint(){
  var pattern = 'one *two *Three *' + newLine() + newLine() + '\r' + 'four';
  var target = 'one two Three ' + newLine() + newLine() + '\r' + 'four';
  var result = checkTextContainsFragments(pattern, target);
  check(result);
  
  var target = 'one Three two  ' + newLine() + newLine() + '\r' + 'four';
  result = checkTextContainsFragments(pattern, target);
  checkFalse(result);
}

function checkTextContainsFragmentsFromFileEndPoint(){
  var pattern = 'one *two *Three *' + newLine() + newLine() + '\r' + 'four';
  var target = 'one two Three ' + newLine() + newLine() + '\r' + 'four';
  checkTextContainsFragmentsFromFile('textFragments.txt', target);
  
  var target = 'one Three two  ' + newLine() + newLine() + '\r' + 'four';
  checkTextContainsFragmentsFromFile('textFragments.txt', target);
}

function checkExistsNotEndPoint() {
  var subject = {Exists: false};
  var result = checkExistsNot(subject);
  check(result);
  
  subject.Exists = true;
  expectDefect(0);
  result = checkExistsNot(subject); 
  endDefect();
  
  checkFalse(result);
}

function checkExistsEndPoint() {
  var subject = {Exists: true};
  var result = checkExists(subject);
  check(result);
  
  subject.Exists = false;
  expectDefect(0);
  result = checkExists(subject); 
  endDefect();
  
  checkFalse(result);
}

function checkTextEndPoint() {
  var testFile = 'TestText.ansi.txt'
  var actualText = testDataString(testFile);
  /* pass */
  checkText(actualText, actualText);
  
  actualText = replace(actualText, newLine(), '\r');
  /* pass despite different line ends */
  checkText(actualText, actualText);
  
  /* Fail */
  var diffText = aqString.Replace(actualText, 'a', 'b');
  checkText(diffText, actualText);
}

function checkTextAgainstTextFileEndPoint() {
  var testFile = 'TestText.ansi.txt'
  var actualText = testDataString(testFile);
  /* pass */
  checkTextAgainstTextFile(testFile, actualText);
  /* Fail */
  actualText = aqString.Replace(actualText, 'a', 'b');
  checkTextAgainstTextFile(testFile, actualText);
}

// You need to disable stop on error to run
// this endPoint
function checkFalseEndPoint(){
  checkFalse(false,"should not error",false,true);
  checkFalse(false);
  checkFalse(false, "No Error");
  checkFalse(false, 'more info', 'additional info', 'start main message');
    
  logBold('Expect All Fails From Here');
  checkFalse(true);
  checkFalse(true, "Error");
  checkFalse(true, 'more info', 'additional info', 'start main message');

}

// You need to disable stop on error to run
// this endPoint
function checkEndPoint(){
  var myVar;
  check(myVar, "Undefined error should log");
	check(false, "msg");
	check(false);
	check(false, "Check Message");
	check(true);
	check(true, "Msg", "Additioal info", "Different prefix");
}

function check_UsersGuideEndPoint(){
  pushLogFolder('Pass Scenarios');
  check(true);
  check(true, "will pass");
  check(true, "will pass", "More info ...");
  check(true, "will pass", "More info ...", "A Different Prefix");
	popLogFolder();
  
  pushLogFolder('Failure Scenarios');
  check(false);
  check(false, "will fail");
  check(false, "will fail", "More info ...");
  check(false, "will fail", "More info ...", "A Different Prefix");
  popLogFolder();
}

function checkEqualUnitTest(){
  checkEqual(1, 1);
  checkEqual(null, null);
  checkEqual("hi", "hi", "messge add on will not be used");
  
  expectDefect(1);
  checkEqual(1, 2, "message to add on will be displayed");
  endDefect();
  
  
  var str1 = bigString(function(){
                /*
                fdssddfdsfdsf
                dfsdfdsfdfdsf
                dsfdfdfdsfdsf
                sdfdsfsdfsdfsdfsdfsdfsdfsdfd
                sdfsdfsdfsdfsdfsdf
                sdfffffssdf
                ss
                */
             });
             
   var str2 = bigString(function(){
                /*
                fdssddfdsfdsf
                dfsdfdsfdfdsf
                dsfdfdfdsfdsf
                sdfdsfsdfsdfsdfsdfsdfsdfsdfd
                sdfsdfsdfsdfsdfsdf
                sdfffffssdf
                sss
                */
             });
             
   checkEqual(str1, str2, "message to add on will be displayed");
}

function checkContainsEndPoint() {
  var result;
  /* pass */
  result = checkContains(' hi ', 'hi');
  check(result);
  
  /* fail */
  expectDefect(0);
  result = checkContains(' hi there ', 'hI', true);
  endDefect();
  checkFalse(result);
  
  /* ignore case by default */
  result = checkContains(' hi there ', 'hI');
  check(result);
   
  /* fail */
  expectDefect(0);
  result = checkContains('', 'hi');
  endDefect();
  checkFalse(result);
  
  expectDefect(0);
  result = checkContains( '', 'hi', 'fail message');
  endDefect();
  checkFalse(result);
}