//USEUNIT _
//USEUNIT SysUtils
//USEUNIT _
//USEUNIT StringUtils

function randomItem(nArItems){
  return _.sample(forceArray.apply(null, _.toArray(arguments)));
}

function randomInt(fromInt, toInt){
  // if 1 param provided then 0 to param
  return _.random(fromInt, toInt);
}