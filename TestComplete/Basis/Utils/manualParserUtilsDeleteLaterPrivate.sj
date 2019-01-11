//USEUNIT StringUtils
//USEUNIT SysUtils
//USEUNIT CheckUtils
//USEUNIT _
//USEUNIT FileUtils

function parseTradeAutomationTestPlans(){
  var PARENT_DIR = 'C:\\Automation\\Docs\\TradeAutomation\\TestPlans';
  eachFile(PARENT_DIR, null,  false, makeManualTest);
}

function makeManualTestExcel(sourceFile){
  log('processing file: ' + sourceFile);
  var source = tokeniseManualTest(fileToString(sourceFile));
  toTemp(source, 'testTokens.json');
  var excelTokens = testTokensToExcelTokens(source);
  toTemp(excelTokens, 'excelTokens.json');
  excelTokensToExcel(makeManualTestExcel);
}

function makeManualTestExcelEndPoint() {
  var source = testDataFile('manualExample.txt');
  makeManualTestExcel(source);
}

function excelTokensToExcel(excelTokens){

}

function testTokensToExcelTokens(testTokens){
  var result = _.chain(testTokens.testSections)
                .map(combineTitles)
                .pluck('tests')
                .flatten()
                .map(convertToExcelColumns)
                .value();
  
  return result;
}

function testTokensToExcelTokensEndPoint(){
  var src = fromTemp('testTokens.json');
  var result = testTokensToExcelTokens(src);
  toTemp(result, 'excelTokens.json');
}

function convertToExcelColumns(test){
  var header = {
    'Subject (Project Name)': 'Trade Automation',
    'Test Case Name': test.title,
    'Test Objective': 'verify that when ' + test.when + newLine() + 'then ' + test.then,
    'Test Description': null,
    'Test Data': '',
    'Expected Result': null,
    'Actual Results': '',
    'PASS/FAIL': '',
    Comments: ''
  };
  
  var stepBase = _.extend(_.clone(header), {
                                        'Subject (Project Name)': '',
                                        'Test Case Name': '',
                                        'Test Objective': ''
                                      });
  
  function setPropsFromGrouped(target, grouped){
    target['Test Description'] = grouped.instructions,
    target['Expected Result'] = grouped.validations;
    return target;
  }
  
  function newStep(grouped){
    var result = _.clone(stepBase);
    setPropsFromGrouped(result, grouped)
    return result;
  }
                                      
  var groupedInstructions = _.reduce(test.steps, groupInstructions, {
                                                        lastWasValidation: true,
                                                        result: []
                                                      });
  
  function joinText(excelStep){
    return {
            instructions: _.flatten(excelStep.instructions).join(newLine()),
            validations: _.flatten(excelStep.validations).join(newLine())
          };
  }
  var grouped = _.map(groupedInstructions.result, joinText);
  
  var first = _.first(grouped),
      steps = _.rest(grouped);
      
  result = [setPropsFromGrouped(header, first)].concat(_.map(steps, newStep)); 
  return result;                                                  
}

function groupInstructions(accum, item){
  var target;                        
  var isStep = sameText(item.type, 'step');
  if (isStep && accum.lastWasValidation){
    target = {
                  instructions: [],
                  validations: []
                };
    accum.result.push(target);
  }
  else {
    target = _.last(accum.result);
  }
  accum.lastWasValidation = !isStep;
  
  if (isStep) {
    target.instructions.push(item.text);
  }
  else {
    target.validations.push(item.text);
  }
  
  return accum;
}

function combineTitles(sec){
  var sectionName = trim(sec.sectionName);
  function updateTitle(test){
    test.title = sectionName + ' - ' + trim(test.title);
    return test;
  }
  sec.tests = _.map(sec.tests, updateTitle);
  return sec;
}

function makeManualTest(sourceFile){
  log('processing file: ' + sourceFile);
  var source = tokeniseManualTest(fileToString(sourceFile));
  var parsedText = testTokensToText(source);
  toTempString(parsedText, aqFileSystem.GetFileNameWithoutExtension(sourceFile) + '_steps.txt');
}

function makeManualTestEndPoint() {
  var source = testDataFile('manualExample.txt');
  makeManualTest(source);
}

