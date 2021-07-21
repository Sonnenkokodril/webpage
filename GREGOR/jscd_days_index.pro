pro jscd_days_index

;file to creat the general index from the neutral index

;restore general paths -> Created from jscd_general_path.pro
@jscd_general_path.pro

; Select a text file and open for reading
file = 'day_neutral.html'
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
loc_obs_in_index=34
loc_tab_in_index=57
loc_tit_in_index=29

date = table.(0)
days = date[UNIQ(date, SORT(date))]
obs=''
; ---------- each day

jj=0
for ii=0,n_elements(days)-1 do begin 
obs=''
  for jj=0,n_elements(filter)-1 do begin 
    imgloc='./obs/images/'+strtrim(days[ii],1)+'/full/'+strtrim(days[ii],1)+'_'+filter[jj]+'.jpg'
    if jj gt 2 then cap = 'AIA '+filter[jj]+' <span>&#8491;</span>' else cap = 'HMI '+filter[jj]
obs=[obs,$
     '								<article>',$
     '								  <a href="'+imgloc+'" class="image">',$
     '								    <img src="'+imgloc+'" alt="">',$
     '								  </a>',$
     '								  <div class="caption">',$
     '								    <h5><strong>'+cap+' </strong></h5>',$
     '								  </div>',$
     '								</article>']
endfor ;for ii

    tab = ''
    mk = where(date eq days[ii],nmk)
    if nmk gt 0 then begin
      for zz=0,nmk-1 do begin
      tmp = strtrim(table.(3)[mk[zz]],1)+strtrim(table.(4)[mk[zz]],1)
      obsloc = './obs/'+strtrim(days[ii],1)+'_'+tmp+'.html'
        tab=[tab,$
'                      <tr>',$
'                      <td> <a href="'+obsloc+'"> '+tmp+' </a> </td>',$
'                      <td> <a href="'+obsloc+'"> '+strtrim(table.(0)[mk[zz]],1)+' </a></td>',$
'                      <td> <a href="'+obsloc+'"> '+strtrim(table.(1)[mk[zz]],1)+'</a></td>',$
'                      <td> <a href="'+obsloc+'"> '+strtrim(table.(2)[mk[zz]],1)+'</a></td>',$
'                      <td> <a href="'+obsloc+'"> '+strtrim(table.(7)[mk[zz]],1)+'</a></td>',$
'                      <td> <a href="'+obsloc+'"> '+strtrim(table.(8)[mk[zz]],1)+'</a></td>',$
; '                      <td> <a href="'+obsloc+'"> '+string(table.(11)[mk[zz]],f='(I02)')+'</a></td>',$
; '                      <td> <a href="'+obsloc+'"> '+strtrim(table.(9)[mk[zz]],1)+'</a></td>',$
'                      </tr>']
      endfor ;for zz
    endif
    title = '<h1><strong>'+strtrim(days[ii],1)+' </strong></h1>''

array2 = [array[0:loc_tit_in_index],title,$
          array[loc_tit_in_index:loc_obs_in_index],obs,$
          array[loc_obs_in_index:loc_tab_in_index],tab,array[loc_tab_in_index:*]]
OpenW, lun, daypath+strtrim(days[ii],1)+'.html', /Get_LUN, WIDTH=250
for i=0,n_elements(array2)-1 do printf, lun,array2[i] 
Free_LUN, lun
endfor ;for ii

end