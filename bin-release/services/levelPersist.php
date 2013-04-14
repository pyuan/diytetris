<?php
	
	$name = $_POST["name"];
	$stringData = $_POST["data"];
	
	$myFile = "../assets/levels/" . $name . ".xml";
	$fh = fopen($myFile, 'w') or die("can't open file");
	$isSuccess = fwrite($fh, $stringData);
	fclose($fh);
	
	if($isSuccess > 0){
		echo 1;
	}
	else{
		echo 0;
	}

?>