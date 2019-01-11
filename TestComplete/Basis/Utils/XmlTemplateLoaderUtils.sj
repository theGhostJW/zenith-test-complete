//USEUNIT StringUtils
//USEUNIT SysUtils
//USEUNIT _
//USEUNIT XmlToJsonUtils
//USEUNIT XmlTemplateLoaderUtilsPrivate


/** Module Info **

?????_NO_DOC_?????

**/



/**

?????_NO_DOC_?????

== Params ==
xmlTemplate: DATA_TYPE_?????_NO_DOC_????? -  Required -  DESCRIPTION_?????_NO_DOC_?????
transformers: DATA_TYPE_?????_NO_DOC_????? -  Required -  DESCRIPTION_?????_NO_DOC_?????
singlePropsObj: DATA_TYPE_?????_NO_DOC_????? -  Required -  DESCRIPTION_?????_NO_DOC_?????
== Return ==
DATA_TYPE_?????_NO_DOC_????? - DESCRIPTION_?????_NO_DOC_?????
== Related ==
?????_NO_DOC_?????
**/
function loadXmlTemplate(xmlTemplate, transformers, singlePropsObj){ 
  /*
    -- a single function to apply to whole template
    func(xmlTemplate, props) -> xml 
    
    OR
    
    -- a mapping from section name to function
    {
      sectionName : func(xmlTemplate, props),
      sectionName2: func(xmlTemplate, props)
    }
    
    -- for reformatting field values eg. date -> string applied to the base object
    finalConverterFunction propsObject -> propsObject
  */
  function applyTransformer(accum, transformerFunc, sectionName){
    var startEnd = standardStartEndTags(sectionName)
        recordStart = startEnd[0],
        recordFinish = startEnd[1],
        section = singlePropsObj[sectionName];
    
    
    return transformSection(section, 
                                    transformerFunc, 
                                    accum.transformedTemplate, 
                                    accum.unTransformedTemplate, 
                                    recordStart, 
                                    recordFinish
                                    );
  }
  
  var result;
  if (_.isFunction(transformers)){
    result = transformers(xmlTemplate);
  }
  else {
    var transformed = _.reduce(transformers, applyTransformer, {
                                                                 transformedTemplate: '',
                                                                 unTransformedTemplate: xmlTemplate
                                                                });
                                                                
    result = transformed.transformedTemplate + transformed.unTransformedTemplate;
  }
  return result;
}


/**

?????_NO_DOC_?????

== Params ==
xml: DATA_TYPE_?????_NO_DOC_????? -  Required -  DESCRIPTION_?????_NO_DOC_?????
== Return ==
DATA_TYPE_?????_NO_DOC_????? - DESCRIPTION_?????_NO_DOC_?????
== Related ==
?????_NO_DOC_?????
**/
function convertToSimpleTemplate(xml){
  var lines = standardiseLineEndings(xml).split(newLine()); 
  
  function makeTemplateLineIfSimple(str){
    var tagName = subStrBetween(str, '<','>');
    var result = str;
    if (hasValue(tagName) && hasText(str, '</' + tagName)) {
      var propName = lowerFirst(replace(tagName, ' ', '')),
          prefix = subStrBefore(str, '>') + '>',
          suffix = '</' + subStrAfter(str, '</'),
          result = prefix + '{{' + propName + '}}' + suffix;
    }
    return result;                                                 
  }
  
  return _.map(lines, makeTemplateLineIfSimple).join(newLine());
}

/**

?????_NO_DOC_?????

== Params ==
xmlStr: DATA_TYPE_?????_NO_DOC_????? -  Required -  DESCRIPTION_?????_NO_DOC_?????
== Return ==
DATA_TYPE_?????_NO_DOC_????? - DESCRIPTION_?????_NO_DOC_?????
== Related ==
?????_NO_DOC_?????
**/
function propsObjectFromTemplate(xmlStr){
  var xmlObj = xmlToObject(xmlStr);
  
  function pipeKey(key){
    return containsNonAlphaNumericOrUnderscore(key) ? key : '|||' + key + '|||'
  }
  
  var result = {};
  function sneakyReduceFunction(value, key, obj, addresss){
    function resultParent(arrProps){
      function subProp(lastParent, nextKey){
        // not allowing for spaces etc
        nextKey = lwrFirst(nextKey);
        lastParent[pipeKey(nextKey)] = def(lastParent[pipeKey(nextKey)], {});
        return lastParent[pipeKey(nextKey)];
      }
      return _.reduce(arrProps, subProp, result);
    }
    
    var addressBits = hasValue(addresss) ? addresss.split('.') : [];
    var parent = resultParent(addressBits);
    if (nonObject(value)) {
      var newKey = pipeKey(lwrFirst(key)); 
      parent[newKey] = null
    }
  }
  
  // result is discarded this is really a reduce using a local global variable
  mapObjectRecursive(xmlObj, sneakyReduceFunction);
  result = replace(objectToJson(result), '|||"', '');
  result = replace(result, '"|||', '');
  return result;
}

