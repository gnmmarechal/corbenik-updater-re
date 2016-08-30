<?php
echo "CURE Nightly Script Updater";
//Download the CURE nightly script
file_put_contents("cure-nightly-test.lua", file_get_contents("https://github.com/gnmmarechal/corbenik-updater-re/raw/master/index-server.lua"));
//Check MD5 hash against current script hash
$currentmd5 = md5_file("cure-nightly.lua");

$newmd5 = md5_file("cure-nightly-test.lua");

if ($currentmd5 == $newmd5)
{
	//Deletes the CURE script downloaded if hash is the same
	unlink("cure-nightly-test.lua");
}
else
{
	//Delete the current CURE and replace it with the new one
	unlink("cure-nightly.lua");
	rename("cure-nightly-test.lua", "cure-nightly.lua");
}
?>