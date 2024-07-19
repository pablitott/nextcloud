import os.path
import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.application import MIMEApplication
import os
import argparse
import getpass


class Password(argparse.Action):
    def __call__(self, parser, namespace, values, option_string):
        if values is None:
            values = getpass.getpass()
        setattr(namespace, self.dest, values)

def send_email(subject, message, from_email, to_email=[], attachment=[], password=''):
    """
    :param subject: email subject
    :param message: Body content of the email (string), can be HTML/CSS or plain text
    :param from_email: Email address from where the email is sent
    :param to_email: List of email recipients, example: ["a@a.com", "b@b.com"]
    :param attachment: List of attachments, exmaple: ["file1.txt", "file2.txt"]
    """
    msg = MIMEMultipart()
    msg['Subject'] = subject
    msg['From'] = from_email
    msg['To'] = ", ".join(to_email)
    msg.attach(MIMEText(message, 'html'))
    print(attachment)
    for f in attachment:
        print(f)
        with open(f, 'rb') as a_file:
            basename = os.path.basename(f)
            part = MIMEApplication(a_file.read(), Name=basename)

        part['Content-Disposition'] = 'attachment; filename="%s"' % basename
        msg.attach(part)

    try:
      email = smtplib.SMTP_SSL('smtp.mail.us-east-1.awsapps.com', 465)
      email.ehlo()
      email.login(from_email, password)
      email.sendmail(from_email, to_email, msg.as_string())

      email.close
      print ("Email sent successfully!")
    except Exception as ex:
        print ("Something went wrong….",ex)

def main():

    parser = argparse.ArgumentParser()
    parser.add_argument('result',              type=str, help='Backup end result (succed/fail)')
    parser.add_argument('message',             type=str, help="mail message regarding the backup")
    parser.add_argument('sender_user_name',    type=str, default="automation@mydeskweb.awsapps.com", help='sender user email')
    parser.add_argument('sender_password',             help='Sender password')
    parser.add_argument("target_email",        type=str, help='list of email address to send the log')
    parser.add_argument('-a', '--attachments', type=list, dest='attachments', help='backup process log', required=False)
    args = parser.parse_args()
    
    sender_user      =  args.sender_user_name
    sender_password   =  args.sender_password
    target_email = args.target_email
    subject = "mydeskweb backup process result: " + args.result
    message = 'mydeskweb backup process'
    if args.attachments is not None:
        sender_attachment = args.attachments
        send_email(subject, message, sender_user, target_email, sender_attachment, sender_attachment, sender_password)
    else:
        send_email(subject, message, sender_user, target_email, attachment=[], password=sender_password)
        

if __name__ == "__main__":
    main()