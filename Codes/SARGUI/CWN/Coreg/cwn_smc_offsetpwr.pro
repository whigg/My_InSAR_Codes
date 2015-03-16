PRO CWN_SMC_OFFSETPWR_EVENT,EVENT
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

    master=config.m_slc
    mparfile=config.m_slcpar
    
    widget_control,(*pstate).master,set_value=infile
    widget_control,(*pstate).master,set_uvalue=infile    
    widget_control,(*pstate).mpar,set_value=mparfile
    widget_control,(*pstate).mpar,set_uvalue=mparfile
    
  END
  'openslave':begin
    slave=config.s_slc
    infile=dialog_pickfile(title='Sasmac InSAR',/read,filter='*.rslc;*.slc', path=workpath,file=slave)
    IF NOT FILE_TEST(infile) THEN return
    
    ; Update widget info.
    config.s_slc=infile
    config.s_slcpar=infile+'.par'

    sparfile=config.s_slcpar
    widget_control,(*pstate).slave,set_value=infile
    widget_control,(*pstate).slave,set_uvalue=infile
    widget_control,(*pstate).spar,set_value=sparfile
    widget_control,(*pstate).spar,set_uvalue=sparfile
   
  END
  'openoff':begin
    off=config.offfile
    infile=dialog_pickfile(title='Sasmac InSAR',/read,filter='*.off', path=workpath,file=off)
    IF NOT FILE_TEST(infile) THEN return
    
    ; Update definitions
    config.offfile=infile
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
        TLI_SMC_DUMMY, inputstr='ERROR! Please select the offset par file.'
        RETURN
      ENDIF 
    offs=workpath+PATH_SEP()+TLI_FNAME(off, /nosuffix)+'.offs'
    snr=workpath+PATH_SEP()+TLI_FNAME(off, /nosuffix)+'.off.snr'
    offsets=workpath+PATH_SEP()+TLI_FNAME(off, /nosuffix)+'.offsets'
    
      finfo=TLI_LOAD_PAR(infile)
      rwisz=STRCOMPRESS(string(long(finfo.offset_estimation_window_width)),/remove_all)
      azwisz=STRCOMPRESS(string(long(finfo.offset_estimation_window_height)),/remove_all)
      rest=STRCOMPRESS(string(long(finfo.offset_estimation_range_samples)),/remove_all)
      azest=STRCOMPRESS(string(long(finfo.offset_estimation_azimuth_samples)),/remove_all)
      estth=STRCOMPRESS(string(long(finfo.offset_estimation_threshhold)),/remove_all)
    widget_control,(*pstate).rwisz,set_value=rwisz
    widget_control,(*pstate).rwisz,set_uvalue=rwisz
    widget_control,(*pstate).azwisz,set_value=azwisz
    widget_control,(*pstate).azwisz,set_uvalue=azwisz
    widget_control,(*pstate).rest,set_value=rest
    widget_control,(*pstate).rest,set_uvalue=rest  
    widget_control,(*pstate).azest,set_value=azest
    widget_control,(*pstate).azest,set_uvalue=azest
    widget_control,(*pstate).estth,set_value=estth
    widget_control,(*pstate).estth,set_uvalue=estth   

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
        TLI_SMC_DUMMY, inputstr='ERROR! Please select the offset par file.'
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
        TLI_SMC_DUMMY, inputstr='ERROR! Please select the offset par file.'
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
        TLI_SMC_DUMMY, inputstr='ERROR! Please select the offset par file.'
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
      
      widget_control,(*pstate).rest,get_value=rest
      widget_control,(*pstate).azest,get_value=azest
      widget_control,(*pstate).estth,get_value=estth
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
      IF NOT FILE_TEST(mparfile) then begin
        TLI_SMC_DUMMY, inputstr='ERROR! Please select input master par file.'
        RETURN
      ENDIF
      IF NOT FILE_TEST(sparfile) then begin
        TLI_SMC_DUMMY, inputstr='ERROR! Please select input slave par file.'
        RETURN
      ENDIF      
      IF NOT FILE_TEST(off) then begin
        TLI_SMC_DUMMY, inputstr='ERROR! Please select the offset par file.'
        RETURN
      ENDIF
      
      if offs EQ '' then begin
        TLI_SMC_DUMMY, inputstr='ERROR! Please specify offs file.'
        RETURN
      ENDIF
      if snr EQ '' then begin
        TLI_SMC_DUMMY, inputstr='ERROR! Please specify snr file.'
        RETURN
      ENDIF
      IF offsets eq  '' then begin
        TLI_SMC_DUMMY, inputstr='ERROR! Please specify coffsets file.'
        RETURN
      ENDIF 
      
      if rest ne '-' then begin      
        if rest le 0 then begin
          result=dialog_message(['number of offset estimates in range direction should be greater than 0:',$
          STRCOMPRESS(rest)],title='Sasmac InSAR',/information,/center)
          return
        endif
      endif
      if azest ne '-' then begin      
        if azest le 0 then begin
          result=dialog_message(['number of offset estimates in azimuth direction should be greater than 0:',$
          STRCOMPRESS(azest)],title='Sasmac InSAR',/information,/center)
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
      if ovr ne '-' then begin
        if ovr ge 5 then begin
          result=dialog_message(['SLC oversampling factor should be 1 2 or 4:',$
          STRCOMPRESS(ovr)],title='Sasmac InSAR',/information,/center)
          return
        endif
      endif
      if estth ne '-' then begin
        if estth le 0 then begin       
          result=dialog_message(['offset estimation quality threshold should be greater than 0:',$
          STRCOMPRESS(estth)],title='Sasmac InSAR',/information,/center)
          return
        endif
      endif
      if pflg ne '-' then begin
        if pflg ge 2 then begin
          result=dialog_message(['print flag should be 0 or 1:',$
          STRCOMPRESS(pflg)],title='Sasmac InSAR',/information,/center)
          return
        endif
      endif      
      
        scr="offset_pwr " +master +' '+slave +' '+master+'.par '+slave+'.par '+off+' '+offs+' '+snr+' '+rwisz+' '+azwisz+' '+offsets+' '+ovr+' '+rest+' '+azest+' '+estth+' '+pflg
        TLI_SMC_SPAWN, scr,info='Offsets between SLC images using intensity cross-correlation, Please wait...'

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


