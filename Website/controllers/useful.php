<?php

$data = array();
$SITE_URL = 'http://detobel36.ddns.net/MTA/';
$db_name = 'mta';
$GOOGLE_KEY='';

function base_url($page = "") {
    global $SITE_URL;
    return $SITE_URL . $page;
}

function current_url() {
    return 'http://' . $_SERVER['HTTP_HOST'] . $_SERVER['REQUEST_URI'];
}

function url_image($nomImage) {
    return base_url() . 'assets/images/' . $nomImage;
}

function loadModel($name) {
    global $db_name;
    require_once(__DIR__ . '/../model/bdd.php');
    require_once(__DIR__ . '/../model/' . $name . '.php');
}

function loadHeader($data = array()) {
    $allData = extract($data);
    global $allData;
    require_once(__DIR__ . '/../views/include/header.php');
}

function loadFooter($data = array()) {
    $allData = extract($data);
    global $allData;
    require_once(__DIR__ . '/../views/include/footer.php');
}

function loadView($viewName, $data = array()) {
    $allData = extract($data);
    global $allData;
    require_once(__DIR__ . '/../views/' . $viewName . '.php');
}

function makeRequest($url, $dataArray = array()) {
    $ch = curl_init();
    if(count($dataArray) > 0) {
        $data = http_build_query($dataArray);
        $getUrl = $url."?".$data;
    } else {
        $getUrl = $url;
    }
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, FALSE);
    curl_setopt($ch, CURLOPT_FOLLOWLOCATION, TRUE);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, TRUE);
    curl_setopt($ch, CURLOPT_URL, $getUrl);
    curl_setopt($ch, CURLOPT_TIMEOUT, 80);
    curl_setopt($ch, CURLOPT_HTTPHEADER,array (
        "Accept: application/json"
    ));
     
    $result = curl_exec($ch);

    if(curl_error($ch)) {
        echo '<br />Request Error:' . curl_error($ch) . '<br />';
        return NULL;
    }

    return $result;
}

function makeJsonRequest($url, $dataArray = array()) {
    return json_decode(makeRequest($url, $dataArray), FALSE);
}

function makeJsonRequestToArray($url, $dataArray = array()) {
    return json_decode(makeRequest($url, $dataArray), TRUE);
}
