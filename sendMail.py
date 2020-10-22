# Source https://www.tutorialspoint.com/send-mail-from-your-gmail-account-using-python

import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
import sys, getopt

mail_content = '''Hello,
Backup succeed

'''

print("   Backup result: " + sys.argv[1] )
print("Log file to send: " + sys.argv[2] )
fileContent  = ''
logResult     = sys.argv[1]
logFile      = sys.argv[2]
fileHandler  = open(logFile,"r")

for line in fileHandler.readlines():
    fileContent += line

print( fileContent )

#The mail addresses and password
sender_address = 'pablo.trujillo.tapia@hotmail.com'
sender_pass = 'Ca11ista'
receiver_address = 'pablitott@gmail.com'
#Setup the MIME
message = MIMEMultipart()
message['From'] = sender_address
message['To'] = receiver_address
message['Subject'] = logResult   #The subject line
#The body and the attachments for the mail
message.attach(MIMEText(fileContent, 'plain'))
#Create SMTP session for sending the mail
session = smtplib.SMTP('smtp.office365.com', 587) #use gmail with port
session.starttls() #enable security
session.login(sender_address, sender_pass) #login with mail_id and 'password'
text = message.as_string()
session.sendmail(sender_address, receiver_address, text)
session.quit()
print('Mail Sent')