function testTokensToText(tokens){
  var lines = _.chain(tokens)
                .map(tokenToLine)
                .reject(isNull)
                .value();

  return trimWhiteSpace(lines.join(newLine(2)));
}

function testTokensToTextEndPoint() {
  var tokens = fromTemp("parsed.json");
  var text = testTokensToText(tokens);
  toTempString(text, 'TestText.txt');
}

function tokenToLine(token, tokenType){
  var result =  sameText(tokenType, 'header') ?
                  headerToText(token):
                sameText(tokenType, 'testSections') ?
                  testSectionsToText(token):
                'UNKNOWN TOKEN'; 
  return trimWhiteSpace(result);
}

function testSectionsToText(sections){
  return _.map(sections, sectionToText).join(newLine(2));
}

function sectionToText(section){
  var result = newLine() + subHeader(section.sectionName);
  if (hasValue(section.header)){
    var header = headerToText(section.header, true);
    if (hasValue(header)){
      result = result + newLine(2) + header;  
    }
  }
 
  result = result + newLine(2) + _.map(section.tests, testToText).join(newLine(2));
  return result;
}

function testToText(test){
 var result = minorHeader(test.title) + newLine() +
            'id: ' +  test.id + newLine() +
            'when: ' +  test.when + newLine() +
            'then: ' +  test.then + newLine() +
            'specIds: ' + test.specIds + newLine() +
            'steps:' + newLine() + _.map(def(test.steps, []), stepText).join(newLine());
 return result;        
}

function stepText(step){
  function indentIt(str){
    return indent(str, step.indent + 1);
  }
 
  var lines = step.text;
  if (lines.length > 0){
    lines[0] = (sameText(step.type, 'step') ? '# ' : '=> ') + lines[0];
  }
  var steps = _.map(lines, indentIt);
  var txt = steps.join(newLine());
  return txt;
}

function indent(str, count){
  str = def(str, '');
  var tab = repeatString('\t', def(count, 1))
 
  function tabOut(str){
    return tab + str;
  }
 
  return _.map(str.split(newLine()), tabOut).join(newLine());
}

function headerToText(token, isInTestSection){
  var result = '',
      displayTitle = {
            setUp: "Set Up",
            text: "Background"
        };
 
  function addLine(text, title){
    if (hasValue(text)){
      title = def(displayTitle[title], 'UNKNOWN PROPERTY !!!!!!');
      var thisResult = isInTestSection ? minorHeader(title) : header(title);
      thisResult = thisResult + newLine() + indent(text);
      result = appendDelim(result, newLine(2), thisResult);
    }
  }

  _.each(token, addLine);
  return hasValue(result) ? result: null;
}

function header(str){
  return '=== ' + str + ' ===';
}

function subHeader(str){
  return '==== ' + str + ' ====';
}

function minorHeader(str){
  return '--- ' + str + ' ---';
}

function tokeniseManualTest(sourceText){
  var result = standardiseLineEndings(def(sourceText, '')).split(newLine());
  result = splitIntoSections(result);
  result = parseSections(result);
  return result.testCases
}

function tokeniseManualTestEndPoint() {
  var result = tokeniseManualTest(tempString('Web Aged Trade Balance Submission Interface Test Plan.txt'));
  toTemp(result, 'parsed.json');
}

function CONSTANTS_SECTION(){return 'Constants';}

function SNIPPETS_SECTION(){return 'Snippets';}

function TEST_CASES_SECTION(){return 'Test Cases';}

function ALL_SECTIONS(){return [CONSTANTS_SECTION(), SNIPPETS_SECTION(), TEST_CASES_SECTION()];}

function parseSection(accum, thisSec){
  var sectionType = thisSec.section;
  if (hasText(sectionType, CONSTANTS_SECTION())){
    accum.vars = parseConstants(thisSec.children, accum.vars);
  }
  else if (hasText(sectionType, SNIPPETS_SECTION())){
    accum.vars = parseSnippets(thisSec.children, accum.vars);
  }
  else if (hasText(sectionType, TEST_CASES_SECTION())){
    accum.testCases = parseTestCases(thisSec.children, accum.vars);
  }
  return accum;
}

