<!DOCTYPE html>
<html>
<head>
  <title>Sunrise III - Coobservation Data</title>
  <meta charset='utf-8'>
  <meta http-equiv="refresh" content="120">
  <script type='text/javascript' src='sot3.js'></script>

  <link rel='stylesheet' href='sot3.css'></style>

  <noscript>
    <h2 style='color: red'>You dont't have JavaScript enabled. Please consider enabling it, as some features of this page won't work without!</h2>
  </noscript>

</head>
<body>
<?php 
require 'sot3_Common.php';

if (!isset($_GET['instrument'])) {
   $_GET['instrument'] = 'Observations';
}

$observ_checked = "";
$susi_checked = "";
$scip_checked = "";
$tumag_checked = "";

switch ($_GET['instrument']) {
   case "Observations" :
   $observ_checked = "checked";
   break;
   case "SUSI" :
   $susi_checked = "checked";
   break;
   case "SCIP" :
   $scip_checked = "checked";
   break;
   case "TUMAG" :
   $tumag_checked = "checked";
   break;
   default :
   $observ_checked = "checked";
}



if (isset($_GET['cur_time'])) {
   $cur_time = $_GET['cur_time'];
} else {
   $cur_time = "2022-06-05T06:00:00";
   $cur_time = date("Y-m-d\TH:i:s");
}
if (isset($_GET['start_time'])) {
   $start_time = $_GET['start_time'];
} else {
   $start_time = "2022-06-05T06:00:00";
   $start_time = date("Y-m-d\TH:i:s");
}
if (isset($_GET['end_time'])) {
   $end_time = $_GET['end_time'];
} else {
   $end_time = "2022-06-07T06:00:00";
   $end_time = date("Y-m-d\TH:i:s");
}


?>
<span style='background:#eeeeee; border-top:0px; xposition: fixed; width: 100%'> 
<h1>Sunrise III Co-observation Data Resource</h1>
<form action='sot3.php' method='get' id='options_form'>
  <label>Current Time:</label> <input type='datetime-local' name='cur_time' value='<?php echo $cur_time; ?>'>
  <label>Start Data Time:</label> <input type='datetime-local' name='start_time' value='<?php echo $start_time; ?>'>
  <label>End Data Time:</label> <input type='datetime-local' name='end_time' value='<?php echo $end_time; ?>'>
<br>
   <input type='radio' id='ins_obs' name='instrument' value='Observations' <?php echo $observ_checked; ?> onchange='document.getElementById("options_form").submit();' >
   <label for='ins_obs'>Observations</label><br>
   <input type='radio' id='ins_susi' name='instrument' value='SUSI' <?php echo $susi_checked; ?> onchange='document.getElementById("options_form").submit();' >
   <label for='ins_susi'>SUSI</label><br>
   <input type='radio' id='ins_scip' name='instrument' value='SCIP' <?php echo $scip_checked; ?> onchange='document.getElementById("options_form").submit();' >
   <label for='ins_scip'>SCIP</label><br>
   <input type='radio' id='ins_tumag' name='instrument' value='TUMAG' <?php echo $tumag_checked; ?> onchange='document.getElementById("options_form").submit();' >
   <label for='ins_obs'>TuMag</label><br>


<button type='submit'>Submit</button>
  
  
</form>
</span>

<?php 
$data_line_OBSERV = [];
$data_line_SUSI = [];
$data_line_SCIP = [];
$data_line_TUMAG = [];

$csv_data = [];
read_csv_data($csv_data, $start_time, $end_time);
$OBS_ID = "SC_0";

// ---------------------------------------------------------------------------
// ----------------------- Output: Observations ------------------------------
// ---------------------------------------------------------------------------
#$max_lines = 6;
$max_lines = 1000;
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
   
