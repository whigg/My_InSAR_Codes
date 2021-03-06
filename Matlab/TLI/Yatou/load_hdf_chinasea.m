% 获取指定区域的hdf数据。
% 用法： result= load_hdf_chinasea(hdf_file, startl, endl, starts, ends)
% 参数： 
%       hdf_file  :  文件路径
%       startl    :  起始行
%       endl      ： 终止行
%       starts    ： 起始列
%       ends      ： 终止列
function result= load_hdf_chinasea(hdf_file, startl, endl, starts, ends)
  file_info= hdfinfo(hdf_file);
  sds_info= file_info.SDS;
  data= hdfread(sds_info);
  result= data(startl:endl, starts:ends);