function parseTestCases(testCases, vars){
 //toTemp(testCases, 'parseTestCasesCases.json');
 //toTemp(vars, 'parseTestCasesVars.json');
 
  function sectionVarSubstitution(section){
    return sectionVarSubstitutionWithVars(section, vars)
  }
 
  function makeHeader(section){
    section.header = tokeniseHeader(section.header);
    return section;
  }
 
  var headerAndLines = splitOffHeader(testCases);
  var testCaseHeader = tokeniseHeader(headerAndLines.header);
  testCaseHeader.text = substituteVars(testCaseHeader.text);
  var lines = headerAndLines.lines;
  var sections = splitTestSections(lines);
  var sections = _.chain(sections)
                  .map(splitTestHeaders)
                  .map(splitTests)
                  .map(tokeniseTests)
                  .map(makeHeader)
                  .map(sectionVarSubstitution)
                  .map(omitLines)
                  .map(transformSteps)
                  .value();
 
  var result = {
    header: tokeniseHeader(headerAndLines.header),
    testSections: sections
  }
 
  //toTemp(result, 'testsStuff.json');
  return result;
}

function transformSteps(section){
  var tests = section.tests;
  section.tests = _.map(tests, updateSteps);
  return section;
}

function updateSteps(test){
  var stepLines = test.steps.split(newLine());
  test.steps = tokeniseStepLines(stepLines);
  return test;
}

function parseTestCasesEndPoint() {
  // up to here debug this check_valid_upload_extension not being applied - header not being substituted
  var testCases = fromTemp('parseTestCasesCases.json'),
      vars = fromTemp('parseTestCasesVars.json');
     
  var result = parseTestCases(testCases, vars);
  toTemp(result, 'parsedTextcasesResult.json');
}

function omitLines(section){
  function linesBeGone(test){
    return _.omit(test, 'lines');
  }
 
  section.tests = _.map(section.tests, linesBeGone);
  return _.omit(section, 'lines');
}

function substituteHeaderVars(header, vars){
  var result = header;
  result.setUp = substituteVars(result.setUp, vars);
  result.text = substituteVars(result.text, vars);
  return result;
}

function sectionVarSubstitutionWithVars(section, vars){
  function testVarSubstitution(test){
    return testVarSubstitutionWithVars(test, vars);
  }

  section.header = substituteHeaderVars(section.header, vars);
  section.tests = _.map(section.tests, testVarSubstitution);
  return section;
}

function subVarsOnProperty(obj, prop, vars){
  obj[prop] = substituteVars(obj[prop], vars);
}

function testVarSubstitutionWithVars(test, vars){
  subVarsOnProperty(test, 'when', vars);
  subVarsOnProperty(test, 'then', vars);
  subVarsOnProperty(test, 'steps', vars);
  return test;
}

function createHeaderObject(arHeader){
  var result = {
                  setUp: null,
                  text: null
                };
               
  function processHeaderLine(accum, line){
    var result = accum;
    if (hasText(line, SET_UP())) {
      ensure(!hasValue(result.text), 'Setup should be the first element of the header');
      result.setUp = [];
      var instructions = trimWhiteSpace(subStrAfter(line, SET_UP()));
      if (hasValue(instructions)){
        result.setUp.push(subStrAfter(line, SET_UP()));
      }
    }
    else {
      var isEmptyLine = !hasValue(trimWhiteSpace(line));
      var isSetupDelimitingLine = hasValue(result.setUp) && isEmptyLine && !hasValue(result.text);
      if ((!isEmptyLine && !hasValue(result.setUp) && !hasValue(result.text)) || isSetupDelimitingLine){
        result.text = [];      
      }
     
      if (hasValue(result.text)){
        result.text.push(line);
      }
      else if (hasValue(result.setUp)){
        result.setUp.push(line);
      }
    }
    return result;
  }
               
  result = _.reduce(arHeader, processHeaderLine, result);
 
  function toText(lines){
    return  hasValue(lines) && lines.length !== 0 ? lines.join(newLine()) : null; 
  }         
  result.text = toText(result.text); 
  result.setUp = toText(result.setUp);    
  return result;

}

function tokeniseHeader(arHeader){
  var result =  {
                  setUp: null,
                  text: null
                }
  if (arHeader.length > 1 || (arHeader.length === 1 && hasValue(trimWhiteSpace(arHeader[0])))){
    result = createHeaderObject(arHeader);
  }
  return result;
}

