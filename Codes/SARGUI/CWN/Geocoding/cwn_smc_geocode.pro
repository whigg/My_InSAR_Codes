PRO CWN_SMC_GEOCODE_EVENT,EVENT
  COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  
  widget_control,event.top,get_uvalue=pstate
   workpath=config.workpath
  uname=widget_info(event.id,/uname)
  case uname of
    'opengcmap':begin
    infile=dialog_pickfile(title='Sasmac InSAR',/read,filter='lookup', path=workpath)
    IF NOT FILE_TEST(infile) THEN return

    widget_control,(*pstate).gcmap,set_value=infile
    widget_control,(*pstate).gcmap,set_uvalue=infile    
    
  END
  'opensimsar':begin
    infile=dialog_pickfile(title='Sasmac InSAR',/read,filter='sim_sar', path=workpath)
    IF NOT FILE_TEST(infile) THEN return

    widget_control,(*pstate).simsar,set_value=infile
    widget_control,(*pstate).simsar,set_uvalue=infile
    
    widget_control,(*pstate).gcmap,get_value=gcmap
    widget_control,(*pstate).simsar,get_value=simsar
    if gcmap eq '' then begin
        result=dialog_message(['Please select the gcmap file.'],title='Sasmac InSAR',/information,/center)
        return
      endif
    if simsar eq '' then begin
        result=dialog_message(['Please select the simsar file.'],title='Sasmac InSAR',/information,/center)
        return
      endif
      
   outputfile=simsar+'.rdc'   
   widget_control,(*pstate).output,set_value=outputfile
   widget_control,(*pstate).output,set_uvalue=outputfile     
   
  END

   'openoutput':begin
    ;-Check if input master parfile
    widget_control,(*pstate).gcmap,get_value=gcmap
    widget_control,(*pstate).simsar,get_value=simsar
    if gcmap eq '' then begin
        result=dialog_message(['Please select the gcmap file.'],title='Sasmac InSAR',/information,/center)
        return
      endif
    if simsar eq '' then begin
        result=dialog_message(['Please select the simsar file.'],title='Sasmac InSAR',/information,/center)
        return
      endif

      file=simsar+'.rdc'
      outputfile=dialog_pickfile(title='',/write,file=file,path=workpath,filter='*.rdc',/overwrite_prompt)
      IF outputfile EQ '' THEN RETURN
     widget_control,(*pstate).output,set_value=outputfile
     widget_control,(*pstate).output,set_uvalue=outputfile    
  END
  
  
    'ok': begin
      widget_control,(*pstate).gcmap,get_value=gcmap 
      widget_control,(*pstate).simsar,get_value=simsar
      widget_control,(*pstate).output,get_value=output
      
      widget_control,(*pstate).widthin,get_value=widthin
      widget_control,(*pstate).interp,get_value=interp 
      widget_control,(*pstate).forflg,get_value=forflg      
      widget_control,(*pstate).lrin,get_value=lrin
      widget_control,(*pstate).novr,get_value=novr
      widget_control,(*pstate).radmax,get_value=radmax
      widget_control,(*pstate).nintr,get_value=nintr
      widget_control,(*pstate).widthout,get_value=widthout
      widget_control,(*pstate).nlinesout,get_value=nlinesout
      widget_control,(*pstate).lrout,get_value=lrout
      
      interp=WIDGET_INFO((*pstate).interp,/droplist_select)
      interp=STRCOMPRESS(interp,/REMOVE_ALL)
      
      forflg=WIDGET_INFO((*pstate).forflg,/droplist_select)
      forflg=STRCOMPRESS(forflg,/REMOVE_ALL)
      
      lrin=WIDGET_INFO((*pstate).lrin,/droplist_select)
      lrin_d=long(lrin)
      if lrin_d eq 0 then begin
        lrin=STRCOMPRESS(string(lrin_d+1),/REMOVE_ALL)
      endif
      if lrin_d ne 0 then begin
        lrin=STRCOMPRESS(string(lrin_d-2),/REMOVE_ALL)
      endif
      
      lrout=WIDGET_INFO((*pstate).lrout,/droplist_select)
      lrout_d=long(lrout)
      if lrout_d eq 0 then begin
        lrout=STRCOMPRESS(string(lrout_d+1),/REMOVE_ALL)
      endif
      if lrout_d ne 0 then begin
        lrout=STRCOMPRESS(string(lrout_d-2),/REMOVE_ALL)
      endif
  
      if gcmap eq '' then begin
        result=dialog_message(['Please select the gcmap file.'],title='Sasmac InSAR',/information,/center)
        return
      endif
      if simsar eq '' then begin
        result=dialog_message(['Please select the simsar file.'],title='Sasmac InSAR',/information,/center)
        return
      endif     
      if output eq '' then begin
        result=dialog_message(['Please select the output file.'],title='Sasmac InSAR',/information,/center)
        return
      endif  
      
      if widthin ne '-' then begin      
        if widthin le 0 then begin
          result=dialog_message(['width of input data should be greater than 0:',$
          STRCOMPRESS(widthin)],title='Sasmac InSAR',/information,/center)
          return
        endif
      endif
 
      if novr ne '-' then begin
        if novr le 0 then begin
          result=dialog_message(['SLC oversampling factor should be greater than 0:',$
          STRCOMPRESS(novr)],title='Sasmac InSAR',/information,/center)
          return
        endif
      endif
      if radmax ne '-' then begin
        if radmax le 4 then begin       
          result=dialog_message(['maximum interpolation search radius should be greater than 4:',$
          STRCOMPRESS(radmax)],title='Sasmac InSAR',/information,/center)
          return
        endif
      endif
      if nintr ne '-' then begin
        if nintr le 0 then begin
          result=dialog_message(['Interpolation points number should be greater than 0:',$
          STRCOMPRESS(nintr)],title='Sasmac InSAR',/information,/center)
          return
        endif
      endif  
      
      if widthout ne '-' then begin
        if widthout le 0 then begin       
          result=dialog_message(['width of output data file should be greater than 4:',$
          STRCOMPRESS(widthout)],title='Sasmac InSAR',/information,/center)
          return
        endif
      endif
      if nlinesout ne '-' then begin
        if nlinesout le 0 then begin
          result=dialog_message(['number of lines for the output data file should be greater than 0:',$
          STRCOMPRESS(nlinesout)],title='Sasmac InSAR',/information,/center)
          return
        endif
      endif    
      
        scr="geocode " +gcmap +' '+simsar +' '+widthin+' '+output+' '+widthout+' '+nlinesout+' '+interp+' '+forflg+' '+lrin+' '+lrout+' '+novr+' '+radmax+' '+nintr
        TLI_SMC_SPAWN, scr,info='Forward geocoding transformation using a lookup table, Please wait...'

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


