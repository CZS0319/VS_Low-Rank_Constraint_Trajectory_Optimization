function [images_array,files_array,filesname_array] = readDirImages( image_dir, fmt )
% readDirImages:读取图像数据集中的所有fmt格式的图像
% input:
%   image_dir:保存图像数据集的路径
%   fmt:图像的格式
% output:
%   images_array:读取的图像集数据数组(单元数组)
%   files_array:读取的图像集路径数组(单元数组)
%   filesname_array:读取的图像集文件名数组(单元数组)

%% 读取整个文件下的图像的所有信息（image_files）
% 判断变量是否存在
if ~exist('fmt','var')
    fmt='png';
end
% 图像的格式
fmt=['*.',fmt];
file_names = fullfile(image_dir, fmt);
% 读取这个文件夹下file_names图片的所有信息
image_files = dir(file_names);
% 判断image_files是否为空
if isempty(image_files)
    images_array={};
    disp(['No image files found in dir: ', image_dir]);
    return;
end

%% 读取文件夹下的所有图像(images_array;file_array)
% 图像数据集中图像的数量
n = length(image_files);
% 初始化保存图像的元胞变量数组（images_array:图像集数组;
%     file_array:图像路径数组;filesname_array:文件名数组）
images_array = cell(n, 1); 
files_array=cell(n,1);
filesname_array=cell(n,1);
% 遍历整个文件夹读取图像
for k = 1:n
    base_name = image_files(k).name;
    % base_name=num2str(k)+".png";
    % 每幅图像的地址
    full_name = fullfile(image_dir, base_name);
    if ~endsWith( base_name,'fits')
        % 非.fits格式的图像
        im = imread(full_name);
    else
        % .fits格式的图像
        im=fitsread(full_name);
    end
    % 图像集数组
    images_array{k} = im;
    % 图像集路径数组
    files_array{k}=full_name;
    % 读取的图像集文件名数组
    filesname_array{k}=base_name;
end

end