PRO CWN_SMC_OFFSETPWRTRAC_EVENT,EVENT
  COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  
  widget_control,event.top,get_uvalue=pstate
  workpath=config.workpath
  uname=widget_info(event.id,/uname)
  case uname of
    'openmaster':begin
      master=config.m_slc
    infile=dialog_pickfile(title='Sasmac InSAR',/read,filter='*.rslc;*.slc', path=workpath,file=master)
    IF NOT FILE_TEST(infile) THEN return
    
    ; Update definitions
    config.m_slc=infile
    config.m_slcpar=infile+'.par'
    workpath=config.workpath
    master=config.m_slc
    mparfile=config.m_slcpar

    finfo=TLI_LOAD_SLC_PAR(mparfile)
    rpixs=STRCOMPRESS(string(long(rwisz)/2),/REMOVE_ALL)
   rpixe=STRCOMPRESS(string(long(finfo.range_samples)-long(rwisz)/2),/REMOVE_ALL)
   azpixs=STRCOMPRESS(string(long(azwisz)/2),/REMOVE_ALL)
   azpixe=STRCOMPRESS(string(long(finfo.azimuth_lines)-long(azwisz)/2),/REMOVE_ALL)
    
    widget_control,(*pstate).master,set_value=infile
    widget_control,(*pstate).master,set_uvalue=infile    
    widget_control,(*pstate).mpar,set_value=mparfile
    widget_control,(*pstate).mpar,set_uvalue=mparfile
    
  END
  'openslave':begin
    slave=config.s_slc
    infile=dialog_pickfile(title='Sasmac InSAR',/read,filter='*.rslc;*.slc', path=workpath,file=slave)
    IF NOT FILE_TEST(infile) THEN return
    
    ; Update definitions

    config.s_slc=infile
    config.s_slcpar=infile+'.par'
    slave=config.s_slc
    sparfile=config.s_slcpar
    widget_control,(*pstate).slave,set_value=infile
    widget_control,(*pstate).slave,set_uvalue=infile
    widget_control,(*pstate).spar,set_value=sparfile
    widget_control,(*pstate).spar,set_uvalue=sparfile
   
  END
  'openoff':begin
    infile=dialog_pickfile(title='Sasmac InSAR',/read,filter='*.off', path=workpath)
    IF NOT FILE_TEST(infile) THEN return
    
    ; Update definitions
    TLI_SMC_DEFINITIONS_UPDATE,inputfile=infile
    
    ; Update widget info.
    workpath=config.workpath
    inputfile=config.inputfile
    widget_control,(*pstate).off,set_value=infile
    widget_control,(*pstate).off,set_uvalue=infile
    
    widget_control,(*pstate).master,get_value=master 
    widget_control,(*pstate).slave,get_value=slave
    widget_control,(*pstate).off,get_value=off
    IF NOT FILE_TEST(master) then begin
        TLI_SMC_DUMMY, inputstr='ERROR! Please select input master file.'
        RETURN
      ENDIF
      IF NOT FILE_TEST(slave) then begin
        TLI_SMC_DUMMY, inputstr='ERROR! Please select input slave file.'
        RETURN
      ENDIF
      IF NOT FILE_TEST(off) then begin
        TLI_SMC_DUMMY, inputstr='ERROR! Please select input offset par file.'
        RETURN
      ENDIF

    offs=workpath+TLI_FNAME(off, /nosuffix)+'.offs'
    snr=workpath+TLI_FNAME(off, /nosuffix)+'.off.snr'
    offsets=workpath+TLI_FNAME(off, /nosuffix)+'.offsets'
    widget_control,(*pstate).offs,set_value=offs
    widget_control,(*pstate).offs,set_uvalue=offs
    widget_control,(*pstate).snr,set_value=snr
    widget_control,(*pstate).snr,set_uvalue=snr
    widget_control,(*pstate).offsets,set_value=offsets
    widget_control,(*pstate).offsets,set_uvalue=offsets       
  end
   'openoffs':begin
    ;-Check if input master parfile
    widget_control,(*pstate).master,get_value=master 
    widget_control,(*pstate).slave,get_value=slave
    widget_control,(*pstate).off,get_value=off
    IF NOT FILE_TEST(master) then begin
        TLI_SMC_DUMMY, inputstr='ERROR! Please select input master file.'
        RETURN
      ENDIF
      IF NOT FILE_TEST(slave) then begin
        TLI_SMC_DUMMY, inputstr='ERROR! Please select input slave file.'
        RETURN
      ENDIF
      IF NOT FILE_TEST(off) then begin
        TLI_SMC_DUMMY, inputstr='ERROR! Please select input offset par file.'
        RETURN
      ENDIF
  
      workpath=config.workpath
      temp=file_basename(off)
      temp=strsplit(temp,'.',/extract)
      off=temp(0)
      file=off+'.offs'
      outfile=dialog_pickfile(title='',/write,file=file,path=workpath,filter='*.offs',/overwrite_prompt)
    widget_control,(*pstate).offs,set_value=outfile
    widget_control,(*pstate).offs,set_uvalue=outfile   
  END
  'opensnr':begin
    ;-Check if input master parfile
    widget_control,(*pstate).master,get_value=master 
    widget_control,(*pstate).slave,get_value=slave
    widget_control,(*pstate).off,get_value=off
    IF NOT FILE_TEST(master) then begin
        TLI_SMC_DUMMY, inputstr='ERROR! Please select input master file.'
        RETURN
      ENDIF
      IF NOT FILE_TEST(slave) then begin
        TLI_SMC_DUMMY, inputstr='ERROR! Please select input slave file.'
        RETURN
      ENDIF
      IF NOT FILE_TEST(off) then begin
        TLI_SMC_DUMMY, inputstr='ERROR! Please select input offset par file.'
        RETURN
      ENDIF
  
      workpath=config.workpath
      temp=file_basename(off)
      temp=strsplit(temp,'.',/extract)
      off=temp(0)
      file=off+'.off.snr'
      outfile=dialog_pickfile(title='',/write,file=file,path=workpath,filter='*.off.snr',/overwrite_prompt)
    widget_control,(*pstate).snr,set_value=outfile
    widget_control,(*pstate).snr,set_uvalue=outfile   
  END
  'openoffsets':begin
    ;-Check if input master parfile
    widget_control,(*pstate).master,get_value=master 
    widget_control,(*pstate).slave,get_value=slave
    widget_control,(*pstate).off,get_value=off
    IF NOT FILE_TEST(master) then begin
        TLI_SMC_DUMMY, inputstr='ERROR! Please select input master file.'
        RETURN
      ENDIF
      IF NOT FILE_TEST(slave) then begin
        TLI_SMC_DUMMY, inputstr='ERROR! Please select input slave file.'
        RETURN
      ENDIF
      IF NOT FILE_TEST(off) then begin
        TLI_SMC_DUMMY, inputstr='ERROR! Please select input offset par file.'
        RETURN
      ENDIF
  
      workpath=config.workpath
      temp=file_basename(off)
      temp=strsplit(temp,'.',/extract)
      off=temp(0)
      file=off+'.offsets'
      outfile=dialog_pickfile(title='',/write,file=file,path=workpath,filter='*.offsets',/overwrite_prompt)
    widget_control,(*pstate).offsets,set_value=outfile
    widget_control,(*pstate).offsets,set_uvalue=outfile   
  END

    'ok': begin
      widget_control,(*pstate).master,get_value=master 
      widget_control,(*pstate).slave,get_value=slave
      widget_control,(*pstate).off,get_value=off
      widget_control,(*pstate).mpar,get_value=mparfile 
      widget_control,(*pstate).spar,get_value=sparfile
      widget_control,(*pstate).offs,get_value=offs
      widget_control,(*pstate).snr,get_value=snr 
      widget_control,(*pstate).offsets,get_value=offsets
      
      widget_control,(*pstate).rpixl,get_value=rpixl
      widget_control,(*pstate).azpixl,get_value=azpixl
      widget_control,(*pstate).rpixs,get_value=rpixs
      widget_control,(*pstate).rpixe,get_value=rpixe
      widget_control,(*pstate).azpixs,get_value=azpixs
      widget_control,(*pstate).azpixe,get_value=azpixe
