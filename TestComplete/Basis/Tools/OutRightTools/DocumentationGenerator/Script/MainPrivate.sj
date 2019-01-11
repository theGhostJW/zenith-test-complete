//USEUNIT SysUtils
//USEUNIT ReflectionUtils
//USEUNIT StringUtils
//USEUNIT FileUtils
//USEUNIT _

function compileSpellCheck(){
  var baseDir = combine(tempDir(), 'helpdocFuncs');
  var result = [];

  function appendResult(file){
    result.push(getDocString(fileToObject(file), file));
  }
  
  eachFile(baseDir, appendResult);
  
  var content = _.flatten(result).join(newLine(2));
  stringToTemp(content, 'helpDoc');
}

// used for spell check
function getDocString(funcInfos, path){
  function getDoc(funcInfo){
    var targ = _.pick(funcInfo, 'name', 'documentation');
    log(funcInfo.name);
    return objectToReadable(targ);
  }
  var result = _.map(funcInfos, getDoc).join(newLine(2));
  return '=====' + path + '=====' + newLine(2) + result;
}

function getDocStringEndPoint() {
  var target = fromTemp('\\helpdocFuncs\\\CheckUtils.json');
  var result = getDocString(target);  
}


function generateSummary(projectFilePath){
  var sourceInfo = extendedScriptInfo(projectFilePath);
  toTemp(sourceInfo, 'sourceInfo.json');
  return sourceInfo;
}

function generateApiHelp(summaryObjects){
  var templateDir = apiTemplateDir();
  var helpParent = combine(tempDir(), aqFileSystem.GetFolderInfo(templateDir).Name);
  ensure(!aqFileSystem.Exists(helpParent) || aqFileSystem.DeleteFolder(helpParent, true), 'delete folder failed');
  ensure(aqFileSystem.CopyFolder(templateDir, tempDir()), 'copy folder failed');
  
  generateAML(summaryObjects, helpParent);
  var topics = topicsFromFiles(combine(helpParent, 'sourceFiles'));
  updateLayout(helpParent, topics);
  updateCastle(helpParent, topics);
  
  logBold('Source files done - compie Sandcasle project manually check then delete output (.chm) then run step 2');
}

function generateApiHelpEndPoint() {
  var summaryObjs = tempObject('summaryObjects.json');
  generateApiHelp(summaryObjs);
}

function updateCastle(helpParent, topics){
  var target = combine(helpParent, 'ZenithAPI.shfbproj');
  var template = fileToString(combine(helpParent, 'ZenithAPITemplate.shfbproj'), aqFile.ctUTF8); 
      
  function files(topics){
    var sub = combine('sourceFiles', topics.script);
    function file(funcName){
      return combine(sub, funcName) + '.aml';    
    }
    var result = _.map(topics.functions, file); 
    return result
  }     
        
  var items = _.chain(topics)
                .map(files)
                .flatten()
                .value();
                  
  function pathToItemStr(path){
    return replace('<None Include="path" />', 'path', path);
  }
  
  var itemsStr = _.chain(items)
                  .map(pathToItemStr)
                  .value()
                  .join(CRLF() + CRLF());
     
  var result = replace(template, '<!--- items --->', itemsStr);
  stringToFile(result, target, aqFile.ctUTF8);                 
}

function updateCastleEndPoint() {
  var dir = 'C:\\automationFramework\\TestComplete\\Basis\\Tools\\OutRightTools\\Temp\\API Help Generation';
  var topics = topicsFromFiles(combine(dir, 'sourceFiles'));
  updateCastle(dir, topics);
}


function topicsFromFiles(sourceDir){
  function getInfo(dir){
  
    function name(file){
      return aqFileSystem.GetFileNameWithoutExtension(file);
    }
    
    return {
              script: aqFileSystem.GetFolderInfo(dir).Name,
              functions: _.map(listFiles(dir), name)
            }
  }
  
  function wantExcluded(dir){
    var name = aqFileSystem.GetFolderInfo(dir).Name
    return isExcludedScript(name) && (name !== '_');
  }
  
  var topics = _.chain(listFolders(sourceDir))
          .reject(wantExcluded)
          .map(getInfo)
          .value();
          
  return topics;
}

function updateLayout(helpParent, topics){
  
  var sourceDir = combine(helpParent, 'sourceFiles'),
      template = combine(sourceDir, 'Layout.content.template'),
      target = combine(sourceDir, 'Layout.content');
      
  aqFileSystem.CopyFile(template, target, false);
  
  var TOPICS_HEADER = bigString(function(){
                         /*
                            <?xml version="1.0" encoding="utf-8"?>
                            <Topics>
                            <Topic id="6fd965ee-fb0f-4fa7-8952-730c1f16f713" visible="True" noFile="true" isExpanded="true" isSelected="true" title="Zenith Automation Framework" tocTitle="Zenith Automation Framework">
                         */
                      });
                      
  var TOPICS_FOOTER = bigString(function(){
                          /*
                              </Topic>
                             </Topics>
                          */
                       });
  
  var result = TOPICS_HEADER + CRLF() + CRLF() +
              _.map(topics, makeTopic).join(CRLF() + CRLF()) + CRLF() + CRLF() +
               TOPICS_FOOTER;
           
  stringToFile(result, target, aqFile.ctUTF8);
}

function updateLayoutEndPoint() {
  var dir = 'C:\\automationFramework\\TestComplete\\Basis\\Tools\\OutRightTools\\Temp\\API Help Generation';
  var topics = topicsFromFiles(combine(dir, 'sourceFiles'));
  updateLayout(dir, topics);
}

function makeTopic(info){
  var functionTopics = _.map(info.functions, funcTopicStr);
  return wrapInUnitTopic(functionTopics.join(CRLF() + CRLF()), info.script);
}

var defaultSet = false;
function funcTopicStr(name){
  var TEMPLATE = bigString(function(){
                    /*
                    <Topic id="#id" visible="True" isDefault="#default" title="#funcName" tocTitle="#funcName" linkText="#funcName">
                    <HelpKeywords>
                      <HelpKeyword index="K" term="#funcName" />
                    </HelpKeywords>
                    </Topic>
                    */
                 });
                 
  var result = replace(TEMPLATE, '#id', toId(name));
  result = replace(result, '#default', (defaultSet ? 'false' : 'true'));
  defaultSet = true;
  result = replace(result, '#funcName', name);
  return result;
}

function wrapInUnitTopic(functionStr, unitName){
  var header = replace('<Topic id="#id" visible="True" noFile="true" isExpanded="true" title="WebUtils" tocTitle="WebUtils" linkText="WebUtils">',
                        '#id', ID_PREFIX() + unitName);
                          
  header = replace(header, 'WebUtils', unitName);
    
  return header + CRLF() + CRLF() + functionStr + CRLF() + CRLF() + '</Topic>'
}

function isExcludedScript(unitName){
  function unitNameHasText(txt){
    return hasText(unitName, txt);
  }
  return _.some(['_', 'Json2Utils', 'WebUtilsDemo', 'manualParserUtils', 'TestCaseListUtils', 'parent', 'private', 'ToReadableUtils'], unitNameHasText);
}

function forceInclude(unitName){
  return sameText(unitName, 'testRunner');
}

function generateAML(summaryObjects, helpParent){
  function isDocTarget(unitInfo){
    return (hasText(unitInfo.name, 'utils') && !isExcludedScript(unitInfo.name)) || forceInclude(unitInfo.name);
  }
  

  var docObjects = _.chain(summaryObjects)
                    .filter(isDocTarget)
                    .value();
  //toTemp(summaryObjects, 'summaryObjects');
  generateFunctionFiles(docObjects, combine(helpParent, 'sourceFiles'));
  generateUnderscoreHelpFiles(summaryObjects, combine(helpParent, 'sourceFiles'));
}

function generateAMLEndPoint() {
  var summaryObjects = tempObject('sourceInfo.json');
  generateAML(summaryObjects, 'C:\\automationFramework\\TestComplete\\Basis\\Tools\\OutRightTools\\Temp\\API Help Generation');
}

