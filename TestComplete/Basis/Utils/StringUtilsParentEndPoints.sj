//USEUNIT StringUtilsParent
//USEUNIT CheckUtils
//USEUNIT EndPointLauncherUtils

function isNumCharsEndPoint() {
  checkFalse(isNumChars('123\f'));
  check(isNumChars('123'));
  check(isNumChars('0.00'));
  checkFalse(isNumChars('01.0'));
  checkFalse(isNumChars('1.'));
}


function numberParserEndPoint() {
  check(numberParser().canParse('0'), true);
  check(numberParser().canParse('1'), true);
  check(numberParser().canParse('1.1110'), true);
  checkFalse(numberParser().canParse('a1.1110'), false);
  checkFalse(numberParser().canParse('Hi'), false);
  
  checkEqual(numberParser().parse('1'), 1);
  checkEqual(numberParser().parse('1.1110'), 1.111);
}


function autoTypeEndPoint() {
  var target = [
              {
                "id": "10",
                "name": "exact",
                "dob": "Y",
                "drivers": "N",
                "address": "N",
                "outcome": "Y",
                "flip/repeat": "Y"
              },
              {
                "id": "11",
                "name": "exact",
                "dob": "N",
                "drivers": "Y",
                "address": "N",
                "outcome": "Y",
                "flip/repeat": "Y"
              },
              {
                "id": "12",
                "name": "exact",
                "dob": "N",
                "drivers": "N",
                "address": "Y",
                "outcome": "Y",
                "flip/repeat": "Y"
              },
              {
                "id": "13",
                "name": "concatFM",
                "dob": "Y",
                "drivers": "N",
                "address": "N",
                "outcome": "Y",
                "flip/repeat": "Y"
              },
              {
                "id": "14",
                "name": "concatML",
                "dob": "N",
                "drivers": "Y",
                "address": "N",
                "outcome": "Y",
                "flip/repeat": "Y"
              },
              {
                "id": "15",
                "name": "concatFM",
                "dob": "N",
                "drivers": "N",
                "address": "Y",
                "outcome": "Y",
                "flip/repeat": "Y"
              },
              {
                "id": "16",
                "name": "exact",
                "dob": "Y",
                "drivers": "Y",
                "address": "Y",
                "outcome": "Y",
                "flip/repeat": "N"
              }
            ];
            
  var result = autoType(target);
}

function autoTypeArrayEndPoint() {
  var targ, expected, result;
  
  // ================================
  /// should never happen props are strings but should work anyway
  
  targ = [{
          dob: 1234
  }];
  
  expected = [{
          dob: 1234
  }]; 
  
  result = autoTypeArray(targ);
  checkEqual(expected, result);
  
  // ================================
  
  targ = [{
          first: 'blahh',
          middle: '.',
          last: '.',
          dob: 1234
  }];
  
  expected = [{
          first: 'blahh',
          middle: null,
          last: null,
          dob: 1234
  }]; 
  
  result = autoTypeArray(targ);
  checkEqual(expected, result);
  
  // ================================
  
  expected = [{
          first: 'blahh',
          middle: null,
          last: '.',
          dob: 1234
  }]; 
  
  result = autoTypeArray(targ, 'last');
  checkEqual(expected, result);
  
  // ================================
  
  targ = [{
          first: 'blahh',
          middle: '.',
          last: '.',
          dob: 1234
  },
  {
          first: '.',
          middle: '.',
          last: '.',
          dob: 1234
  }];
   
  expected = [{
          first: 'blahh',
          middle: null,
          last: '.',
          dob: 1234
  },
  {
          first: null,
          middle: null,
          last: '.',
          dob: 1234
  }]; 
  
  result = autoTypeArray(targ, 'last');
  checkEqual(expected, result);
  
  // ================================
  targ = [
          {
            first: 'blahh',
            middle: '.',
            last: '.',
            dob: '2000-1-1',
            bool: '.',
            flt: '1.22',
            intg: '4',
            mixed: 'T',
            ignore: '.'
          },
          {
            first: '.',
            middle: '.',
            last: '.',
            dob: '.',
            bool: 'T',
            flt: '1.23',
            intg: '.',
            mixed: '1979-1-1',
            ignore: '1'
          },
          {
            first: '.',
            middle: '.',
            last: '.',
            dob: '1979-1-1',
            bool: 'N',
            flt: '.',
            intg: '5',
            mixed: '.',
            ignore: '2'
          }
  ];
   
  expected = [
          {
            first: 'blahh',
            middle: null,
            last: null,
            dob: aqDateTime.SetDateElements(2000, 1, 1),
            bool: null,
            flt: 1.22,
            intg: 4,
            mixed: 'T',
            ignore: '.'
          },
          {
            first: null,
            middle: null,
            last: null,
            dob: null,
            bool: true,
            flt: 1.23,
            intg: null,
            mixed: '1979-1-1',
            ignore: '1'
          },
          {
            first: null,
            middle: null,
            last: null,
            dob: aqDateTime.SetDateElements(1979, 1, 1),
            bool: false,
            flt: null,
            intg: 5,
            mixed: null,
            ignore: '2'
          }
  ];
  
  result = autoTypeArray(targ, 'ignore');
  
  function workAround(val){
    return _.omit(val, 'dob');
  }
  
  checkEqual(expected, result);
}

function dateParserUnitTest() {
  checkFalse(dateTimeParser().canParse('1.22'));
  checkFalse(dateTimeParser().canParse('jkjjk'));
  checkFalse(dateTimeParser().canParse('1234'));

  checkEqual(dateTimeParser().parse('2015-01-04'), aqDateTime.SetDateElements(2015, 1, 4));
  checkEqual(dateTimeParser().parse('2015-01-04 10:20'), aqDateTime.SetDateTimeElements(2015, 1, 4, 10, 20, 0));
}

function dotToNullsUnitTest() {
  var targ = {
          first: 'blahh',
          middle: '.',
          last: null,
          dob: 1234
  },
  
  expected = {
          first: 'blahh',
          middle: null,
          last: null,
          dob: 1234
  };
  
  var result = dotToNulls(targ);
  checkEqual(expected, result);
}