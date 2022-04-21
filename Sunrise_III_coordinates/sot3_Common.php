<?php



function table_HTML($csv_data, $instrument, $cur_time, $start_time, $end_time, $max_lines) {

   $csv_data = [];
   read_csv_data($csv_data, $start_time, $end_time);
   $table_html = table_header($instrument);

   $line = 0;
   $green_counter = 0;
   $OBS_ID= get_first_OBS_ID($csv_data);
   while ($OBS_ID != "") {
      get_data($csv_data, $OBS_ID, $instrument, $data_line);
      if ($instrument == "Observations") {
         get_data($csv_data, $OBS_ID, "SUSI", $data_line);
      }      
      $line_background = get_color($cur_time, $data_line); 
         
      if ($line_background == "light_green") {
         if ($green_counter % 2  == 0) {
             $line_background = "light_green_high";
         }
         $green_counter++;
      }
      if (substr($data_line['obs_id'],0,2) == "SC") { 
         $thumbnail_icon = "<img src='icon_thumbnail.png' width='15px' height='15px'>";
      } else {
         $thumbnail_icon = "";
      }
      
      $table_html .= table_row($instrument, $data_line, $line_background, $thumbnail_icon);
      if ($line > ($max_lines-1) ) {
         break;
      }
      $line++;

      $table_html .= table_empty_row($instrument);
      
      $OBS_ID = get_next_obs_id($csv_data, $OBS_ID);
   }
   $table_html .= "</table>\n";
   return $table_html;
   
}
      
function get_first_OBS_ID($csv_data) {
   for ($i=0; $i< count($csv_data); $i++) {
      $splits = explode(",", $csv_data[$i]);
      return $splits[0];
   }
   return "";
}
      
      
function get_next_obs_id($csv_data, $OBS_ID) {
   for ($i=0; $i< count($csv_data); $i++) {
      $splits = explode(",", $csv_data[$i]);
      if (($splits[0] == $OBS_ID) && ($splits[1] == "TUMAG")) {
         if ($i < (count($csv_data) -1)) {
            $splits_next = explode(",", $csv_data[$i+1]);
            return $splits_next[0];
         } else {
            return "";
         }
      }   
   }
}

function get_data($csv_data, $OBS_ID, $instrument, &$data_line) {
   $Instrument = strtoupper($instrument);
   for ($i=0; $i< count($csv_data); $i++) {
      $splits = explode(",", $csv_data[$i]);
      if (($splits[0] == $OBS_ID) && ($splits[1] == $Instrument)) {
         $data_line['obs_id']     = $splits[0];
         $data_line['instrument'] = $splits[1];
      
         $data_line['start_time'] = $splits[2];
         $data_line['end_time']   = $splits[3];
         $data_line['xcen']       = $splits[4];
         $data_line['ycen']       = $splits[5];
         $data_line['xsize']      = $splits[6];
         $data_line['ysize']      = $splits[6];
         $data_line['obs_mode']   = $splits[8];
         $data_line['roi']        = $splits[9];

         $splits_date = explode("T", $data_line['start_time']);
         $data_line['start_date'] = $splits_date[0];
         $data_line['start_UT']   = $splits_date[1];
         
         $splits_date = explode("T", $data_line['end_time']);
         $data_line['end_date'] = $splits_date[0];
         $data_line['end_UT']   = $splits_date[1];
         
         $data_line['thumbnail'] = "";
         $data_line['scan_speed'] = "unset";
         
         
         return;
      }
   }
   return;
}    


function read_csv_data(&$csv_data, $start_time, $end_time) {
   $file = fopen('example_data.csv', 'r');
   while (($line = fgets($file)) !== false) {
   
      $splits = explode(",", $line);
      $data_start = $splits[2];
      $data_end   = $splits[3];
      
      if (($data_start >= $start_time) && ($data_end <= $end_time)) {
         $csv_data[] = $line;
      }
   }
   fclose($file);
}