function generateFunctionFiles(summaryObjects, dir){
  var templateStr = templateText(dir);
  
  function makeUnitAml(unitSummary){
    makeUnitAmlInDir(unitSummary, templateStr, dir);                                     
  };   
  
  function isEndPoint(unitSummary){
    return hasText(unitSummary.name, 'endPoint');
  }
  
  _.chain(summaryObjects)
    .reject(isEndPoint)
    .each(makeUnitAml);
    
}

function generateUnderscoreHelpFiles(summaryObjects, dir){
  var underscoreUnit = _.find(summaryObjects, function(item){return item.name === '_'});
  var parent = forceUnitDir(dir, '_');
  
  function makeUSAML(functionName){
    var result = templateText(dir, '_.aml');
    result = replace(result, 'lamdahof_api_set', toId(functionName));
    result = simpleReplace(result, 'introduction', underscoreComment(functionName));
    stringToFile(result, combine(parent, functionName + '.aml'), aqFile.ctUTF8);
  }
  
  _.chain(underscoreUnit.functions)
      .pluck('name')
      .each(makeUSAML);
}

function generateUnderscoreHelpFilesEndPoint() {
  var summaryObjects = tempObject('sourceInfo.json');
  generateUnderscoreHelpFiles(summaryObjects, 'C:\\automationFramework\\TestComplete\\Basis\\Tools\\OutRightTools\\Temp\\API Help Generation\\sourceFiles');
}

function underscoreComment(functionName){
  var VERSION = '1.8.3'
  var link = 'https://cdn.rawgit.com/jashkenas/underscore/' + VERSION + '/index.html#' + functionName;
  return 'See external underscore documentation for: ' + toLink(link + '|' + functionName);
}

function generateFunctionFilesEndPoint() {
  var summaryObjects = tempObject('summaryObjects');
  generateFunctionFiles(summaryObjects, 
                        'C:\\automationFramework\\TestComplete\\Basis\\Tools\\OutRightTools\\Temp\\API Help Generation\\sourceFiles');
}

function forceUnitDir(parent, unitName){
  var unitDir = combine(parent, unitName);
  aqFileSystem.DeleteFolder(unitDir, true);
  forceDirectory(unitDir);
  return unitDir;
}

function makeUnitAmlInDir(unitSummary, templateText, dir){
  
//  logWarning('Blahh');
//  if (unitSummary.name !== 'SysUtils'){
//    return;
//  }
  var arContent = fileToArray(unitSummary.path);
  var unitDir = forceUnitDir(dir, unitSummary.name);
  
  function escapeXml(funcInfo){
    var doc = _.omit(funcInfo.documentation, 'params');
    doc = _.mapObject(doc, _.escape);
    doc.params = _.map(funcInfo.documentation.params, _.escape);
    funcInfo.documentation = doc;
    return funcInfo;
  }  
  
//  logWarning('Blahh');
//  unitSummary.functions = _.filter(unitSummary.functions, function(fu){return fu.name === 'logCheckPoint'});
   
  var functions = filterAndGetDocumentation(unitSummary.functions, arContent);
  
  var filePath = combine(forceDirectory(combine(tempDir(), 'helpdocFuncs')), unitSummary.name + '.json')
  logWarning('writing file: ' + filePath);
  objectToFile(functions, filePath);
  
  
  functions = _.map(functions, escapeXml); 
       
  function functionInfoToAml(funcInfo){
    return transformFuncInfoToAml(funcInfo, templateText);
  }
  
  var amlContent = _.map(functions, functionInfoToAml);
  
  function save(amlObj){
    stringToFile(amlObj.aml, combine(unitDir, amlObj.name), aqFile.ctUTF8);
  }
  
  function frameworkUseOnly(amlObj){
    return hasText(amlObj.aml, 'framework use only');
  }
  
  _.chain(amlContent)
    .reject(frameworkUseOnly)
    .each(save);
}

function makeUnitAmlInDirEndPoint() {
  var unitSummary = tempObject('unitSummary');
  var dir = 'C:\\automationFramework\\TestComplete\\Basis\\Tools\\OutRightTools\\Temp\\API Help Generation\\sourceFiles';
  makeUnitAmlInDir(unitSummary, templateText(dir), dir)
}

function escapeEndPoint(){
  var target = bigString(function(){
     /*
           Fires singleRowCell function for each cell of a grid function (cell, colTitle, rowIndex, colIndex, arRowCells)
filtering for visible cells & height > 1 starts on row index 1 - normally the col title row is row 0
row index will be index of visible row which may differ from true rowIndex (cell.RowIndex)
     */
  });
  
  var result = _.escape(target);
  stringToTemp(result);
}

function ID_PREFIX(){
  return 'lamdahof_api_';
}

function toId(functionName){
  return ID_PREFIX() + functionName; 
}


function transformFuncInfoToAml(funcInfo, templateText){
  var documentation = funcInfo.documentation,
      functionName = funcInfo.name;
  
  //id
  var result = replace(templateText, 'lamdahof_api_set', toId(functionName));
  
  // declaration
  var declaration = subStrBefore(funcInfo.functionText, ')') + ')';
  result = simpleReplace(result, 'declaration', declaration);
  
  // introduction
  result = simpleReplace(result, 'introduction', documentation.description);
  
  // parameters
  var parameters = makeParamTable(documentation.params);
  result = simpleReplace(result, 'parameters', parameters);

  // result
  var returns = makeResultTable(documentation.returnInfo);
  result = simpleReplace(result, 'result', returns);
  
  // examples
  if (hasValue(funcInfo.examples) && funcInfo.examples.length > 0){
    var exampleText = funcInfo.examples.join(newLine(2));
    var path = tempFile(toId(functionName) + '.js');
    stringToFile(exampleText, path);
    var sampleElement = '<section address="SampleCode">' + newLine() +
                '<title>Sample Code</title>' + newLine() +
                '<content>' + newLine() +
                '<code source="' + path + '" language="JavaScript" title="Example"/>' + newLine() +
                '</content>' + newLine() +
                '</section>';
  } else {
    sampleElement = '';
  }            
  result = simpleReplace(result, 'sampleCode', sampleElement);
  
  // related topics
  function toLink(funcName){
    return '<link xlink:href="' + toId(trim(funcName)) + '" topicType_id="F9205737-4DEC-4A58-AA69-0E621B1236BD"/>';
  }
  
  var related = _.filter(trimWhiteSpace(documentation.related).split(','), hasValue);
  if (related.length > 0){
    related = _.map(related, toLink);
    related = hasValue(related) ? _.flatten([['<relatedTopics>'], related, ['</relatedTopics>']]).join(newLine()) : '';
  }
  else {
    related = '';
  }
  result = simpleReplace(result, 'relatedTopics', related);
  
  return {
          name: functionName + '.aml',
          aml: result
          };
}

function transformFuncInfoToAmlEndPoint() {
  var funcInfo = tempObject('funcInfo');
  var dir = 'C:\\automationFramework\\TestComplete\\Basis\\Tools\\OutRightTools\\Temp\\API Help Generation\\sourceFiles';
  var tmp = templateText(dir);
  stringToTemp(tmp);
  var result = transformFuncInfoToAml(funcInfo, tmp);
  stringToTemp(result, 'result.aml', aqFile.ctUTF8);
}

function makeResultTable(returnInfo){
  var result = '';
  if (hasValue(returnInfo)){
    var typeDesc = _.map(bisect(returnInfo, '-'), trim);
    var result = bigString(function(){
                    /*
                    <section address="Result">
                    <title>Returns</title>
                		<content>
                		<table>
                		<tableHeader>
                		<row>
                		<entry><para>Type</para></entry>
                		<entry><para>Description</para></entry>
                		</row>
                		</tableHeader>
                		<row>
                		<entry><para>#type</para></entry>
                		<entry><para>#desc</para></entry>
                		</row>
                		</table>
                		</content>
                    </section>
                    */
                 });
    result = replace(result, '#type', typeDesc[0]);
    result = replace(result, '#desc', typeDesc[1]);
  }
  return result;
}

