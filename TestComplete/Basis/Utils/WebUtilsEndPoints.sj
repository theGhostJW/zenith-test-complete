//USEUNIT WebUtils
//USEUNIT CheckUtils
//USEUNIT SysUtils
//USEUNIT StringUtils


//
function sendWebRequestEndPoint() {
  var result = sendWebRequest('https://jsonplaceholder.typicode.com/posts', 'GET')
  toTemp(jsonToObject(result.responseText))
}

function captureDOMEndPoint() {
  toTemp(captureDOM('height', 'width', 'left', 'defaultChecked', 3));
}

function seekParentEndPoint(){
  var userNameTxt = seekInPage({idStr: 'ctl00_MainContent_username'}, 0);
  set(userNameTxt, 'Tester');
  var parentPanel = seekParent(userNameTxt, {
                                               ObjectType: 'Panel',
                                               Visible: 'True'
                                            })
  
  setByIdStr(parentPanel, 'ctl00_MainContent_password', 'test');
}

function seekAllInPageEndPoint(){
  var form = seekInPage({ObjectType: 'Form'});
  var textNodes = seekAll(form, {ObjectType: 'TextNode'});
  
  textNodes = seekAllInPage({ObjectType: 'TextNode'});
}

function setFormREndPoint(){
 /* http://support.smartbear.com/samples/testcomplete10/weborders/ */
 var params =  {
    product: 'ScreenSaver',
    quantity: 1,
    priceperUnit: 30,
    discount: 15,  
    name: 'Julie Smith',
    street: 'MyStreet',
    city: 'Melbourne',
    state: 'Vic',
    zip: 3126,
    visa: true,
    cardNo: '1234567890',
    expiry: '15/07'
  }
  setFormR(params);
  
  /* => puts the following in the clipboard 
     Note: label name and IdString for each text element the user would delete one for each field
     Note: also property names are listed so they can be dragged intoo place in the setForm
  
  
			product
			quantity
			priceperUnit
			discount
			name
			street
			city
			state
			zip
			visa
			cardNo
			expiry
      
	setForm(
		{
			ctl00_MainContent_fmwOrder_ddlProduct: params.,
			"Product:": params.,
			ctl00_MainContent_fmwOrder_txtQuantity: params.,
			"Quantity:": params.,
			ctl00_MainContent_fmwOrder_txtUnitPrice: params.,
			"Price per unit:": params.,
			ctl00_MainContent_fmwOrder_txtDiscount: params.,
			"Discount:": params.,
			ctl00_MainContent_fmwOrder_txtTotal: params.,
			"Total:": params.,
			ctl00_MainContent_fmwOrder_txtName: params.,
			"Customer name:": params.,
			ctl00_MainContent_fmwOrder_TextBox2: params.,
			"Street:": params.,
			ctl00_MainContent_fmwOrder_TextBox3: params.,
			"City:": params.,
			ctl00_MainContent_fmwOrder_TextBox4: params.,
			"State:": params.,
			ctl00_MainContent_fmwOrder_TextBox5: params.,
			"Zip:": params.,
			ctl00_MainContent_fmwOrder_cardList_0: params.,
			"Visa": params.,
			ctl00_MainContent_fmwOrder_cardList_1: params.,
			"MasterCard": params.,
			ctl00_MainContent_fmwOrder_cardList_2: params.,
			"American Express": params.,
			ctl00_MainContent_fmwOrder_TextBox6: params.,
			"Card Nr:": params.,
			ctl00_MainContent_fmwOrder_TextBox1: params.
			"Expire date (mm/yy):": params.
		}
	);
  
  which can be manually trimmed down to this =>
  
 	*/

	setForm(
		{
			ctl00_MainContent_fmwOrder_ddlProduct: params.product,
			ctl00_MainContent_fmwOrder_txtQuantity: params.quantity,
			ctl00_MainContent_fmwOrder_txtUnitPrice: params.priceperUnit,
			ctl00_MainContent_fmwOrder_txtDiscount: params.discount,
			ctl00_MainContent_fmwOrder_txtName: params.name,
			"Street:": params.street,
			"City:": params.city,
			"State:": params.state,
			"Zip:": params.zip,
			"Visa": true,
			"Card Nr:": params.cardNo,
			"Expire date (mm/yy):": params.expiry   
		}
	);
}