function get_color($cur_time, $data) {
   $start = $data['start_time'];
   $end   = $data['end_time'];
   # echo $cur_time." ".$start."<br>";
   if (((string) $cur_time >= (string) $start) && ((string) $cur_time <= (string) $end)) {
      return "light_red";
   } else {
      if ($cur_time < $start) {
         if (substr($data['obs_id'],0,3) == 'CAL') {
            return "light_orange";
         }
         return "light_green";
      } else {
         return "light_blue";
      }
   }
}
  
function table_header($instrument) {
   if ($instrument == "Observations") {
      $observ_html = "<table width='60%' id='data_table'>\n";
      $observ_html .= "  <tr style='font-weight:bold; font-size:1.3em; background: #e2e2e2' id='data_header'>\n"; 
      $observ_html .= "    <td class='width_obs_header' colspan='2' rowspan='2'>OBs_ID</td>\n";
      $observ_html .= "    <td class='width_start_time' colspan='2' >Start time</td>\n";
      $observ_html .= "    <td class='width_end_time' colspan='2'>End time</td>\n";
      $observ_html .= "    <td class='width_xcen'>Xcen</td>\n"; 
      $observ_html .= "    <td class='width_ycen'>Ycen</td>\n"; 
      $observ_html .= "    <td class='width_roi' rowspan='2'>ROI</td>\n";
      $observ_html .= "  </tr>\n";
      $observ_html .= "  <tr style='font-weight:bold; background: #e6e6e6' id='data_header2'>\n"; 
      $observ_html .= "    <td class='width_date'>(Date)</td>\n";
      $observ_html .= "    <td class='width_time'>(UT time)</td>\n";
      $observ_html .= "    <td class='width_date'>(Date)</td>\n";
      $observ_html .= "    <td class='width_time'>(UT time)</td>\n";
      $observ_html .= "    <td class='width_xcen'>(arcsec)</td>\n";
      $observ_html .= "    <td class='width_ycen'>(arcsec)</td>\n";
      $observ_html .= "  </tr>\n";
      $observ_html .= "  <tr style='font-weight:bold; font-size:1.4em; background: rgb(244,204,204)' id='data_size'>\n"; 
      $observ_html .= "    <td colspan='9'><center>Size of the FoV is 64\"x64\"</center></td>\n";   
      $observ_html .= "  </tr>\n";
      return $observ_html;
   }
   if ($instrument == "SUSI") {
      $susi_html = "<table width='60%' id='data_table'>\n";
      $susi_html .= "  <tr style='font-weight:bold; font-size:1.3em; background: #e2e2e2' id='data_header'>\n"; 
      $susi_html .= "    <td class='width_obs_header' rowspan='2'>OBs_ID</td>\n";
      $susi_html .= "    <td class='width_instrument' rowspan='2' colspan='2'>Instrument</td>\n";
      $susi_html .= "    <td class='width_start_time' colspan='2' >Start time</td>\n";
      $susi_html .= "    <td class='width_end_time' colspan='2'>End time</td>\n";
      $susi_html .= "    <td class='width_xcen'>Xcen</td>\n"; 
      $susi_html .= "    <td class='width_ycen'>Ycen</td>\n"; 
      $susi_html .= "    <td class='width_xsize'>Xsize</td>\n"; 
      $susi_html .= "    <td class='width_scan_speed'>Scan speed</td>\n"; 
      $susi_html .= "    <td class='width_obs_mode' rowspan='2'>Obs mode</td>\n"; 
      
      $susi_html .= "    <td class='width_roi' rowspan='2'>ROI</td>\n";
      $susi_html .= "  </tr>\n";
      $susi_html .= "  <tr style='font-weight:bold; font-size:0.8em; background: #e2e2e2' id='data_header2'>\n"; 
      $susi_html .= "    <td class='width_date'>(Date)</td>\n";
      $susi_html .= "    <td class='width_time'>(UT time)</td>\n";
      $susi_html .= "    <td class='width_date'>(Date)</td>\n";
      $susi_html .= "    <td class='width_time'>(UT time)</td>\n";
      $susi_html .= "    <td class='width_xcen'>(arcsec)</td>\n";
      $susi_html .= "    <td class='width_ycen'>(arcsec)</td>\n";
      $susi_html .= "    <td class='width_xsize'>(arcsec)</td>\n";
      $susi_html .= "    <td class='width_scan_speed'>(arcsec/sec)</td>\n";
      $susi_html .= "  </tr>\n";
      $susi_html .= "  <tr style='font-weight:bold; font-size:1.4em; background: rgb(244,204,204)' id='data_size'>\n"; 
      $susi_html .= "    <td colspan='13'><center>Slit length is 60\"</center></td>\n";   
      $susi_html .= "  </tr>\n";
      return $susi_html;
   }
   
   if ($instrument == "SCIP") {
      $scip_html = "<table width='60%' id='data_table'>\n";
      $scip_html .= "  <tr style='font-weight:bold; font-size:1.3em; background: #e2e2e2' id='data_header'>\n"; 
      $scip_html .= "    <td class='width_obs_header' rowspan='2'>OBs_ID</td>\n";
      $scip_html .= "    <td class='width_instrument' rowspan='2' colspan='2'>Instrument</td>\n";
      $scip_html .= "    <td class='width_start_time' colspan='2' >Start time</td>\n";
      $scip_html .= "    <td class='width_end_time' colspan='2'>End time</td>\n";
      $scip_html .= "    <td class='width_xcen'>Xcen</td>\n"; 
      $scip_html .= "    <td class='width_ycen'>Ycen</td>\n"; 
      $scip_html .= "    <td class='width_xsize'>Xsize</td>\n"; 
      $scip_html .= "    <td class='width_scan_speed'>Scan speed</td>\n"; 
      $scip_html .= "    <td class='width_obs_mode' rowspan='2'>Obs mode</td>\n"; 
      
      $scip_html .= "    <td class='width_roi' rowspan='2'>ROI</td>\n";
      $scip_html .= "  </tr>\n";
      $scip_html .= "  <tr style='font-weight:bold; font-size:0.8em; background: #e2e2e2' id='data_header2'>\n"; 
      $scip_html .= "    <td class='width_date'>(Date)</td>\n";
      $scip_html .= "    <td class='width_time'>(UT time)</td>\n";
      $scip_html .= "    <td class='width_date'>(Date)</td>\n";
      $scip_html .= "    <td class='width_time'>(UT time)</td>\n";
      $scip_html .= "    <td class='width_xcen'>(arcsec)</td>\n";
      $scip_html .= "    <td class='width_ycen'>(arcsec)</td>\n";
      $scip_html .= "    <td class='width_xsize'>(arcsec)</td>\n";
      $scip_html .= "    <td class='width_scan_speed'>(arcsec/sec)</td>\n";
      $scip_html .= "  </tr>\n";
      $scip_html .= "  <tr style='font-weight:bold; font-size:1.4em; background: rgb(244,204,204)' id='data_size'>\n"; 
      $scip_html .= "    <td colspan='13'><center>Slit length is 60\"</center></td>\n";   
      $scip_html .= "  </tr>\n";
      return $scip_html;
   }
   
   if ($instrument == "TuMag") {
      $tumag_html = "<table width='60%' id='data_table'>\n";
      $tumag_html .= "  <tr style='font-weight:bold; font-size:1.3em; background: #e2e2e2' id='data_header'>\n"; 
      $tumag_html .= "    <td class='width_obs_header' colspan='1' rowspan='2'>OBs_ID</td>\n";
      $tumag_html .= "    <td class='width_obs_header' colspan='2' rowspan='2'>Instrument</td>\n";
      $tumag_html .= "    <td class='width_start_time' colspan='2' >Start time</td>\n";
      $tumag_html .= "    <td class='width_end_time' colspan='2'>End time</td>\n";
      $tumag_html .= "    <td class='width_xcen'>Xcen</td>\n"; 
      $tumag_html .= "    <td class='width_ycen'>Ycen</td>\n"; 
      $tumag_html .= "    <td class='width_roi' rowspan='2'>ROI</td>\n";
      $tumag_html .= "  </tr>\n";
      $tumag_html .= "  <tr style='font-weight:bold; background: #e6e6e6' id='data_header2'>\n"; 
      $tumag_html .= "    <td class='width_date'>(Date)</td>\n";
      $tumag_html .= "    <td class='width_time'>(UT time)</td>\n";
      $tumag_html .= "    <td class='width_date'>(Date)</td>\n";
      $tumag_html .= "    <td class='width_time'>(UT time)</td>\n";
      $tumag_html .= "    <td class='width_xcen'>(arcsec)</td>\n";
      $tumag_html .= "    <td class='width_ycen'>(arcsec)</td>\n";
      $tumag_html .= "  </tr>\n";
      $tumag_html .= "  <tr style='font-weight:bold; font-size:1.4em; background: rgb(244,204,204)' id='data_size'>\n"; 
      $tumag_html .= "    <td colspan='10'><center>Size of the FoV is 64\"x64\"</center></td>\n";   
      $tumag_html .= "  </tr>\n";
      return $tumag_html;
   }
}   