/**

?????_NO_DOC_?????

== Params ==
sectionName: DATA_TYPE_?????_NO_DOC_????? -  Required -  DESCRIPTION_?????_NO_DOC_?????
== Return ==
DATA_TYPE_?????_NO_DOC_????? - DESCRIPTION_?????_NO_DOC_?????
== Related ==
?????_NO_DOC_?????
**/
function standardStartEndTags(sectionName){
  var recordStart = '<!-- ' + sectionName +' -->',
      recordFinish = '<!-- end ' + sectionName + ' -->';
  return [recordStart, recordFinish]
}

/**

?????_NO_DOC_?????

== Params ==
xml: DATA_TYPE_?????_NO_DOC_????? -  Required -  DESCRIPTION_?????_NO_DOC_?????
sectionName: DATA_TYPE_?????_NO_DOC_????? -  Required -  DESCRIPTION_?????_NO_DOC_?????
recordStart: DATA_TYPE_?????_NO_DOC_????? -  Required -  DESCRIPTION_?????_NO_DOC_?????
recordFinish: DATA_TYPE_?????_NO_DOC_????? -  Required -  DESCRIPTION_?????_NO_DOC_?????
== Return ==
DATA_TYPE_?????_NO_DOC_????? - DESCRIPTION_?????_NO_DOC_?????
== Related ==
?????_NO_DOC_?????
**/
function templateParts(xml, sectionName, recordStart, recordFinish){

  if (!hasValue(recordStart) || !hasValue(recordFinish)){
    ensure(hasValue(sectionName), 'Must specify section name if start / end tags not specified');
    var tags = standardStartEndTags(sectionName);
    recordStart = def(recordStart, tags[0]);
    recordFinish = def(recordFinish, tags[1]);
  }
  else {
    sectionName = def(sectionName, 'section name not specified in function call');
  }

  ensure(hasText(xml, recordStart),
    'Cannot find section start in template: "' + recordStart + '"'+
      newLine() + 'looking in template remaining: '
      + xml + newLine(2) 
      + 'NOTE PROPERTIES OF THE TRANSFORMERS OBJECT MUST BE LISTED IN THE SAME ORDER AS THEY APPEAR IN THE TEMPLATE');
   
  var prefixTarget = bisect(xml, recordStart),
      prefix = prefixTarget[0],
      target = prefixTarget[1];
     
  function textIsInTarget(txt){
    return hasText(target, txt, true);
  }
  recordFinish = forceArray(recordFinish);
  var firstTerminatorTag = _.find(recordFinish, textIsInTarget);
  ensure(hasValue(firstTerminatorTag), 
                'Cannot find section end in template (case sensitive): ' + recordFinish.join(newLine() + '==== OR ====' + newLine()) +  
                newLine() + 'looking in template remaining: ' 
                + target);   
       
  var targetRemainder = bisect(target, firstTerminatorTag),
      remainder = targetRemainder[1];
      
  target = targetRemainder[0];
  

  return {
          prefix: prefix,
          section: target,
          suffix: remainder
         };
}

/**

?????_NO_DOC_?????

== Params ==
xml: DATA_TYPE_?????_NO_DOC_????? -  Required -  DESCRIPTION_?????_NO_DOC_?????
sectionName: DATA_TYPE_?????_NO_DOC_????? -  Required -  DESCRIPTION_?????_NO_DOC_?????
recordStart: DATA_TYPE_?????_NO_DOC_????? -  Required -  DESCRIPTION_?????_NO_DOC_?????
recordFinish: DATA_TYPE_?????_NO_DOC_????? -  Required -  DESCRIPTION_?????_NO_DOC_?????
== Return ==
DATA_TYPE_?????_NO_DOC_????? - DESCRIPTION_?????_NO_DOC_?????
== Related ==
?????_NO_DOC_?????
**/
function removeSection(xml, sectionName, recordStart, recordFinish){
  var parts = templateParts(xml, sectionName, recordStart, recordFinish);
  return parts.prefix + parts.suffix;
}


/**

?????_NO_DOC_?????

== Params ==
dataObj: DATA_TYPE_?????_NO_DOC_????? -  Required -  DESCRIPTION_?????_NO_DOC_?????
transformerFunc: DATA_TYPE_?????_NO_DOC_????? -  Required -  DESCRIPTION_?????_NO_DOC_?????
transformedTemplate: DATA_TYPE_?????_NO_DOC_????? -  Required -  DESCRIPTION_?????_NO_DOC_?????
unTransformedTemplate: DATA_TYPE_?????_NO_DOC_????? -  Required -  DESCRIPTION_?????_NO_DOC_?????
recordStart: DATA_TYPE_?????_NO_DOC_????? -  Required -  DESCRIPTION_?????_NO_DOC_?????
recordFinish: DATA_TYPE_?????_NO_DOC_????? -  Required -  DESCRIPTION_?????_NO_DOC_?????
== Return ==
DATA_TYPE_?????_NO_DOC_????? - DESCRIPTION_?????_NO_DOC_?????
== Related ==
?????_NO_DOC_?????
**/
function transformSection(dataObj, transformerFunc, transformedTemplate, unTransformedTemplate, recordStart, recordFinish){
  var parts = templateParts(unTransformedTemplate, null, recordStart, recordFinish)
  var transformedSection = transformerFunc(parts.section, dataObj);

  return {
        transformedTemplate: transformedTemplate + parts.prefix + transformedSection,
        unTransformedTemplate: parts.suffix
      };
}