function clickLinkhEndPoint() {
   clickLinkh('Scala');
}

function clickLinkEndPoint() {
   clickLink('Scala');
}

function clickByPropertyEndPoint() {
  clickByProperty('idStr', 'ctl00_MainContent_login_button');
}

function clickByIdStrEndPoint() {
  clickByIdStr('ctl00_MainContent_login_button');
}

function clickByObjectIdentifierEndPoint() {
  clickByObjectIdentifier('ctl00_MainContent_login_button');
}

function clickInPageEndPoint() {
  clickInPage({ObjectIdentifier: 'ctl00_MainContent_login_button'});
}

function withSetterEndPoint() {
  /* assumes you are here: http://support.smartbear.com/samples/testcomplete11/weborders/Process.asp */ 
  function doKeys(uiObj, val){
    uiObj.Keys(val);  
  }
  
  var container = seekByIdStr('ctl00_MainContent_fmwOrder');
  var data =  {
    ctl00_MainContent_fmwOrder_ddlProduct: 'ScreenSaver',
    Quantity: 1,
    'Price per unit:': 30,
    Discount: 15,  
    name: 'Julie Smith',
    Street: 'MyStreet',
    City: withSetter('Melbourne', doKeys),
    State:'VIC',
    Zip: 3126,
    Visa: true, 
    'Card Nr:': '1234567890',
    'Expire date': '15/07'
  }
  
  /* a parent object can also be used */
  setForm(container, data);
}


function setFormEndPoint() {
  function doKeys(uiObj, val){
    uiObj.Keys(val);  
  }
  
  /* assumes you are here: http://support.smartbear.com/samples/testcomplete11/weborders/Process.asp */
  var container = seekByIdStr('ctl00_MainContent_fmwOrder');
  var data =  {
    ctl00_MainContent_fmwOrder_ddlProduct: 'ScreenSaver',
    Quantity: 1,
    'Price per unit:': 30,
    Discount: 15,  
    name: 'Julie Smith',
    Street: 'MyStreet',
    City: withSetter('Melbourne', doKeys),
    State:'VIC',
    Zip: 3126,
    Visa: true, 
    'Card Nr:': '1234567890',
    'Expire date': '15/07'
  }

  /* a parent object can also be used */
  setForm(container, data);
}

function setForm_In_Grid_EndPoint() {
  /* assumes you are here: http://support.smartbear.com/samples/testcomplete10/weborders/Default.aspx */
  var container = seekByIdStr('ctl00_MainContent_orderGrid');
  var data =  {
    'Steve Johns':true
  }
  setForm(container, data);
  
  var data = {
    398743242342: true
  }
  setForm(container, data);
}


function readByObjectIdentifierhEndPoint(){
  var browser = Sys.Browser("firefox");
  setByObjectIdentifier('*username', 'the ghost');
  
  var txt = readByObjectIdentifierh({ObjectType: 'Form'}, 3, '*zsername');
  checkEqual('the ghost', txt);
  
  var txt = readByObjectIdentifierh(BROWSER_NAME_FIREFOX(),'*username');
  checkEqual('the ghost', txt);
  
  var txt = readByObjectIdentifierh('*username');
  checkEqual('the ghost', txt);
  
  var txt = readByObjectIdentifier('*username');
  checkEqual('the ghost', txt);
  
  expectDefect('000');

  /* too shallow should fail */
  var txt = readByObjectIdentifierh(
    {ObjectType: 'Form'},
    0, 2,  '*username');
  endDefect();
}

function readByIdStrhEndPoint(){
  /* runUrl('http://support.smartbear.com/samples/testcomplete10/weborders/') */
  setByObjectIdentifier('*username', 'the ghost');
  
  var txt = readByIdStrh({ObjectType: 'Form'}, 3, '*username');
  checkEqual('the ghost', txt);
  
  var txt = readByIdStrh(
    BROWSER_NAME_FIREFOX(),'*username');
  checkEqual('the ghost', txt);
  
  var txt = readByIdStrh('*username');
  checkEqual('the ghost', txt);
  
  expectDefect('000');
  /* too shallow should fail */
  var txt = readByIdStrh(
    {ObjectType: 'Form'},
    0, 2,  '*username');
  endDefect();
}


