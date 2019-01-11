//USEUNIT XmlToJsonUtils
//USEUNIT SysUtils
//USEUNIT StringUtils
//USEUNIT _

function containsNonAlphaNumericOrUnderscore(str){
  var allowable = ALLOWABLE_PROP_CHARS();
  
  function notAllowed(chr){
    return !_.contains(allowable, chr);
  }  
  
  return _.some(str.split(''), notAllowed);
}

function nonObject(value){
  return (_.isArray(value) || !isObject(value));
}

var singletonAllowablePropChars = null;
function ALLOWABLE_PROP_CHARS(){
  
  function firstChar(str){
    return str.slice(0, 1);
  }
  
  if (!hasValue(singletonAllowablePropChars)){
      singletonAllowablePropChars =  _.chain(_.range(65, 91))
                                        .concat(_.range(97, 123))
                                        .map(String.fromCharCode)
                                        .map(firstChar)
                                        .concat('_')
                                        .concat(_.map(_.range(0, 11), trim))
                                        .value();
  }
  return singletonAllowablePropChars;
}

function containsNonAlphaNumericOrUnderscoreEndPoint() {
  var result = containsNonAlphaNumericOrUnderscore('dfdfdfs123');
  result = containsNonAlphaNumericOrUnderscore('df:dfdfs123');
}