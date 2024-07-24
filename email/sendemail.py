import smtplib
import os

sender_user =  os.environ.get('SENDER_USER') # ok
#sender_user = 'pablitott@mydeskweb.awsapps.com'
sender_password = os.environ.get('SENDER_PWD')

sent_from = sender_user
to = [ os.environ.get('TARGET_EMAIL') ]
subject = 'Lorem ipsum dolor sit amet'
body = 'consectetur adipiscing elit'

email_text = """\
From: %s
To: %s
Subject: %s

%s
""" % (sent_from, ", ".join(to), subject, body, )

try:
    smtp_server = smtplib.SMTP_SSL('smtp.mail.us-east-1.awsapps.com', 465)
    smtp_server.ehlo()
    
    smtp_server.login(sender_user, sender_password)
    smtp_server.sendmail(sent_from, to, email_text)
    smtp_server.close()
    print ("Email sent successfully!")
except Exception as ex:
    print ("Something went wrong….",ex)