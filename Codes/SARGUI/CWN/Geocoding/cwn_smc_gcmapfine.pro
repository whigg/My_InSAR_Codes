PRO CWN_SMC_GCMAPFINE_EVENT,EVENT
  COMMON TLI_SMC_GUI, types, file, wid, config, finfo

  widget_control,event.top,get_uvalue=pstate
  workpath=config.workpath
  uname=widget_info(event.id,/uname)
  case uname of
    'opengcmap':begin
    infile=dialog_pickfile(title='Sasmac InSAR',/read,filter='lookup', path=config.workpath)
    IF NOT FILE_TEST(infile) THEN return

    widget_control,(*pstate).gcmap,set_value=infile
    widget_control,(*pstate).gcmap,set_uvalue=infile

  END
  'opendiffpar':begin
  infile=dialog_pickfile(title='Sasmac InSAR',/read,filter='*.diff_par', path=config.workpath)
  IF NOT FILE_TEST(infile) THEN return

  widget_control,(*pstate).diffpar,set_value=infile
  widget_control,(*pstate).diffpar,set_uvalue=infile

  widget_control,(*pstate).gcmap,get_value=gcmap
  widget_control,(*pstate).diffpar,get_value=diffpar
  if gcmap eq '' then begin
    result=dialog_message(['Please select the gcmap file.'],title='Sasmac InSAR',/information,/center)
    return
  endif
  if diffpar eq '' then begin
    result=dialog_message(['Please select the diffpar file.'],title='Sasmac InSAR',/information,/center)
    return
  endif

  outputfile=workpath+'lookup_fine'
  widget_control,(*pstate).output,set_value=outputfile
  widget_control,(*pstate).output,set_uvalue=outputfile
  
  offinfo=TLI_LOAD_PAR(infile,/keeptxt)
  dem_samples=offinfo.range_samp_1
  WIDGET_CONTROL, (*pstate).widthin, set_value=dem_samples

END

'openoutput':begin
;-Check if input master parfile
widget_control,(*pstate).gcmap,get_value=gcmap
widget_control,(*pstate).diffpar,get_value=diffpar
if gcmap eq '' then begin
  result=dialog_message(['Please select the gcmap file.'],title='Sasmac InSAR',/information,/center)
  return
endif
if diffpar eq '' then begin
  result=dialog_message(['Please select the simsar file.'],title='Sasmac InSAR',/information,/center)
  return
endif

workpath=config.workpath
file='lookup_fine'
outputfile=dialog_pickfile(title='',/write,file=file,path=workpath,filter='lookup_fine',/overwrite_prompt)
widget_control,(*pstate).output,set_value=outputfile
widget_control,(*pstate).output,set_uvalue=outputfile
END


'ok': begin
  widget_control,(*pstate).gcmap,get_value=gcmap
  widget_control,(*pstate).diffpar,get_value=diffpar
  widget_control,(*pstate).output,get_value=output

  widget_control,(*pstate).widthin,get_value=widthin

  reflg=WIDGET_INFO((*pstate).reflg,/droplist_select)
  Case reflg OF
    0: reflg='1'
    1: reflg='0'
    ELSE: 
  ENDCASE
  
  
  if gcmap eq '' then begin
    result=dialog_message(['Please select the gcmap file.'],title='Sasmac InSAR',/information,/center)
    return
  endif
  if diffpar eq '' then begin
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

  scr="gc_map_fine " +gcmap +' '+widthin +' '+diffpar+' '+output+' '+reflg
  TLI_SMC_SPAWN, scr,info='Geocoding lookup table refinement using DIFF_par offset polynomials, Please wait...'

;  stop
end

'cl':begin
;result=dialog_message('Sure exit?',title='Exit',/question,/default_no,/center)
;if result eq 'Yes'then begin
  widget_control,event.top,/destroy
;endif
end
else: begin
  return
end
endcase
END


