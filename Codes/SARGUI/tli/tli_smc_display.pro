;
; Display the given data
;
; Parameters:
;
; Keywords:
;
; Written by:
;   T.LI @ Sasmac, 20121231
;
PRO TLI_SMC_DISPLAY, data

  COMMON TLI_SMC_GUI, types, file, wid, config
  data_i=data
  ; Update file
  file.data=PTR_NEW(data)
  
  sz  = size(data,/DIMENSIONS)
  
  Case N_ELEMENTS(sz) OF
    2: BEGIN      
      sz  = size(data,/DIMENSIONS)
      xdim = sz[0]
      ydim = sz[1]
      
      widget_control,wid.draw, DRAW_YSIZE = ydim >wid.base_ysize, DRAW_XSIZE=xdim>wid.base_xsize; update scroll bar
      
      data=ROTATE(data, 7)
      ERASE
      TVSCL,data
    END
    3: BEGIN
      sz=sz[1:2]
      
      xdim = sz[0]
      ydim = sz[1]
      
      widget_control,wid.draw, DRAW_YSIZE = ydim , DRAW_XSIZE=xdim; update scroll bar
      
      FOR i=0, 2 DO BEGIN
        data[i, *,*]=ROTATE(REFORM(data[i,*,*]), 7)
      ENDFOR
      ERASE
      TVSCL, data,/true
    END
    
    ELSE: TLI_SMC_DUMMY, inputstr=['Error! TLI_SMC_DISPLAY: Data Dimensions error.', STRCOMPRESS(N_ELEMENTS(sz))]
  ENDCASE
  
  END