function tokeniseHeaderEndPoint() {
  var header, result;
  header = [
                "setUp: ",
                "\t# insert_update_initial_user_via_sql",
                ""
            ];
  result = tokeniseHeader(header);
  header = [
                ""
            ];
  result = tokeniseHeader(header);
}

function tokeniseSectionHeader(section){
  section.header = tokeniseHeader(section.header);
  return section;
}

function tokeniseTests(section){
  section.tests = _.map(section.tests, tokeniseSingleTest)
  return section;
}

function tokeniseSingleTest(test){
  var str = test.lines.join(newLine());
  var steps = getSteps(test.lines);
  var result = {
    title: test.title,
    id: subStrBetween(str, 'id:', newLine()),
    when: subStrBetween(str, 'when:', newLine() + 'then:'),
    then: subStrBetween(str, 'then:', newLine() + 'specIds:'),
    specIds: subStrBetween(str, 'specIds:', newLine() + 'steps:'),
    steps: steps
  }
 
  function ensurehasVal(key){
    var val = result[key];
    ensure(hasValue(trimWhiteSpace(val)), 'Problem with test no ' + key + newLine() + str);
  }
 
  _.chain(result)
    .keys()
    .each(ensurehasVal);
   
  return result;
}

function getSteps(testLines){
  //toTemp(testLines, 'testLines.json');
  var idx = _.indexOf(testLines, STEPS());
  ensure(idx > -1, 'no steps header');
  var stepLines = testLines.slice(idx + 1);
  return stepLines.join(newLine());
}

function tokeniseStepLines(stepLines){
  var result = _.reduce(stepLines, tokeniseStepLine, {steps: [], active: null});
  return result.steps;
}

function getStepsEndPoint() {
  var lines = fromTemp('testLines.json');
  var result = getSteps(lines);
  toTemp(result, 'getStepsResult.json')
}

function tokeniseStepLine(accum, line){
  var trimmed = trimWhiteSpace(line);
  if (startsWith(trimmed, STEP_TOKEN())){
    updateActive('step', accum, line);
  }
  else if (startsWith(trimmed, CHECK_TOKEN())){
    updateActive('check', accum, line);
  }
  else if (!hasValue(accum.active)){
    updateActive('text', accum, line);
  }
  else {
    appendActive(accum, line);
  }
  return accum;
}

function appendActive(accum, line){
  var prefix = getPrefixIndentation(line, accum.active.indent);
  var updatedLine = prefix + trimWhiteSpace(line);
  accum.active.text.push(updatedLine)
  return accum;
}

function trimFirstLine(line, indent){
 
  var base = line
  do {
    old = base;
    base = trim(trimChars(trimWhiteSpace(old), [STEP_TOKEN()]));
    if (startsWith(base, CHECK_TOKEN())){
      base = subStrAfter(base, CHECK_TOKEN());
    }
  } while (old !== base);

  var prefix = getPrefixIndentation(line, indent);
  var result = prefix + base;
  return result;
}

function getPrefixIndentation(line, indent){
  var indent = countTabs(line) - countTabs(line, indent);
  var prefix = indent > 0 ? Array(indent + 1).join("\t"): '';
  return prefix;
}

function updateActive(itemType, accum, line){
  var indent = countTabs(line);
  var nextItem = {
    type: itemType,
    indent: indent,
    text: [trimFirstLine(line, indent)]
  }
  accum.active = nextItem;
  accum.steps.push(accum.active);
}

function countTabs(line, limit){
  var result = 0;
  if (hasValue(line)){
    var counter = 0,
        limit = def(limit, line.length);
   
    while (counter < limit && line.charAt(counter) === '\t') {
      result++;
      counter++;
    }
  }
  return result;
}

function countTabsEndPoint(){
  var str = '\t\t\t blahh';
  checkEqual(3, countTabs(str));
  checkEqual(2, countTabs(str, 2));
  checkEqual(0, countTabs(''));
}

function splitTestHeaders(section){
  var lines = section.lines;
  var result = splitOffHeader(lines);
  result.sectionName = section.sectionName;
  return result;
}

function accumTest(accum, line){
  if (startsWith(line, TEST_START())){
    var title = trim(subStrBetween(line, TEST_START(), '-'));
    accum.push(
      {
        title: title,
        lines: []
      }
    )  
  }
  else {
    ensure(accum.length > 0, 'Tests must start with a test declaration');
    var thisTest = _.last(accum);
    thisTest.lines.push(line);
  }
  return accum;
}

