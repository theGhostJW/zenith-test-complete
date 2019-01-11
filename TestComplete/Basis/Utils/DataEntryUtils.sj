//USEUNIT SysUtils
//USEUNIT DataEntryUtilsPrivate

/** Module Info **
DataEntryUtils provides function to assist with setting and getting data for standard data entry UI components
**/

/**
Reads the default property of an object - logs an error if reading the object is not handled
== Params ==
uiObj:  UI object -  Required -  the target object
== Return ==
Object - the default value of the object
== Related ==
set
**/
function read(uiObj){
  return DataEntryUtilsPrivate.read(uiObj);
}

/**
Sets the value of an object. Logs an error if the object type is not handled by set
== Params ==
uiObj:  UI object -  Required -  the target object
value: String -  Required -  the value to set
wantSet: Boolean - Optional - Default: true - set this flag to false to make the function simply check if the object can be set without actually setting it
errorMessage: String -  Optional - Default: '' - additional information for error message if the UI object is not handled by the set function
== Returns ==
Boolean: returns true if the object can or was set
== Related ==
read
**/
function set(uiObj, value, errorMessage, wantSet){
  DataEntryUtilsPrivate.set(uiObj, value, errorMessage, wantSet);
}
