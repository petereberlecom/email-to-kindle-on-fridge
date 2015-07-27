# gem install gmail - https://github.com/dcparker/ruby-gmail
require 'gmail'
require 'sinatra'
require 'base64'

gmail_login = ARGV[0]
gmail_password = ARGV[1]
$gmail = Gmail.new gmail_login, gmail_password
$currently_displayed_email_uid = nil

def fetch_last_email
  email = $gmail.inbox.emails.last
  if email.uid == $currently_displayed_email_uid
    return
  end
   
  $currently_displayed_email_uid = email.uid
  $sender = email.sender.first.name
  $subject = email.subject
  $received_at = email.envelope.date
  $image = nil
  if email.attachments.size > 0
    $image = email.attachments.first.decoded
  end
end

get '/email' do
  fetch_last_email
  
<<STRING
<html>
  <head>
    <meta http-equiv="refresh" content="10" />
  </head>
  <body>
    <p><b>#{$sender}</b>, #{$received_at}</p>
    <h1>#{$subject}</h1>
    <img src="data:image/jpg;base64,#{Base64.encode64($image) if $image}" style="width:100%;">
  </body>
</html>
STRING
end


#gmail.logout