function readByPropertyhEndPoint(){
  /*  runUrl('http://support.smartbear.com/samples/testcomplete10/weborders/') */
  setByObjectIdentifier('*username', 'the ghost');
  
  var txt = readByPropertyh({ObjectType: 'Form'}, 3, 'idStr', '*username');
  checkEqual('the ghost', txt);
  
  var txt = readByPropertyh(
    BROWSER_NAME_FIREFOX(),
    'idStr', '*username');
  checkEqual('the ghost', txt);
  
  var txt = readByPropertyh('idStr', '*username');
  checkEqual('the ghost', txt);
  
  expectDefect('000');
  /* too shallow should fail */
  var txt = readByPropertyh(
    {ObjectType: 'Form'},
    0, 2, 'idStr',  '*username');
  endDefect();
}

function readInPagehEndPoint(){
  /* runUrl('http://support.smartbear.com/samples/testcomplete10/weborders/') */
  setByObjectIdentifier('*username', 'the ghost');
  
  var txt = readInPageh(
    {ObjectType: 'Form'},
    function(obj){return hasText(obj.idStr, 'username')},
    3);
  checkEqual('the ghost', txt);
  
  var txt = readInPageh(
    BROWSER_NAME_FIREFOX(),
    function(obj){return hasText(obj.idStr, 'username')});
  checkEqual('the ghost', txt);;
  
  expectDefect('000')
  /* too shallow should fail */
  var txt = readInPageh(
    {ObjectType: 'Form'},
    function(obj){return hasText(obj.idStr, 'username')},
    0, 2);
  endDefect();
}

function setByObjectIdentifierhEndPoint(){
/*  runUrl('http://support.smartbear.com/samples/testcomplete10/weborders/')
    runUrl('http://support.smartbear.com/samples/testcomplete10/weborders/')
*/
  setByObjectIdentifierh(
    {ObjectType: 'Form'},
     '*username',
    'John');
    
  setByObjectIdentifierh('*username', 'Ghost');
    
  setByObjectIdentifierh(3, '*username',  'Ghost Again');
  
  /* too shallow should fail */
  expectDefect('9999');
  setByObjectIdentifierh(
    {ObjectType: 'Form'},    0, 2, 
   '*username', 'JW');
  endDefect();
}


function setByPropertyEndPoint(){
  /*  runUrl('http://support.smartbear.com/samples/testcomplete10/weborders/') */
  setByProperty(
    {ObjectType: 'Form'},
    'idStr', '*username',
    'John');
    
  setByProperty('idStr', '*username', 'Ghost');
    
  setByProperty(3, 'idStr', '*username',  'Ghost Again');
  
  /* too shallow should fail */
  expectDefect('9999');
  setByProperty(
    {ObjectType: 'Form'},
    'idStr', '*username',
    0, 2, 'JW');
  endDefect();
}


function setInPagehEndPoint(){
/*  runUrl('http://support.smartbear.com/samples/testcomplete10/weborders/')
    runUrl('http://support.smartbear.com/samples/testcomplete10/weborders/') */
  setInPageh(
    {ObjectType: 'Form'},
    function(obj){return hasText(obj.idStr, 'username')},
    3, 'John');
    
  setInPageh(
    function(obj){return hasText(obj.idStr, 'username')},
    3, 'Ghost');
    
  setInPageh({idStr: '*username'}, 3, 'Ghost Again');
  
  /* too shallow should fail */
  expectDefect('9999');
  setInPageh(
    {ObjectType: 'Form'},
    function(obj){return hasText(obj.idStr, 'username')},
    0, 2, 'JW');
  endDefect();
}

function setInPageEndPoint(){
  /*  runUrl('http://support.smartbear.com/samples/testcomplete10/weborders/') */
  setInPage(
    {ObjectType: 'Form'},
    function(obj){return hasText(obj.idStr, 'username')},
    3, 'John');
    
  setInPage(
    function(obj){return hasText(obj.idStr, 'username')},
    3, 'Ghost');
    
  setInPage({idStr: '*username'}, 3, 'Ghost Again');
  
  /* too shallow should fail */
  expectDefect('9999');
  setInPage(
    {ObjectType: 'Form'},
    function(obj){return hasText(obj.idStr, 'username')},
    0, 2);
  checkFalse(txt.Exists);
  endDefect();

}

