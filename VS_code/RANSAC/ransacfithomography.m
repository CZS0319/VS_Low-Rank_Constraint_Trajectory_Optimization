function [H, inliers] = ransacfithomography(x1, x2, t)
% ransacfithomography--使用RANSAC拟合2D单应性
% input:
%        x1: (维数)[2,N]或[3,N]齐次点集合。如果数据是[2,N]，则假设齐次尺度因子为1
%        x2: 同x1
%         t: 数据点与模型之间的距离阈值，用来决定一个点是否为内线。
%            注意，点坐标被归一化为它们到原点的平均距离是√(2)。
%            t的值应该相对于此设置，比如在0.001 - 0.01的范围内
% output:
%         H: 使x2 = H*x1的3x3单应性。
%   inliers: 一个由x1, x2元素的索引组成的数组，它们是最佳模型的内联元素。

    % 判断x1和x2同维
    if ~all(size(x1)==size(x2))
        error('Data sets x1 and x2 must have the same dimension');
    end
    % 求x1的维数及其维数满足的条件
    [rows,npts] = size(x1);
    if rows~=2 & rows~=3
        error('x1 and x2 must have 2 or 3 rows');
    end
    if npts < 4
        error('Must have at least 4 points to fit homography');
    end
    % 齐次尺度因子为1的Pad数据
    if rows == 2     
        x1 = [x1; ones(1,npts)];
        x2 = [x2; ones(1,npts)];        
    end
        
    % 归一化每一组点，使原点在质心和从原点的平均距离是√(2)
    [x1, T1] = normalise2dpts(x1);
    [x2, T2] = normalise2dpts(x2);
    
    % 匹配单应式所需点的最小的特征点。
    s = 4;  
    
    fittingfn = @homography2d;
    distfn    = @homogdist2d;
    degenfn   = @isdegenerate;
    % x1和x2结合为一个数组，为ransac创建一个6xN数组
    [H, inliers] = ransac([x1; x2], fittingfn, distfn, degenfn, s, t);
    
    % 对内联的数据点做最后的最小二乘拟合
    H = homography2d(x1(:,inliers), x2(:,inliers));
    % Denormalise
    H = T2\H*T1;  
end

%----------------------------------------------------------------------
% 根据RANSAC所需的一组匹配点来评估单应性的对称传递误差的函数。
function [inliers, H] = homogdist2d(H, x, t)
    %从x中提取x1和x2
    x1 = x(1:3,:);   
    x2 = x(4:6,:);    
    
    % 在两个方向计算转移的点   
    Hx1    = H*x1;
    invHx2 = H\x2;
    
    % 归一化，使所有坐标的齐次尺度参数为1。
    x1     = hnormalise(x1);
    x2     = hnormalise(x2);     
    Hx1    = hnormalise(Hx1);
    invHx2 = hnormalise(invHx2); 
    
    d2 = sum((x1-invHx2).^2)  + sum((x2-Hx1).^2);
    inliers = find(abs(d2) < t);  
end
    
    
%----------------------------------------------------------------------
% Function to determine if a set of 4 pairs of matched  points give rise
% to a degeneracy in the calculation of a homography as needed by RANSAC.
% This involves testing whether any 3 of the 4 points in each set is
% colinear. 
     
function r = isdegenerate(x)

    % 从x中提取x1和x2
    x1 = x(1:3,:);   
    x2 = x(4:6,:);    
    
    r = ...
    iscolinear(x1(:,1),x1(:,2),x1(:,3)) | ...
    iscolinear(x1(:,1),x1(:,2),x1(:,4)) | ...
    iscolinear(x1(:,1),x1(:,3),x1(:,4)) | ...
    iscolinear(x1(:,2),x1(:,3),x1(:,4)) | ...
    iscolinear(x2(:,1),x2(:,2),x2(:,3)) | ...
    iscolinear(x2(:,1),x2(:,2),x2(:,4)) | ...
    iscolinear(x2(:,1),x2(:,3),x2(:,4)) | ...
    iscolinear(x2(:,2),x2(:,3),x2(:,4));
end
    
