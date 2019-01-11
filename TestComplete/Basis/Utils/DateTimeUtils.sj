//USEUNIT _

/** Module Info **

?????_NO_DOC_?????

**/



/**

Converts a TestComplete date to an readable string e.g. Thursday 10/1/2015 1:01:59 PM. 
Useful in logging

== Params ==
tcDate: Date (TestComplete) -  Required -  the input date
== Return ==
Sttring - a formatted date string 
**/
function dateTimeToReadableString(tcDateTime){
  return aqConvert.DateTimeToFormatStr(tcDateTime, '%A %c'); 
}

/**

Converts a TestComplete date to an int. 
Occasionally used to work around JSON serialisation issues with testComplete dates. 

== Params ==
tcDate: Date (TestComplete) -  Required -  the input date
== Return ==
int - date converted to an integer 
**/
function tcDateTimeToInt(tcDate){
  var s = aqDateTime.GetSeconds(tcDate),
      mn = aqDateTime.GetMinutes(tcDate) * 100,
      h = aqDateTime.GetHours(tcDate) * 10000,
      d = aqDateTime.GetDay(tcDate) * 1000000,
      m = aqDateTime.GetMonth(tcDate) * 100000000,
      y = aqDateTime.GetYear(tcDate) * 10000000000;

  return y + m + d + h + mn + s;
}

function intToTCDateTime(intDate){
  var  y = Math.floor(intDate / 10000000000),
       m = Math.floor((intDate % 10000000000)/ 100000000),
       d = Math.floor((intDate % 100000000) / 1000000),
       h = Math.floor((intDate % 1000000) / 10000),
       mn = Math.floor((intDate % 10000) / 100),
       s =  intDate % 100;
  
  return getTime(y, m, d, h, mn, s);
}

// note the difference to _ which is always value, key
function dateReplacer(key, value){
  return GetVarType(value) === 7 ? {testCompleteNativeDate: tcDateTimeToInt(value)} : value;
}

// note the difference to _ which is always value, key
function dateReviver(key, value){
  return _.isObject(value) && !_.isArray(value) && value.testCompleteNativeDate !== undefined ? intToTCDateTime(value.testCompleteNativeDate) : value;
}

/**
A wrapper around [[http://support.smartbear.com/viewarticle/32154/|aqDateTime.Now()]]
**/
function now(){
  return aqDateTime.Now();
}

/**
A wrapper around [[http://support.smartbear.com/viewarticle/32526/|aqDateTime.Today()]]
**/
function today(){
  return aqDateTime.Today();
}

/**
A wrapper around [[http://support.smartbear.com/viewarticle/28178/|aqDateTime.SetDateElements(Year, Month, Day)]]
**/
function getDate(year, month, day){
  return aqDateTime.SetDateElements(year, month, day);
}

/**
A wrapper around [[http://support.smartbear.com/viewarticle/29148/|aqDateTime.SetDateTimeElements(Year, Month, Day, Hour, Min, Sec)]]
**/
function getTime(year, month, day, hour, min, sec){
  return aqDateTime.SetDateTimeElements(year, month, day, hour, min, sec);
}

/**
A wrapper around [[http://support.smartbear.com/viewarticle/28153/|aqDateTime.AddDays(InputDate, Days)]]
**/
function datePlus(baseDate, daysToAdd){
  return aqDateTime.AddDays(baseDate, daysToAdd);
}

/**
Returns today's date plus the nominated number of days (which can be negative)
== Params ==
daysToAdd: Int -  Required - the number of days to add
== Return ==
DateTime - today's date plus the nominated number of days
== Related ==
datePlus
**/
function todayPlus(daysToAdd){
  return datePlus(aqDateTime.Today(), daysToAdd)
}


/**
 Framework use only
**/
function logDateHeader(){
 return '==== ' + dateTimeToReadableString(now()) + ' ====';
}



