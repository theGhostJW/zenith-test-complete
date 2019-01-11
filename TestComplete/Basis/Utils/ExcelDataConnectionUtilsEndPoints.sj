//USEUNIT FileUtils
//USEUNIT CheckUtils
//USEUNIT SysUtils
//USEUNIT StringUtils
//USEUNIT _
//USEUNIT ExcelDataConnectionUtils

function dataSetConnectionUnitTest(){
  var dc = DataConnection("DataClassGentest");
  var expected = aqDateTime.SetDateElements(2000,1,4);
  var result = dc.locate({fieldDate: expected});
  var tc = dc.value("Id");
  var dt = dc.value("fieldDate");
  var day = aqDateTime.GetDay(dt);
  check(result);
  checkEqual(4, day);
  
  // change index
  expected = aqDateTime.SetDateElements(2000,1,3);
  var result = dc.locate({fieldDate: expected}, 0);
  tc = dc.value("id");
  checkEqual(2, tc);
  
  result = dc.locate({fieldDate: expected}, 1);
  tc = dc.value("id");
  checkEqual(4, tc);
  
  result = dc.locate({fieldDate: expected}, 2);
  tc = dc.value("id");
  checkEqual(5, tc);
  
  // locate next
  var result = dc.locate({fieldDate: expected});
  tc = dc.value("id");
  checkEqual(2, tc);
  
  dc.locateNext({fieldDate: expected});
  tc = dc.value("id");
  checkEqual(4, tc);
  
  dc.locateNext({fieldDate: expected});
  tc = dc.value("id");
  checkEqual(5, tc);
  
  dc.close();
}