function makeResultTableEndPoint() {
  var result = makeResultTable("Boolean - true if the test passed")
}

function makeParamTable(params){
  var HEADER = bigString(function(){
                  /*
                  <section address="Parameters">
                  <title>Parameters</title>
              		<content>
                  <table>
              		<tableHeader>
              		<row>
              		<entry><para>Name</para></entry>
              		<entry><para>Type</para></entry>
              		<entry><para>Required</para></entry>
              		<entry><para>Default</para></entry>
              		<entry><para>Description</para></entry>
              		</row>
              		</tableHeader>
                  */
               });
               
  var FOOTER = '</table></content></section>'; 
  
  var result = '';
  params = _.reject(params, _.isEmpty);
  if (params.length > 0){
    var rows = _.chain(params)
                .map(paramPartsFromString)
                .map(paramPartsToRow)
                .value()
                .join(CRLF());
                
    
   result = [HEADER, rows, FOOTER].join(CRLF());
    
  }
  return result;
}

function paramPartsToRow(paramParts){
  function toEntry(str){
    return '<entry><para>'+ trim(str) +'</para></entry>'  
  }
  
  var partsStr = _.map(paramParts, toEntry).join(CRLF());
  return '<row>' 
            + CRLF() 
            + partsStr 
            + CRLF() 
            +  '</row>';
}

function paramPartsFromString(str){
  var parts = _.map(str.split('-'), trim); 
  var required = hasText(parts[1], 'required');
  return {
          name: subStrBefore(parts[0], ':'),
          type: subStrAfter(parts[0], ':'),
          required: required ? 'true' : 'false',
          defaultVal: required ? 'N/A' : trim(subStrAfter(parts[2], ':')),
          description: _.last(parts)
         };
}

function simpleReplace(source, tag, replaceStr){
  tag = '<!-- #' + tag + ' -->';
  var parts = bisect(source, tag);
  ensure(hasValue(parts[0]), 'could not find ' + tag);

  return parts[0] + escapeLinks(replaceStr) +  subStrAfter(parts[1], '# -->');
}

//var callCount = 0;
function escapeLinks(str, recurse){
//  if (!recurse){
//    callCount++;
//    if (callCount === 1731){
//      delay(1);
//    }
//    log(callCount);
//  }
  str = def(str, '');
  if (hasText(str, '[[')){
    
    toTemp(str,'theStr');
    
    ensure(hasText(str, ']]'), 'unclosed dbl bracket in: ' + str);
    var pre = subStrBefore(str, '[['),
        post = subStrAfter(str, ']]'),
        link = toLink(subStrBetween(str, '[[', ']]'));
    return(escapeLinks(pre + link + post, true));
  }
  else {
    return str;
  }
}

function escapeLinksEndPoint() {
  var result = escapeLinks('see [[#checkExists|checkExists]]');
  log(result);
  
  result = escapeLinks('see [[checkExists]]');
  log(result);
  
  result = escapeLinks('A wrapper around [[http://support.smartbear.com/viewarticle/28178/|aqDateTime.SetDateElements(Year, Month, Day)]]');
  log(result);
}

function toLink(str){
  var EXTERNAL_LINK = bigString(function(){
                         /*
                          <externalLink>
                          <linkText>#linkText</linkText>
                          <linkAlternateText>#linkText</linkAlternateText>
                          <linkUri>#linkUri</linkUri>
                          </externalLink>
                         */
                      });
                      
  var INTERNAL_LINK = bigString(function(){
                        /*
                        <link xlink:href="#xLink">#topic</link>
                        */
                     });
                     
  var linkParts = _.map(bisect(str, '|'), trim);
  var link = trimChars(linkParts[0], ['#']),
      label = hasValue(linkParts[1]) ? linkParts[1]: linkParts[0];

  return hasText(link, 'http') ?
    replace(
            replace(EXTERNAL_LINK, '#linkText', label),
            '#linkUri',
             link
            ):
    
    replace(                           
            replace(INTERNAL_LINK, '#xLink',  toId(link)),
                                    '#topic', label);
}

function filterAndGetDocumentation(functions, arContent){
  getFunctionsToDocument(functions);
  addDocumentationTextToFunctionInfo(functions, arContent);
   
  function sectioniseDocumentation(funcInfo){
    var arDocs = stringToArray(funcInfo.documentation);
    var documentation = sectionise(arDocs);
    
    function tidySection(str){
      return trimChars(str, ['*', '/', '\r', '\n'])
    }
    documentation = _.mapObject(documentation, tidySection);
    documentation.params = standardiseLineEndings(documentation.params).split(newLine());
    funcInfo.documentation = documentation;
    return funcInfo;
  }
   
  return _.map(functions, sectioniseDocumentation);
}

function filterAndGetDocumentationEndPoint() {
  var arContent = tempObject('arContent'),
      unitSummary = tempObject('unitSummary');

  var result = filterAndGetDocumentation(unitSummary.functions, arContent);
  toTemp(result, 'result');
}

function templateText(dir, fileName){
  fileName = def(fileName, 'set.aml'); 
  return  fileToString(combine(
                                dir, 
                                'WebUtilsDemo', 
                                fileName
                                ),  aqFile.ctUTF8);
}

//htmlHelp builder expects this format
function CRLF(){ return '\r\n';}

function updateWorkingFiles(workingDir){
  var hhp = combine(workingDir, 'Help1x.hhp');
  var hhpContent = fileToString(hhp);
  hhpContent = replace(hhpContent, '[OPTIONS]', '[OPTIONS]' + CRLF() + 'Binary Index=Yes');
  
  // windows
  var windowDef = subStrBetween(trimWhiteSpace(subStrAfter(hhpContent, '[WINDOWS]')), '=', CRLF());
  
  function winDef(winName){
    return winName + '=' + windowDef
  }
  
  var windows = '[WINDOWS]' + CRLF() + _.map(['Main', '$global_Main'], winDef).join(CRLF());
  
  hhpContent = subStrBefore(hhpContent, '[WINDOWS]') + windows + CRLF() + CRLF()
                        + '[FILES]' 
                        + subStrAfter(hhpContent, '[FILES]');
  
  hhpContent = replace(hhpContent, 'MsdnHelp', 'Main'); 
  stringToFile(hhpContent, hhp);
  
  var htmlDir = combine(workingDir, 'Output', 'HtmlHelp1', 'html');
  eachFile(htmlDir, addALinkParams);

}

function updateWorkingFilesEndPoint() {
  updateWorkingFiles('C:\\automationFramework\\TestComplete\\Documentation\\API Help Generation\\working');
}

function addALinkParams(path){
  var content = fileToString(path);
  var title = subStrBetween(content, '<title>', '</title>');
 
  var template = bigString(function(){
                    /*
                    <object type="application/x-oleobject" classid="clsid:1e2a7bd0-dab9-11d0-b93a-00c04fc99f9e">
                    <param name="ALink Name" value="#title">
                    </object> 
                    */
                 });
  
  var aLink = replace(template, "#title", title);
  content = replace(content, '</head>', aLink + newLine() + '</head>');
  stringToFile(content, path);
}

function addALinkParamsEndPoint() {

}

function apiTemplateDir(){
  
  function hasDocumentationSubDir(dir){
    var docDir = combine(dir, 'Documentation');
    return aqFileSystem.Exists(docDir);
  }
  
  function getDocDirParent(dir){
    ensure(hasValue(dir), 'Cannot find docs path');
    return hasDocumentationSubDir(dir) ? dir : getDocDirParent(parentFolder(dir));
  }
  
  var result = combine(getDocDirParent(Project.Path), 'Documentation', 'API Help Generation');
  ensure(aqFileSystem.Exists(result), 'API Help Generation folder does not exist');
  return result;
}

