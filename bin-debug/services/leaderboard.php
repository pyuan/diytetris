<?php
	
	//'set' adds data to board if qualifies and returns leaderboard in xml, 'check' returns if data qualifies, 'get' just returns leaderboard in xml
	$command = $_POST["command"]; 
	$mName = isset($_POST["name"]) ? $_POST["name"] : "Firstname Lastname";
	$mScore = isset($_POST["score"]) ? $_POST["score"] : 0;
	$mLevel = isset($_POST["level"]) ? $_POST["level"] : 0;
	$mCountry = isset($_POST["country"]) ? $_POST["country"] : "na";
	
	$XML_URL = "../data/leaderboard.xml";
	$NUMBER_LEADERS = 20;
	$xml = simplexml_load_file($XML_URL);
	$leaders = array();
	$lowest_leader = null;
	
	//parse through xml leaderboard
	$i = 0;
	$low_score = $mScore;
	foreach($xml->children() as $leader)
	{
		$name = "";
		$score = -1;
		$level = -1;
		$country = "";
		
		foreach($leader->children() as $property)
		{
			$node = $property->getName();
			if($node == 'name')
			{
				$name = $property;
			}
			else if($node == 'score')
			{
				$score = (int) $property;
			}
			else if($node == 'level')
			{
				$level = (int) $property;
			}
			else if($node == 'country')
			{
				$country = $property;
			}
		}
		
		$obj = new Leader($name, $score, $level, $country, $i);
		$leaders[] = $obj;
		$i++;
		
		if($score < $low_score){
			$low_score = $score;
			$lowest_leader = $obj;
		}
	}
	
	if($command == "check"){
		if($lowest_leader != null || count($leaders) < $NUMBER_LEADERS){
			echo 1;
		}
		else{
			echo 0;
		}
	}
	else if($command == "set"){
		
		if(count($leaders) < $NUMBER_LEADERS){
			$obj = new Leader($mName, $mScore, $mLevel, $mCountry, -1);
			$leaders[] = $obj;
		}
		else{
			if($lowest_leader != null){
				unset($leaders[$lowest_leader->index]);
				$obj = new Leader($mName, $mScore, $mLevel, $mCountry, -1);
				$leaders[] = $obj;
			}
		}
		
		//persist data to xml document
		$doc = new DOMDocument();
		$doc->formatOutput = true;
		
		$r = $doc->createElement( "leaders" );
		$doc->appendChild($r);
		
		foreach($leaders as $leader)
		{
			$b = $doc->createElement( "leader" );
			
			$xml_name = $doc->createElement( "name" );
			$xml_name->appendChild(
				$doc->createTextNode( $leader->name )
			);
			$b->appendChild( $xml_name );
			
			$xml_score = $doc->createElement( "score" );
			$xml_score->appendChild(
				$doc->createTextNode( $leader->score )
			);
			$b->appendChild( $xml_score );
			
			$xml_level = $doc->createElement( "level" );
			$xml_level->appendChild(
				$doc->createTextNode( $leader->level )
			);
			$b->appendChild( $xml_level );
			
			$xml_country = $doc->createElement( "country" );
			$xml_country->appendChild(
				$doc->createTextNode( $leader->country )
			);
			$b->appendChild( $xml_country );
			
			$r->appendChild( $b );
		}
		
		$doc->save($XML_URL);
		returnLeaderboard($leaders);
	}
	else if($command == "get"){
		returnLeaderboard($leaders);
	}
	
	//return updated leaderboard as xml
	function returnLeaderboard($leaders)
	{
		header("Content-type: text/xml");
		$xml = '<?xml version="1.0" encoding="utf-8"?>';
		$xml .= "<leaders>";
		foreach($leaders as $leader){
			$xml .= "\n<leader>";
			$xml .= "\n\t<name>$leader->name</name>";
			$xml .= "\n\t<score>$leader->score</score>";
			$xml .= "\n\t<level>$leader->level</level>";
			$xml .= "\n\t<country>$leader->country</country>";
			$xml .= "\n</leader>";
		}
		$xml .= "\n</leaders>";
		echo $xml;
	}
	
	class Leader
	{
		public $name = "";
		public $score = -1;
		public $level = -1;
		public $country = "";
		public $index = -1;
		
	    function Leader($name, $score, $level, $country, $index)
	    {
	        $this->name = $name;
			$this->score = $score;
			$this->level = $level;
			$this->country = $country;
			$this->index = $index;
	    }
	}
	
?>