//USEUNIT CheckUtils
//USEUNIT SysUtilsPrivate
//USEUNIT WebUtils
//USEUNIT EndPointLauncherUtils

function areEqualWithToleranceEndPoint() {
  check(areEqualWithTolerance(1,1.000000, 0.000001));
  check(areEqualWithTolerance(1.000001, 1.000000, 0.000001));
  checkFalse(areEqualWithTolerance(1.000001, 1.000000, 0.0000009));
  check(areEqualWithTolerance(0, 0, 0.000001));
  check(areEqualWithTolerance(1, 1.1, 0.1));
  check(areEqualWithTolerance(1, '1.1', 0.1));
  check(areEqualWithTolerance(1, '0.9', 0.1));
  checkFalse(areEqualWithTolerance(1, '0.9', 0.09));
  check(areEqualWithTolerance(1.000001, '1', 0.000001));
  checkFalse(areEqualWithTolerance(1.000001, '1', 0.0000009999999));
  checkFalse(areEqualWithTolerance(1.000001, '1.000001001', 0));
}

function cloneArrayUnitTest(){
  var targ = [1,2,3,4],
      klone = cloneArray(targ);
      
  checkEqual([1,2,3,4], klone);
  
  // mutate the clone
  klone.push(999);
  klone[0] = klone[0] + 1;
  
  checkEqual([1,2,3,4], targ);

  targ = [[9, 'a', 4, 2, 1]];
  klone = cloneArray(targ);
  checkEqual([[9, 'a', 4, 2, 1]], klone);
  
  targ = [1,{p1: 'rrr'},[9, 'a', 4, 2, 1],4];
  klone = cloneArray(targ);
  checkEqual(targ, klone);
  
  targ = [1,{p1: 'rrr'},[9, 'a', 4, 2, 1],4];
  klone = cloneArray(targ);
  checkEqual([1,{p1: 'rrr'},[9, 'a', 4, 2, 1],4], klone);

  klone[1].p1 = 'bbb';
  checkEqual('rrr', targ[1].p1, 'changes to clone shoould not affect original');
}

function depthFromContainerEndPoint() {
   // runUrl('http://support.smartbear.com/samples/testcomplete10/weborders/')
   // login page
   var child = seekByIdStr('ctl00_MainContent_username');
   var container = seekByIdStr('aspnetForm');
   var result
   result = depthFromContainer(child, container);
   checkEqual(2, result);

}

function pointsOverlapUnitTest() {
  var result;
  result = pointsOverlap(10, 20, 10, 20);
  check(result);
  
  result = pointsOverlap(10, 20, 20, 30);
  check(result);
      
  result = pointsOverlap(20, 30, 10, 20);
  check(result);
      
  result = pointsOverlap(10, 40, 20, 30);
  check(result);
      
  result = pointsOverlap(10, 20, 10, 40);
  check(result);
      
  result = pointsOverlap(10, 40, 20, 30);
  check(result);
      
  result = pointsOverlap(10, 20, 30, 40);
  check(!result);
}



function findChildNestedEndPoint(){
 // runUrl('http://support.smartbear.com/samples/testcomplete10/weborders/')
  var page = activePage();
  var txt = findChildNested(page, false, function(obj){return hasText(obj.idStr, 'username')});
  delay(1);
  
  txt = findChildNested(page, true, function(obj){return hasText(obj.idStr, 'username')});
  delay(1);
  
  txt = findChildNested(page, true, 
    {ObjectType: 'Page'},
    function(obj){return hasText(obj.idStr, 'username')});
  checkFalse(txt.Exists);
  
  txt = findChildNested(page, true, 
    {ObjectType: 'Form'},
    function(obj){return hasText(obj.idStr, 'username')});
  check(txt.Exists);

}

// © John Walker 2013 – Permission for unrestricted use and modification granted within 
// THE-COMPANY and affiliated companies