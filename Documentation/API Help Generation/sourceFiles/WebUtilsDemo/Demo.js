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