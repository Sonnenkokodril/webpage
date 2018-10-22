;general path that repeast on different codes

; read table
path = '/home/castellanos/Dropbox/Webpage/GREGOR/'
path = './'
daypath =path+'day/'
obspath =path+'day/obs/'
; table = read_csv(path+'Test_grisp.csv')
table = read_csv(path+'gregor_obs.csv')
angs = '<span>&#8491;</span>'
filter=['continuum','magnetogram','dopplergram','94','131','171','193','211',$
        '304','335','1600','1700']
save,path,daypath,obspath,table,angs,filter,filename=path+'general_path.sav'