function generateUnderScoreWrapper(){
  var UNDERSCORE_FUNC_NAMES_FROM_WEB = bigString(function(){
                                      /*
                                      Collections

    - each
    - map
    - reduce
    - reduceRight
    - find
    - filter
    - where
    - findWhere
    - reject
    - every
    - some
    - contains
    - invoke
    - pluck
    - max
    - min
    - sortBy
    - groupBy
    - indexBy
    - countBy
    - shuffle
    - sample
    - toArray
    - size
    - partition

Arrays

    - first
    - initial
    - last
    - rest
    - compact
    - flatten
    - without
    - union
    - intersection
    - difference
    - uniq
    - zip
    - unzip
    - object
    - indexOf
    - lastIndexOf
    - sortedIndex
    - findIndex
    - findLastIndex
    - range

Functions

    - bind
    - bindAll
    - partial
    - memoize
    - delay
    - defer
    - throttle
    - debounce
    - once
    - after
    - before
    - wrap
    - negate
    - compose

Objects

    - keys
    - allKeys
    - values
    - mapObject
    - pairs
    - invert
    - create
    - functions
    - findKey
    - extend
    - extendOwn
    - pick
    - omit
    - defaults
    - clone
    - tap
    - has
    - matcher
    - property
    - propertyOf
    - isEqual
    - isMatch
    - isEmpty
    - isElement
    - isArray
    - isObject
    - isArguments
    - isFunction
    - isString
    - isNumber
    - isFinite
    - isBoolean
    - isDate
    - isRegExp
    - isNaN
    - isNull
    - isUndefined

Utility

    - noConflict
    - identity
    - constant
    - noop
    - times
    - random
    - mixin
    - iteratee
    - uniqueId
    - escape
    - unescape
    - result
    - now
    - template

Chaining

    - chain
    - value

  */
  });

  var PREFIX = '/**' +  newLine() +
                'This is a wrapper around an Undersore.js function - see [[http://underscorejs.org/|the Underscore web site]] for complete' + newLine() + 
                'documentation on this function.'+ newLine() +
                '**/' + newLine();
  
  var TEMPLATE = PREFIX +
                'function map(args){return _Private._.map.apply(this, _Private._.toArray(arguments));}'
                
  var DELAY = bigString(function(){
                 /*
                    function delay(args){
                      var arArgs = _.toArray(arguments);
                      if (_.isFunction(arArgs[0])){
                        return _Private._.delay.apply(this, arArgs);
                      }
                      else {
                        var ms = arArgs[0];
                        if (arArgs.length > 1 ) {
                          aqUtils.Delay(ms, arArgs[1]);
                        }
                        else {
                          aqUtils.Delay(ms);
                        } 
                      }
                    }
                 */
              });
              
  var NOW =   bigString(function(){
                                    /*
                                    
                                     // This is a wrapper around an Undersore.js function - see [[http://underscorejs.org/|the Underscore web site]] for complete
                                     // documentation on this function.
                                     // Conflicts with datetime utils now
                                     //  function now(args){return _Private._.now.apply(this, _Private._.toArray(arguments));}
                                     
                                      */
                                 });

               

  function generateWrapper(functionName){
    return sameText(functionName, 'delay') ? PREFIX + DELAY : 
            sameText(functionName, 'now') ? NOW : 
            replace(TEMPLATE, 'map',  functionName); 
  }
  
  var funcs = _.chain(UNDERSCORE_FUNC_NAMES_FROM_WEB.split(newLine()))
                .map(trim)
                .filter(function(str){return hasValue(str) && startsWith(str, '-')})
                .map(function(str){return  trimChars(str, ['-', ' '])})
                .map(generateWrapper)
                .value()
                .join(newLine(2));
                
  var script = '//USEUNIT _Private' + newLine(3) + funcs;
  stringToTemp(script, '_.sj');
}

//
// test wrapping map
//
//function filter(args){
//  return _.filter.apply(this, _.toArray(arguments))
//}
//
//function value(args){
//  return _.value.apply(this, _.toArray(arguments))
//}
//
//function chain(args){
//  return _.chain.apply(this, _.toArray(arguments))
//}
//
//function mapEndPoint() {
//  var input = [1, 2, 3, 4, 5, 6 ,7 ,8 ,9 , 0];
//  
//  var out =  chain(input)
//              .filter(function(n){return n < 7})
//              .map(function(n){return n + 3;})
//              .value();
//  
//  log(out);
//
//}

function generateCreoleDocPage(projectFilePath, destDirectory){
  var destDirectory = def(destDirectory, combine(activeDataDir(), 'genDoc'));
  forceDirectory(destDirectory);
  var sourceInfo = extendedScriptInfo(projectFilePath);
  genDoc(sourceInfo, destDirectory);
}

function generateCreoleDocPageEndPoint() {
  generateCreoleDocPage(null, null);
}

// fills in missing documentation blocks with a stub
// CHECK IN BACK UP ALL FILES BEFORE RUNNING THIS ROUTINE !!!
// DOES AN IN PLACE EDIT ON SCRIPTS AND MAY CORRUPT THEM
function mergeDocs(params){
  var sourceProjectFilePath = params.sourceProjectFilePath,
  destProjectFilePath = params.destProjectFilePath,
  // used for testing rewrite source files to a different drive
  // rather than mutating
  destDirOverride  = params.destDirOverride;
  
  var destInfo = extendedScriptInfo(destProjectFilePath);
  var sourceInfo = hasValue(sourceProjectFilePath) ? 
                    extendedScriptInfo(sourceProjectFilePath):
                    null;
                    
  mergeDocumentationInfo(sourceInfo, destInfo, destDirOverride);
}



var MINOR_DIVIDER = '----';
var MAJOR_DIVIDER = '------';

var HEADER = ['<<Anchor(Top)>>',
              '<<Action(print,print mode)>>',
                newLine(),
                newLine(),
                "''This documentation is generated from source code. Do not update this page manually''",
                newLine(),
                newLine(),
                "~+'''Contents'''+~<<BR>>",
                newLine(),
                newLine()
                ];

var FOOTER = [newLine(),
              '[[#Top|Top]]'];

function genDoc(sourceInfo, destDirectory){
  var outPath = combine(destDirectory, 'apiDoc.creole.txt');
  
  // delete old File
  var info = aqFileSystem.DeleteFile(outPath);
  
  mergeDocumentationInfo(null, sourceInfo, '', false);
  
  var arBody = [];
  function updateToMoinMoinDoc(scriptInfo){
    Indicator.PushText('Generating Documentation for: ' + scriptInfo.name);
    var scriptDoc = translateDocumentationToMoinMoin(scriptInfo);
    arBody = arBody.concat(scriptDoc);
    Indicator.PopText();
  }
  
  var publicScripts = _.filter(sourceInfo, isPublicScript);
  var arContents = getFunctionsBlockContentsHeader(publicScripts);
  
  _.each(publicScripts, updateToMoinMoinDoc);
  
  
  Indicator.PushText('Putting result together');
  var result = HEADER
                .concat(arContents)
                .concat(arBody)
                .concat(FOOTER);
                
  Indicator.PopText();
  
  Indicator.PushText('Saving Creole file to: ' + outPath);
  arrayToFile(result, outPath);
  Indicator.PopText();
  
  logBold('Creole Documentation file written to: ' + outPath + '. Copy the content of this document into your wiki.')
}

function genDocEndPoint() {
  var sourceInfo = testScriptInfo(),
  destDirectory = 'C:\\genDoc';
  genDoc(sourceInfo, destDirectory)
}

function getFunctionsBlockContentsHeader(sourceInfo){
  
  function blockWithLinkHeader(scriptInfo){
    return getFunctionsBlock(scriptInfo, true);
  }
  
  var functionBlocks = _.chain(sourceInfo)
                        .map(blockWithLinkHeader)
                        .value();
                        
  var result = functionBlocks.join(newLine() + newLine());
  result =  stringToArray(result);
  result.push(MAJOR_DIVIDER);
  return result;
}

