$mpdUtilsPath = "/Users/Chance/JCHDev/MPDUtils/MPDUtils";
$q = htmlspecialchars_decode("{query}", ENT_QUOTES);
$q = str_replace('"', '\\"', $q);

shell_exec($mpdUtilsPath.' -a "'.$q.'"');
