pro jscd_index

;file to creat the general index from the neutral index

;restore general paths -> Created from jscd_general_path.pro
@jscd_general_path.pro

; Select a text file and open for reading
file = 'index_neutral.html'
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
loc_obs_in_index = 63
date = table.(0)
days = date[UNIQ(date, SORT(date))]
year = uint(strmid(strtrim(days,1),0,4))
years= year[UNIQ(year, SORT(year))]
obs=''
; ---------- each day


;;
;; FOR GRIS++
;;

sec_fil=[1,6];[1,5,6]
for jj=0,n_elements(sec_fil)-1 do begin
obs=[obs,'<div class="gallery style2 small lightbox onscroll-fade-in">']
for ii=0,n_elements(days)-1 do begin 
if year[ii] eq 2018 then begin
imgloc=obspath+'images/'+strtrim(days[ii],1)+'/full/'+strtrim(days[ii],1)+'_'+filter[sec_fil[jj]]+'.jpg'
tmp = file_search(imgloc,count=ntmp)
if ntmp gt 0 then begin
obs=[obs,'<article>',$
     '									<a href="'+imgloc+'" class="image">',$
     '                                      <img src="'+imgloc+'" alt="">',$
     '									</a>',$
     '                                    <div class="caption">',$
     '                                      <h5><strong>'+strtrim(days[ii],1)+'</strong></h5>',$
     '                                      <ul class="actions">',$
     '                                        <li><a href="'+daypath+strtrim(days[ii],1)+'.html" class="button small">Go to obs</a></li>',$
     '                                      </ul>',$
     '									</div>',$
     '</article>']
endif
endif
endfor ;for ii
obs=[obs,'</div>']
endfor ;for jj

;;
;; FOR GRIS
;;

obs=[obs,'<h1 id="gris" class="align-left"><strong>GRIS<strong></h1>']

for yy=0, n_elements(years) -1 do begin

if years[yy] ne 2018 then obs=[obs,'<h2 class="align-center"><strong>'+strtrim(years[yy],1)+'<strong></h2>']
mk = where(year eq years[yy],nmk)
if nmk gt 0 then begin
sec_fil=[1,6];[1,5,6]
for jj=0,n_elements(sec_fil)-1 do begin
obs=[obs,'<div class="gallery style2 small lightbox onscroll-fade-in">']
for zz=0,nmk-1 do begin
ii = mk[zz]
if year[ii] lt 2018 then begin
imgloc=obspath+'images/'+strtrim(days[ii],1)+'/full/'+strtrim(days[ii],1)+'_'+filter[sec_fil[jj]]+'.jpg'
tmp = file_search(imgloc,count=ntmp)
if ntmp gt 0 then begin
obs=[obs,'<article>',$
     '									<a href="'+imgloc+'" class="image">',$
     '                                      <img src="'+imgloc+'" alt="">',$
     '									</a>',$
     '                                    <div class="caption">',$
     '                                      <h5><strong>'+strtrim(days[ii],1)+'</strong></h5>',$
     '                                      <ul class="actions">',$
     '                                        <li><a href="'+daypath+strtrim(days[ii],1)+'.html" class="button small">Go to obs</a></li>',$
     '                                      </ul>',$
     '									</div>',$
     '</article>']
endif
endif
endfor ;for ii
obs=[obs,'</div>']
endfor ;for jj
endif ;for nmk
endfor ;for yy


;concatenate and print file
array = [array[0:loc_obs_in_index],obs,array[loc_obs_in_index:*]]
OpenW, lun, path+'index.html', /Get_LUN, WIDTH=250
for i=0,n_elements(array)-1 do printf, lun,array[i] 
Free_LUN, lun


end