function getFunctionsBlockContentsHeaderEndPoint(){
  var sourceInfo = testScriptInfo();
  var result = getFunctionsBlockContentsHeader(sourceInfo);
}


function getFunctionsBlock(scriptInfo, wantScriptLinkHeader){
  var functions = getFunctionsToDocument(scriptInfo.functions);
  var funcionItems = _.map(functions,
                        function(funcInfo){
                          var funcName = funcInfo.name;
                          var result = aqString.format('[[#%s|%s]]', funcName, funcName); 
                          return result;
                        });
                    
   var result = funcionItems.join(' ~ ');
   
   var header = wantScriptLinkHeader ?
                  aqString.format("'''[[#%s|%s]]'''", scriptInfo.name, scriptInfo.name):
                  "'''Functions'''" + WIKI_BREAK;
   
   header = header + WIKI_BREAK +  newLine();
    
   result = header + result;              
   return result;                
}

function getFunctionsBlockEndPoint() {
   var sourceInfo = testScriptInfo();
   var sciptInfo = sourceInfo[0];
   var result  = getFunctionsBlock(sciptInfo, true);  
}

function getFunctionsToDocument(functions){
  return _.chain(functions)
        .filter(function(func){return !isEndPointOrUnitTestName(func.name)})
        .sortBy(function(func){return aqString.ToLower(func.name);})
        .value();
}

function translateDocumentationToMoinMoin(scriptInfo){
  var oldDoc = def(scriptInfo.updatedModuleDoc, scriptInfo.moduleDoc);
  var arResult = translateToMoinMoinModuleDoc(oldDoc, scriptInfo);

  function moinMoinTransFunctionDoc(funcInfo){
    var newDoc = translateToMoinMoinFunctionDoc(scriptInfo, funcInfo, funcInfo === lastFunction);
    arResult = arResult.concat(newDoc);
  }
  
  var publicFunctions = getFunctionsToDocument(scriptInfo.functions);
  var funcCount = publicFunctions.length;
  var lastFunction = funcCount > 0 ? publicFunctions[funcCount - 1] : null;
  _.each(publicFunctions, moinMoinTransFunctionDoc);
  
  return arResult;
}

var WIKI_BREAK = '<<BR>>';

function anchor(anchorName){
  return aqString.format("<<Anchor(%s)>>" + newLine(), anchorName); 
}

function translateToMoinMoinModuleDoc(oldDoc, scriptInfo){
  var TEMPLATE_TOP =  anchor(scriptInfo.name) +
                      "~-[[#Top|Top]]-~<<BR>>" + newLine() +
                      "~+'''!%s'''+~<<BR>><<BR>>";
  var FOOTER = MINOR_DIVIDER;
  
  TEMPLATE_TOP = aqString.format(TEMPLATE_TOP, scriptInfo.name);
  var arResult = stringToArray(TEMPLATE_TOP);
   
  var arOldDoc = stringToArray(oldDoc);
  oldDoc = getSection(arOldDoc, function(str){return hasText(str, 'Module Info');});
  arOldDoc = stringToArray(oldDoc);
  var arFunctionBlock = stringToArray(getFunctionsBlock(scriptInfo, false));
  
  // append all three arrays
  arResult.push.apply(arResult, arFunctionBlock);
  arResult.push.apply(arResult, arOldDoc);
  arResult.push(FOOTER);
  return arResult; 
}

function translateToMoinMoinModuleDocEndPoint() {
  var old = 
    '/** Module Info **' + newLine() + newLine() +
    '?????_NO_DOC_?????' + newLine() + newLine() + '**/';
  var result = translateToMoinMoinModuleDoc(old, {name: 'stringUtils'});
  log(arrayToString(result))
}

function translateToMoinMoinFunctionDoc(scriptInfo, functionInfo, atlast){
  var oldDoc = def(functionInfo.updatedDoc, functionInfo.documentation);
  oldDoc = trimChars(oldDoc,[' ' , newLine(), '/', '\\', '*'] );
  oldDoc = stringToArray(oldDoc);
  
  var sections = sectionise(oldDoc);
  
  var desc = sections.description;
  var params = sections.params;
  var returnInfo = sections.returnInfo;
  var related = sections.related;
  
  var arDesc = getFunctionHeaderAndDesc(functionInfo, desc, scriptInfo.name);
  var arParams = getParamStringArray(params);
  var arReturn = getReturnArray(returnInfo);
  var arExamples = getExamples(functionInfo.examples);
  var arRelated = translateRelated(scriptInfo.name, related);
  
  var result = 
      arDesc.concat(arParams)
            .concat(arReturn)
            .concat(arExamples)
            .concat(arRelated)
            .concat(atlast ? [MAJOR_DIVIDER] : [MINOR_DIVIDER]);
  
  return result;
}

function sectionise(arDocString){
  return {
     description: getSection(arDocString, function(){return true;}),
     params: getSection(arDocString, function(str){return hasText(str, '==') && hasText(str,  'params');}),
     returnInfo: getSection(arDocString, function(str){return hasText(str, '==') && hasText(str,  'return');}),
     related: getSection(arDocString, function(str){return hasText( str, '==') && hasText(str, 'related');})
  }   
}

function getFunctionHeaderAndDesc(functionInfo, desc, scriptName){
  var prmsStr = hasValue(functionInfo.params) ? _.map(functionInfo.params, function(prm){return prm.name}).join(', ') : '';
  var header = anchor(scriptName);
  header = header + "~+'''" + functionInfo.name + "'''+~" + '{{{      ' + functionInfo.name + '( ' + prmsStr + ' )}}}<<BR>>';
  desc = def(desc, '').split(newLine());
 
  function convertLineToItalic(str){
    var result = hasValue(trim(str)) ? trim(str) : '';
    result = trimChars(result, ' ', '\r');
    result = hasValue(trim(result)) ? " ''" + result + "''" : '';
    return result;
  }
  
  desc = _.map(desc, convertLineToItalic);
  var functionAnchor = anchor(functionInfo.name);
  return [functionAnchor, header].concat(desc); // result.reverse()
}

function getFunctionHeaderAndDescEndPoint() {
  var scriptInfo = {}
  scriptInfo.name = 'hasText';
  scriptInfo.params = ['p1', 'p2'];
  var desc = 'this function finds text in a string ' + newLine() + newLine() + 'some more info goes here ';
  log(getFunctionHeaderAndDesc(scriptInfo, desc).join(newLine()));
  desc = 'this function finds text in a string ' + newLine() + 'some more info goes here ';
  log(getFunctionHeaderAndDesc(scriptInfo, desc, 'SysUtils').join(newLine()));
}

function getExamples(egs){
  var result = _.map(egs, function(eg){
                            return ' {{{#!highlight javascript numbers=disable' + 
                                newLine() + eg +
                                newLine() +
                                  '}}}';});
  
 return  result.length > 0 ? 
          ['==== Examples ===='].concat(result) :
          [];
}

function getExamplesEndPoint() {
  var eg = 'function(){' + newLine() + 'stuff' + newLine() +'}';
  var result = getExamples([eg]);
  log(arrayToString(result));
}



function trimSubHeader(str, subHeader){
  str = subStrAfter(str, subHeader);
  str = subStrAfter(str, '==' +  newLine()); 
  return str;
}

function translateRelated(scriptName, related){
  var result = ['Top', scriptName].concat(stringToArray(related));
  result = _.chain(result)
              .map(function(str){return str.split(',');})
              .flatten()
              .map(function(str){return trim(str);})
              .filter(function(str){return hasValue(str);})
              .reject(function(str){return hasText(str, 'no_doc');})
              .map(function(str){return aqString.Format('[[#%s|%s]]', str, str)})
              .value();
              
   //==== See Also ====
 //[[#SysUtils|SysUtils]], [[#hasText|hastext]]
 return ["'''See Also'''<<BR>>", ' ' + result.join(', ')];

}

