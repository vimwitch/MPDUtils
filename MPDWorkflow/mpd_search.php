$q = "{query}";
if(strlen($q) == 0){
	return;
}

$mpdUtilsPath = "/Users/Chance/JCHDev/MPDUtils/MPDUtils";

echo '<?xml version="1.0"?>
<items>';

$resultsFound = 0;
$count;

$artistList = shell_exec($mpdUtilsPath.' -tA -s "'.$q.'"');
foreach(preg_split("/((\r?\n)|(\r\n?))/", $artistList) as $line){
	if(strlen($line) == 0){
		continue; //skip blank lines
	}
	$final = htmlspecialchars($line, ENT_QUOTES);
    echo '<item uid="'.$final.'" arg="'.$final.'">
    <title>Play songs by '.$final.'</title>
  	</item>';
	$resultsFound = 1;
}

$songList = shell_exec($mpdUtilsPath.' -s "'.$q.'"');

foreach(preg_split("/((\r?\n)|(\r\n?))/", $songList) as $line){
	if(strlen($line) == 0){
		continue; //skip blank lines
	}
	$finalFixed = htmlspecialchars($line, ENT_QUOTES);
	$pipePos1 = strpos($finalFixed, "|");
	$pipePos2 = strpos($finalFixed, "|", $pipePos1+1);
	$uri = substr($finalFixed, 0, $pipePos1);
	$name = substr($finalFixed, $pipePos1+1, $pipePos2-$pipePos1-1);
	$artist = substr($finalFixed, $pipePos2+1);
	
    echo '<item uid="'.$uri.'" arg="'.$uri.'">
    <title>'.$name.'</title>
	<subtitle>'.$artist.'</subtitle>
	<icon>icon.png</icon>
  	</item>';
	$resultsFound = 1;
	if($count > 20)
		break;
	$count++;
}

if($resultsFound == 0){
	echo '<item uid="nonefound" valid="no"><title>No results found</title><subtitle>Big noob</subtitle><icon>icon.png</icon></item>';
}

echo '</items>';