function seekByObjectIdentifierhEndPoint(){
  /* runUrl('http://support.smartbear.com/samples/testcomplete10/weborders/') */
  setInPage('ctl00_MainContent_username');
  
  /* too shallow should fail + wait > 2 secs */
  obj = seekByObjectIdentifierh(
    {ObjectType: 'Form'}, 2000, 2,
     'ctl00_MainContent_username'
    );
  checkFalse(obj.Exists);
  
  var obj = seekByObjectIdentifierh(
    {ObjectType: 'Form'}, 1000, 3,
      "*username"
  );
  check(obj.Exists);
  
  var form = seekByProperty('ObjectType', 'Form');
    var obj = seekByObjectIdentifierh(
    form, 1000, 3,
      "*username"
  );
  check(obj.Exists);
}

function seekByObjectIdentifierEndPoint(){
  /* runUrl('http://support.smartbear.com/samples/testcomplete10/weborders/') */
  var obj = seekByObjectIdentifier('ctl00_MainContent_username');
  check(obj.Exists);
  
  /* too shallow should fail + wait > 2 secs */
  obj = seekByObjectIdentifier(
    {ObjectType: 'Form'}, 2000, 2,
     'ctl00_MainContent_username'
    );
  checkFalse(obj.Exists);
  
  var obj = seekByObjectIdentifier(
    {ObjectType: 'Form'}, 1000, 3,
      "*username"
  );
  check(obj.Exists);
}

function seekByIdStrhEndPoint(){
  /* runUrl('http://support.smartbear.com/samples/testcomplete10/weborders/') */
  var obj = seekByIdStrh('ctl00_MainContent_username');
  check(obj.Exists);
  
  /* too shallow should fail + wait > 2 secs */
  obj = seekByIdStrh(
    {ObjectType: 'Form'}, 2000, 2,
     'ctl00_MainContent_username'
    );
  checkFalse(obj.Exists);
  
  var obj = seekByIdStrh(
    {ObjectType: 'Form'}, 1000, 3,
      "*username"
  );
  check(obj.Exists);
}

function seekByIdStrEndPoint(){
  /* runUrl('http://support.smartbear.com/samples/testcomplete10/weborders/') */
  var obj = seekByIdStr('ctl00_MainContent_username');
  check(obj.Exists);
  
  /* too shallow should fail + wait > 2 secs */
  obj = seekByIdStr(
    {ObjectType: 'Form'}, 2000, 2,
     'ctl00_MainContent_username'
    );
  checkFalse(obj.Exists);
  
  var obj = seekByIdStr(
    {ObjectType: 'Form'}, 1000, 3,
      "*username"
  );
  check(obj.Exists);
}

function seekByPropertyhEndPoint(){
  /* runUrl('http://support.smartbear.com/samples/testcomplete10/weborders/') */
  var obj = seekByPropertyh('idStr', 'ctl00_MainContent_username');
  check(obj.Exists);
  
  /* too shallow should fail */
  obj = seekByPropertyh(
    {ObjectType: 'Form'}, 1000, 2,
     'idStr', 'ctl00_MainContent_username'
    );
  checkFalse(obj.Exists);
  
  /* too shallow should fail + wait > 2 secs */
  obj = seekByPropertyh(
    {ObjectType: 'Form'}, 2000, 2,
     'idStr', 'ctl00_MainContent_username'
    );
  checkFalse(obj.Exists);
  
  var txt = obj = seekByPropertyh(
    {ObjectType: 'Form'}, 1000, 3,
     'Name', 'Textbox("ctl00_MainContent_username")'
    );
  check(obj.Exists);
}

