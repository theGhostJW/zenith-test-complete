//USEUNIT StringUtils
//USEUNIT FileUtils
//USEUNIT SysUtils 
//USEUNIT _

function argsToParams(passThroughArguments){
  var args = _.toArray(passThroughArguments);
  var argLength = args.length;
  ensure(args.length > 0 && args.length < 5, 'Invalid arguments must ba a single paramds object or: sql, serverName, dbName [optional], timeOut [optional]');
  var result
  if (argLength > 1){
  var sql = args[0],
  server = args[1];

  result =  {
              sql: sql,
              serverName: server
            };

  // deal with optional params
  if (argLength > 2){
    var optParams = _.rest(args, 2);
    var dbName = _.find(optParams, _.isString);
    var timeOut = _.find(optParams, _.isNumber);
    if (hasValue(dbName)){
      result.dbName = dbName;
    }

    if (hasValue(timeOut)){
      result.timeOut = timeOut;
    }
  }

  }
  else {
    result = args[0];
    ensure(_.isObject(result), 'If a single argument is passed to databasse function it must be a params object');
  }
  return result;
}

function argsToParamsEndPoint() {
  function callArgs(){
    return argsToParams(arguments);
  }
  var result = callArgs('select from tbl', 'ccb101', 'consumerDb', 1000);
  result = callArgs('select from tbl', 'ccb101', 1000);
  result = callArgs('select from tbl', 'ccb101', 'consumerDb');
  result = callArgs('select from tbl', 'ccb101');
}


function runSQLQuery(params){
/*
 eg params = {
  server: 'SERVER_NAME',
  db: 'DB_NAME',
  sql: 'test.sql',
  timeout: 100000,
  rowFunction: function(recordSet){// Do something } Or null if non query like an update,
  connectionStringMakerFunction: params => String
 }
*/
  function indicate(str){
    Indicator.PopText();
    Indicator.PushText(str);
  }
  
  function atRecord(recSet){
    return !(recSet.EOF || recSet.BOF); 
  }
  
  var sqlFileName =  aqString.ToLower((params.sql));
  var isFile = endsWith(sqlFileName, '.sql');
  var sql = isFile ? testDataString(params.sql): params.sql;

  var adOpenStatic = 3;
  var adLockOptimistic = 3;
  var connection = Sys.OleObject("ADODB.Connection");
  
  if (hasValue(params.timeout)){
    connection.CommandTimeout = Math.round(params.timeout / 1000); // seconds
  }

  var recordSet = Sys.OleObject("ADODB.Recordset");
   
  var strConnection = params.connectionStringMakerFunction(params);
  
  log('Executing SQL (Connecting) - ' + strConnection, strConnection);
  Indicator.PushText('Executing SQL (Connecting) - ' + strConnection);
  connection.Open(strConnection);
  try {
    log('Executing SQL (Executing) - ' + params.sql, sql);
    Indicator.PushText('Executing SQL (Executing) - ' + params.sql);
    
    if (hasValue(params.rowFunction)){
      recordSet.Open(sql, connection, adOpenStatic, adLockOptimistic);
      try { 
        if (!recordSet.EOF){
          recordSet.MoveFirst();
          indicate('Processing records');
          var counter = 0,
              interval = 0;
          
          while (atRecord(recordSet)) {
            params.rowFunction(recordSet);  
            recordSet.MoveNext();
            interval++;
            counter++;
            if (interval == 100){
              indicate(counter + ' records processed');
              interval = 0;
            }
          } 
        }
      }
      finally {
        Indicator.PopText();
        recordSet.Close();
      }
    }
    else {
      // if there is no row function - then assume this is a non query like an insert or delete
      connection.Execute(sql);
    }
    
  }
  finally {
    Indicator.PopText();
    connection.Close();
  }
}


function getSQlResultAsObjects(params, isScalar){
/* 
Same as for runSQLQuery but no rowFunction
 eg params = {
  server: 'SERVER_NAME',
  db: 'DB_NAME',
  sql: 'test.sql',
  timeout: 100000
 }
*/
  isScalar = def(isScalar, false);
  var result = null;
  var fieldCount = null;
  
  function loadResult(recordSet){
    ensure(!isScalar || !hasValue(result), 'More than one record returned from scalar query' )
    
    var thisRecord = {};
    if (fieldCount === null){
      fieldCount = recordSet.Fields.Count;
    }
    
    for (var counter = 0; counter < fieldCount; counter++){
      thisRecord[recordSet.Fields(counter).Name]  =  recordSet.Fields(counter).Value;
    }
    
    if (isScalar){
      result = thisRecord;
    }
    else {
      result = def(result, []);
      result.push(thisRecord);
    }
  }
  
  params.rowFunction = loadResult;
  runSQLQuery(params)

  return result;
}

function makeSQLite3ConnectionString(params){
  ensure(hasValue(params.dbPath, 'params.dbPath required'));
  return "DRIVER=SQLite3 ODBC Driver;Database=" + params.dbPath  + ";LongNames=0;Timeout=1000;NoTXN=0;SyncPragma=NORMAL;StepAPI=0;version=3;";
}

function getSQlResultAsObjectsEndPoint() {
  var params = {
    dbPath: testDataFile('testDb.s3db'),
    sql: 'select * from test',
    connectionStringMakerFunction: makeSQLite3ConnectionString
 }
 
 var result =  getSQlResultAsObjects(params, false);
 log(objectToJson(result));
}