function table_row($instrument, $data_line, $line_background, $thumbnail_icon) {
   if ($instrument == "Observations") {
      $observ_html = "<tr id='OBSERV_".$data_line['start_time']."' class='OBSERV_row ".$line_background."'>\n";
      $observ_html .= "  <td class='width_obs_header'>".$data_line['obs_id']."</td>\n";
      $observ_html .= "  <td class='width_instr_thb'>".$thumbnail_icon.$data_line['thumbnail']."</td>\n";
      $observ_html .= "  <td class='width_date'>".$data_line['start_date']."</td>\n";
      $observ_html .= "  <td class='width_time'>".$data_line['start_UT']."</td>\n";
      $observ_html .= "  <td class='width_date'>".$data_line['end_date']."</td>\n";
      $observ_html .= "  <td class='width_time'>".$data_line['end_UT']."</td>\n";
      $observ_html .= "  <td class='width_xcen'>".$data_line['xcen']."</td>\n";
      $observ_html .= "  <td class='width_ycen'>".$data_line['ycen']."</td>\n";
      $observ_html .= "  <td class='width_roi'>".$data_line['roi']."</td>\n";
      $observ_html .= "</tr>\n";
      return $observ_html;
   }      
   if ($instrument == "SUSI") {
      $susi_html = "<tr id='SUSI_".$data_line['start_time']."' class='SUSI_row ".$line_background."'>\n";
      $susi_html .= "  <td class='width_obs_header'>".$data_line['obs_id']."</td>\n";
      $susi_html .= "  <td class='width_instr_name'>".$data_line['instrument']."</td>\n";
      $susi_html .= "  <td class='width_instr_thb'>".$thumbnail_icon.$data_line['thumbnail']."</td>\n";
      $susi_html .= "  <td class='width_date'>".$data_line['start_date']."</td>\n";
      $susi_html .= "  <td class='width_time'>".$data_line['start_UT']."</td>\n";
      $susi_html .= "  <td class='width_date'>".$data_line['end_date']."</td>\n";
      $susi_html .= "  <td class='width_time'>".$data_line['end_UT']."</td>\n";
      $susi_html .= "  <td class='width_xcen'>".$data_line['xcen']."</td>\n";
      $susi_html .= "  <td class='width_ycen'>".$data_line['ycen']."</td>\n";
      $susi_html .= "  <td class='width_xsize'>".$data_line['xsize']."</td>\n";
      $susi_html .= "  <td class='width_scan_speed'>".$data_line['scan_speed']."</td>\n";
      $susi_html .= "  <td class='width_obs_mode'>".$data_line['obs_mode']."</td>\n";
      $susi_html .= "  <td class='width_roi'>".$data_line['roi']."</td>\n";
      $susi_html .= "</tr>\n";
      return $susi_html;
   }
   
   if ($instrument == "SCIP") {
      $scip_html = "<tr id='SCIP_".$data_line['start_time']."' class='SCIP_row ".$line_background."'>\n";
      $scip_html .= "  <td class='width_obs_header'>".$data_line['obs_id']."</td>\n";
      $scip_html .= "  <td class='width_instr_name'>".$data_line['instrument']."</td>\n";
      $scip_html .= "  <td class='width_instr_thb'>".$thumbnail_icon.$data_line['thumbnail']."</td>\n";
      $scip_html .= "  <td class='width_date'>".$data_line['start_date']."</td>\n";
      $scip_html .= "  <td class='width_time'>".$data_line['start_UT']."</td>\n";
      $scip_html .= "  <td class='width_date'>".$data_line['end_date']."</td>\n";
      $scip_html .= "  <td class='width_time'>".$data_line['end_UT']."</td>\n";
      $scip_html .= "  <td class='width_xcen'>".$data_line['xcen']."</td>\n";
      $scip_html .= "  <td class='width_ycen'>".$data_line['ycen']."</td>\n";
      $scip_html .= "  <td class='width_xsize'>".$data_line['xsize']."</td>\n";
      $scip_html .= "  <td class='width_scan_speed'>".$data_line['scan_speed']."</td>\n";
      $scip_html .= "  <td class='width_obs_mode'>".$data_line['obs_mode']."</td>\n";
      $scip_html .= "  <td class='width_roi'>".$data_line['roi']."</td>\n";
      $scip_html .= "</tr>\n";
      return $scip_html;
   }
  
   if ($instrument == "TuMag") {
      $tumag_html = "<tr id='TUMAG_".$data_line['start_time']."' class='TUMAG_row ".$line_background."'>\n";
      $tumag_html .= "  <td class='width_obs_header'>".$data_line['obs_id']."</td>\n";
      $tumag_html .= "  <td class='width_instr_name'>".$data_line['instrument']."</td>\n";
      $tumag_html .= "  <td class='width_instr_thb'>".$thumbnail_icon.$data_line['thumbnail']."</td>\n";
      $tumag_html .= "  <td class='width_date'>".$data_line['start_date']."</td>\n";
      $tumag_html .= "  <td class='width_time'>".$data_line['start_UT']."</td>\n";
      $tumag_html .= "  <td class='width_date'>".$data_line['end_date']."</td>\n";
      $tumag_html .= "  <td class='width_time'>".$data_line['end_UT']."</td>\n";
      $tumag_html .= "  <td class='width_xcen'>".$data_line['xcen']."</td>\n";
      $tumag_html .= "  <td class='width_ycen'>".$data_line['ycen']."</td>\n";
      $tumag_html .= "  <td class='width_roi'>".$data_line['roi']."</td>\n";
      $tumag_html .= "</tr>\n";
      return $tumag_html;
   }
}
   
   
function table_empty_row($instrument) {
   if ($instrument == "Observations") {
      $observ_html = "<tr style='height:10px; background: white><td colspan='9' width=100%>&nbsp;</td></tr>\n";
      return $observ_html;
   }
   if ($instrument == "SUSI") {
      $susi_html = "<tr style='height:10px; background: white><td colspan='9' width=100%>&nbsp;</td></tr>\n";
      return $susi_html;
   }
   
   if ($instrument == "SCIP") {
      $scip_html = "<tr style='height:10px; background: white><td colspan='9' width=100%>&nbsp;</td></tr>\n";
      return $scip_html;
   }
  
   if ($instrument == "TuMag") {
      $tumag_html = "<tr style='height:10px; background: white><td colspan='9' width=100%>&nbsp;</td></tr>\n";
      return $tumag_html;
   }
}