function translateRelatedEndPoint() {
  var related = '== Related ==' + newLine() + '?????_NO_DOC_?????';
  var result = translateRelated('StringUtils', related);
  log(arrayToString(result));
  
  related = '== Related ==' + newLine() + 'def, isNullorEmpty, hasValue';
  var result = translateRelated('StringUtils', related);
  log(arrayToString(result));
}


function getReturnArray(returnInfo){
  //DATA_TYPE_?????_NO_DOC_????? - DESCRIPTION_?????_NO_DOC_????? =>
  // ==== Returns ====
  // ''Object'': an object
  var result = '';
  returnInfo = trimChars(returnInfo, [' ', newLine()]);
  if (hasValue(returnInfo)){
    var arReturnInfo = returnInfo.split(' - ');
    arReturnInfo = _.reject(arReturnInfo,function(str){return !hasValue(trim(str));});
    var length = arReturnInfo.length;
    switch (length) {
      case 0: result = ''; 
        break;
      
      case 1 : result = ' ' + arReturnInfo[0]; 
        break;
      
      default : 
        var arDesc = arReturnInfo.slice(1);
        result = " ''" +  arReturnInfo[0] + "'': " + arDesc.join(newLine()); 
        break;
    }
  }
  result = hasValue(result) ? ["'''Returns'''<<BR>>", result] : [];
  return result;
}

function getReturnArrayEndPoint(){
  var str,
  result,
  logit = [];
  
    
  str = '== Return ==' + newLine() + 'returns the name of stuff'; 
  result = getReturnArray(str);
  logit = logit.concat(result);
  
  str = '== Return ==' + newLine() + 'DATA_TYPE_?????_NO_DOC_????? - DESCRIPTION_?????_NO_DOC_?????'; 
  result = getReturnArray(str);
  logit = logit.concat(result);
  
  str = '== Return ==' + newLine() + 'number - thisis a number'; 
  result = getReturnArray(str);
  logit = logit.concat(result);

  
  str = '== Return ==' + ''; 
  result = getReturnArray(str);
  logit = logit.concat(result);
  
  str = ''; 
  result = getReturnArray(str);
  logit = logit.concat(result);
  
  log(logit.join(newLine()));
}

function getParamStringArray(params){
  params = stringToArray(params);
 
  items = [];
  function addItem(str){
    if(hasValue(trim(str))){
      items.push(str);
    }
  }
 
  var thisStr = '';
  var length = params.length;
  for (var counter = 0; counter < length; counter++){
    var thisLine = params[counter];
    var words = thisLine.split(' ');
    if (words.length > 0 && endsWith(words[0], ':')){
      addItem(thisStr);
      thisStr = thisLine;
    } 
    else {
      thisStr = appendDelim(thisStr, newLine(), thisLine); 
    }
  }
  addItem(thisStr);

  var result;
  if (items.length > 0) {
    var header = "'''Parameters'''<<BR>>" + newLine() +
    "||<tablestyle=\"width: 80%;color: black\":>''Name'' ||<:>''Type''||<:>''Required or Optional''||<:>''Default''||<:>''Description''||"
    result = [header].concat(_.map(items, parseParamStr));
  }
  else {
    result = [];
  }
  
  return result;
}

function getParamStringArrayEndPoint() {
  var params = '== Params ==' + newLine() +
  'arr: DATA_TYPE_?????_NO_DOC_????? -  Required -  DESCRIPTION_?????_NO_DOC_?????' + newLine() +
  'filePath: DATA_TYPE_?????_NO_DOC_????? -  Required -  DESCRIPTION_?????_NO_DOC_?????' + newLine() +
  'encoding: DATA_TYPE_?????_NO_DOC_????? -  Optional -  Default: ?????_NO_DOC_????? -  DESCRIPTION_?????_NO_DOC_?????';
  
  
  var result = getParamStringArray(params); 
  log(result.join(newLine()));
  
  params = '== Params ==' + newLine() +
  'arr: array of strings -  Required -  the source array ' + newLine() +
  'filePath: String -  Required -  the path to the file' + newLine() +
  'encoding: TC File encoding type -  Optional -  Default: ecAnsi -  the eexpected file encoding';
  
  result = getParamStringArray(params); 
  log(result.join(newLine()));
}

function parseParamStr(str){
  //sourceFileNameNoPath: DATA_TYPE_?????_NO_DOC_????? -  Required -  DESCRIPTION_?????_NO_DOC_?????
  //destFileNameNoPath: DATA_TYPE_?????_NO_DOC_????? -  Required -  DESCRIPTION_?????_NO_DOC_?????
  //
  //filePath: DATA_TYPE_?????_NO_DOC_????? -  Required -  this is a flowing
  //multi-line description for file path
  //encoding: DATA_TYPE_?????_NO_DOC_????? -  Optional -  Default: ?????_NO_DOC_????? -  DESCRIPTION_?????_NO_DOC_?????

  var bits = bisect(str, ':');
  var name = bits.prefix;
  var arFields = _.map(bits.suffix.split(' - '), trim);
  
  var isDefaultField = function(str){return hasText(str, 'Default:')}
  var defaultVal = _.find(arFields, isDefaultField);
  arFields = _.reject(arFields, isDefaultField);
  defaultVal = trim(subStrAfter(defaultVal, ':'));
  var hasDefault = hasValue(defaultVal); 
  
  var isOptionalField = function(str){
    str = trim(str);
    return sameText('optional', str) || sameText('required', str); 
  }
  var optional = hasValue(defaultVal) ? 'Optional' : trim(def(_.find(arFields, isOptionalField), 'Required'));
  var isOptional = sameText(optional, 'Optional');
  defaultVal = !isOptional ? 'NA' : 
                hasDefault ? defaultVal : ' ';
  
  arFields = _.reject(arFields, isOptionalField);
  var desc = (arFields.length > 0) ? arFields[arFields.length - 1] : '';
  var dataType = (arFields.length > 1) ? arFields[0] : '';
  
  var resultStr = aqString.format('||%s||%s||%s||%s||%s||', name, dataType, optional, defaultVal, desc);
  return resultStr;
}

function translateToMoinMoinFunctionDocEndPoint() {
  var oldDoc = fileToString(testDataFile('testFunctionDocBlock.txt'));
  var funcInfo = {
    updatedDoc: oldDoc,
    name: 'copyFile'
  };
  
  var scriptInfo = { name: 'fileUtils' };
  translateToMoinMoinFunctionDoc(scriptInfo, funcInfo);
}

function getSection(oldDoc, secStartFunc){
  var result = [];
  var started = secStartFunc('');
  var length = oldDoc.length;
  for (var counter = 0; counter < length; counter++){
    var thisStr = oldDoc[counter];
    if(started){
      if (startsWith(trim(thisStr), '==')  ||  startsWith(trim(thisStr), '**/') ){
        break;
      }
      result.push(thisStr);
    }
    else {
      started = secStartFunc(thisStr) 
    }
  }
  return arrayToString(result);
}

function mergeDocumentationInfo(sourceInfo, destInfo, destDirOverride, wantRewrite){

  wantRewrite = def(wantRewrite, true);
  
  function getPublicScripts(info) {
   return hasValue(info) ?  
      _.filter(info, 
        function(script){return isPublicScriptName(script.name)}) 
      : null;
  }
  
  var publicSourceScripts = getPublicScripts(sourceInfo);
  var publicDestScripts = getPublicScripts(destInfo);
  
  function updateThisScriptDocumentation(scriptInfo){
    var sourceScript = hasValue(publicSourceScripts) ?
                        _.find(publicSourceScripts, function(scr){return sameText(scr.name, scriptInfo.name)}) :
                        null;
    updateDocumentationUsingSource(sourceScript, scriptInfo);
  }
  
  _.each(publicDestScripts, updateThisScriptDocumentation);
  
  function rewriteFileIfRequired(scriptInfo){
    if (wantRewrite) {
      doRewriteIfRequired(scriptInfo, destDirOverride);
    }
  }
  
  _.each(publicDestScripts, rewriteFileIfRequired);
}

function testScriptInfo(){
  var file = testDataFile('parsedInfoPlusExamples.txt'),
  txt = fileToString(file),
  target = JSON.parse(txt);
  return target;
}

