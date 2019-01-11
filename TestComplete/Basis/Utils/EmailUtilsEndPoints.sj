//USEUNIT EmailUtils

function sendEmailEndPoint() {
  /* you would need to change this to match your credentials before 
     running this endpoint */
  var params = {
    smtpserver: "smtp.gmail.com",
    smtpserverport: 465, 
    sendusername:  "theghostjw@gmail.com",
    sendpassword: "password goes here",
    from: '"theGhost" <theghostjw1@gmail.com>',
    /* note special formatting required */
    to: '"AtGoogle" <theghostjw1@gmail.com>, "AtYahoo" <theghostjw@yahoo.com.au>',
    cc: '',
    bcc: '',
    subject: 'Important message',
    body: 'Hello from a testcomplete end point'
   /* attachments: 'C:\\Whereis.pdf,C:\\Fish Markets.pdf' */
  }
  
  sendEmail(params)

}