function splitTests(section){
  var lines = section.lines;
  var tests = _.reduce(lines, accumTest, []);
  section.tests = tests;
  return section;
}

function TEST_START(){return '--- ';}

function SECTION_START(){return '==== ';}

function ID(){return 'id:';}

function WHEN(){return 'when:';}

function THEN(){return 'then:';}

function STEPS(){return 'steps:';}

function SET_UP(){return 'setUp:';}

function SPEC_IDS(){return 'specIds:';}

function STEP_TOKEN(){return '#'}

function CHECK_TOKEN(){return '=>'}

function splitTestSections(lines){

  function pushSectionLine(accum, line){
    if (startsWith(line, SECTION_START())){
      var name = trim(subStrBetween(line, SECTION_START(), '='));
      accum.push({
        sectionName: name,
        lines: []
      })
    }
    else {
      ensure(accum.length > 0, 'Test cases must be contained in a section - section without test cases found in the following text - ' +
        lines.join(newLine()));
       
      var sec = _.last(accum);
      sec.lines.push(line);
    }
    return accum;
  }
 
  var result = _.reduce(lines, pushSectionLine, []);
  return result;
}

function splitOffHeader(lines){
  var result = {
    header: [],
    lines: []
  }
 
  function addLine(accum, thisLine){
    inHeader = accum.inHeader && !startsWith(thisLine, TEST_START())
                              && !startsWith(thisLine, SECTION_START());
    if (inHeader){
      accum.result.header.push(thisLine);
    }
    else {
      accum.result.lines.push(thisLine);
    }
    accum.inHeader = inHeader;
    return accum;
  }
 
 
  var parts = _.reduce(lines, addLine, {
                            result: result,
                            inHeader: true
                            });
                           
  return parts.result;

}

function parseSnippets(arStepLines, vars){
  function addApplyVars(vars, snipppet){
    var lineText = snipppet.lines.join(newLine());
    var newLines = substituteVars(lineText, vars);
    snipppet.lines = newLines.split(newLine());
    vars[snipppet.header] = snipppet;
    return vars;
  }
 
  var result = _.chain(arStepLines)
                  .reduce(splitSections, [])
                  .map(removeTrailingLines)
                  .reduce(addApplyVars, vars)
                  .value();
                 
  return result;
}

function parseSnippetsEndPoint() {
  var arStepLines = fromTemp('arStepLines.json')
  vars = fromTemp('vars.json');
 
  parseSnippets(arStepLines, vars);
}

function removeTrailingLines(testSteps){
  function removeBlank(accum, thisLine){
    if (accum.atEnd){
      if (hasValue(trimWhiteSpace(thisLine))){
        accum.atEnd = false;
        accum.result.push(thisLine);
      }
    }
    else {
      accum.result.push(thisLine);  
    }
    return accum;
  }
 
  var lines = testSteps.lines;
  var trimmedLines = _.reduceRight(lines, removeBlank, {result:[], atEnd: true});
  testSteps.lines = trimmedLines.result.reverse();
  return testSteps;
}

function splitSections(sections, thisLine){
  if (isStepDeclaration(thisLine)){
    var newSection = headerAndParams(thisLine);
    newSection.lines = [];
    sections.push(newSection);
  }
  else {
    var currentSection = _.last(sections);
    currentSection.lines.push(thisLine);
  }
 
  return sections;
}

function headerAndParams(stepsDeclaration){
  var parts = bisect(stepsDeclaration, ' ');
  var suffix = params(parts[1]);
  var result = {
                  header: trim(parts[0]),
                  params: suffix
               };
  return result;
}

function params(str){
  function trimDelimsUnderscores(str){
    return trimChars(str, [',', ';', '_'])
  }
 
  var result = null;
  if (hasValue(trimWhiteSpace(str))) {
    result = str.split(' ');
    result = _.chain(result)
              .filter(isParam)
              .map(trimDelimsUnderscores)
              .sortBy(negLength)
              .value();
             
    result = result.length === 0 ? null : result;
  }
  return result;
}

function parseSections(arSections){
  var result = _.reduce(arSections, parseSection, {testCases: [], vars: {}});
  return result;
}

function negLength(str){
  var result = def(str, '').length * -1;
  return result;
}

