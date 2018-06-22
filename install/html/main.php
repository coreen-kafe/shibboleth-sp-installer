
<?php
    $hostname = gethostbyaddr($_SERVER['SERVER_ADDR']);
    $url = "https://" . $hostname . "/Shibboleth.sso/Login?target=https://".$hostname . "/secure";

    $username = $_SERVER['REMOTE_USER'];
    if (!isset($username) || empty($username)){
	print "<p>Anonymous user ";
	print "<a href='" . $url . "'>Login</a></p>";
    } else {
	print "<p>Authenticated user: ". $username. "</p>";
    }
?>

