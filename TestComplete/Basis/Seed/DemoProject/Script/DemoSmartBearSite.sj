//USEUNIT WebUtils
//USEUNIT SysUtils


/** Module Info **

?????_NO_DOC_?????

**/





/**

?????_NO_DOC_?????

== Related ==
?????_NO_DOC_?????
**/
function WEB_ORDERS_LOG_IN_URL(){return 'http://secure.smartbearsoftware.com/samples/TestComplete12/WebOrders/Login.aspx';}
function WEB_ORDERS_DEFAULT_URL(){return 'http://secure.smartbearsoftware.com/samples/TestComplete10/WebOrders/default.aspx' }

function populateLogIn(userName, password){
  setForm(
          {
            Username: def(userName, 'Tester'), 
            Password: def(password, 'test')
          }
        );
}

function clickLogIn(){
  clickByProperty('value', 'LogIn');
}

function logInSmartBear(userName, password){
  goUrl(WEB_ORDERS_LOG_IN_URL());
  waitActivePage();
  populateLogIn(userName, password);
  clickLogIn();
  waitActivePage();
}

function logInSmartBearEndPoint() {
  logInSmartBear('Tester', 'test')
}
 


