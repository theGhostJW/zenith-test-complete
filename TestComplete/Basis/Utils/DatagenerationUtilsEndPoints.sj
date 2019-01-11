//USEUNIT StringUtils
//USEUNIT SysUtils
//USEUNIT CheckUtils
//USEUNIT DataGenerationUtils
//USEUNIT EndPointLauncherUtils


function randomItemEndPoint() {
  pushLogFolder('array');
  
  function logRandom(itemNo){
    log(itemNo + ': ' + randomItem([1,2,3,4,5]));
  }
  
  _.each(_.range(1,100), logRandom);
  
  popLogFolder();
  
  pushLogFolder('single args');
  
  function logRandom2(itemNo){
    log(itemNo + ': ' + randomItem(1,2,3,4,5));
  }
  
  _.each(_.range(1,100),logRandom2);
  
  popLogFolder();
  
  pushLogFolder('mixed args');
  
  function logRandom3(itemNo){
    log(itemNo + ': ' + randomItem([1,2],3,4,[5]));
  }
  
  _.each(_.range(1,100),logRandom3);
  
  popLogFolder();

}

function randomIntEndPoint() {

  function logRandom(itemNo){
    log(itemNo + ': ' + randomInt(10));
  }
  
  pushLogFolder('single arg');
  _.each(_.range(1,100), logRandom);
  popLogFolder();
  
  pushLogFolder('2 args');
  
  function logRandom2(itemNo){
    log(itemNo + ': ' + randomInt(1, 10));
  }
  
  _.each(_.range(1,100), logRandom2);
  popLogFolder();

}