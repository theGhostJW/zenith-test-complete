//USEUNIT DBUtils
//USEUNIT CheckUtils


function runSQLQueryEndPoint() {
  var sql = 'select * from test';
  var params = {
    dbPath: testDataFile('testDb.s3db'),
    sql: sql,
    connectionStringMakerFunction: makeSQLite3ConnectionString,
    rowFunction: logIt 
 }
 
 var counter = 0;
 function logIt(recordSet){
    counter++;
    log(counter + ': ' + recordSet.Fields('given').Value +  ' ' + recordSet.Fields('surname').Value);
 };
    
  runSQLQuery(params)
}

function getRecordsEndPoint() {
  var sql = 'select * from test';
  var params = {
    dbPath: testDataFile('testDb.s3db'),
    sql: sql,
    connectionStringMakerFunction: makeSQLite3ConnectionString
 }
 
 var result = getRecords(params);
 log(objectToJson(result));
}

function getRecordEndPoint() {
  var sql = 'select * from test limit 1';
  var params = {
    dbPath: testDataFile('testDb.s3db'),
    sql: sql,
    connectionStringMakerFunction: makeSQLite3ConnectionString
 }
 
 var result = getRecord(params);
 log(objectToJson(result));
}

function getFieldEndPoint() { 
  var sql = 'select given from test limit 1';
  var params = {
    dbPath: testDataFile('testDb.s3db'),
    sql: sql,
    connectionStringMakerFunction: makeSQLite3ConnectionString
 }
 
 var result = getField(params);
 
 sql = 'select given from test where given = "sdsdsddsdsddsddsaadsdsa"';
          
 params.sql = sql;
 result = getField(params);
 checkEqual(null, result); 
 
 expectDefect('2 fields');
 
 sql = 'select * from test limit 1';
 params.sql = sql;
 result = getField(params);        
}