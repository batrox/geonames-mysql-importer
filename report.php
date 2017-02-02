<?php

if (file_exists(__DIR__.'/off')) die('off');

$today = date('Y-m-d');

$files = glob(__DIR__.'/var/'.$today.'/*.txt');

if (!count($files)) {
    mailme("No file found today of import failed ! Manual check required...", "ERROR DB Geonames", "Batrox", true);
    touch(__DIR__.'/off');
}