function substituteVars(str, vars){
  var result = null;
  if (hasValue(str)){
    var keys = _.chain(vars)
                  .keys()
                  .reject(function(str){return sameText(str, ACTIVE_ITEM_NAME())})
                  .sortBy(negLength)
                  .value();
   
    function singleReplacementPass(str){
      function replaceVar(result, key){
        var val = vars[key];
        var result = (_.isString(val)) ?
                                replace(result, key, val):
                                applySnippet(result, key, vars);
        return result;
      }   
   
      var result = _.reduce(keys, replaceVar, str);
      return result;
    }
 
    var text = str;
    var resursionCounter = 0;
    do {
      var oldText = text;
      resursionCounter++;
      text = singleReplacementPass(str);
      ensure(resursionCounter < 100, 'Looks like recursive snippet or varible declaration in ' + str);
    } while (oldText !== text);
 
    result = text;
  }
  return result;
}

function applySnippet(txt, snippetName, vars){
  if (hasText(txt, snippetName)){
   
    var snippet = vars[snippetName],
        params = snippet.params,
        snippetText = snippet.lines.join(newLine()),
        hasParams = hasValue(params);
     
    var result = hasParams ? applyParams(snippetName, params, snippetText, txt)
                            : replace(txt, snippetName, snippetText);

  }
  else {
    result = txt;
  }

  return result;
}

function applySnippetEndPoint() {
  var vars = fromTemp('applySnippetVars.json'),
      str = "\t=> at_submission_page",
      snippetName = "at_submission_page";
 
  var result = applySnippet(str, snippetName, vars);  
  toTempString(result, 'applySnippetResult.txt')
}

function applyParams(snippetName, params, snippetText, targetStr){
 
  function makeSegments(segments, line){
    var trimLine = trim(line);
    var hasSnippetName =  startsWith(trimLine, snippetName + ' ') ||
                              sameText(snippetName, trimLine) ||
                              hasText(trimLine, ' ' + snippetName + ' ') ||
                              endsWith(trimLine, ' ' + snippetName);
                             
    if (hasSnippetName || segments.length === 0){
      segments.push([]);  
    }

    _.last(segments).push(line);
    return segments
  }
 
  function readParamOrLine(accum, thisLine){
   
    function paramInLine(prm){
      var prmWithColumn = prm + ':';
      return hasText(thisLine, ' ' + prmWithColumn) || startsWith(trimWhiteSpace(thisLine), prmWithColumn)  
    }
   
    var readParams = _.keys(accum.params);
    var toRead = _.difference(params, readParams);
    if (toRead.length === 0){
      accum.trailingLines.push(thisLine);
    }
    else {
      // all params are assumed to be single line
      var thisParam = _.find(toRead, paramInLine);
      ensure(hasValue(thisParam), '(note multi line params not supported) param(s) miising in call to snippet: ' + snippetName
                                      + newLine() + 'param(s): ' + toRead.join(', ') + newLine() +
                                      'In Section' + newLine() + targetStr
                                      );
                                     
      accum.params[thisParam] = trim(subStrAfter(thisLine, thisParam + ':'));
    }
    return accum;  
  }
     
  function replaceParamText(text, paramVal, paramName){
    var snippetParam = '_' + paramName;
    var result = replace(text, snippetParam, paramVal);
    return result;
  }
 
  function replaceSnippetInSegment(segment){
    var txt = segment.join(newLine());
    var result = txt;
    if (hasText(result, snippetName)){
      var parts = bisect(result, snippetName);
      var suffixLines = parts[1].split(newLine());
     
      var trailingParts = _.reduce(suffixLines, readParamOrLine, {params: {}, trailingLines: []});
      var parameterisedSnippetText = _.reduce(trailingParts.params, replaceParamText, snippetText);
      var trailingLines = trailingParts.trailingLines.length === 0 ? '' : newLine() + trailingParts.trailingLines.join(newLine());
      result = parts[0] + parameterisedSnippetText + trailingLines;
    }
    return result;
 
  }
 
  var segments = _.chain(targetStr.split(newLine()))
                    .reduce(makeSegments, [])
                    .map(replaceSnippetInSegment)
                    .value();
                      
  return segments.join(newLine());
}

