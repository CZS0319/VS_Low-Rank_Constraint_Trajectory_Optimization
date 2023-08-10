function [ features, descriptors ] = extractSIFT( images )
% extrectSIFT():提取图像序列中每个图像的SIFT特征
% input:
%   images:图像序列
% output:
%   features:图像序列中每幅图像的特征点的x(列),y(行)坐标
%   descriptors:图像中特征点的特征描述字

% 图像的数目
n = size(images, 1);

% 建立一个n*1的特征和描述子的cell数组
features = cell(n, 1);
descriptors = cell(n, 1);

fprintf('为每一帧提取SIFT特征点:\n');
for k = 1:n
    % 输出正在处理的图像序号
    fprintf('%5d',k);
    if mod(k,20)==0
        fprintf('\n');
    end
    % 第K张图像的矩阵信息
    curr_image = images{k};  
    % 判断图像是否为彩色图像
    [~, ~, chan] = size(curr_image); 
    % 每个图像的SIFT的特征和描述子
    if(chan == 3)
        [features{k}, descriptors{k}] = vl_sift(single(rgb2gray(curr_image)),'PeakThresh', 1);
    else
        % [features{k}, descriptors{k}] = vl_sift(single(curr_image),'Levels',3,'PeakThresh', 3);
        [features{k}, descriptors{k}] = vl_sift(single(curr_image),'PeakThresh', 1);
    end
end
fprintf('\n');
end