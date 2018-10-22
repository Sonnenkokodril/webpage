pro jscd_coaligned_hmi 

;restore general paths -> Created from jscd_general_path.pro
@jscd_general_path.pro


ii=123
nfolder = ['continuum','magnetogram',$
           'dopplergram','1600', '94', '335', '193', '131', '171', '211', '304','1700']
wv = nfolder


for ii =0,n_elements(table.(0))-1 do begin
; for ii =n_elements(table.(0))-1,0,-1 do begin
dpath = obspath+'data/'+strtrim(table.(0)[ii],1)+'/'+strtrim(table.(3)[ii],1)+strtrim(table.(4)[ii],1)+'/'
name      = strtrim(table.(0)[ii],1)


for ll=0, n_elements(wv)-1 do begin

 obs  = strtrim(table.(3)[ii])+strtrim(table.(4)[ii],1)
 file = obspath+'images/'+strtrim(table.(0)[ii],1)+'/'+obs+'/'+ nfolder[ll]+'/'
 file_video = obspath+'video/'+strtrim(table.(0)[ii],1)+'/'+obs+'/'
 file_full = obspath+'images/'+strtrim(table.(0)[ii],1)+'/full/'
 file_mkdir,file,file_full,file_video
 

ang=0.
; ; ; coordinates
sx = 100 ; arcsec ;size sjc
sy = 100 ; arcsec 

xran=[table.(7)[ii]-sx/2.,table.(7)[ii]+sy/2.] 
yran=[table.(8)[ii]-sx/2.,table.(8)[ii]+sy/2.]  ; 
; ang = table.(11)[ii]

files = file_search(dpath + nfolder[ll]+'/*.*.fits',count=nfiles)
spath = dpath + nfolder[ll]+'/'
file_mkdir,spath
if (nfiles ge 1) and (table.(7)[ii] gt -1500) then begin

read_sdo,files[0],hdr2,data2
aia_prep,hdr2,data2,hdr_int,data,/use_hdr,scale_ref=.504

; coordinates submap
ss = 50. ; make bigger the FOV
xran2 = xran & yran2 = yran
xran2[0] =xran[0]-ss 
xran2[1] =xran[1]+ss  
yran2[0] =yran[0]-ss  
yran2[1] =yran[1]+ss 

;in terms of pixels
resol = 0.504 ;sdo resolution
xran2 = round(xran2/resol+hdr_int.CRPIX1)
yran2 = round(yran2/resol+hdr_int.CRPIX2)
if xran2[0] gt xran2[1] then xran2 = reverse(xran2)
if yran2[0] gt yran2[1] then yran2 = reverse(yran2)
sd = [3,xran2[1]-xran2[0],yran2[1]-yran2[0],nfiles]


intdata    = fltarr(sd[1],sd[2],sd[3])
times      = strarr(sd[3])
tmp        = struct2fitshead(hdr_int)
nentry_hdr = n_elements(tmp)
indexes    = strarr(nentry_hdr,sd[3])
xran3      = fltarr(2,sd[3])
yran3      = fltarr(2,sd[3])
xran3[*,0] = xran2
yran3[*,0] = yran2

