%  ---------------函数目的-----------------
% 1. 利用SIFT提取特征点并利用改进的RFM_SCAN排除异常值
% 2. 根据改进的优化正则化方法进行路径轨迹平滑
%  ----------------------------------------

% 设置编程环境
run('D:\MatlabR2018a\toolbox\vlfeat-0.9.21\toolbox\vl_setup.m');
clear;

% 添加路径
addpath("ReadImages");
addpath("SIFT");
addpath("RANSAC");
addpath("MeshFlow");
addpath("SmoothPath");
addpath("ImageWarp");


%% 初始化各项参数

% ------ReadImages中的参数设置-------
% 设置默认的输入图像集的文件夹路径
frame_dir = './input/';
% 设置输出的文件夹路径
out_dir = './output/';
% -----------------------------------

% ------MeshFlow中的参数设置-------
num_width=16;  % 将图像宽分为16个网格
num_height=12; % 将图像高分为12个网格
num_mesh=[num_height,num_width];
% ---------------------------------

% ------SmoothPath中的参数设置-----
iter=10;  % 平滑的迭代次数
% ---------------------------------

% ------ImageWarp中的参数设置------
% 进行最后的运动补偿
gap=100;      % 黑框边界
scale=0.85;      % 保留原始图像的尺寸视野
% 保存结果图像
path=out_dir+"/opt_frames/";    
path_syn=out_dir+"/syn_frames/";
% ---------------------------------


%% 读取图像序列
% 要读取图像的格式类型
fmt='png';
% im_array:图像序列；filesname_array:图像序列的文件名(含后缀)
[im_array,~,filesname_array] = readImages(frame_dir,fmt);
% 图像集的帧数
num_frames=length(im_array);
% 图像的高宽
im_size=size(im_array{1});

%% 提取图像序列中相互匹配的SIFT的特征点
% 计算每一张图像的SIFT的特征和描述子
% featureas:num_frames*1的cell
% featureas{i}:存储特征点的坐标位置x,y,尺度s和方向th
% descriptors:num_frames*1的cell
% descriptors{i}:存储每个特征点的特征描述子
[features, descriptors] = extractSIFT(im_array);

% 得到相互匹配的特征点元胞
matched_F = matchFeatures(features, descriptors);


%% 利用改进的DBSCAN聚类算法排除异常值
% 保存相邻帧匹配的特征点坐标
global_F=cell(num_frames-1,1);

% 保存相邻帧的线性变换矩阵(单应性变换)
transforms=cell(num_frames-1,1);

% 保存相邻帧的网格的运动(第一列保存x方向，第二列保存y方向)
% 保存每帧中各个顶点的运动矢量
motion_meshes=cell(num_frames-1,2);
% 保存各个顶点的运动轨迹
x_path_meshes=zeros(num_mesh(1)+1,num_mesh(2)+1,num_frames);
y_path_meshes=zeros(num_mesh(1)+1,num_mesh(2)+1,num_frames);

fprintf('在相邻帧之间排除异常值并构造顶点轮廓:\n');
for i=1:num_frames-1
    % 显示处理的图像
    fprintf('%5d',i);
    if mod(i,20)==0
        fprintf('\n');
    end

    %------------ 使用RANSAC估计运动分离的结果---------------------
    [~,inliers]=ransacfithomography(matched_F{i}(:,1:2)',matched_F{i}(:,3:4)',0.002);
    global_F{i}=matched_F{i}(inliers,:);
    % -----------------------------------------------

    % 通过RANSAC为相邻帧估计一个单应性变换矩阵(注意：dx和dy的位置)
    X_matched=global_F{i}(:,1:2);
    Y_matched=global_F{i}(:,3:4);
    [H,~]=ransacfithomography(X_matched',Y_matched',0.001);
    transforms{i}=H';

    % -------------通过MeshFlow构造顶点轮廓------------
    % 计算各个顶点的运动
    [x_mesh_motion,y_mesh_motion]=motionPropagate(transforms{i},X_matched,...
        Y_matched,num_mesh,im_size);
    % 将其保存在元胞中
    motion_meshes{i,1}=x_mesh_motion;
    motion_meshes{i,2}=y_mesh_motion;

    % 计算各个顶点轮廓
    [x_path_meshes(:,:,i+1),y_path_meshes(:,:,i+1)]=generateVertexProfiles(...
        x_path_meshes(:,:,i),y_path_meshes(:,:,i),x_mesh_motion,y_mesh_motion);
    % -------------------------------------------------
end

%% 构造每个顶点的轨迹序列(n*num_frames; n:每帧中的顶点个数，按列排序)
x_path=reshape(x_path_meshes,[(num_mesh(1)+1)*(num_mesh(2)+1),num_frames]);
y_path=reshape(y_path_meshes,[(num_mesh(1)+1)*(num_mesh(2)+1),num_frames]);

% 保存原始路径
y_original_path=y_path;
x_original_path=x_path;

%% 平滑轨迹（x方向和y方向）
tic;
iter=round((num_frames+10)/100)*2+1;
for i=1:iter
    % 平滑x(水平)方向的各个顶点的运动路径
    disp("水平运动路径:第"+num2str(i)+"次迭代:");
    x_path=smoothLowRank(x_path); 
    % 平滑y(竖直)方向的各个顶点的运动路径
    disp("竖直运动路径:第"+num2str(i)+"次迭代:");
    y_path=smoothLowRank(y_path);
    if mod(i,5)==0
        disp("连续迭代五次");
    end
end
toc;

%% 得到平滑后各个顶点的运动轨迹
x_path_meshes_smoothed=reshape(x_path,[num_mesh(1)+1,num_mesh(2)+1,num_frames]);
y_path_meshes_smoothed=reshape(y_path,[num_mesh(1)+1,num_mesh(2)+1,num_frames]);

%% 渲染图像
% 得到新的网格运动矢量
[new_x_mesh_motion,new_y_mesh_motion] = getFrameWarp(x_path_meshes,y_path_meshes,...
    x_path_meshes_smoothed,y_path_meshes_smoothed);

% 渲染图像
[ori_array,imwarp_array,new_array]=renderStaFrame_1(im_array,new_x_mesh_motion,new_y_mesh_motion,gap,path,path_syn,scale);








