; Chapter04TestRunTime1.pro
PRO Chapter04TestRunTime1
　　MyVariable = DIST(1000, 1000)
　　Sum = 0.0
　　StartTime = SYSTIME(/SECONDS)
　　FOR i = 0, 999 DO BEGIN
　　　　FOR j = 0, 999 DO BEGIN
　　　　　　Sum = Sum + MyVariable[i,j]
　　　　ENDFOR
　　ENDFOR
　　EndTime = SYSTIME(/SECONDS)
　　PRINT, '方怏議才��', Sum
　　PRINT, '聞喘扮寂��' , EndTime - StartTime
END