for i=0,nfiles-1 do begin

 bar,i,nfiles-1
 print,''
 print,nfolder[ll],i, ' of ', nfiles-1

  read_sdo,files[i],hdr2,data2
  aia_prep,hdr2,data2,hdr_int2,data,/use_hdr,scale_ref=.504
  data2 = data
  
  if i ge 1 then begin
  xran3[*,i] = xran3[*,i-1]
  yran3[*,i] = yran3[*,i-1]
  endif
  help,i,ii,ll,nfiles,xran3
  
  ;array of images
  intdata[*,*,i] = data2[xran3[0,i]:xran3[1,i]-1,yran3[0,i]:yran3[1,i]-1]
  ;shift the fov
  if i gt 0 then begin
  shf = xyoff(intdata[*,*,i-1], intdata[*,*,i], sd[1], sd[2])
  if abs(shf[0]) lt 3 then xran3[*,i] -=shf[0] 
  if abs(shf[1]) lt 3 then yran3[*,i] -=shf[1] 
  if (ll eq 1) or (ll eq 2) then begin
  restore,dpath + nfolder[0]+'/'+ name+'_hdrs_coods.sav'
  if (size(xran3))[2] lt nfiles then begin
  xran4 = fltarr(2,sd[3]) &yran4 = fltarr(2,sd[3])
    for q=0,nfiles-1 do begin
      if q lt (size(xran3))[2] then begin
      xran4[*,q] = xran3[*,q]
      yran4[*,q] = yran3[*,q]
      endif else begin
      shf = xyoff(intdata[*,*,q-1], intdata[*,*,q], sd[1], sd[2])
      xran4[*,q] = xran4[*,q-1]
      yran4[*,q] = yran4[*,q-1]
      xran4[*,q] -=shf[0]
      yran4[*,q] -=shf[1]
      endelse
    endfor
    xran3=xran4 & yran3=yran4
  endif
  endif
  
  intdata[*,*,i] = data2[xran3[0,i]:xran3[1,i]-1,yran3[0,i]:yran3[1,i]-1]
  endif
  
  print,'X coords - ',xran3[*,i]
  print,'Y coords - ',yran3[*,i]
  
  times[i]       = hdr_int2.date_obs
  tmp     = struct2fitshead(hdr_int2)
  if nentry_hdr le n_elements(tmp) then $
  indexes[*,i] = tmp else indexes[*,i] = tmp[0:nentry_hdr-1]
  
 
endfor


if (ll ne 1) and (ll ne 2) then begin ;to co-align with SDO_intensity or AIA images

;first round interpolation
sd = size(intdata)
offset1 = fltarr(sd[3],2)
for i=0, sd[3] -2 do begin
offset1[i+1,*] = xyoff(intdata[*,*,i], intdata[*,*,i+1], sd[1]-ss/2., sd[2]-ss/2.)
endfor;for i


;shift images
for i=0, sd[3] -1 do begin
t1 = (total(offset1[0:i,*],1))[0]
t2 = (total(offset1[0:i,*],1))[1]
intdata[*,*,i] = interpolate(intdata[*,*,i], findgen(sd[1]) -t1, findgen(sd[2]) -t2, /grid, cubic=-0.5)
endfor;for i

;save if the procedure stops in one step 
ntemp = spath + name+'_hdrs.sav'
save,indexes,times,offset1,xran3,yran3, filename=ntemp
if ll eq 0 then save,offset1,xran3,yran3, filename=dpath + nfolder[0]+'/'+ name+'_hdrs_coods.sav'



endif else begin ;to co-align with SDO_intensity or AIA images
;save if the procedure stops in one step 
restore,dpath + nfolder[0]+'/'+ name+'_hdrs_coods.sav'
  if (size(xran3))[2] lt nfiles then begin
  offset2 = fltarr(sd[3],2)
  for q=0,nfiles-1 do begin
  if q lt (size(offset1))[1] then begin
  offset2[q,*] = offset1[q,*]
  endif else begin
  offset2[q,*] = xyoff(intdata[*,*,q-1], intdata[*,*,q], sd[1], sd[2])
  endelse
  endfor
  offset1=offset2
  endif
save,indexes,times,offset1,filename=ntemp


;shift images
sd = size(intdata)
for i=0, sd[3] -1 do begin
 t1 = (total(offset1[0:i,*],1))[0]
 t2 = (total(offset1[0:i,*],1))[1]
 intdata[*,*,i] = interpolate(intdata[*,*,i], findgen(sd[1]) -t1, findgen(sd[2]) -t2, /grid, cubic=-0.5)
endfor;for i

endelse


aligndata = intdata

;writefits data
print,spath
hdr = struct2fitshead(hdr_int)
writefits,spath+name+'_'+wv[ll]+'.fits',aligndata,hdr


