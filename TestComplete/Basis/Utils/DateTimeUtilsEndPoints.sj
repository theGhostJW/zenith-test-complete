//USEUNIT DateTimeUtils
//USEUNIT CheckUtils
//USEUNIT SysUtils
//USEUNIT EndPointLauncherUtils

function dateTimeToReadableStringUnitTest() {
  var result = dateTimeToReadableString(aqDateTime.SetDateTimeElements(2015, 10, 1, 13, 1, 59));
  checkEqual('Thursday 10/1/2015 1:01:59 PM', result);
}

function tcDateTimeToIntEndPoint() {
  var tcDate = aqDateTime.SetDateTimeElements(2015, 1, 1, 12, 0, 0),
      result = tcDateTimeToInt(tcDate);
  checkEqual(20150101120000, result);
  
  tcDate = aqDateTime.SetDateTimeElements(2015, 10, 1, 13, 1, 59),
  result = tcDateTimeToInt(tcDate);
  checkEqual(20151001130159, result);
  
  tcDate = aqDateTime.SetDateTimeElements(2015, 10, 19, 0, 0, 0 ),
  result = tcDateTimeToInt(tcDate);
  checkEqual(20151019000000, result);
}

function dateReplacerEndPoint() {
  var result;
  result = dateReplacer('Dummy', getDate(2001, 10, 23));
  log(result);
  
  result = dateReplacer('Dummy', getTime(2001, 10, 23, 10, 11, 11));
  log(result);
}

function intToTCDateTimeEndPoint() {
  var expected = aqDateTime.SetDateTimeElements(2015, 1, 1, 12, 0, 0),
      intDate = 20150101120000,
      result = intToTCDateTime(intDate);
  checkEqual(expected, result);
  
  expected = aqDateTime.SetDateTimeElements(2015, 10, 1, 13, 1, 59),
  intDate = 20151001130159,
  result = intToTCDateTime(intDate);
  checkEqual(expected, result);
  
  expected = aqDateTime.SetDateTimeElements(2015, 10, 19, 0, 0, 0 ),
  intDate = 20151019000000,
  result = intToTCDateTime(intDate);
  checkEqual(expected, result);
}

function nowEndPoint() {
  var unWrapped, result;
  unWrapped = aqDateTime.Now();
  result = now();
  checkEqual(unWrapped, result);
}

function todayEndPoint() {
  var unWrapped, result;
  unWrapped = aqDateTime.Today();
  result = today();
  checkEqual(unWrapped, result);
}

function datePlusUnitTest() {
  var unWrapped, result;
  var baseDate = getDate(2013, 5, 4);
  
  unWrapped = aqDateTime.AddDays(baseDate, 3);
  result = datePlus(baseDate, 3);
  checkEqual(unWrapped, result);
  
  unWrapped = aqDateTime.AddDays(baseDate, -5);
  result = datePlus(baseDate,  -5);
  checkEqual(unWrapped, result);
}

function todayPlusEndPoint() {
  var unWrapped, result;
  
  unWrapped = aqDateTime.AddDays(aqDateTime.Today(), 3);
  result = todayPlus(3);
  checkEqual(unWrapped, result);
  
  unWrapped = aqDateTime.AddDays(aqDateTime.Today(), -3);
  result = todayPlus(-3);
  checkEqual(unWrapped, result);
}

function getDateUnitTest() {
  var unWrapped, result;
  unWrapped = aqDateTime.SetDateElements(2013, 5, 5);
  result = getDate(2013, 5, 5);
  checkEqual(unWrapped, result);
}

function getTimeUnitTest() {
  var unWrapped, result;
  unWrapped = aqDateTime.SetDateTimeElements(2013, 5, 5, 13, 9, 55);
  result = getTime(2013, 5, 5, 13, 9, 55);
  checkEqual(unWrapped, result);
}