PRO CWN_SMC_GEOCODE
COMMON TLI_SMC_GUI, types, file, wid, config, finfo
  
  ; --------------------------------------------------------------------
  ; Assignment
  
  device,get_screen_size=screen_size
  xoffset=screen_size(0)/3
  yoffset=screen_size(1)/3
  xsize=565
  ysize=580
  
  ; Get config info
    gcmap=''
    simsar=''    
    widthin=''
    novr='2'
    radmax='8'
    nintr='4'
    widthout=''
    nlinesout=''
    output=''
    
    dem_segpar=config.workpath+'dem_seg.par'
    IF FILE_TEST(dem_segpar) THEN BEGIN
      deminfo=TLI_LOAD_PAR(dem_segpar, /keeptxt)
      widthin=deminfo.width
    ENDIF
    
    pwrpar=config.workpath+TLI_FNAME(config.m_slc,/nosuffix)+'.pwr.par'
    IF FILE_TEST(pwrpar) THEN BEGIN
      pwrinfo=TLI_LOAD_PAR(pwrpar,/keeptxt)
      widthout=pwrinfo.range_samples
      nlinesout=pwrinfo.azimuth_lines
    ENDIF

  ;-------------------------------------------------------------------------
  ; Create widgets
  tlb=widget_base(title='geocode',tlb_frame_attr=0,/column,xsize=xsize,ysize=ysize,xoffset=xoffset,yoffset=yoffset)
 
  gcmapID=widget_base(tlb,/row,xsize=xsize,frame=1)
  gcmap=widget_text(gcmapID,value=master,uvalue=master,uname='gcmap',/editable,xsize=72)
  opengcmap=widget_button(gcmapID,value='Input gc_map',uname='opengcmap',xsize=105)
  
  simsarID=widget_base(tlb,/row,xsize=xsize,frame=1)
  simsar=widget_text(simsarID,value=simsar,uvalue=simsar,uname='simsar',/editable,xsize=72)
  opensimsar=widget_button(simsarID,value='Input sim_sar',uname='opensimsar',xsize=105) 

    
  temp=widget_label(tlb,value='------------------------------------------------------------------------------------------')
  ;-----------------------------------------------
  ; Basic information about input parameters
  labID=widget_base(tlb,/column,xsize=xsize)
  
  parID=widget_base(labID,/row, xsize=xsize)
  parlabel=widget_label(parID, xsize=xsize-10, value='Basic information about input parameters:',/align_left,/dynamic_resize) 
  
  ;-----------------------------------------------------------------------------------------
  ; window size parameters
  infoID=widget_base(labID,/row, xsize=xsize)
  
  tempID=widget_base(infoID,/row,xsize=xsize/3-45, frame=1)
  widthinID=widget_base(tempID,/column, xsize=xsize/3-5,/ALIGN_CENTER)
  widthinlabel=widget_label(widthinID, value='DEM Width:',/ALIGN_LEFT)
  widthin=widget_text(widthinID, value=widthin,uvalue=widthin, uname='widthin',/editable,xsize=10) 

  tempID=widget_base(infoID,/row,xsize=xsize/3-15, frame=1)
  nintrID=widget_base(tempID,/column, xsize=xsize/3-5)
  nintrlabel=widget_label(nintrID, value='Interpolation points number:',/ALIGN_LEFT)
  nintr=widget_text(nintrID, value=nintr,uvalue=nintr, uname='nintr',/editable,xsize=13)
  
  tempID=widget_base(infoID,/row,xsize=xsize/3+25, frame=1)
  radmaxID=widget_base(tempID,/column, xsize=xsize/3+25)
  radmaxlabel=widget_label(radmaxID, value='Maximum interpolation search radius:',/ALIGN_LEFT)
  radmax=widget_text(radmaxID, value=radmax,uvalue=radmax, uname='radmax',/editable,xsize=10) 
  
  infoID=widget_base(labID,/row, xsize=xsize)
  tempID=widget_base(infoID,/row,xsize=xsize/3-45, frame=1)
  widthoutID=widget_base(tempID,/column, xsize=xsize/3-5)
  widthoutlabel=widget_label(widthoutID, value=' Output Width:',/ALIGN_LEFT)
  widthout=widget_text(widthoutID, value=widthout,uvalue=widthout, uname='widthout',/editable,xsize=10)
  
  tempID=widget_base(infoID,/row,xsize=xsize/3-15, frame=1)
  nlinesoutID=widget_base(tempID,/column, xsize=xsize/3-5)
  nlinesoutlabel=widget_label(nlinesoutID, value='Output Lines:',/ALIGN_LEFT)
  nlinesout=widget_text(nlinesoutID, value=nlinesout,uvalue=nlinesout, uname='nlinesout',/editable,xsize=10)
  
  tempID=widget_base(infoID,/row,xsize=xsize/3+25, frame=1)
  novrID=widget_base(tempID,/column, xsize=xsize/3+25)
  novrlabel=widget_label(novrID, value='Interpolation Oversampling Factor:',/ALIGN_LEFT)
  novr=widget_text(novrID, value=novr,uvalue=novr, uname='novr',/editable,xsize=10)
  
  infoID=widget_base(labID,/row, xsize=xsize) 
  tempID=widget_base(infoID,/row,xsize=xsize/2-15, frame=1)
  interpID=widget_base(tempID,/column, xsize=xsize/2-5)
  interplabel=widget_label(interpID, value='Resampling interpolation mode:',/ALIGN_LEFT)
  
  interp=widget_droplist(interpID, value=['1/dist',$
                                          'nearest neighbor',$
                                          'SQR(1/dist)',$
                                          'constant',$
                                          'Gauss weighting'])
  
  tempID=widget_base(infoID,/row,xsize=xsize/2-10, frame=1)
  forflgID=widget_base(tempID,/column, xsize=xsize/2-5)
  forflglabel=widget_label(forflgID, value='Input/output data format:',/ALIGN_LEFT)
  
  forflg=widget_droplist(forflgID, value=['FLOAT',$
                                          'FCOMPLEX',$
                                          'SUN raster/BMP format',$
                                          'UNSIGNED CHAR',$
                                          'SHORT',$
                                          'SCOMPLEX'])
  
  ;-----------------------------------------------------------------------------------------
  ;estimates parameters
  infoID=widget_base(labID,/row, xsize=xsize)
  tempID=widget_base(infoID,/row,xsize=xsize/2-15, frame=1)
  lrinID=widget_base(tempID,/column, xsize=xsize/2-5)
  lrinlabel=widget_label(lrinID, value='Input SUN raster/BMP format left flipped:',/ALIGN_LEFT)
  
  lrin=widget_droplist(lrinID, value=['not flipped',$
                                      'flipped'])
  
  tempID=widget_base(infoID,/row,xsize=xsize/2-10, frame=1)
  lroutID=widget_base(tempID,/column, xsize=xsize/2-5)
  lroutlabel=widget_label(lroutID, value='Output SUN raster/BMP format write flipped:',/ALIGN_LEFT)

  lrout=widget_droplist(lroutID, value=['not flipped',$
                                      'flipped'])
  
  
  

  
  ;-----------------------------------------------------------------------------------------------
  ;output parameters
  temp=widget_label(tlb,value='-----------------------------------------------------------------------------------------')
  mlID=widget_base(tlb,/column,xsize=xsize)
  
  tempID=widget_base(mlID,/row, xsize=xsize)
  templabel=widget_label(tempID, xsize=xsize-10, value='Forward geocoding transformation using a lookup table:',/align_left,/dynamic_resize)
  
  
  
  outputID=widget_base(tlb,row=1, frame=1)
  output=widget_text(outputID,value=output,uvalue=output,uname='output',/editable,xsize=72)
  openoutput=widget_button(outputID,value='Output datafile',uname='openoutput',xsize=105)
  
  ;-Create common components
  funID=widget_base(tlb,row=1,/align_center)
  ok=widget_button(funID,value='Script',uname='ok',xsize=90,ysize=30)
  cl=widget_button(funID,value='Exit',uname='cl',xsize=90,ysize=30) 
  
  ;Recognize components
   state={gcmap:gcmap,$
    opengcmap:opengcmap,$
    simsar:simsar,$
    opensimsar:opensimsar,$
    
    widthin:widthin,$
    interp:interp,$
    forflg:forflg,$
    lrin:lrin,$
    novr:novr,$
    radmax:radmax,$
    nintr:nintr,$
    widthout:widthout,$
    nlinesout:nlinesout,$
    lrout:lrout,$
    output:output,$
    openoutput:openoutput,$
    
    ok:ok,$
    cl:cl $
   }
    
  pstate=ptr_new(state,/no_copy) 
  widget_control,tlb,set_uvalue=pstate
  widget_control,tlb,/realize
  xmanager,'CWN_SMC_GEOCODE',tlb,/no_block
END