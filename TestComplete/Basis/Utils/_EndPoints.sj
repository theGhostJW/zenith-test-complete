//USEUNIT _
//USEUNIT SysUtils
//USEUNIT CheckUtils

function variousEndPoint() {
  // just call utils to test underscore works in new format
  var input = [1, 2, 3, 4, 5, 6 ,7 ,8 ,9 , 0];
  
  var out =  chain(input)
              .filter(function(n){return n < 7})
              .map(function(n){return n + 3;})
              .value();
  
  log(out);
}

function delayEndPoint(){
  // this should just cause a delay TC NOT underscore
  delay(10000, 'waiting');
}

function findIndexEndPoint(){
  var arr = ['a', 'b', 'c', 'd'];
  function isa(chr){
    return chr === 'a'; 
  }
  
  var result = _.findIndex(arr, isa);
  checkEqual(0, result);
  
  function isd(chr){
    return chr === 'd'; 
  }
  
  var result = _.findIndex(arr, isd);
  checkEqual(3, result);
  
  
  function ise(chr){
    return chr === 'e'; 
  }
  
  var result = _.findIndex(arr, ise);
  checkEqual(-1, result);
}