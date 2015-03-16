pro fdecomp, filename, disk, dir, name, qual, version, OSfamily = osfamily
  ;+
  ; NAME:
  ;     FDECOMP
  ; PURPOSE:
  ;     Routine to decompose file name(s) for any operating system.
  ;
  ; CALLING SEQUENCE:
  ;     FDECOMP, filename, disk, dir, name, qual, [OSFamily = ]
  ;
  ; INPUT:
  ;     filename - string file name(s), scalar or vector
  ;
  ; OUTPUTS:
  ;     All the output parameters will have the same number of elements as
  ;       input filename
  ;
  ;       disk - disk name, always '' on a Unix machine, scalar or vector string
  ;       dir - directory name, scalar or vector string
  ;       name - file name, scalar or vector string
  ;       qual - qualifier, set equal to the characters beyond the last "."
  ;
  ; OPTIONAL INPUT KEYWORD:
  ;     OSFamily -  scalar string specifying the operating system, must be either
  ;             'Windows' or 'unix'.    If not supplied,
  ;             then !VERSION.OS_FAMILY is used to determine the OS.
  ; EXAMPLES:
  ;     Consider the following file names
  ;
  ;     unix:    file = '/itt/idl71/avg.pro'
  ;     Windows: file =  'd:\itt\idl71\avg.pro'
  ;
  ;     then IDL> FDECOMP,  file, disk, dir, name, qual
  ;       will return the following
  ;
  ;                 Disk             Dir          Name        Qual
  ;       Unix:      ''            '/itt/idl71/'  'avg'       'pro'
  ;       Windows:    'd:'         \itt\idl71\    'avg'       'pro'
  ;
  ; NOTES:
  ;     (1) The period is removed between the name and qualifier
  ;     (2) Unlike the intrinsic FILE_BASENAME() and FILE_DIRNAME() functions,
  ;         one can use FDECOMP to decompose a Windows file name on a Unix machine
  ;         or a Unix filename on a Windows machine.
  ;
  ; ROUTINES CALLED:
  ;     None.
  ; HISTORY
  ;     version 1  D. Lindler  Oct 1986
  ;     Include VMS DECNET machine name in disk    W. Landsman  HSTX  Feb. 94
  ;     Converted to Mac IDL, I. Freedman HSTX March 1994
  ;     Major rewrite to accept vector filenames V5.3   W. Landsman June 2000
  ;     Fix cases where disk name not always present  W. Landsman  Sep. 2000
  ;     Make sure version defined for Windows  W. Landsman April 2004
  ;     Include final delimiter in directory under Windows as advertised
  ;                W. Landsman   May 2006
  ;     Remove VMS support, W. Landsman    September 2006
  ;     Remove MacOS branch (same as Unix) W. Landsman  August 2009
  ;-
  ;--------------------------------------------------------
  ;
  On_error,2                            ;Return to caller
  compile_opt idl2
  
  if N_params() LT 2 then begin
    print, 'Syntax - FDECOMP, filename, disk, [dir, name, qual ] '
    return
  endif
  
  
  if ~keyword_set(osfamily) then osfamily = !Version.OS_Family
  st = filename
  disk = st
  replicate_inplace,disk,''
  dir = disk
  qual = disk
  
  
  if OSFAMILY EQ "Windows" then begin
  
    lpos = strpos( st, ':')                 ; DOS diskdrive (i.e. c:)
    good = where(lpos GT 0, Ngood)
    if Ngood GT 0 then begin
      stg = st[good]
      lpos = reform( lpos[good], 1, Ngood)
      disk[good] = strmid( stg, 0, lpos+1)
      st[good] = strmid(stg,lpos+1 )
    endif
    
    ;  Search the path name (i.e. \dos\idl\) and locate last backslash
    
    lpos = strpos(st,'\',/reverse_search)
    good = where(lpos Gt 0, Ngood)
    
    
  endif ELSE begin                 ;Unix
  
  
    ; Unix directory name ends at last slash
  
    lpos = strpos(st,'/',/reverse_search)
    good = where(lpos GE 0, Ngood)
    
  endelse
  
  if Ngood GT 0 then begin      ;Extract directory name if present
    stg = st[good]
    lpos = reform( lpos[good],1, Ngood )
    
    dir[good] = strmid(stg,0, lpos+1)
    st[good] = strmid(stg,lpos+1 )
  endif
  
  ; get  name and qualifier (extension)...qual is optional
  
  lpos = strpos(st,'.',/reverse_search)
  good = where(lpos GE 0, Ngood)
  name = st
  
  if Ngood GT 0 then begin
    stg = st[good]
    lpos = reform(lpos[good], 1, Ngood)
    
    name[good] = strmid(stg,0,lpos )
    qual[good] = strmid(stg,lpos+1 )
  endif
  
  
  return
end


pro FindPro, Proc_Name, NoPrint=NoPrint, DirList=DirList, ProList=ProList
  ;+
  ; NAME:
  ;     FINDPRO
  ; PURPOSE:
  ;     Find all locations of a procedure in the IDL !PATH
  ; EXPLANATION:
  ;     FINDPRO searces for the procedure name (as a .pro or a .sav file) in all
  ;     IDL libraries or directories given in the !PATH system variable.    This
  ;     differs from the intrinsic FILE_WHICH() function which only finds the
  ;     first occurence of the procedure name.
  ;
  ; CALLING SEQUENCE:
  ;    FINDPRO, [ Proc_Name, /NoPrint, DirList = , ProList = ]
  ;
  ; OPTIONAL INPUT:
  ;     Proc_Name - Character string giving the name of the IDL procedure or
  ;             function. Do not include the ".pro" extension. If Proc_Name is
  ;             omitted, the program will prompt for PROC_NAME.  "*" wildcards
  ;             are permitted.
  ;
  ; OPTIONAL KEYWORD INPUT:
  ;     /NoPrint - if set, then the file's path is not printed on the screen and
  ;             absolutely no error messages are printed on the screen.  If not
  ;             set, then - since the MESSAGE routine is used - error messages
  ;             will be printed but the printing of informational messages
  ;             depends on the value of the !Quiet variable.
  ;
  ; OPTIONAL KEYWORD OUTPUTS:
  ;     DirList - The directories in which the file is located are returned in
  ;             the keyword as a string array.
  ;             If the procedure is an intrinsic IDL procedure, then the
  ;             value of DirList = ['INTRINSIC'].
  ;             If the procedure is not found, the value of DirList = [''].
  ;     ProList - The list (full pathnames) of procedures found.  Useful if you
  ;             are looking for the name of a procedure using wildcards.
  ;
  ;     The order of the names in DirList and ProList is identical to the order
  ;     in which the procedure name appears in the !PATH
  ; PROCEDURE:
  ;     The system variable !PATH is parsed using EXPAND_PATH into individual
  ;     directories.  FILE_SEARCH() is used to search the directories for
  ;     the procedure name.  If not found in !PATH, then the name is compared
  ;     with the list of intrinsic IDL procedures given by the ROUTINE_INFO()
  ;     function.
  ;
  ; EXAMPLE:
  ;     (1) Find the procedure CURVEFIT.  Assume for this example that the user
  ;     also has a copy of the curvefit.pro procedure in her home directory
  ;     on a Unix machine.
  ;
  ;       IDL> findpro, 'curvefit', DIRLIST=DirList
  ;       Procedure curvefit.pro found in directory  /home/user/.
  ;       Procedure curvefit.pro found in directory  /software/IDL/idl82/lib/
  ;       IDL> help, DirList
  ;       DIRLIST         STRING    = Array(2)
  ;       IDL> help, DirList[0], DirList[1]
  ;       <Expression>    STRING    = '/home/user'
  ;       <Expression>    STRING    = '/software/IDL/idl82/lib/'
  ;
  ;     (2) Find all procedures in one's !path containing the characters "zoom"
  ;
  ;       IDL> findpro,'*zoom*'
  ; RESTRICTIONS:
  ;       User will be unable to find a path for a native IDL function
  ;       or procedure, or for a FORTRAN or C routine added with CALL_EXTERNAL.
  ;       Remember that Unix is case sensitive, and most procedures will be in
  ;       lower case.
  ; PROCEDURES USED:
  ;       FDECOMP   -- Decompose file name
  ;
  ; REVISION HISTORY:
  ;       Based on code extracted from the GETPRO procedure, J. Parker 1994
  ;       Use the intrinsic EXPAND_PATH function    W. Landsman Nov. 1994
  ;       Use ROUTINE_NAMES() to check for intrinsic procs   W. Landsman Jul 95
  ;       Added Macintosh, WINDOWS compatibility    W. Landsman   Sep. 95
  ;       Removed spurious first element in PROLIST  W. Landsman  March 1997
  ;       Don't include duplicate directories  in !PATH  WL   May 1997
  ;       Use ROUTINE_INFO instead of undocumented ROUTINE_NAMES W.L. October 1998
  ;       Also check for save sets   W. Landsman  October 1999
  ;       Force lower case check for VMS  W. Landsman January 2000
  ;       Only return .pro or .sav files in PROLIST   W. Landsman  January 2002
  ;       Force lower case check for .pro and .sav    D. Swain  September 2002
  ;       Use FILE_SEARCH() if V5.5 or later   W. Landsman June 2006
  ;       Assume since V55, remove VMS support W. Landsman Sep. 2006
  ;       Assume since V6.0, use file_basename() W.Landsman Feb 2009
  ;       Specify whether an intrinsic function or procedure W.L.  Jan 2013
  ;
  ;-
  ;/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/

  On_error,2                           ;Return to caller on error
  compile_opt idl2
  
  if (N_params() EQ 0) then begin      ;Prompt for procedure name?
    Proc_Name = ' '
    read,'Enter name of procedure for which you want the path: ',Proc_Name
  endif else $
    if (size(proc_name,/type) NE 7 ) && (N_elements(proc_name) NE 1) then $
    message,'ERROR - First parameter (.pro name) must be a scalar string'
    
  NoPrint = keyword_set(NoPrint)
  
  Name = strtrim( file_basename(proc_name,'.pro'), 2 )
  
  ; Set up separate file and directory separators for current OS
  
  psep = path_sep()
  
  pathdir = expand_path(!PATH,/ARRAY, Count = N_dir)
  cd,current = dir
  
  ; Remove duplicate directories  in !PATH but keep original order
  path_dir = [dir]
  for i = 0,N_dir -1 do begin
    test = where(path_dir EQ pathdir[i], Ndup)
    if Ndup EQ 0 then path_dir = [path_dir,pathdir[i]]
  endfor
  N_dir = N_elements(path_dir)
  
  ; Use FILE_PATH() to search all directories for <name>.pro or <name>.sav files
  
  ProList = file_search(path_dir + psep + name + '.{pro,sav}', COUNT=Nfile)
  if (Nfile ge 1) then begin                     ;Found by FILE_SEARCH?
    fdecomp, ProList, ddisk,ddir,fname,ext
    dirlist = ddisk + ddir
    found = 1b
    for j = 0,nfile-1 do begin
      case strlowcase(ext[j]) of
        'pro':  message,/Con,  NoPrint = NoPrint,/NoPrefix, /Noname, $
          'Procedure ' + fname[j] + ' found in directory  ' + dirlist[j]
        'sav':  message,/Con,NoPrint = NoPrint,/NoPrefix, /Noname, $
          'Save set ' + fname[j] + '.sav found in directory  ' + dirlist[j]
      endcase
    endfor
  endif  else begin
  
  
    ; At this point !PATH has been searched.  If the procedure was not found
    ; check if it is an intrinsic IDL procedure or function
  
    funcnames = routine_info(/system,/func)
    fcount = ~array_equal( funcnames NE strupcase(name), 1b )
    ;  test = where ( funcnames EQ strupcase(name), fcount)    Slower method
    
    funcnames = routine_info(/system)
    pcount = ~array_equal( funcnames NE strupcase(name) , 1b)
    ;
    
    if (fcount EQ 0) && (pcount EQ 0) then begin
      prolist = strarr(1)
      dirlist = strarr(1)
      if ~NoPrint then begin
        message, 'Procedure '+Name+' not found in a !PATH directory.', /CONT
        message, 'Check your spelling or search individual directories.', /INF
      endif
    endif else begin
      DirList = ['INTRINSIC']
      ProList = ['INTRINSIC']
      if ~NoPrint then begin
        if pcount NE 0 then $
          message, 'Procedure ' + Name + ' is an intrinsic IDL procedure.', $
          /CONT else $
          message, 'Procedure ' + Name + ' is an intrinsic IDL function.',/CONT
        message, 'No path information available.', /INF
      endif
    endelse
    
  endelse
  
  return
end

FUNCTION TLI_PROINFO, propath
; Get the information for the given proname.
; Parameter: 
;   propath: Full path of the pro/function
; Return: 
;   Information of the pro/function.
; Written by: 
;   T.LI @ Home, 20140207
;
  IF NOT FILE_TEST(propath) THEN Message, 'Error! File not found:'+STRING(13B)+propath
  
  nlines=FILE_LINES(propath)
  prostr=STRARR(1,nlines)
  OPENR, lun, propath,/GET_LUN
  READF, lun, prostr
  FREE_LUN, lun
  
  ; Locate the annotation lines.
  


END

;
; Find the procedure/function in !PATH
; Parameters:
;   proname     : Name of the pro/function.
; Usage:
;   TLI_FINDPRO, proname
; Return:
;   Dialog message.
; Written by:
;   T.LI @ Home, 20140207. 
;
PRO TLI_FINDPRO, proname
  
  COMPILE_OPT idl2
  
  pathdir = EXPAND_pATH(!PATH,/ARRAY, Count = N_dir)
  FindPro, proname,/NoPrint, DirList=DirList, ProList=ProList
  
  nfiles=N_ELEMENTS(prolist)
  IF prolist[0] EQ '' THEN nfiles=0
  
  Case nfiles OF
    
    0: BEGIN
      info='File is not found in the given path:'+STRJOIN(13b)    
    END
    
    1: BEGIN
      info='File is in the following path:'+STRING(13b)+prolist    
    END
    
    ELSE: BEGIN
      info='Files are in the following path:'+STRJOIN(prolist, STRING(13b))
    END
    
  ENDCASE
  
  void=DIALOG_MESSAGE(info,/info,/center)
    
END