;      widget_control,(*pstate).ovr,get_value=ovr
      widget_control,(*pstate).thres,get_value=thres
;      widget_control,(*pstate).pflg,get_value=pflg
      widget_control,(*pstate).rwisz,get_value=rwisz
      widget_control,(*pstate).azwisz,get_value=azwisz
      
      ovr=WIDGET_INFO((*pstate).ovr,/droplist_select)
       n_ovr=long(ovr)
       Case n_ovr OF
         0: BEGIN
           ovr='2'
         END
         1: BEGIN
           ovr='1'
         END
         2: BEGIN
           ovr='2'
         END
       ENDCASE
       
 ;      ovr=STRCOMPRESS(ovr+1, /REMOVE_ALL)
       pflg=WIDGET_INFO((*pstate).pflg,/droplist_select)
       pflg=STRCOMPRESS(pflg, /REMOVE_ALL)
      
      IF NOT FILE_TEST(master) then begin
        TLI_SMC_DUMMY, inputstr='ERROR! Please select input master file.'
        RETURN
      ENDIF
      IF NOT FILE_TEST(slave) then begin
        TLI_SMC_DUMMY, inputstr='ERROR! Please select input slave file.'
        RETURN
      ENDIF
      IF NOT FILE_TEST(off) then begin
        TLI_SMC_DUMMY, inputstr='ERROR! Please select input offset par file.'
        RETURN
      ENDIF
      IF NOT FILE_TEST(mparfile) then begin
        TLI_SMC_DUMMY, inputstr='ERROR! Please select input master par file.'
        RETURN
      ENDIF
      IF NOT FILE_TEST(sparfile) then begin
        TLI_SMC_DUMMY, inputstr='ERROR! Please select input slave par file.'
        RETURN
      ENDIF    
      IF offs eq '' then begin
        TLI_SMC_DUMMY, inputstr='ERROR! Please specify offs file.'
        RETURN
      ENDIF
      IF snr eq '' then begin
        TLI_SMC_DUMMY, inputstr='ERROR! Please specify snr file.'
        RETURN
      ENDIF
      IF offsets eq '' then begin
        TLI_SMC_DUMMY, inputstr='ERROR! Please specify coffsets file.'
        RETURN
      ENDIF
    
      if rpixl ne '-' then begin      
        if rpixl le 0 then begin
          result=dialog_message(['step in range pixel should be greater than 0:',$
          STRCOMPRESS(rpixl)],title='Sasmac InSAR',/information,/center)
          return
        endif
      endif
      if azpixl ne '-' then begin      
        if azpixl le 0 then begin
          result=dialog_message(['step in azimuth pixel should be greater than 0:',$
          STRCOMPRESS(azpixl)],title='Sasmac InSAR',/information,/center)
          return
        endif
      endif
      if rpixs ne '-' then begin      
        if rpixs le 0 then begin
          result=dialog_message(['starting range pixel should be greater than 0:',$
          STRCOMPRESS(rpixs)],title='Sasmac InSAR',/information,/center)
          return
        endif
      endif
      if rpixe ne '-' then begin      
        if rpixe le 0 then begin
          result=dialog_message(['ending range pixel should be greater than 0:',$
          STRCOMPRESS(rpixe)],title='Sasmac InSAR',/information,/center)
          return
        endif
      endif
      if azpixs ne '-' then begin      
        if azpixs le 0 then begin
          result=dialog_message(['starting azimuth line should be greater than 0:',$
          STRCOMPRESS(azpixs)],title='Sasmac InSAR',/information,/center)
          return
        endif
      endif
      if azpixe ne '-' then begin      
        if azpixe le 0 then begin
          result=dialog_message(['ending azimuth line should be greater than 0:',$
          STRCOMPRESS(azpixe)],title='Sasmac InSAR',/information,/center)
          return
        endif
      endif
      if rwisz ne '-' then begin
        if rwisz le 0 then begin
          result=dialog_message(['range window size should be greater than 0:',$
          STRCOMPRESS(rwisz)],title='Sasmac InSAR',/information,/center)
          return
        endif
      endif
      if azwisz ne '-' then begin      
        if azwisz le 0 then begin
          result=dialog_message(['azimuth window size should be greater than 0:',$
          STRCOMPRESS(azwisz)],title='Sasmac InSAR',/information,/center)
          return
        endif
      endif

      if thres ne '-' then begin
        if thres le 0 then begin       
          result=dialog_message(['offset estimation quality threshold should be greater than 0:',$
          STRCOMPRESS(thres)],title='Sasmac InSAR',/information,/center)
          return
        endif
      endif

        scr="offset_pwr_tracking " +master +' '+slave +' '+master+'.par '+slave+'.par '+off+' '+offs+' '+snr+' '+rwisz+' '+azwisz+' '+offsets+' '+ovr+' '+thres+' '+rpixl+' '+azpixl+' '+$
          rpixs+' '+rpixe+' '+azpixs+' '+azpixe+' '+pflg
        TLI_SMC_SPAWN, scr,info='Determine initial offset between SLC images, Please wait...'

