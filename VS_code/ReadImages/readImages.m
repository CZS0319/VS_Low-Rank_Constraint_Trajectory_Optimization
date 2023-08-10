function [im_array,files_array,filesname_array] = readImages(impath,fmt)
% readimages:读取impath路径下的文件夹中所有fmt格式的图像
% input:
%   impath:保存图像集的文件夹路径
%   fmt:要读取的图像的格式
% output:
%   im_array:读取的图像集数据数组(单元数组)
%   file_array:读取的图像集路径数组(单元数组)
%   filesname_array:读取的图像集文件名数组(单元数组)

% 选择要读取数据集的路径
frame_dir = uigetdir(impath,'选择输入图像序列路径');
if frame_dir==0
    disp('路径选择出错');
    return;
end

% 读取文件夹下的图像集
% im_array：图像集数组；files_array:图像集路径数组；filesname_array：图像集文件名数组
[im_array,files_array,filesname_array] = readDirImages(frame_dir,fmt);
% 判断图像数据集是否为空
if isempty(im_array)
    disp('invalid path for input image sequence selected!');    
    return;
end

end