; if ll ge 3 then begin
sq = size(aligndata)
; nmax =fltarr(sq[3])
; nmin = nmax
; for pp=0,sq[3]-1 do begin
; nmax[pp] = max(aligndata[*,*,pp]);*1.1
; nmin[pp] = min(aligndata[*,*,pp])*0.95
; endfor
; nmax = mean(nmax)
; nmin = mean(nmin)
;   for pp=0,sq[3]-1 do begin
; img  = aligndata[*,*,pp]
; aligndata[*,*,pp] = ((img-min(img))*(nmax-nmin)/(max(img)-min(img)))+nmin
;   endfor
  
  ;substract mean for doppler
  if ll eq 2 then begin
  mdopp = mean(aligndata)
  for pp=0,sq[3]-1 do aligndata[*,*,pp]-=mdopp
  endif


sd = size(aligndata)
for i=0,nfiles-1 do begin

;header 
; hdr = hdr_int2
hdr = fitshead2struct(indexes[*,i])

;creathe the circule to cut some images
isize=size(data)
isize=isize(1)
x_center=hdr.CRPIX1
y_center=hdr.CRPIX2
radius = hdr.RSUN_OBS/0.504
dist_circle,dist_grid,isize,x_center,y_center
dist_grid=dist_grid/radius
outside=where(dist_grid gt 1.,complement=inside)

if ll ge 3 then begin
 aia_lct,wave=hdr.wavelnth,/load
 case hdr.wavelnth of
 94:  img_full = sdo_intscale(hdr,data,strtrim(hdr.wavelnth,1),clipmin = 0,clipmax = -2 )
 304:  img_full = sdo_intscale(hdr,data,strtrim(hdr.wavelnth,1),clipmin = 0,clipmax = -2)
 335:  img_full = sdo_intscale(hdr,data,strtrim(hdr.wavelnth,1),clipmin = -1,clipmax = -2)
 211:  img_full = sdo_intscale(hdr,data,strtrim(hdr.wavelnth,1),clipmin = -1,clipmax = -1)
 193:  img_full = sdo_intscale(hdr,data,strtrim(hdr.wavelnth,1),clipmin = -1,clipmax = -1)
 171:  img_full = sdo_intscale(hdr,data,strtrim(hdr.wavelnth,1),clipmin = -1,clipmax = -1)
 1600:  begin
 mk = where(data gt 1e3,nmk)
 if nmk gt 0 then data[mk] = 0.
 img_full = sdo_intscale(hdr,data,strtrim(hdr.wavelnth,1),clipmax = -2,clipmin = -1)
 end
 1700:  begin
 mk = where(data gt 1e4,nmk)
 if nmk gt 0 then data[mk] = 0.
 img_full = sdo_intscale(hdr,data,strtrim(hdr.wavelnth,1),clipmax = -2,clipmin = -1)
 end
 131:  img_full = sdo_intscale(hdr,data,strtrim(hdr.wavelnth,1),clipmax = -1,clipmin = -1)
 endcase
 img = aia_intscale(aligndata[*,*,i],exptime=hdr.exptime,/bytescale,wave=hdr.wavelnth)
 img = sdo_intscale(hdr,aligndata[*,*,i],strtrim(hdr.wavelnth,1),clipmax = -1,clipmin = -1)
 if i eq 0 then img_full = sdo_intscale(hdr,data,strtrim(hdr.wavelnth,1),clipmax = -1,clipmin = -1)
endif else begin

if ll eq 0 then begin
loadct,3,/sil
img = bytscl(aligndata[*,*,i],min=1e4,max=6.8e4)
if i eq 0 then img_full = bytscl(data,min=1e4,max=6.8e4)
endif
if ll eq 1 then begin
loadct,0,/sil
img = bytscl(aligndata[*,*,i],min=-.5e3,max=.5e3)
if i eq 0 then img_full = bytscl(data,min=-.5e3,max=.5e3)
endif
if ll eq 2 then begin
loadct,70,/sil
img = bytscl(aligndata[*,*,i],min=-5e3,max=5e3)
data -=mean(data[inside]) 
if i eq 0 then img_full = bytscl(data,min=-5e3,max=5e3)
endif

endelse

