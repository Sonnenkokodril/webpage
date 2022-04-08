pro jscd_download_hmi
;restore general paths -> Created from jscd_general_path.pro
@jscd_general_path.pro

; 
for ii=0, n_elements(table.(0))-1 do begin
; for ii=n_elements(table.(0))-1,0,-1 do begin

v = strtrim(table.(0)[ii],1)
date = strmid(v,0,4)+'/'+strmid(v,4,2)+'/'+strmid(v,6,2)
down = date+'T'+strtrim(table.(1)[ii],1)+'-'+date+'T'+strtrim(table.(2)[ii],1)
dsdopath = obspath+'data/'+strtrim(table.(0)[ii],1)+'/'+strtrim(table.(3)[ii],1)+strtrim(table.(4)[ii],1)+'/'


print,'TIME',down
print,'LOC',dsdopath


wv = ['1600', '94', '335', '193', '131', '171', '211', '304','1700','intensity','LOS_magnetic_field','LOS_velocity']

nfolder = ['1600', '94', '335', '193', '131', '171', '211', '304','1700','continuum','magnetogram',$
           'dopplergram']


for k=0,11 do begin
if keyword_set(before) then down = downs[1]
if keyword_set(after) then down = downs[0]
print,down
if k lt 9 then tmp = vso_search(date=down, inst='aia', wave =wv[k], sample=30) $
else           tmp = vso_search(date=down, physobs=wv[k], inst='hmi')
sdopath = dsdopath+nfolder[k]+'/'
file_mkdir,sdopath
downr = vso_get(tmp, out_dir= sdopath, /FORCE)
endfor
endfor

end
