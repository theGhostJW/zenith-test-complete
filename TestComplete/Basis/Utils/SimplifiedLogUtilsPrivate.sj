//USEUNIT SysUtils
//USEUNIT StringUtils
//USEUNIT FileUtils
//USEUNIT _


function makeIssuesSummary(folderPath){
  var WORKSPACE_TAGS = 
              bigString(function(){
                 /*
                <NotepadPlus>
                    <Project name="Issues">
                        {{0}}
                    </Project>
                </NotepadPlus>
                 */
              });
  
  var issuesLists = listFiles(folderPath, '*' + ISSUES_FILE_SUFFIX());

  function toTag(filePath){
    return '<File name="' + aqFileSystem.GetFileName(filePath) + '"/>';
  }
  
  var issuesTags = _.map(issuesLists, toTag).join(newLine());
  stringToFile(loadTemplate(WORKSPACE_TAGS, issuesTags), combine(folderPath, 'NotePadPlusPlusWorkSpaceIssues.txt'));
}