function mergeDocumentationInfonEndPoint() {
  var target = testScriptInfo()
  mergeDocumentationInfo(null, target, 'C:\\Rewrite');
}

function updateNeeded(updateAction){
  return updateAction === INSERT_FROM_SOURCE ||
    updateAction === INSERT_FROM_GENERATED ||
    updateAction === REPLACE_WITH_SOURCE;
}

function logNeeded(updateAction){
  return updateAction === LOG_DIFFERENCE;
}


function doRewriteIfRequired(scriptInfo, destDirOverride){
  var functions = scriptInfo.functions;
  var updateRequired = updateNeeded(scriptInfo.moduleDocumentationUpdateAction) ||
    _.find(functions, function(funcInfo){return updateNeeded(funcInfo.documentationUpdateAction)});
    
  if (updateRequired){
    var srcFilePath = scriptInfo.path;
    var destFilePath = hasValue(destDirOverride) ? combine(destDirOverride, aqFileSystem.GetFileName(srcFilePath)) : srcFilePath;
    var arText = fileToArray(srcFilePath);
    var fileStr = getUpdatedFileString(arText, scriptInfo);
    stringToFile(fileStr, destFilePath);
  }
  
  var changedFunctions = _.filter(functions, function(funcInfo){return logNeeded(funcInfo.documentationUpdateAction)}); 
  var moduleDocChanged = logNeeded(scriptInfo.moduleDocumentationUpdateAction)
  var logRequired = moduleDocChanged || changedFunctions.length > 0;
  
  if (logRequired){
    var message = moduleDocChanged ? 'Module Documentation Changed' + newLine() : '';
    var changedFunctionNames = _.map(changedFunctions, function(funcInfo){return funcInfo.name;});
    message = appendDelim(message, newLine(), arrayToString(changedFunctionNames));
    log(scriptInfo.name + ' Changed documentation detected - manual merge may be required.', message);
  }
}

function getUpdatedFileStringGeneric(arText, scriptInfo, updateNeededFunc){
  // do functions fist from bottom up so don't corrupt line number
  
  var strResult = '',
  cursorPos = arText.length - 1;
  
  function updateFunctionDocs(functionInfo){
    var arThisStretch = [];

    for (var counter = cursorPos; counter >= functionInfo.lineNo; counter--){
      arThisStretch.push(arText[counter])
      cursorPos = counter - 1;   
    }
    
    if (updateNeededFunc(functionInfo.documentationUpdateAction)){
      var startEnd = getStartEndDocLines(functionInfo.lineNo, arText);
      if (startEnd.startDocLine > 0){
        cursorPos = startEnd.startDocLine - 1;
      }
      var arNewDoc = stringToArray(functionInfo.updatedDoc);
      for (var i = arNewDoc.length - 1; i > -1 ; i--){
        arThisStretch.push(arNewDoc[i]);     
      } 
    }
    
    arThisStretch.reverse();
    strResult = arrayToString(arThisStretch) + newLine() + strResult;
  }
  
  // sort in descending order by line number
  var functions = _.sortBy(scriptInfo.functions, function(func){return func.lineNo * -1});
  
  _.each(functions, updateFunctionDocs);
  
  // do module doc and 
  var arTopOfFile = [];
  var moduleUpdateNeeded = updateNeededFunc(scriptInfo.moduleDocumentationUpdateAction);
  var moduleUpdated = false;
  for (var j = 0; j <= cursorPos ; j++){
    var thisLine = arText[j];
    if (moduleUpdateNeeded && !moduleUpdated && !startsWith(thisLine, '//USEUNIT')){
      arTopOfFile.push(newLine());
      arTopOfFile.push(scriptInfo.updatedModuleDoc);
      arTopOfFile.push(newLine());
      moduleUpdated = true;
    }
    arTopOfFile.push(thisLine);   
  }
   
  strResult = arrayToString(arTopOfFile) + strResult;
  return strResult;
}

function getUpdatedFileString(arText, scriptInfo){
  return getUpdatedFileStringGeneric(arText, scriptInfo, updateNeeded);
}

function updateDocumentationUsingSource(sourceScriptInfo, destScriptInfo){
  Indicator.PushText('Updating in memory documentation for: ' + destScriptInfo.name);
  
  var arContent = fileToArray(destScriptInfo.path);
  var destModuleDocString = getModuleDocString(arContent);
  
  var arSourceContent = null,
  srcModuleInfo = null;
  var srcModuleModuleDocString = '';
  if (hasValue(sourceScriptInfo)) {
    arSourceContent = fileToArray(sourceScriptInfo.path);
    srcModuleModuleDocString = getModuleDocString(arSourceContent);
    addDocumentationTextToFunctionInfo(sourceScriptInfo.functions, arSourceContent);
  }
  
  addDocumentationTextToFunctionInfo(destScriptInfo.functions, arContent);
  updateDocumentationAndUpdateRequiredFlag(srcModuleInfo, destScriptInfo, srcModuleModuleDocString, destModuleDocString);

  // add module info under uses 
  
  Indicator.PopText();
}

var NO_ACTION = 0,
    INSERT_FROM_SOURCE = 1,
    INSERT_FROM_GENERATED = 2,
    REPLACE_WITH_SOURCE = 3,
    LOG_DIFFERENCE = 4;
    
var NOT_DOCUMENTED_TOKEN = '?????_NO_DOC_?????';

function isDocumented(str) {
  return hasValue(str) && !hasText(str, NOT_DOCUMENTED_TOKEN);  
}
  
function calculatedRequiredDocAction(srcStr, dstStr){
  var result =  
          isDocumented(dstStr) ?
            isDocumented(srcStr) ?
              sametext(srcStr, dstStr) ? NO_ACTION : LOG_DIFFERENCE 
            :
              NO_ACTION
          : // dest string not documented
            isDocumented(srcStr) ? INSERT_FROM_SOURCE : INSERT_FROM_GENERATED;
    
   // update insert => replace if there is already documentation in dest        
   if (hasValue(dstStr)) {
    result =  result === INSERT_FROM_SOURCE ? REPLACE_WITH_SOURCE :
              // don't replace pre generated code in dest with newly generated code 
              result === INSERT_FROM_GENERATED ? NO_ACTION :
              result;
   } 
   
   return result;  
} 

function calculatedRequiredDocActionUnitTest(){
  var srcStr, dstStr, result;
  
  srcStr = '';
  dstStr = '';
  result = calculatedRequiredDocAction(srcStr, dstStr);
  checkEqual(INSERT_FROM_GENERATED, result);
  
  srcStr = '';
  dstStr = 'fdfdsf';
  result = calculatedRequiredDocAction(srcStr, dstStr);
  checkEqual(NO_ACTION, result);
  
  srcStr = 'hh';
  dstStr = 'fdfdsf';
  result = calculatedRequiredDocAction(srcStr, dstStr);
  checkEqual(LOG_DIFFERENCE, result);
  
  srcStr = 'hh';
  dstStr = '';
  result = calculatedRequiredDocAction(srcStr, dstStr);
  checkEqual(INSERT_FROM_SOURCE, result);
  
  srcStr = 'hh';
  dstStr = NOT_DOCUMENTED_TOKEN;
  result = calculatedRequiredDocAction(srcStr, dstStr);
  checkEqual(REPLACE_WITH_SOURCE, result);
  
  srcStr = NOT_DOCUMENTED_TOKEN;
  dstStr = NOT_DOCUMENTED_TOKEN;
  result = calculatedRequiredDocAction(srcStr, dstStr);
  checkEqual(NO_ACTION, result);
}   

