var interval_reposition = setInterval(function() {
   // alert("20s reposition");
   
   update_tables();
   
  /* susi_elems = document.getElementsByClassName('SUSI_row');
   for (i=0; i < susi_elems.length; i++) {
      if (susi_elems[i].classList.contains("light_red")) {
         // alert("red marked:");
         if (i>3) {
            // susi_elems[i-3].scrollIntoView(true);
         } else {
            // susi_elems[i].scrollIntoView(true);
         }   
      }
   } */
}, 20000);   

function update_table(instrument, row_count) {
   if (id_exists("table_"+instrument) == false) {
      return;
   }

   if (id_exists('table_start_time')) {
      start_time = document.getElementById('table_start_time').value;
   } else {
      start_time = "2022-06-01";
   }
   if (id_exists('table_end_time')) {
      end_time   = document.getElementById('table_end_time').value;
   } else {
      end_time   = "2022-06-30";
   }
   
   /* if (id_exists('t1')) {
       alert(document.getElementById('t1').innerHTML);
   } */
   if (id_exists('current_time')) {
      cur_time = document.getElementById('current_time').value;
   } else {
      cur_time = "2022-06-05T10:00";
   }       
       
   cur_time = cur_time+":00";
   start_time = start_time+":00";
   end_time   = end_time+":59";   
   // alert(cur_time);
   // --- Create data object
   var data = new FormData();
   data.set('instrument',instrument);
   data.set('cur_time', cur_time);
   data.set('start_time', start_time);
   data.set('end_time', end_time);
   data.set('rows', row_count);
   
   var request = new XMLHttpRequest();
   request.open('POST', "sot3_AJAX.php", true);
   request.setRequestHeader('ContentType', 'application/x-www-form-urlencoded');
   request.onreadystatechange = function() {
      if (request.readyState == 4 && request.status == 200) {
            // alert(request.responseText);
            document.getElementById('table_'+instrument).innerHTML = request.responseText;
         }   
      }
   
         
   request.send(data);
}

function update_tables() {
   if (id_exists('table_Observations')) {
      update_table('Observations', 6);
   }
   if (id_exists('table_SUSI')) {
      update_table('SUSI', 6);
   }
   if (id_exists('table_SCIP')) {
      update_table('SCIP', 6);
   }
   if (id_exists('table_TuMag')) {
      update_table('TuMag', 6);
   }
}

function id_exists(id) {
   var elem = document.getElementById(id);
   if (typeof(elem) != "undefined" && (elem != null)) {
     return true;
   } else {
      return false;
   }
}
      
