//USEUNIT StringUtils


/** Module Info **

?????_NO_DOC_?????

**/


/**

?????_NO_DOC_?????

== Return ==
DATA_TYPE_?????_NO_DOC_????? - DESCRIPTION_?????_NO_DOC_?????
== Related ==
?????_NO_DOC_?????
**/
function baseData(){
  return stringToTables(TABLE_TEXT());
  //if simple single table use below
  //return stringToTable(TABLE_TEXT());
}

/**

?????_NO_DOC_?????

== Return ==
DATA_TYPE_?????_NO_DOC_????? - DESCRIPTION_?????_NO_DOC_?????
== Related ==
?????_NO_DOC_?????
**/
function TABLE_TEXT(){
  return bigString(
    function(){
    /*
	
2 requests same account no / sub no
		
=== Direct Hit Matching ===

directHitCases::
id						name	   			 			dob				 drivers				address					outcome				flip/repeat
------------------------------------------------------------------------------------------------------------------------------------------------------------------
10						exact									Y					 N								N								Y									Y
11						exact									N					 Y								N								Y									Y
12						exact									N					 N								Y								Y									Y
13						concatFM							Y					 N								N								Y									Y
14						concatML							N					 Y								N								Y									Y
15						concatFM							N					 N								Y								Y									Y
16						exact									Y					 Y								Y								Y									N


=== Secondary Matching ===

secondaryMatch::
id							name								dob						drivers					  	address							outcome				flip/repeat
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
20							none 									N					 			N											N										N									N
21							> 80%									N					 			N											N										Y									N
22							first									Y					 			N											N										Y									Y
23							first									N					 			Y											N										Y									Y
24							last									N					 			Y											N										Y									Y
25							first & last				  N					 			N											N										Y									Y
26							first								  N					 			N											N										N									N
27							last								  N					 			N											N										N									N

  
    */
    })
};
