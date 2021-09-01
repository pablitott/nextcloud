<!doctype html>
<html>
<head>
<meta charset="utf-8">
<title>Untitled Document</title>
</head>
<?php 
  // captura de datos por medio de POST
	$my_email="pavel.trujillo.p@gmail.com";
	$contact_name=$_POST['contact_name'];
	$contact_email=$_POST['contact_email'];
	$contact_message=$_POST['contact_message'];
	$content="contact_name: ".$contact_name."\ncontact_email:".$contact_email."\ncontact_message:".$contact_message;
	mail("$my_email","contact","$content");
	if($correo)
	{
		echo"<p>Your information has been sent</p>";
	}
	else
	{
		echo"<p>We're sorry, something went wrong</p>";
	}
?>

<body>
</body>
</html>