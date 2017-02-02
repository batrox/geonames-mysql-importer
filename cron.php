<?php

if (file_exists(__DIR__.'/off')) die('off');

$today = date('Y-m-d');

$files = glob(__DIR__.'/var/'.$today.'/*.txt');

if (count($files)) {
    exit;
}

exec('/home/batrox/geonames/geonames-mysql-importer/importer.sh update');



