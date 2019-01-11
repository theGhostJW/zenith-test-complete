//USEUNIT _
//USEUNIT CheckUtils
//USEUNIT ExcelDataConnectionUtils
//USEUNIT FileUtils
//USEUNIT ReflectionUtils
//USEUNIT StringUtils

function nestChildRecs(arRawFields, validationFunction){
  var commentFields = null,
      hasComments = null,
      parentFieldNames = null,
      childFieldNames = null,
      childMarker = null,
      childFieldName = null;
  
  function isChildRecsMarker(str){
    return hasText(str, 'child:');
  }    
    
  if (arRawFields.length > 0){
    var keys = _.keys(arRawFields[0]);
    ensure(_.indexOf(keys, 'validators') === -1, 'validators is a reserved column name and cannot be used in spreadsheet data');
    commentFields = _.chain(keys)
                      .filter(isCommentField)
                      .value();
              
    var childrecsIndex = _.findIndex(keys, isChildRecsMarker);

    function isParent(key){
      return _.indexOf(keys, key) < childrecsIndex;
    }
    
    if (childrecsIndex === -1){
      parentFieldNames = keys;
      childFieldNames = [];  
    }
    else {
      var splitFields = _.partition(keys, isParent);
      parentFieldNames = splitFields[0];
      childFieldNames = splitFields[1]; 
      childMarker = keys[childrecsIndex];
      childFieldName = subStrAfter(childMarker, ':');
    }
    
                      
    hasComments = commentFields.length > 0;
  }
  
  function removeComments(obj){
    return hasComments ? _.omit(obj, commentFields): obj;
  }
  
  function removeChildMarker(obj){
    return hasValue(childMarker) ? _.omit(obj, childMarker): obj;
  }
  
  function allNulls(obj, fieldNames){
    function isNullProp(accum, propName){
      return accum && isNull(obj[propName]);
    }
    return _.reduce(fieldNames, isNullProp, true);
  }
  
  function addrecord(accum, obj, index){
    var isParent = hasValue(obj.id);
    var parent = isParent ? _.pick(obj, parentFieldNames): accum.lastParent;
    
    ensure(isParent || allNulls(obj, parentFieldNames), 'Cannot load spreadsheet record: ' + (index + 1) + ' has non empty parent fields but no id field');
    
    if (!allNulls(obj, childFieldNames)){
      parent[childFieldName] = def(parent[childFieldName] , []);
      parent[childFieldName].push(_.pick(obj, childFieldNames));
    }
    
    if (isParent){
      accum.result.push(parent);
    }
    accum.lastParent = parent;
    return accum;
  }
  
  function addValidation(obj){
    obj.validators = validationFunction;  
    return obj;
  }
  
  var result = _.chain(arRawFields)
                .map(removeComments)
                .map(removeChildMarker)
                .reduce(addrecord, {result: [], lastParent: null})
                .value()
                .result;
      
  if (hasValue(validationFunction)){
    result = _.map(result, addValidation);  
  }          
  return result;             
}

function nestChildRecsEndPoint() {
  var result = nestChildRecs(fromTestData('excelLoaderRaw.json'));
  toTemp(result, 'excleObjs.json')
}


function isCommentField(thisFieldName){
  thisFieldName = trim(thisFieldName);
  return (aqString.Find(thisFieldName, "<") === 0);
}

function isCommentFieldUnitTest(){
  var result = isCommentField("  <Comment rec Blahh>"); 
  check(result);   
}