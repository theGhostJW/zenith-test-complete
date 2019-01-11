//USEUNIT XmlToJsonUtilsPrivate
//USEUNIT SysUtils


/** Module Info **

 A wrapper around open source xjs
 
 Copyright 2011-2013 Abdulla Abdurakhmanov
 Original sources are available at https://code.google.com/p/x2js/

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */
 
/**
Converts an xml string to a JS object
==  Params ==
xmlStr: String -  Required -  The xml string
== Return ==
Object - a Json object
==  Related ==
xmlToJson
**/
function xmlToObject(xmlStr){
  // remove unprintable char that often comes at start of text
  xmlStr = subStrAfter(xmlStr, '<');
  if (hasValue(xmlStr)){
    xmlStr = '<' + xmlStr;
  }
  var config = {enableToStringFunc: false};
  return X2JS(config).xml_str2json(xmlStr);
}
/**
Converts an xml string to a Json string
==  Params ==
xmlStr: String -  Required -  The xml string
== Return ==
String - a json representation of the XML data
==  Related ==
xmlToJson
**/
function xmlToJson(xmlStr){
  var obj = xmlToObject(xmlStr);
  var json = objectToJson(obj);
  return json;
}
