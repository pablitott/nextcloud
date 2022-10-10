<?php

// Import PHPMailer classes into the global namespace
// These must be at the top of your script, not inside a function
use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

// If necessary, modify the path in the require statement below to refer to the
// location of your Composer autoload.php file.
// require 'vendor/autoload.php';
// require_once("/usr/src/myapp" . '/vendor/autoload.php');
// Replace sender@example.com with your "From" address.
// This address must be verified with Amazon SES.
$sender = 'webadmin@drawingmonos.com';
$senderName = 'Web Admin do not reply';

// Replace recipient@example.com with a "To" address. If your account
// is still in the sandbox, this address must be verified.
$recipient = 'batlink77@gmail.com';

// Replace smtp_username with your Amazon SES SMTP user name.
$usernameSmtp = 'AKIA2BKRFWRACIFKKYNR';

// Replace smtp_password with your Amazon SES SMTP password.
$passwordSmtp = 'BLwECfcVBDcM/TKlAA09fo+cUpnUt/a20tBCvg/u4RsQ';

// Specify a configuration set. If you do not want to use a configuration
// set, comment or remove the next line.
$configurationSet = 'drawmonosmail';

// If you're using Amazon SES in a region other than US West (Oregon),
// replace email-smtp.us-west-2.amazonaws.com with the Amazon SES SMTP
// endpoint in the appropriate region.
$host = 'email-smtp.us-east-1.amazonaws.com';
$port = 587;
$name    = $_POST['contact_name'];
$email   = $_POST['contact_email'];
$message = $_POST['contact_message'];
// The subject line of the email

$subject = 'Customer interested ' . $name ;

// The plain-text body of the email
$bodyText =  "Email Test\r\n from click on me test " . $argv[0];
    // Amazon SES SMTP interface using the PHPMailer class.";

// The HTML-formatted body of the email
$bodyHtml = '<p>Contact Name:' . $name . "</p>" . 
    "<p> customer email: " . $email . "</p>" . 
     "<p>Message: </p>" . 
     "<p>" . $message . "</p>";

// use PHPMailer\PHPMailer\PHPMailer;
// use PHPMailer\PHPMailer\Exception;
    
require '/usr/src/myapp/PHPMailer/src/Exception.php';
require '/usr/src/myapp/PHPMailer/src/PHPMailer.php';
require '/usr/src/myapp/PHPMailer/src/SMTP.php';

$mail = new PHPMailer(true);

try {
    // Specify the SMTP settings.
    $mail->isSMTP();
    $mail->setFrom($sender, $senderName);
    $mail->Username   = $usernameSmtp;
    $mail->Password   = $passwordSmtp;
    $mail->Host       = $host;
    $mail->Port       = $port;
    $mail->SMTPAuth   = true;
    $mail->SMTPSecure = 'tls';
    $mail->addCustomHeader('X-SES-CONFIGURATION-SET', $configurationSet);

    // Specify the message recipients.
    $mail->addAddress($recipient);
    // You can also add CC, BCC, and additional To recipients here.

    // Specify the content of the message.
    $mail->isHTML(true);
    $mail->Subject    = $subject;
    $mail->Body       = $bodyHtml;
    $mail->AltBody    = $bodyText;
    $mail->Send();
    echo "Email sent!" , PHP_EOL;
} catch (phpmailerException $e) {
    echo "An error occurred. {$e->errorMessage()}", PHP_EOL; //Catch errors from PHPMailer.
} catch (Exception $e) {
    echo "Email not sent. {$mail->ErrorInfo}", PHP_EOL; //Catch errors from Amazon SES.
}

?>

