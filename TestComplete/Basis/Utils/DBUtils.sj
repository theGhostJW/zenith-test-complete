//USEUNIT StringUtils
//USEUNIT FileUtils
//USEUNIT SysUtils 
//USEUNIT _
//USEUNIT DBUtilsPrivate


/** Module Info **

Provides functions to simplify database access

**/


/**

Makes a trusted connection string for Sql Server - this does not need to be called by the user. It is passed in as a connectionStringMakerFunction param property to other db functions such as [[runSQLQuery]].

== Params ==
params: Object - Required - an object including a 'server' property and optional 'db' used for setting the "Initial Catalog" property of the connection string
== Return ==
String - a connection string 
== Related ==
runSQLQuery
**/
function makeSQlServerConnectionString(params){
  return [
          "Provider=SQLOLEDB;Data Source='", 
          params.server, 
          "'; Trusted_Connection=Yes;Initial Catalog='",
          params.db,
          "'"].join('');
}

/**

Makes a makeSQLite3 connection string - this does not need to be called by the user. It is passed in as a connectionStringMakerFunction param property to other db functions such as [[runSQLQuery]].

== Params ==
params: Object - Required - an object including a dbPath property
== Return ==
String - a connection string 
== Related ==
runSQLQuery
**/
function makeSQLite3ConnectionString(params){
  return DBUtilsPrivate.makeSQLite3ConnectionString(params);
}


/**

Runs a function on each record of a query after connecting via windows authentication

params will vary depending on the requirements of the connectionStringMakerFunction

== Params ==
params: Object - Required - will vary depending on the requirements of the connectionStringMakerFunction
                            {
                              server: 'SERVER_NAME',
                              db: 'DB_NAME',
                              sql: 'test.sql', // the data file name in the test data directory
                              rowFunction: function(recordSet){// Do something with the record set },
                              connectionStringMakerFunction:  params => String
                             }
== Related ==
getRecords, getRecord, getField
**/
function runSQLQuery(params){
 return DBUtilsPrivate.runSQLQuery(params);
}

/**

Returns one or more records record as an array from a database given SQL and connection params

Note this function has been overloaded such that you can also call with the following arguments:
  sql: the sql string
  server: the server name
  timeout (optional) timeout in milliseconds
instead of using a params object.

== Params ==
params: Object - Required - runSQLQuery params minus rowFunction see [[runSQLQuery]]
== Return ==
Object[] - an array of objects each object representing a row of a table
== Related ==
runSQLQuery, getRecord, getField
**/
function getRecords(params){
  return getSQlResultAsObjects(argsToParams(arguments), false);
}

/**

Returns a single record as an object from a database given SQL and connection params (will throw an exception if more than one record is returned)

Note this function has been overloaded such that you can also call with the following arguments:
  sql: the sql string
  server: the server name
  timeout (optional) timeout in milliseconds
instead of using a params object.

== Params ==
params: Object -  Required - runSQLQuery params minus rowFunction see [[runSQLQuery]]
== Return ==
Object - field / value pairs
== Related ==
runSQLQuery, getRecords, getField
**/
function getRecord(params){
  return getSQlResultAsObjects(argsToParams(arguments), true);
}

/**

Returns a single field from a database given SQL and connection params

Note this function has been overloaded such that you can also call with the following arguments:
  sql: the sql string
  server: the server name
  timeout (optional) timeout in milliseconds
instead of using a params object.

== Params ==
params: Object -  Required - runSQLQuery params minus rowFunction see [[runSQLQuery]]
== Return ==
Int, String etc. depending on field type - the value of the field
== Related ==
runSQLQuery, getRecords, getRecord
**/
function getField(params){
  var obj = getSQlResultAsObjects(argsToParams(arguments), true);
  var objKeys = _.keys(obj);
  ensure(objKeys.length < 2, 'you cannot call getField on an sql that returns more than one field' );
  return objKeys.length === 0 ? null : obj[objKeys[0]];
}