tvlct,rs,gs,bs,/get
 
 
 image24=mk_24bit(img,rs,gs,bs)
 image24_full=mk_24bit(img_full,rs,gs,bs)
 
 if (ll le 3) or (ll eq 11) then begin 
 for h=0,2 do begin
 tmp = image24_full[h,*,*]
 tmp(outside) = 0.
 image24_full[h,*,*] = tmp
 endfor
 endif 
 
 date = table.(0)
 days = date[UNIQ(date, SORT(date))]
 mk = where(date eq table.(0)[ii],nmk)
 
 if nmk gt 0 then begin
 for zz=0,nmk-1 do begin
 xran4=[table.(7)[mk[zz]]-sx/2.,table.(7)[mk[zz]]+sy/2.] 
 yran4=[table.(8)[mk[zz]]-sx/2.,table.(8)[mk[zz]]+sy/2.]  ; 
 xbox = (xran4/0.504)+x_center
 ybox = (yran4/0.504)+y_center
 
 rgb = [102,255,102]
 tk = 7
 for d=0,2 do begin
 image24_full[d,xbox[0]-tk:xbox[0]+tk,ybox[0]-tk:ybox[1]+tk] = rgb[d]
 image24_full[d,xbox[1]-tk:xbox[1]+tk,ybox[0]-tk:ybox[1]+tk] = rgb[d]
 image24_full[d,xbox[0]-tk:xbox[1]+tk,ybox[0]-tk:ybox[0]+tk] = rgb[d]
 image24_full[d,xbox[0]-tk:xbox[1]+tk,ybox[1]-tk:ybox[1]+tk] = rgb[d]
 endfor
 
endfor
endif
 
 nimage = strtrim(table.(0)[ii],1)+'_'+obs+'_'+nfolder[ll]
 WRITE_JPEG, file+nimage +'_'+string(i,f='(I04)')+'.jpg',true=1, image24, QUALITY=100
 if i eq 0 then begin 
 ssdata = size(image24_full);rebin data
 image24_full = rebin(image24_full,ssdata[1],ssdata[2]/4,ssdata[3]/4)
 WRITE_JPEG, file_full+strtrim(table.(0)[ii],1)+'_'+nfolder[ll]+'.jpg',true=1, image24_full, QUALITY=80
 endif
 endfor
 endif else begin;no coord
 

 print,'---------'
 !p.thick = 5
 !x.thick = 5
 !y.thick = 5
 !p.charthick = 5
 !p.charsize=1.2
 !p.ticklen = -.01
 !p.font = 7
 image24 = indgen(3,100,100)
 xpaper = 10
 nimage = strtrim(table.(0)[ii],1)+'_'+obs+'_'+nfolder[ll]
 fname = file_full+strtrim(table.(0)[ii],1)+'_'+nfolder[ll]+'.eps'
 tmp = file_search(file_full+strtrim(table.(0)[ii],1)+'_'+nfolder[ll]+'.jpg',count=ntmp)
 for tt=0, 3 do begin
 if (tt ge 1) or (ntmp eq 0) then fname=file+nimage +'_'+string(tt,f='(I04)')+'.eps'
 set_plot,'ps'
 device,xsize=xpaper,ysize=xpaper,xoffset=0., yoffset=0.,/color,$ ;SIZE OUTPUT FILE
 /encapsulate,bits_per_pixel=8,filename=fname,font_index=7
 cgimage,image24
 cgtext,.5,.5,/norm,'NO COORDINATES',ali=.5,col='red6',ori=45,char=3
 ;CLOSE PS	
 device,/close
 set_plot,'x'
 cgps2raster,fname,/delete_ps,/jpeg,/silent ;CONVERT TO PDF
 endfor
 
 endelse
 
 ;create video
  ssd = size(image24)
  if evenodd(ssd[2]) then ssd[2]-=1
  if evenodd(ssd[3]) then ssd[3]-=1
  nvideo =file_video+nimage+'.mp4'
  del = file_search(nvideo,count=nvid)
  if nvid gt 0 then file_delete,del
  spawn, 'ffmpeg -framerate 5 -i '+file+nimage+'_%04d.jpg -vf scale='+strtrim(ssd[2],1)+':'+strtrim(ssd[3],1)+' -c:v libx264 -profile:v high -crf 20 -pix_fmt yuv420p '+nvideo
  
  
  
  
endfor ;for ll


 endfor ;for ii
end