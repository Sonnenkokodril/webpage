pro jscd_obs

;file to creat the general index from the neutral index

;restore general paths -> Created from jscd_general_path.pro
@jscd_general_path.pro

; Select a text file and open for reading
file = 'obs_neutral.html'
OPENR, lun, file, /GET_LUN
; Read one line at a time, saving the result into array
array = ''
line = ''
WHILE NOT EOF(lun) DO BEGIN & $
READF, lun, line & $
array = [array, line] & $
ENDWHILE
; Close the file and free the file unit
FREE_LUN, lun

;create the table for days
loc_obs_in_index = 16

date = table.(0)
days = date[UNIQ(date, SORT(date))]

ii=0
for ii=0,n_elements(table.(0))-1 do begin

obsname = strtrim(table.(3)[ii])+strtrim(table.(4)[ii],1)


obs=['  <!-- Two -->',$
' <!-- Header -->',$
'   <header id="header">',$
'     <h2><a href="../'+strtrim(table.(0)[ii],1)+'.html">'+strtrim(table.(0)[ii],1)+'</h2></a>',$
'     <h1><a href="../../index.html">Home</h1></a>',$
'   </header>',$
' <section>',$
'     <h2><a href="../'+strtrim(table.(0)[ii],1)+'.html">Observations</a></h2>',$
'</section>',$
'<!-- Tabbed Video Section -->',$
'   <div class="flex flex-tabs">',$
'       <ul class="tab-list">']
;  ---- each channel
for jj=0,n_elements(filter)-1 do begin
cap = STRUPCASE(filter[jj])
if jj gt 2 then cap = 'AIA '+cap+' <span>&#8491;</span>' else cap = 'HMI '+cap
obs=[obs,'      <li><a href="#" data-tab="tab-'+strtrim(jj+1,1)+'" class="active">'+cap+'</a></li>']
endfor

obs=[obs,'      </ul>',$
' <div class="tabs">']
for jj=0,n_elements(filter)-1 do begin
vidloc='./video/'+strtrim(table.(0)[ii],1)+'/'+obsname+'/'+strtrim(table.(0)[ii],1)+'_'+obsname+'_'+filter[jj]+'.mp4'
datloc='./data/'+strtrim(table.(0)[ii],1)+'/'+obsname+'/'+filter[jj]+'/'+strtrim(table.(0)[ii],1)+'_'+filter[jj]+'.fits'
cap = STRUPCASE(filter[jj])
if jj gt 2 then cap = 'AIA '+cap+' <span>&#8491;</span>' else cap = 'HMI '+cap
obs=[obs,$
' <!-- Tab '+strtrim(jj+1,1)+'-->',$
'   <div class="tab tab-'+strtrim(jj+1,1)+' flex flex-1 active">',$
'   <!-- Video Thumbnail -->',$
'     <div class="video col" loop>',$
'       <iframe width="600" height="600" src="'+vidloc+'" frameborder="0" allowfullscreen loop></iframe>',$
'     <p class="caption">'+cap+$
'<a href="'+vidloc+'" download>'+'  (video)  '+'</a>'+$
'<a href="'+datloc+'" >'+'(fits)'+'</a>'+'</p>',$
'     </div>',$
'     <h2>'+obsname+'</h2>',$
'     <h4>Time: '+strtrim(table.(1)[ii],1)+'UT-'+strtrim(table.(2)[ii],1)+'UT<br>',$
'     Position: ('+strtrim(table.(7)[ii],1)+','+strtrim(table.(8)[ii],1)+')<br>',$
; '     Derotator: '+strtrim(table.(11)[ii],1)+'<br>',$
; '     Seeing: '+strtrim(table.(9)[ii],1)+'</h4>',$
'     <h3><a href="../'+strtrim(table.(0)[ii],1)+'.html">Back to '+strtrim(table.(0)[ii],1)+'</a><br>'+$
'<a href="../../index.html#obs">Back to observations</a></h3>',$
'   </div>']

endfor ;for jj

name = strtrim(table.(0)[ii],1)+'_'+obsname+'.html'


array = [array[0:loc_obs_in_index],obs,array[loc_obs_in_index:*]]
OpenW, lun, obspath+name, /Get_LUN, WIDTH=250

for i=0,n_elements(array)-1 do printf,lun,array[i] 
Free_LUN, lun
endfor;for ii

end