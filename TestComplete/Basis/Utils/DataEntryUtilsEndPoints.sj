//USEUNIT DataEntryUtils
//USEUNIT WebUtils
//USEUNIT SysUtils
//USEUNIT CheckUtils

function play(){
  var item = seekByIdStr('ctl00_MainContent_fmwOrder_txtName'); 
}

function Test1()
{
  Browsers.Item(btIExplorer).Navigate("http://support.smartbear.com/samples/testcomplete10/weborders/Process.aspx");
  Aliases.browser.pageWebOrders.formAspnetform.tableCtl00MaincontentFmworder.cell.textnode.radiobuttonCtl00MaincontentFmwor2.value = true;
  Aliases.browser.pageWebOrders.formAspnetform.tableCtl00MaincontentFmworder.cell.tableCtl00MaincontentFmworderCar.radiobuttonCtl00MaincontentFmwor.ClickButton();
  Aliases.browser.pageWebOrders.formAspnetform.tableCtl00MaincontentFmworder.cell.textnode.radiobuttonCtl00MaincontentFmwor.ClickButton();
  Aliases.browser.pageWebOrders.formAspnetform.tableCtl00MaincontentFmworder.cell.textnode.radiobuttonCtl00MaincontentFmwor2.ClickButton();
}