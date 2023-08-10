function [newpts, T] = normalise2dpts(pts)
% normalise2dpts--标准化二维齐次点.函数平移并规范化一组二维齐次点，
%                 使它们的质心在原点，它们到原点的平均距离是√(2).
% input:
%             pts: 二维齐次坐标的3*N数组
% output:
%          newpts: 变换后的二维齐次坐标的3xN数组。缩放参数归一化为1.
%               T: 3x3变换矩阵，newpts = T*pts
    
    %数组维数
    if size(pts,1) ~= 3
        error('pts must be 3xN');
    end
    
    % 求出非无穷点的位置
    finiteind = find(abs(pts(3,:)) > eps);
    
    % 判断全为非无穷点
    if length(finiteind) ~= size(pts,2)
        warning('Some points are at infinity');
    end
    
    % 对于有限点，保证齐次坐标的尺度为1
    pts(1,finiteind) = pts(1,finiteind)./pts(3,finiteind);
    pts(2,finiteind) = pts(2,finiteind)./pts(3,finiteind);
    pts(3,finiteind) = 1;
    
    % 求所有点每一行（x，y）的平均值(质点)
    c = mean(pts(1:2,finiteind)')';  
    % 将原点移到质心，以质点为中心，即减去质心
    newp(1,finiteind) = pts(1,finiteind)-c(1); 
    newp(2,finiteind) = pts(2,finiteind)-c(2);
    % 求距离质心的距离
    dist = sqrt(newp(1,finiteind).^2 + newp(2,finiteind).^2);
    % 求平均值
    meandist = mean(dist(:)); 
    
    scale = sqrt(2)/meandist;
    % 变化矩阵
    T = [scale   0   -scale*c(1)
         0     scale -scale*c(2)
         0       0      1      ];
    % 新（x,y）的坐标
    newpts = T*pts;
    
    
    