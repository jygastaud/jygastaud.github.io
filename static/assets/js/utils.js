function sendMail(){
  $.ajax({
    type: "POST",
    url: "https://mandrillapp.com/api/1.0/messages/send.json",
    data: {
      'key': 'Tz_I7rcotIloB5vR6sf9aw',
      'message': {
        'from_email': 'jygastaud@gmail.com',
        'to': [
          {
            'email': 'jygastaud@gmail.com',
            'name': 'Contact Gastaud.io',
            'type': 'to'
          }
        ],
        'subject': '[Gastaud.io] Me contacter - ' + document.getElementById("subject").value,
        'text': document.getElementById("message").value
      }
    },
    error: function(xhr, status, error) {

      var err = eval("(" + xhr.responseText + ")");
      alert(err.Message);
    },
    success: function ( )
    {
     alert ( " Done ! " );
   }
  });
}

$('.ui.form')
  .form({
    email: {
      identifier  : 'email',
      rules: [
        {
          type   : 'email',
          prompt : 'Please enter a valid e-mail'
        }
      ]
    },
    subject: {
      identifier : 'subject',
      rules: [
        {
          type   : 'empty',
          prompt : 'Please enter a subject'
        }
      ]
    },
    message: {
      identifier : 'message',
      rules: [
        {
          type   : 'empty',
          prompt : 'Please enter a message'
        }
      ]
    },
  })
;