PRO CWN_SMC_OFFSETPWR
COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  
  ; --------------------------------------------------------------------
  ; Assignment
  
  device,get_screen_size=screen_size
  xoffset=screen_size(0)/3
  yoffset=screen_size(1)/3
  xsize=560
  ysize=730
  
  ; Get config info
  workpath=config.workpath
  m_slc=config.m_slc
  s_slc=config.s_slc
  mparfile=config.m_slcpar
  sparfile=config.s_slcpar
  off=config.offfile
  rlks='5'
  azlks='5'
  rest='-'
  azest='-'
  rwisz='-'
  azwisz='-' 
  ovr='2'
  estth='-'
  pflg='0'
  offs=''
  snr=''
  offsets=''
  
  IF FILE_TEST(m_slc) THEN BEGIN
    IF FILE_TEST(s_slc) THEN BEGIN
    temp=TLI_FNAME(m_slc,suffix=suffix)
    IF suffix EQ '.rslc' OR suffix EQ '.slc' THEN BEGIN
      mparfile=mparfile
      ;mparlab=mparfile
    ENDIF
    temp=TLI_FNAME(s_slc,suffix=suffix)
    IF suffix EQ '.rslc' OR suffix EQ '.slc' THEN BEGIN
      sparfile=sparfile
      ;sparlab=sparfile
    ENDIF
 ;   outputfile=workpath+PATH_SEP()+TLI_FNAME(m_slc, /nosuffix)+'-'+TLI_FNAME(s_slc, /nosuffix)+'.off'
  ENDIF
  ENDIF
  if file_test(off) then begin
    temp=TLI_FNAME(off,suffix=suffix)
    IF suffix EQ '.off' THEN BEGIN
      finfo=TLI_LOAD_PAR(off)
      rwisz=STRCOMPRESS(string(long(finfo.offset_estimation_window_width)),/remove_all)
      azwisz=STRCOMPRESS(string(long(finfo.offset_estimation_window_height)),/remove_all)
      rest=STRCOMPRESS(string(long(finfo.offset_estimation_range_samples)),/remove_all)
      azest=STRCOMPRESS(string(long(finfo.offset_estimation_azimuth_samples)),/remove_all)
      estth=STRCOMPRESS(string(long(finfo.offset_estimation_threshhold)),/remove_all)
      offs=workpath+TLI_FNAME(off, /nosuffix)+'.offs'
      snr=workpath+TLI_FNAME(off, /nosuffix)+'.off.snr'
      offsets=workpath+TLI_FNAME(off, /nosuffix)+'.offsets'
    ENDIF
  endif

  ;-------------------------------------------------------------------------
  ; Create widgets
  tlb=widget_base(title='offset_pwr',tlb_frame_attr=0,/column,xsize=xsize,ysize=ysize,xoffset=xoffset,yoffset=yoffset)
 
  masterID=widget_base(tlb,/row,xsize=xsize,frame=1)
  master=widget_text(masterID,value=m_slc,uvalue=m_slc,uname='master',/editable,xsize=74)
  openmaster=widget_button(masterID,value='Input Master',uname='openmaster',xsize=90)
  
  slaveID=widget_base(tlb,/row,xsize=xsize,frame=1)
  slave=widget_text(slaveID,value=s_slc,uvalue=s_slc,uname='slave',/editable,xsize=74)
  openslave=widget_button(slaveID,value='Input Slave',uname='openslave',xsize=90) 
  
  offID=widget_base(tlb,/row,xsize=xsize,frame=1)
  off=widget_text(offID,value=off,uvalue=off,uname='off',/editable,xsize=74)
  openoff=widget_button(offID,value='Input Offset',uname='openoff',xsize=90)
    
  temp=widget_label(tlb,value='------------------------------------------------------------------------------------------')
  ;-----------------------------------------------
  ; Basic information about input parameters
  labID=widget_base(tlb,/column,xsize=xsize)
  
  parID=widget_base(labID,/row, xsize=xsize)
  parlabel=widget_label(parID, xsize=xsize-10, value='Basic information about input parameters:',/align_left,/dynamic_resize) 
  
  mparID=widget_base(labID,/row,xsize=xsize,frame=1)
  mpar=widget_text(mparID,value=mparfile,uvalue=mparfile,uname='mpar',/editable,xsize=89)
  
  sparID=widget_base(labID,/row, xsize=xsize,frame=1)
  spar=widget_text(sparID,value=sparfile,uvalue=sparfile,uname='spar',/editable,xsize=89) 
  
  ;-----------------------------------------------------------------------------------------
  ; window size parameters
  infoID=widget_base(labID,/row, xsize=xsize)
  
  tempID=widget_base(infoID,/row,xsize=xsize/3-20, frame=1)
  rwiszID=widget_base(tempID,/column, xsize=xsize/3-10)
  rwiszlabel=widget_label(rwiszID, value='Range Window Size:',/ALIGN_LEFT)
  rwisz=widget_text(rwiszID, value=rwisz,uvalue=rwisz, uname='rwisz',/editable,xsize=10) 
  
  

  tempID=widget_base(infoID,/row,xsize=xsize/3-10, frame=1)
  restID=widget_base(tempID,/column, xsize=xsize/3-10)
  restlabel=widget_label(restID, value='Range Estimates:',/ALIGN_LEFT)
  rest=widget_text(restID, value=rest,uvalue=rest, uname='rest',/editable,xsize=10) 
  
  tempID=widget_base(infoID,/row,xsize=xsize/3-10, frame=1)
  estthID=widget_base(tempID,/column, xsize=xsize/3-10)
  estthlabel=widget_label(estthID, value='Estimation Threshold:',/ALIGN_LEFT)
  estth=widget_text(estthID, value=estth,uvalue=estth, uname='estth',/editable,xsize=10)
  
  ;-------------------------------------------------------------------------------------------
  ;other parameters 
  infoID=widget_base(labID,/row, xsize=xsize)
  
  tempID=widget_base(infoID,/row,xsize=xsize/3-20, frame=1)
  azwiszID=widget_base(tempID,/column, xsize=xsize/3-10)
  azwiszlabel=widget_label(azwiszID, value='Azimuth Window Size:',/ALIGN_LEFT)
  azwisz=widget_text(azwiszID, value=azwisz,uvalue=azwisz, uname='azwisz',/editable,xsize=10)
  
  tempID=widget_base(infoID,/row,xsize=xsize/3-10, frame=1)
  azestID=widget_base(tempID,/column, xsize=xsize/3-10)
  azestlabel=widget_label(azestID, value='Azimuth Estimates:',/ALIGN_LEFT)
  azest=widget_text(azestID, value=azest,uvalue=azest, uname='azest',/editable,xsize=10)
  
  temp=widget_label(tlb,value='------------------------------------------------------------------------------------------')
  labID=widget_base(tlb,/column,xsize=xsize)
  infoID=widget_base(labID,/row, xsize=xsize)
  temp=widget_base(infoID,/row,xsize=xsize/2-50,/frame)
  lab=widget_label(temp,value='Oversampling factor:')
  
  ovr=widget_droplist(temp, value=['2       ',$
                                   '1       ',$
                                   '4       '])
                                   
  temp=widget_base(infoID,/row,xsize=xsize/2+24,/frame)
  lab=widget_label(temp,value='Print flag:')  
  pflg=widget_droplist(temp, value=['Print offset summary',$
                                    'Print all offset data'])

  temp=widget_label(tlb,value='------------------------------------------------------------------------------------------')
 
  mlID=widget_base(tlb,/column,xsize=xsize)
  
  tempID=widget_base(mlID,/row, xsize=xsize)
  templabel=widget_label(tempID, xsize=xsize-10, value='Offsets between SLC images using intensity cross-correlation:',/align_left,/dynamic_resize)
  
  offsID=widget_base(tlb,row=1, frame=1)
  offs=widget_text(offsID,value=offs,uvalue=offs,uname='offs',/editable,xsize=73)
  openoffs=widget_button(offsID,value='Output Offs',uname='openoffs',xsize=90)
  
  snrID=widget_base(tlb,row=1, frame=1)
  snr=widget_text(snrID,value=snr,uvalue=snr,uname='snr',/editable,xsize=73)
  opensnr=widget_button(snrID,value='Output offsnr',uname='opensnr',xsize=90)
  
  offsetsID=widget_base(tlb,row=1, frame=1)
  offsets=widget_text(offsetsID,value=offsets,uvalue=offsets,uname='offsets',/editable,xsize=73)
  openoffsets=widget_button(offsetsID,value='Output offsets',uname='openoffsets',xsize=90)
  
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
    rest:rest,$
    azest:azest,$
    ovr:ovr,$
    estth:estth,$
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
  xmanager,'CWN_SMC_OFFSETPWR',tlb,/no_block
END