function applyParamsEndPoint() {
  var target = bigString(function(){
                 /*
                    # prepare your test environment
                      # log_in     userName: initial_trade_partner_username
                                          password: _oldPassword
                      => the change password page is active
                      => the user is unable to proceed without changing password
   
                      # complete the change password form as follows
                          -- may be old password field that needs to be filled out
                          new password: _newPassword
                          confirm new password: _newPassword
                      # click <Change Password>
                      => at_submission_page
                      # log_out
   
                      # log_in using userName: initial_trade_partner_username,
                                                   password: _newPassword
                      => at_submission_page
                      # log_out
                 */
               });
              
  var name = 'log_in';
  var params = ['userName','password'];
  var snippetText = bigString(function(){
                      /*
                        -- if not already logged in with the specified credentials
                          # log out if requred
                          # browse_to_log_in_page
                          # log in using username: _userName and password: _password
                          # click <Log In>
                      */
                    });
 
  var result = applyParams('log_in', params, snippetText, target);
  toTempString(result, 'ApplyParamsResult.txt');
}

function isParam(str){
  return startsWith(str, '_');
}

function isComment(str){
  var str = trimWhiteSpace(str);
  return startsWith( str, '--') &&
                    !startsWith(str, '---');
}

function isStepDeclaration(str){

   return !startsWith(str, "_") &&
          hasText(str, "_") &&
          // step declarations must be hard against the
          // left of the page
          !startsWith(str, "\t") &&
          !startsWith(str, " ");
}

function isVarDeclaration(str){
   trimWhiteSpace(str);
   return !startsWith(str, "_") &&
          hasText(str, "_") &&
          endsWith(str, ':');
}

function isParamDeclaration(str){
   trimWhiteSpace(str);
   return startsWith(str, "_");
}

function ACTIVE_ITEM_NAME(){return 'activeName';}

function parseConstants(arConstantList, vars){
  arConstantList = _.reject(arConstantList, isComment);
 
  var listLength = arConstantList.length;
 
  function updateVars(vars){
    if (hasValue(vars[ACTIVE_ITEM_NAME()])){
      var active = vars[ACTIVE_ITEM_NAME()];
      vars[active.name] = active.value;
    }
    return vars;
  }
 
  function addConstantToVars(accum, constLine, index){
    var trimmedLine = trimWhiteSpace(constLine);
    var declaration = hasText(trimmedLine, ' ') ?
                        subStrBefore(trimmedLine, ' ') :
                        trimmedLine;
                       
    ensure(!isParamDeclaration(declaration), 'Cannot declare params in the constants section');
    if (isVarDeclaration(declaration)){
      accum = updateVars(vars);
      var decParts = bisect(constLine, ':');
      var val = substituteVars(decParts[1], accum);
     
      accum[ACTIVE_ITEM_NAME()] = {
                            name: trimWhiteSpace(decParts[0]),
                            value: val
                          }
    }
    else {
      var active = accum[ACTIVE_ITEM_NAME()];
      ensure(hasValue(active) || !hasValue(trimWhiteSpace(constLine)), 'Problem parsing constants at line with text: ' + constLine);
      if (hasValue(active)){
        active.value = substituteVars(active.value + newLine() + constLine, accum);
      }
    }
   
    return accum;
  }
 
  var result = _.reduce(arConstantList, addConstantToVars, vars);
  result = updateVars(result);
 
  return _.omit(result, ACTIVE_ITEM_NAME());
}

function splitIntoSections(arScriptLines){
 
  var SEC_DELIMITER = '===';
  function accumulateSections(accum, thisLine){
    var secHeader = trimWhiteSpace(thisLine);
    secHeader = trim(replace(secHeader, SEC_DELIMITER, ''));
   
    function matchesThisHeader(str){
      return sameText(str, secHeader);
    }
 
    if (hasText(thisLine, SEC_DELIMITER) && hasValue(_.find(ALL_SECTIONS(), matchesThisHeader))){
        accum.push(
          {
            section: trim(thisLine),
            children: []
          }
        );
    }
    else {
      ensure(accum.length > 0, 'First line of file must be a section header: === Constants === or ' +
      '=== Snippets === or === Test Cases ===');
      var currentSection = _.last(accum);
      currentSection.children.push(thisLine);
    }
    return accum;
  }

  var result = _.reduce(arScriptLines, accumulateSections, [])
  return result;
}
