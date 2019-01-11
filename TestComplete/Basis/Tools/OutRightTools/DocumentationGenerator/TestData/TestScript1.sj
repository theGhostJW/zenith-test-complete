//USEUNIT ReflectionUtilsPrivate
//USEUNIT SysUtilsParent
//USEUNIT _

/** Module Info **

**/

function testScriptFuncSimple(){

}

function testScriptFuncParams(p1, p2, p3){
  p3 = def(p3, 1);
  p2 = def(p2, 'hello');
  return true;
}

/*
function testScriptFuncParams2(p1, p2, p3){

}
*/

/*
function testScriptFuncParams2(p1, p2, p3){
  // another comment
}
*/

//function testScriptFuncParams2(p1, p2, p3){
//  p1 = p2;
//}

/**

This is an important function that does important stuff.

== Params ==
p1: String - Required -
p2: Object - Required - 
p3: Number - Optional - Default: 43 - a very important number
== Return ==
String - an array of objects with a single property {filename: filePath}
representing all the script files referenced by the project
== Related ==
**/ 
function testScriptFuncParamsNested(p1, p2, p3){
  function subFuncShouldNotBeListed(p3){
    // should not be default
    p2 = def(p2, 1);
    return true;
     function subFuncShouldNotBeListed(){
      return false;
     }
  }
}

function testScriptFuncParamsNestedReturns(p1, p2, p3){
  // should not be read
  p3 = Mydef(p3, 5);
  function subFuncShouldNotBeListed(){
    return true;
     function subFuncShouldNotBeListed(){
      return false;
     }
  }
  return true;
}

/**

This is an important function that does important stuff.

== Params ==
p1: String - Required -
p2: Object - Required - 
p3: Number - Optional - Default: 43 - a very important number
== Return ==
String - an array of objects with a single property {filename: filePath}
representing all the script files referenced by the project
== Related ==
**/ 
// this should stop the parser reading the block
function shouldBeListedNestedBlocks(){
  if (true){
    //{
    var stuff =
    '{';
    var stuff2 =
    '{"';
    var stuff3 =
    '{\' {'
    var stuff4 =
    "{\" {"
    var stuff5 =
    "{\\";
    // /* 
  }
}

/**

This is another important function and should be listed

== Params ==
== Return ==
String - an array of objects with a single property {filename: filePath}
representing all the script files referenced by the project
== Related ==
**/ 
function shouldBeListed(){

}

function shouldBeListedNestedBlocks2(){
 /* 
  {
  */
}

function shouldBeListed2(param1, /* optional */ param2){

}

var funcShouldNotbeListed = function(){return true}