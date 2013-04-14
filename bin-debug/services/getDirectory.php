<?php

	$path = "assets";
	$root = "../$path";
	$dir = $_GET['dir'];
	
	$files = scandir($root . $dir);
	header("Content-type: text/xml");
	$xml = '<?xml version="1.0" encoding="utf-8"?>';
	
	$xml .= '<content>';
	
	foreach($files as $file){
		if($file != '.' && $file != '..'){
			$extension = substr($file, -4);
			$is_valid = validateExtension($dir, $extension);
			if($is_valid){
				$xml .= '<link>' . $path . $dir . '/' . $file . '</link>';
			}
		}
	}
	
	$xml .= '</content>';
	
	echo $xml;
	
	function validateExtension($dir, $extension)
	{
		switch($dir){
			case '/levels':
				$extensions = array('.xml');
				break;
			case '/audio/backgrounds':
				$extensions = array('.mp3', '.wav');
				break;	
			default:
				$extensions = array('.jpg', '.png', '.gif', '.bmp', '.swf');
				break;
		}
		
		$is_valid = false;
		foreach($extensions as $ext){
			if($extension == $ext){
				$is_valid = true;
				break;
			}
		}
		return $is_valid;
	}

?>