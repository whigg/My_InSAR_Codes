;
; Generate kml file indicating the range of SLC image.
; 
; Parameters:
;   parfile    : SLC par.
;
; Keywords:
;   outputfile : Outputfile. Default: parfile+'.kml'
;   annotation : Annotation of kml file. Default: none.
;
; Written by:
;   T.LI @ Sasmac, 20140904.
;
@kml
FUNCTION TLI_SLC_RANGE_CONNECTION, slc_range, order=order
  ; Determine the connection of SLC corner coordinates.
  ; 
  ; Parameters:
  ;   slc_range: Input slc_corners. slc_range is a 2*4 array. [lat, lon]
  ; 
  ; Keywords:
  ;   order    : Order of the points to connect.
  ;
  ; Written by:
  ;   T.LI @ Sasmac, 20140904.
  ;  
  order_orig=LINDGEN(4)
  
  ; SORT the longitudes
  temp=SORT(slc_range[1,*])
  slc_range_new=slc_range[*, temp]
  order_new=order_orig[temp]
  
  ; SORT the latitudes and find the UL corner
  IF slc_range_new[0, 0] GE slc_range_new[0, 1] THEN BEGIN ; The first nod is UL corner.

    IF slc_range_new[0, 2] GE slc_range_new[0, 3] THEN BEGIN
      order_new[2:3]=[order_new[3], order_new[2]]
    ENDIF ELSE BEGIN

    ENDELSE
    
  ENDIF ELSE BEGIN

    order_new[0:1]=[order_new[1], order_new[0]]
    
    IF slc_range_new[0,2] LE slc_range_new[0,3] THEN BEGIN

    ENDIF ELSE BEGIN

      order_new[2:3]=[order_new[3], order_new[2]]
    ENDELSE
    
  ENDELSE
  order=order_new
  
  slc_range_new=slc_range[*, order]
  RETURN, slc_range_new
END

PRO TLI_SLC_RANGE, parfile, outputfile=outputfile, annotation=annotation
  
  COMPILE_OPT idl2
  
  IF NOT FILE_TEST(parfile) THEN BEGIN
    Message, 'Error! Par file not found!'+STRING(13b)+parfile
  ENDIF
  
  IF NOT KEYWORD_SET(outputfile) THEN BEGIN
    outputfile=parfile+'.kml'
  ENDIF
  
  IF NOT KEYWORD_SET(annotation) THEN BEGIN
    annotation=''  
  ENDIF
  
  void=TLI_FNAME(parfile, all_suffix=all_suffix)
;  IF all_suffix NE '.slc.par' AND all_suffix NE '.rslc.par' THEN BEGIN
;    Message, 'TLI_SLC_RANGE. ERROR! par file is illegal:'+parfile
;  ENDIF
  
  workpath=FILE_DIRNAME(parfile)+PATH_SEP()
  
  ; Call SLC_corners to calculate SLC corners.
  scr='SLC_corners '+parfile+' >tli_slc_range_temp'
  
  CD, current=temp
  CD, workpath
  SPAWN, scr
  CD, temp
  
  ; Read results from SLC_corners
  slc_range=TLI_READTXT(workpath+'tli_slc_range_temp',/txt)
  slc_range=slc_range[*, 2:5]
  
  slc_range=TLI_STRSPLIT(slc_range)
  
  slc_range=DOUBLE(slc_range[[2, 5], *])
  
  ; Determine the connections.
  slc_range=TLI_SLC_RANGE_CONNECTION(slc_range)  
  
  ; Make kml file
  ; First write 4 corner points.
  I_err=Open_KML(outputfile,I_Unit)
  Transparency='ff'
  Style_iconscale=0.8
  Style_iconhref='http://maps.google.com/mapfiles/kml/shapes/shaded_dot.png'
  style_names=['UL', 'DL', 'DR', 'UR']
  
  Style_iconcolor=Transparency+STRING(0,255,0,format='(3z2.2)')
  FOR i=0, 3 DO BEGIN
    Style_name=style_names[i]
    Style_KML,  I_Unit, Style_Name,  $
      Style_iconcolor=Style_iconcolor, Style_iconscale=Style_iconscale,$
      Style_iconhref=Style_iconref,Style_labelcolor=Style_labelcolor
  ENDFOR
  
  Begin_Folder_KML, I_Unit
  
  For i=0, 3 DO BEGIN
    Point_KML, I_Unit, [slc_range[*, i], 0], Style_name=style_names[i],$
      descri='[lon., lat.] = ['+STRCOMPRESS(slc_range[1, i],/REMOVE_ALL)+', '+STRCOMPRESS(slc_range[0,i],/REMOVE_ALL)+']'+ STRING(13b)+STRING(13b)
  ENDFOR
  
  End_Folder_KML, I_Unit
  
  ; Second write the ractangle.
  
  polygon=[slc_range, FLTARR(1,4)]
  polygon=[[polygon], [polygon[*, 0]]]
  description='SLC par file:'+parfile+STRING(13b)+STRING(13b)+$
              'SLC corners:'+STRING(13b)+STRING(13b)+$
              TLI_ARRAY2STRING(slc_range)+STRING(13b)+STRING(13b)+$
              annotation
              
  Polygon_kml, I_Unit , polygon, name='Range of SLC: '+FILE_BASENAME(parfile), color=Transparency+STRING(0,255,255, format='(3z2.2)'),description=description
  
  ; Close the KML file.  
  Close_KML,  I_Unit
  ;----------------------------
  
  FILE_DELETE, workpath+'tli_slc_range_temp'
  
;  void=DIALOG_MESSAGE( 'Outputfile:'+STRING(10b)+outputfile+STRING(10b)+STRING(10b)+$
;                  'Main Pro Finished at:'+ STRCOMPRESS(STRJOIN(TLI_TIME())), /INFORMATION,/CENTER)
  Print, 'Outputfile:'+STRING(10b)+outputfile
END