;stop
     end
     
    'cl':begin
;      result=dialog_message('Sure exit？',title='Exit',/question,/default_no,/center)
;      if result eq 'Yes'then begin
        widget_control,event.top,/destroy
;      endif
      end
      else: begin
        return
      end
   endcase
END


PRO CWN_SMC_OFFSETPWRTRAC
COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  
  ; --------------------------------------------------------------------
  ; Assignment
  
  device,get_screen_size=screen_size
  xoffset=screen_size(0)/3
  yoffset=screen_size(1)/3
  xsize=560
  ysize=710
  
  ; Get config info
  workpath=config.workpath
  m_slc=config.m_slc
  s_slc=config.s_slc
  mparfile=config.m_slcpar
  sparfile=config.s_slcpar
  off=config.offfile
  rwisz='32'
  azwisz='32'
  rpixl='40'
  azpixl='40'
  rpixs='-'
  rpixe='-'
  azpixs='-'
  azpixe='-' 
  ovr='2'
  thres='9.0'
  pflg='1'
  offs=''
  snr=''
  offsets=''
  
  IF FILE_TEST(mparfile) THEN BEGIN
   finfo=TLI_LOAD_SLC_PAR(mparfile)
;   samples=STRCOMPRESS(finfo.range_samples,/REMOVE_ALL)
;   lines=STRCOMPRESS(finfo.azimuth_lines,/REMOVE_ALL)
   rpixs=STRCOMPRESS(string(long(rwisz)/2),/REMOVE_ALL)
   rpixe=STRCOMPRESS(string(long(finfo.range_samples)-long(rwisz)/2),/REMOVE_ALL)
   azpixs=STRCOMPRESS(string(long(azwisz)/2),/REMOVE_ALL)
   azpixe=STRCOMPRESS(string(long(finfo.azimuth_lines)-long(azwisz)/2),/REMOVE_ALL)
   
  ENDIF
  
  if FILE_TEST(off) then begin
    temp=TLI_FNAME(off,suffix=suffix)
    IF suffix EQ '.off' THEN BEGIN
      finfo=TLI_LOAD_PAR(off)
      rwisz=STRCOMPRESS(string(long(finfo.offset_estimation_window_width)),/remove_all)
      azwisz=STRCOMPRESS(string(long(finfo.offset_estimation_window_height)),/remove_all)
      thres=STRCOMPRESS(string(long(finfo.offset_estimation_threshhold)),/remove_all)
      offs=workpath+TLI_FNAME(off, /nosuffix)+'.offs'
      snr=workpath+TLI_FNAME(off, /nosuffix)+'.off.snr'
      offsets=workpath+TLI_FNAME(off, /nosuffix)+'.offsets'
    ENDIF
  endif

  ;-------------------------------------------------------------------------
  ; Create widgets
  tlb=widget_base(title='offset_pwr_tracking',tlb_frame_attr=0,/column,xsize=xsize,ysize=ysize,xoffset=xoffset,yoffset=yoffset)
 
  masterID=widget_base(tlb,/row,xsize=xsize,frame=1)
  master=widget_text(masterID,value=m_slc,uvalue=m_slc,uname='master',/editable,xsize=72)
  openmaster=widget_button(masterID,value='Input Master',uname='openmaster',xsize=100)
  
  slaveID=widget_base(tlb,/row,xsize=xsize,frame=1)
  slave=widget_text(slaveID,value=s_slc,uvalue=s_slc,uname='slave',/editable,xsize=72)
  openslave=widget_button(slaveID,value='Input Slave',uname='openslave',xsize=100) 
  
  offID=widget_base(tlb,/row,xsize=xsize,frame=1)
  off=widget_text(offID,value=off,uvalue=off,uname='off',/editable,xsize=72)
  openoff=widget_button(offID,value='Input Offeset',uname='openoff',xsize=100)
    
  temp=widget_label(tlb,value='------------------------------------------------------------------------------------------')
  ;-----------------------------------------------
  ; Basic information about input parameters
  labID=widget_base(tlb,/column,xsize=xsize)
  
  parID=widget_base(labID,/row, xsize=xsize)
  parlabel=widget_label(parID, xsize=xsize-10, value='Basic information about input parameters:',/align_left,/dynamic_resize) 
  
  mparID=widget_base(labID,/row,xsize=xsize-20,frame=1)
  mpar=widget_text(mparID,value=mparfile,uvalue=mparfile,uname='mpar',/editable,xsize=90)
  
  sparID=widget_base(labID,/row, xsize=xsize-20,frame=1)
  spar=widget_text(sparID,value=sparfile,uvalue=sparfile,uname='spar',/editable,xsize=90) 
  
  ;-----------------------------------------------------------------------------------------
  ; window size parameters
  infoID=widget_base(labID,/row, xsize=xsize)
  
  tempID=widget_base(infoID,/row,xsize=xsize/4-15, frame=1)
  rwiszID=widget_base(tempID,/column, xsize=xsize/4-5)
  rwiszlabel=widget_label(rwiszID, value='Range Window Size:',/ALIGN_LEFT)
  rwisz=widget_text(rwiszID, value=rwisz,uvalue=rwisz, uname='rwisz',/editable,xsize=10) 
  
  tempID=widget_base(infoID,/row,xsize=xsize/4-15, frame=1)
  rpixlID=widget_base(tempID,/column, xsize=xsize/4-5)
  rpixllabel=widget_label(rpixlID, value='Range Step Pixel:',/ALIGN_LEFT)
  rpixl=widget_text(rpixlID, value=rpixl,uvalue=rpixl, uname='rpixl',/editable,xsize=10)

  tempID=widget_base(infoID,/row,xsize=xsize/4-15, frame=1)
  rpixsID=widget_base(tempID,/column, xsize=xsize/4-5)
  rpixslabel=widget_label(rpixsID, value='Range Pixel Start:',/ALIGN_LEFT)
  rpixs=widget_text(rpixsID, value=rpixs,uvalue=rpixs, uname='rpixs',/editable,xsize=10) 
  
  tempID=widget_base(infoID,/row,xsize=xsize/4-15, frame=1)
  azpixsID=widget_base(tempID,/column, xsize=xsize/4-5)
  azpixslabel=widget_label(azpixsID, value='Azimuth Pixel Start:',/ALIGN_LEFT)
  azpixs=widget_text(azpixsID, value=azpixs,uvalue=azpixs, uname='azpixs',/editable,xsize=10)

  ;-----------------------------------------------------------------------------------------
  ; window size parameters
  infoID=widget_base(labID,/row, xsize=xsize)
  
  tempID=widget_base(infoID,/row,xsize=xsize/4-15, frame=1)
  azwiszID=widget_base(tempID,/column, xsize=xsize/4-5)
  azwiszlabel=widget_label(azwiszID, value='Azimuth Window Size:',/ALIGN_LEFT)
  azwisz=widget_text(azwiszID, value=azwisz,uvalue=azwisz, uname='azwisz',/editable,xsize=10)
  
  tempID=widget_base(infoID,/row,xsize=xsize/4-15, frame=1)
  azpixlID=widget_base(tempID,/column, xsize=xsize/4-5)
  azpixllabel=widget_label(azpixlID, value='Azimuth Step Pixel:',/ALIGN_LEFT)
  azpixl=widget_text(azpixlID, value=azpixl,uvalue=azpixl, uname='azpixl',/editable,xsize=10)
  
  tempID=widget_base(infoID,/row,xsize=xsize/4-15, frame=1)
  rpixeID=widget_base(tempID,/column, xsize=xsize/4-5)
  rpixelabel=widget_label(rpixeID, value='Range Pixel End:',/ALIGN_LEFT)
  rpixe=widget_text(rpixeID, value=rpixe,uvalue=rpixe, uname='rpixe',/editable,xsize=10) 
  
  tempID=widget_base(infoID,/row,xsize=xsize/4-15, frame=1)
  azpixeID=widget_base(tempID,/column, xsize=xsize/4-5)
  azpixelabel=widget_label(azpixeID, value='Azimuth Pixel End:',/ALIGN_LEFT)
  azpixe=widget_text(azpixeID, value=azpixe,uvalue=azpixe, uname='azpixe',/editable,xsize=10)
  
  ;-------------------------------------------------------------------------------------------
  ;other parameters 
  infoID=widget_base(labID,/row, xsize=xsize)
  tempID=widget_base(infoID,/row,xsize=xsize/4-10, frame=1)
  ovrID=widget_base(tempID,/column, xsize=xsize/3-5)
  ovrlabel=widget_label(ovrID, value='Oversampling Factor:',/ALIGN_LEFT)
  ovr=widget_droplist(ovrID, value=[ '2         ',$
                                   '1         ',$
                                   '4         '])
  ;ovr=widget_text(ovrID, value=ovr,uvalue=ovr, uname='ovr',/editable,xsize=10) 
  
  tempID=widget_base(infoID,/row,xsize=xsize/4-10, frame=1)
  thresID=widget_base(tempID,/column, xsize=xsize/3-5)
  threslabel=widget_label(thresID, value='SNR Threshold:',/ALIGN_LEFT)
  thres=widget_text(thresID, value=thres,uvalue=thres, uname='thres',/editable,xsize=10)
  
  tempID=widget_base(infoID,/row,xsize=xsize/2-30, frame=1,/ALIGN_LEFT)
  pflgID=widget_base(tempID,/column, xsize=xsize/2-5,/ALIGN_LEFT)
  pflglabel=widget_label(pflgID, value='Print Flag:',/ALIGN_LEFT)
  pflg=widget_droplist(pflgID, value=['Print offset summary',$
                                    'Print all offset data'])
  ;pflg=widget_text(pflgID, value=pflg,uvalue=pflg, uname='pflg',/editable,xsize=10)
  
  ;-----------------------------------------------------------------------------------------------
  ;output parameters
  temp=widget_label(tlb,value='-----------------------------------------------------------------------------------------')
  mlID=widget_base(tlb,/column,xsize=xsize)
  
  tempID=widget_base(mlID,/row, xsize=xsize)
  templabel=widget_label(tempID, xsize=xsize-10, value='Offset tracking between SLC images using intensity cross-correlation:',/align_left,/dynamic_resize)
  
  offsID=widget_base(tlb,row=1, frame=1)
  offs=widget_text(offsID,value=offs,uvalue=offs,uname='offs',/editable,xsize=72)
  openoffs=widget_button(offsID,value='Output Offs',uname='openoffs',xsize=100)
  
  snrID=widget_base(tlb,row=1, frame=1)
  snr=widget_text(snrID,value=snr,uvalue=snr,uname='snr',/editable,xsize=72)
  opensnr=widget_button(snrID,value='Output offsnr',uname='opensnr',xsize=100)
  
  offsetsID=widget_base(tlb,row=1, frame=1)
  offsets=widget_text(offsetsID,value=offsets,uvalue=offsets,uname='offsets',/editable,xsize=72)
  openoffsets=widget_button(offsetsID,value='Output offsets',uname='openoffsets',xsize=100)
  
  ;-Create common components
  funID=widget_base(tlb,row=1,/align_center)
  ok=widget_button(funID,value='Script',uname='ok',xsize=90,ysize=30)
  cl=widget_button(funID,value='Exit',uname='cl',xsize=90,ysize=30) 
  
  ;Recognize components
   state={master:master,$
    openmaster:openmaster,$
    slave:slave,$
    openslave:openslave,$
    off:off,$
    openoff:openoff,$
    mpar:mpar,$
    spar:spar,$
    rwisz:rwisz,$
    azwisz:azwisz,$
    rpixl:rpixl,$
    azpixl:azpixl,$
    rpixs:rpixs,$
    rpixe:rpixe,$
    azpixs:azpixs,$
    azpixe:azpixe,$
    ovr:ovr,$
    thres:thres,$
    pflg:pflg,$
    offs:offs,$
    openoffs:openoffs,$
    snr:snr,$
    opensnr:opensnr,$
    offsets:offsets,$
    openoffsets:openoffsets,$
    
    ok:ok,$
    cl:cl $
   }
    
  pstate=ptr_new(state,/no_copy) 
  widget_control,tlb,set_uvalue=pstate
  widget_control,tlb,/realize
  xmanager,'CWN_SMC_OFFSETPWRTRAC',tlb,/no_block
END