PRO CWN_SMC_GCMAPFINE
  COMMON TLI_SMC_GUI, types, file, wid, config, finfo

  ; --------------------------------------------------------------------
  ; Assignment

  device,get_screen_size=screen_size
  xoffset=screen_size(0)/3
  yoffset=screen_size(1)/3
  xsize=465
  ysize=400

  ; Get config info
    gcmap=''
    diffpar=''
    widthin=''
    reflg='-'
    output=''

  ;-------------------------------------------------------------------------
  ; Create widgets
  tlb=widget_base(title='gc_map_fine',tlb_frame_attr=0,/column,xsize=xsize,ysize=ysize,xoffset=xoffset,yoffset=yoffset)

  gcmapID=widget_base(tlb,/row,xsize=xsize,frame=1)
  gcmap=widget_text(gcmapID,value=master,uvalue=master,uname='gcmap',/editable,xsize=55)
  opengcmap=widget_button(gcmapID,value='Input gc_map',uname='opengcmap',xsize=105)

  diffparID=widget_base(tlb,/row,xsize=xsize,frame=1)
  diffpar=widget_text(diffparID,value=diffpar,uvalue=diffpar,uname='diffpar',/editable,xsize=55)
  opendiffpar=widget_button(diffparID,value='Input Diff_par',uname='opendiffpar',xsize=105)


  temp=widget_label(tlb,value='------------------------------------------------------------------------------------------')
  ;-----------------------------------------------
  ; Basic information about input parameters
  labID=widget_base(tlb,/column,xsize=xsize)

  parID=widget_base(labID,/row, xsize=xsize)
  parlabel=widget_label(parID, xsize=xsize-200, value='Basic information about input parameters:',/align_left)

  infoID=widget_base(parID,/row, xsize=xsize)

  tempID=widget_base(infoID,/row,xsize=xsize/2-60, frame=1)
  widthinID=widget_base(tempID,/row, xsize=xsize/2)
  widthinlabel=widget_label(widthinID, value='DEM Width:',/ALIGN_LEFT)
  widthin=widget_text(widthinID, value=widthin,uvalue=widthin, uname='widthin',/editable,xsize=13)
  
  infoID=widget_base(labID,/row, xsize=xsize)
  tempID=widget_base(infoID,/row,xsize=xsize-15, frame=1)
  reflgID=widget_base(tempID,/column, xsize=xsize-10)
  reflglabel=widget_label(reflgID, value='reference image flag (offsets are measured relative to the reference image):',/ALIGN_LEFT)
  
  reflg=widget_droplist(reflgID, value=['Simulated SAR image',$
                                        'Actual SAR image'])

  
  ;-----------------------------------------------------------------------------------------------
  ;output parameters
  temp=widget_label(tlb,value='-----------------------------------------------------------------------------------------')
  mlID=widget_base(tlb,/column,xsize=xsize)

  tempID=widget_base(mlID,/row, xsize=xsize)
  templabel=widget_label(tempID, xsize=xsize-10, value='Forward geocoding transformation using a lookup table:',/align_left,/dynamic_resize)

  outputID=widget_base(tlb,row=1, frame=1)
  output=widget_text(outputID,value=output,uvalue=output,uname='output',/editable,xsize=55)
  openoutput=widget_button(outputID,value='Output datafile',uname='openoutput',xsize=105)

  ;-Create common components
  funID=widget_base(tlb,row=1,/align_center)
  ok=widget_button(funID,value='Script',uname='ok',xsize=90,ysize=30)
  cl=widget_button(funID,value='Exit',uname='cl',xsize=90,ysize=30)

  ;Recognize components
  state={gcmap:gcmap,$
    opengcmap:opengcmap,$
    diffpar:diffpar,$
    opendiffpar:opendiffpar,$
    widthin:widthin,$
    reflg:reflg,$
    output:output,$
    openoutput:openoutput,$
    ok:ok,$
    cl:cl $
  }

  pstate=ptr_new(state,/no_copy)
  widget_control,tlb,set_uvalue=pstate
  widget_control,tlb,/realize
  xmanager,'CWN_SMC_GCMAPFINE',tlb,/no_block
END