function updateDocumentationAndUpdateRequiredFlag(srcModuleInfo, destScriptInfo, srcModuleModuleDocString, destModuleDocString){
  srcModuleModuleDocString = def(srcModuleModuleDocString, '');
  var arLog = [];
  var moduleDocAction = calculatedRequiredDocAction(srcModuleModuleDocString, destModuleDocString);
  var BLANK_MODULE_DOC = '/** Module Info **' +  newLine() + newLine() + NOT_DOCUMENTED_TOKEN + newLine() + newLine() + '**/'

  // work out what to do with module documentation
  destScriptInfo.moduleDocumentationUpdateAction = moduleDocAction;
  switch (moduleDocAction) {
    case NO_ACTION: destScriptInfo.moduleDoc = destModuleDocString;
      break;
      
    case INSERT_FROM_SOURCE, 
          REPLACE_WITH_SOURCE, 
          LOG_DIFFERENCE: destScriptInfo.updatedModuleDoc = srcModuleModuleDocString;
      break;
      
    case INSERT_FROM_GENERATED: destScriptInfo.updatedModuleDoc = BLANK_MODULE_DOC;
      break;
      
    default: 
      logError('Unhandled module documentation action: ' + moduleDocAction);
  }
  
  function setUpdateActionAndValue(funcInfo){
    var dstDoc = funcInfo.documentation;
    var srcDoc = '';
    if (hasValue(srcModuleInfo)){
      var srcFunc = _.find(srcModuleInfo.functions, function(srcFuncInfo){return funcInfo.name === srcFuncInfo.name})  
      srcDoc = hasValue(srcFunc) ? srcFunc.documentation : ''; 
    }
    
    funcInfo.documentationUpdateAction = calculatedRequiredDocAction(srcDoc, dstDoc);
    switch (funcInfo.documentationUpdateAction) {
      case NO_ACTION: // do nothing
        break;
      
      case INSERT_FROM_SOURCE, 
            REPLACE_WITH_SOURCE, 
            LOG_DIFFERENCE: funcInfo.updatedDoc = srcDoc;
        break;
      
      case INSERT_FROM_GENERATED: funcInfo.updatedDoc = generateFunctionDocStub(funcInfo);
        break;
      
      default: 
        logError('Unhandled module documentation action: ' + moduleDocAction);
    }
  }
  
  // work out what to do with documentation of each function
  _.each(destScriptInfo.functions, setUpdateActionAndValue);
}

function generateFunctionDocStub(funcInfo){
  var TEMPLATE_HEADER =
    '/**' + newLine() + newLine() + NOT_DOCUMENTED_TOKEN + newLine() ; 
    
  var TEMPLATE_FOOTER = '== Related ==' +  newLine() + NOT_DOCUMENTED_TOKEN + newLine() + '**/'  

  return TEMPLATE_HEADER + 
      newLine() +
      paramsDocStr(funcInfo.params) + 
      returnDocString(funcInfo) +
      TEMPLATE_FOOTER;
}

function generateFunctionDocStubEndPoint() {
  var func = {
    name: 'threeParams',
    hasResult: false,
    params: [
      {name:'p1', markedOptional: false, defaultVal: '5'},
      {name:'p2', markedOptional: false},
      {name:'p2', markedOptional: true}
    ]
  }
  
  var result = generateFunctionDocStub(func);
  
  func.hasResult = true;
  result = generateFunctionDocStub(func);
}

function  returnDocString(funcInfo){
  return funcInfo.hasResult ?
    '== Return ==' +  newLine() + 'DATA_TYPE_' + NOT_DOCUMENTED_TOKEN + ' - ' +  
    'DESCRIPTION_'+ NOT_DOCUMENTED_TOKEN + newLine() :
    '';  
}

function paramsDocStr(params){
  var paramStrs = _.map(params, function (param){
    var result = param.name + ': ' + 'DATA_TYPE_' + NOT_DOCUMENTED_TOKEN + ' - ' + 
      (param.markedOptional || hasValue(param.defaultVal) ? ' Optional' : ' Required') + ' - ' +  
      (hasValue(param.defaultVal) ? ' Default: ' + param.defaultVal + ' - ' :
        param.markedOptional ? ' Default: ' + NOT_DOCUMENTED_TOKEN + ' - ' : '') +
      ' DESCRIPTION_'+ NOT_DOCUMENTED_TOKEN;  
    return result;
  })
  
  return (paramStrs.length > 0) ? '== Params ==' + newLine() + arrayToString(paramStrs) + newLine() : '';
}
function paramsDocStrEndPoint() {
  var params = [
      {name:'p1', markedOptionalAsOptional: false, defaultVal: '5'},
      {name:'p2', markedOptional: false},
      {name:'p2', markedOptional: true}
    ];
  var result =  paramsDocStr(params);
}

function getStartEndDocLines(funcHeaderLineNo, arContent){
    var lineNo = funcHeaderLineNo;
    
    var result = {
      startDocLine: -1,
      endDocLine: -1
    }
    
    for (var counter = lineNo - 1; counter > -1; counter--){
      var line = arContent[counter];
      var inBlock = result.endDocLine > -1;
      if (inBlock) {
        if (isDocBlockStartLine(line)){
          // reset the result for function doc to [] if we have been reading a module 
          // document block
          if (isModuleDocBlockStartLine(line)) {
            result.startDocLine = -1;
            result.endDocLine = -1;
          }
          result.startDocLine = counter;
          break;
        }
      }
      else if (isDocBlockEndLine(line)) {
        result.endDocLine = counter;
      } 
      else {
        line = trim(line);
        if (hasValue(line)){
          break;
        }
      }
    }
    
    return result;

}

function addDocumentationTextToFunctionInfo(arFunctions, arContent){
  function addDocText(funcInfo){
    if (hasText(funcInfo.name, 'wild')){
    delay(1); 
    }
    var lineNo = funcInfo.lineNo;
    var arResult = [];
    var docBlockBounds = getStartEndDocLines(lineNo, arContent);
    var startBlockLine = docBlockBounds.startDocLine;
    var endBlockLine = docBlockBounds.endDocLine;
    
    if (startBlockLine > -1 && endBlockLine > -1 ){
      for (var counter = startBlockLine; counter <= endBlockLine; counter++){
        arResult.push(arContent[counter])    
      }
    }
    
    funcInfo.documentation = arrayToString(arResult);
  }

  _.each(arFunctions, addDocText);
}

function addDocumentationTextToFunctionInfoUnitTest() {
  var destProjectFilePath = testDataFile('ProjectSuiteForReflectionTesting\\TestProjectForreflectionTesting\\TestProjectForreflectionTesting.mds')
  var target = extendedScriptInfo(destProjectFilePath);
  var script1Info = target[0];
  var arFunctions = script1Info.functions;
  var arContent = fileToArray(script1Info.path);
  addDocumentationTextToFunctionInfo(arFunctions, arContent);
  
  checkEqual(script1Info.functions[0].documentation, '', 'the top function is not documented');
  var funcsWithDocs = _.filter(script1Info.functions, function (funcInfo){return hasValue(funcInfo.documentation)});
  var funcsWithDocsName = _.map(funcsWithDocs, function(funcInfo){return funcInfo.name;});
  checkEqual(['testScriptFuncParamsNested','shouldBeListed'], funcsWithDocsName);
}

function getModuleDocString(arContent){
  var length = arContent.length;
  var inModuleInfo = false;
  var result = [];
  for (var counter = 0; counter < length; counter++){
    var line = arContent[counter];
    if (inModuleInfo){
      if (isDocBlockEndLine(line)){
        break;
      }
      else {
        result.push(line);   
      }
    }
    else {
      inModuleInfo = isModuleDocBlockStartLine(line);  
    }
  }
  return arrayToString(result);
}

function getModuleDocStringUnitTest() {
  var path = testDataFile('TestScript1.sj');
  var arContent = fileToArray(path);
  var result = getModuleDocString(arContent);
  checkContains('because I say so', result);
}

function isModuleDocBlockStartLine(line){
  str = trim(line);
  return isDocBlockStartLine(str) && hasText(line, 'module') ;
}

function isDocBlockStartLine(line){
  line = trim(line);
  return startsWith(line, '/**');
}

function isDocBlockEndLine(line){
  line = trim(line);
  return endsWith(line, '**/');
}