FUNCTION TLI_SLC_CC, masterfile, slavefile,width=width
  IF ~KEYWORD_SET(width) THEN BEGIN
    width=2135
  ENDIF
  master= TLI_READDATA(masterfile,samples=width,FORMAT='SCOMPLEX',/SWAP_ENDIAN)
  slave= TLI_READDATA(slavefile,samples=width,Format='SCOMPLEX',/SWAP_ENDIAN)
  temp_r= master[0:*:2, *]
  temp_i= master[1:*:2, *]
  master= COMPLEX(temp_r, temp_i)
  temp_r= slave[0:*:2, *]
  temp_i= slave[1:*:2, *]
  slave= COMPLEX(temp_r, temp_i)
  
  numerator= ABS(TOTAL(master* CONJ(slave)))
  denomilator= (TOTAL(ABS(master)^2)*TOTAL(ABS(slave)^2))^0.5
  cc= numerator/denomilator
  RETURN,cc
END

FUNCTION TLI_MEAN_COH, masterfile, slavefile, width=width, ccpath=ccpath
  mbasename= FILE_BASENAME(masterfile, '.rslc')
  sbasename= FILE_BASENAME(slavefile, '.rslc')
  ccfile= ccpath+PATH_SEP()+mbasename+'-'+sbasename+'.cc'
  ccfile= STRCOMPRESS(ccfile)
  cc=TLI_READDATA(ccfile,samples=width, format='FLOAT',/SWAP_ENDIAN)
  cc= cc[WHERE(cc NE 0)]
  cc= MEAN(cc)
  RETURN, cc
  
END

PRO TLI_CC_Qingli

  workpath='/mnt/backup/experiment/Qingli_all/test1'
  ccpath=workpath+PATH_SEP()+'cc_ras'
  ccdat= workpath+PATH_SEP()+'meancc.dat'
  cctxt= workpath+PATH_SEP()+'meancc.txt'
  itabfile=workpath+PATH_SEP()+'itab'
  sarlistfile=workpath+PATH_SEP()+'SLC_tab'
  basefile= workpath+PATH_SEP()+'base.list'
  IF 0 THEN BEGIN
    ; Read itab
    nlines= FILE_LINES(itabfile)
    itab=[0,0,0,0]
    OPENR, lun, itabfile,/GET_LUN
    For i=0, nlines-1 DO BEGIN
      temp=''
      READF, lun, temp
      temp= STRSPLIT(temp,' ',/EXTRACT)
      itab=[[itab],[LONG(temp)]]
    ENDFOR
    FREE_LUN, lun
    itab= itab[*,1:*]
    
    ; Read sarlist
    nlines= FILE_LINES(sarlistfile)
    sarlist=''
    OPENR, lun, sarlistfile,/GET_LUN
    For i=0, nlines-1 DO BEGIN
      temp=''
      READF, lun, temp
      temp= STRSPLIT(temp, ' ',/EXTRACT)
      temp= workpath+PATH_SEP()+'piece'+PATH_SEP()+FILE_BASENAME(temp[0])
      sarlist=[[sarlist],temp]
    ENDFOR
    FREE_LUN, lun
    sarlist= sarlist[1:*]
    
    ; Read base.list
    nlines= FILE_LINES(basefile)
    base=DBLARR(5)
    OPENR, lun, basefile,/GET_LUN
    For i=0, nlines-1 DO BEGIN
      temp=''
      READF, lun, temp
      temp= STRSPLIT(temp, ' ',/EXTRACT)
      base=[[base], [DOUBLE(temp)]]
    ENDFOR
    FREE_LUN, lun
    base= ABS(base[*, 1:*])
    
    ; Calculate cc for each pair in itab
    nlines= FILE_LINES(itabfile)
    ccs=0D
    
    For i=0, nlines-1 DO BEGIN
      Print, STRCOMPRESS(i),'/',STRCOMPRESS(nlines-1)
      master_ind= itab[0, i]-1
      slave_ind= itab[1, i]-1
      masterfile= sarlist[master_ind]
      slavefile= sarlist[slave_ind]
      width= READ_PARAMS(masterfile+'.par','range_samples')
      ;    temp=TLI_SLC_CC(masterfile,slavefile,width=width)
      temp= TLI_MEAN_COH(masterfile, slavefile, width=width, ccpath=ccpath)
      ccs=[ccs,temp]
    ENDFOR
    ccs= DOUBLE(TRANSPOSE(ccs[1:*]))
    datdata= [base[3:4, *], ccs]
    OPENW, lun, ccdat,/GET_LUN
    WRITEU, lun, datdata  ; 二进制文件，Double类型，3列(垂直基线，时间基线，相关系数)
    FREE_LUN, lun
    
    
    
    txtdata= DOUBLE([base, ccs])
    OPENW, lun, cctxt,/GET_LUN
    PrintF, lun, ['Index','master','slave','Bperp','BT','CC'],FORMAT='(A6, A11, A11, A24, A5, A25)'
    PRINTF, lun, txtdata, FORMAT='(I6, I11, I11, F24, I5, D25)'
    FREE_LUN, lun
  ENDIF
  
  ; Analyze the data
  datdata= TLI_READDATA(ccdat, samples=3, format='DOUBLE')
  bperp=ABS(datdata[0, 0:39])
  mean_coh= datdata[2, 0:39]
  
  x=bperp
  y=mean_coh
  iPLOT, x, y,linestyle=6, sim_size=1.0,sym_index=5
  
  Print, 'Pro successfully finished.'
END

