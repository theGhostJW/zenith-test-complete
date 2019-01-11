//USEUNIT SimplifiedLogUtils
//USEUNIT SysUtils
//USEUNIT CheckUtils
//USEUNIT StringUtils

function defaultSimpleLogProcessingEndPoint() {
  var log = fromTemp('arLog');
  defaultSimpleLogProcessing({dummmy: true}, log);
}


function createIssuesSummaryZipEndPoint(){
  createIssuesSummaryZip('C:\\TestCompleteLogs\\6_01_2016_3_46 PM_13_714');
}