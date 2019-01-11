//USEUNIT XmlToJsonUtils
//USEUNIT FileUtils
//USEUNIT SysUtils
//USEUNIT CheckUtils

function xmlToJsonUnitTest(){
  var json = xmlToJson(testDataString('books.xml'));
  checkContains(json, '"title": "Midnight Rain"')
}

function xmlToObjectUnitTest() {
  var obj = xmlToObject(testDataString('books.xml'));
  var recCount = obj.catalog.book.length;
  checkEqual(12, recCount);
}