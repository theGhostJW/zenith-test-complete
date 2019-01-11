//USEUNIT SysUtils
//USEUNIT _


/** Module Info **

Provides a wrapper around CDO.send for a generic email send function

**/


/**
A modified version of the implementation shown in [[http://support.smartbear.com/viewarticle/26637/|Sending Emails from Scripts]]
Uses CDO - Collaboration Data Objects to send emails

== Params ==
params: an emailParams object -  Required -  this object contains all the properties required to send the email see example for details. Also see [[http://msdn.microsoft.com/en-us/library/exchange/aa487617%28v=exchg.65%29.aspx|Formatting of send, CC and BCC fields]]
== Return ==
Boolean: true if the email was sent successfully 
**/
function sendEmail(params){

  try {
    var schema = "http://schemas.microsoft.com/cdo/configuration/";
    var config = Sys.OleObject("CDO.Configuration");
    config.Fields.Item(schema + "sendusing") = 2; // cdoSendUsingPort
    config.Fields.Item(schema + "smtpserver") = params.smtpserver; // SMTP server
    config.Fields.Item(schema + "smtpserverport") = params.smtpserverport; // Port number
    config.Fields.Item(schema + "smtpauthenticate") = 1; // Authentication mechanism
    config.Fields.Item(schema + "sendusername") = params.sendusername; // User name (if needed)
    config.Fields.Item(schema + "sendpassword") = params.sendpassword; // User password (if needed)
    config.Fields.Item(schema + "smtpusessl") = true; // User password (if needed)
    config.Fields.Update();

    var message = Sys.OleObject("CDO.Message");
    message.Configuration = config;
    message.From = params.from;
    message.To = def(params.to, '');
    message.CC  = def(params.cc, '');
    message.BCC  = def(params.bcc, '');
    message.Subject = def(params.subject, '');
    
    var body = aqString.Replace(params.body, newLine(),'<br>');
    message.HTMLBody = body;

    if (hasValue(params.attachments)){
      var attachments = def(params.attachments, '').split(',');
      _.each(attachments, 
            function(path){
              message.AddAttachment(path);
            }
        );
    }
    
    message.Send();
    
    log("Message to <" + message.To + "> was successfully sent", body);
    return true;
  }
  catch (exception) {
    logError("E-mail cannot be sent", exception.description);
    return false;
  }
  
}