function seekByPropertyEndPoint(){
  /* runUrl('http://support.smartbear.com/samples/testcomplete10/weborders/') */
  var obj = seekByProperty(
    {ObjectType: 'Form'}, 3000, 20,
     'idStr', 'ctl00_MainContent_username'
   );
  check(obj.Exists);
  
  /* too shallow should fail */
  obj = seekByProperty(
    {ObjectType: 'Form'}, 1000, 2,
     'idStr', 'ctl00_MainContent_username'
    );
  checkFalse(obj.Exists);
  
  /* too shallow should fail + wait > 2 secs */
  obj = seekByProperty(
    {ObjectType: 'Form'}, 2000, 2,
     'idStr', 'ctl00_MainContent_username'
    );
  checkFalse(obj.Exists);
  
  var txt = obj = seekByProperty(
    {ObjectType: 'Form'}, 1000, 3,
     'idStr', '*username'
    );
  check(obj.Exists);
}

function activeBrowserEndPoint() {
  var browser = activeBrowser();
  ShowMessage(browser.Exists);
}

function targetBrowserNameEndPoint() {
  var browser = targetBrowserName();
  setTargetBrowserName('chrome');
  browser = targetBrowserName();
  checkEqual('chrome', browser);
  
  setTargetBrowserName('iexplore');
  browser = targetBrowserName();
  checkEqual('iexplore', browser);
}

function goUrlEndPoint() {
  goUrl('http://support.smartbear.com/samples/testcomplete10/weborders/')
}

function readInPageEndPoint(){
  /* runUrl('http://support.smartbear.com/samples/testcomplete10/weborders/') */
  setByObjectIdentifier('*username', 'the ghost');
  
  var txt = readInPage(
    {ObjectType: 'Form'},
    function(obj){return hasText(obj.idStr, 'username')},
    3);
  checkEqual('the ghost', txt);
  
  var txt = readInPage(
    BROWSER_NAME_FIREFOX(),
    function(obj){return hasText(obj.idStr, 'username')});
  checkEqual('the ghost', txt);;
  
  expectDefect('000')
  /*  too shallow should fail */
  var txt = readInPage(
    {ObjectType: 'Form'},
    function(obj){return hasText(obj.idStr, 'username')},
    0, 2);
  endDefect();
}

function seekInPageEndPoint(){
  /* runUrl('http://support.smartbear.com/samples/testcomplete10/weborders/') */
  var txt = seekInPage(
    {ObjectType: 'Form'},
    function(obj){return hasText(obj.idStr, 'username')},
    3);
  check(txt.Exists);
  
  /* too shallow should fail */
  var txt = seekInPage(
    {ObjectType: 'Form'},
    function(obj){return hasText(obj.idStr, 'username')},
    0, 2);
  checkFalse(txt.Exists);
  
  /* too shallow should fail + wait > 5 secs */
  var txt = seekInPage(
    {ObjectType: 'Form'},
    function(obj){return hasText(obj.idStr, 'username')},
    5000, 2);
  checkFalse(txt.Exists);
  
  var txt = seekInPage(
    BROWSER_NAME_FIREFOX(),
    {ObjectType: 'Form'},
    function(obj){return hasText(obj.idStr, 'username')});
  check(txt.Exists);
}

function seekInPagehEndPoint(){
  /* runUrl('http://support.smartbear.com/samples/testcomplete10/weborders/') */
  var txt = seekInPageh(
    {ObjectType: 'Form'},
    function(obj){return hasText(obj.idStr, 'username')});
  check(txt.Exists);
  
  var txt = seekInPageh(
    BROWSER_NAME_FIREFOX(),
    {ObjectType: 'Form'},
    function(obj){return hasText(obj.idStr, 'username')});
  check(txt.Exists);
}


function backClickEndPoint() {
  backClick();
}

function ExtractMailToFromHrefUnittest() {
  var href = 'mailto:enquiries@acmi.com.au';
  var result = extractMailToFromHref(href);
  checkEqual('enquiries@acmi.com.au', result);
  
  href = 'mailto:enquiries@avalonwaterways.co.nz?subject=Website Enquiry';
  result = extractMailToFromHref(href);
  checkEqual('enquiries@avalonwaterways.co.nz', result);
}

function waitActivePageEndPoint() {
  var result = waitActivePage(1);
}

function activePageEndPoint() {
  var page = activePage();
}

function closeBrowserUnitTest(){
  closeBrowser();  
}


// © John Walker 2013 – Permission for unrestricted use and modification granted within 
// THE-COMPANY and affiliated companies