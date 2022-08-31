<?php
require 'sot3_Common.php';

if (!isset($_REQUEST['instrument'])) {
   $_REQUEST['instrument'] = 'Observations';
}
if (!isset($_REQUEST['cur_time'])) {
   $_REQUEST['cur_time'] = '2022-06-05T00:00:00';
}
if (!isset($_REQUEST['start_time'])) {
   $_REQUEST['start_time'] = '2022-06-05T00:00:00';
}
if (!isset($_REQUEST['end_time'])) {
   $_REQUEST['start_time'] = '2022-06-05T22:00:00';
}
if (!isset($_REQUEST['rows'])) {
   $_REQUEST['rows'] = '12';
}

$cur_time = $_REQUEST['cur_time'].":00";
$start_time = $_REQUEST['start_time'].":00";
$end_time = $_REQUEST['end_time'].":59";
$max_lines = $_REQUEST['rows'];
$instrument = $_REQUEST['instrument'];

$observ_checked = "";
$susi_checked = "";
$scip_checked = "";
$tumag_checked = "";

switch ($_REQUEST['instrument']) {
   case "Observations" :
   $observ_checked = "checked";
   break;
   case "SUSI" :
   $susi_checked = "checked";
   break;
   case "SCIP" :
   $scip_checked = "checked";
   break;
   case "TuMag" :
   $tumag_checked = "checked";
   break;
   default :
   $observ_checked = "checked";
}


$csv_data = [];
read_csv_data($csv_data, $start_time, $end_time);
// ---------------------------------------------------------------------------
// ----------------------- Output: Observations ------------------------------
// ---------------------------------------------------------------------------
if ($observ_checked == "checked") {
   $observ_html = table_HTML($csv_data, "Observations", $cur_time, $start_time, $end_time, $max_lines);
   echo $observ_html;
}
if ($susi_checked == "checked") {
   $susi_html = table_HTML($csv_data, "SUSI", $cur_time, $start_time, $end_time, $max_lines);
   echo $susi_html;
}
if ($scip_checked == "checked") {
   $scip_html = table_HTML($csv_data, "SCIP", $cur_time, $start_time, $end_time, $max_lines);
   echo $scip_html;
}
if ($tumag_checked == "checked") {
   $tumag_html = table_HTML($csv_data, "TuMag", $cur_time, $start_time, $end_time, $max_lines);
   echo $tumag_html;
}

echo "</table>\n";
echo "</body>\n";
echo "</html>\n";
   
