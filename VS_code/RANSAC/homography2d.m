function H = homography2d(varargin)
% homography2d--计算2D单应性
%          H = homography2d(x1, x2)
%          H = homography2d(x)
% input:
%         x1: [3,N]齐次点集合
%         x2: 同x1
%          x: x = [x1;x2]
% output:
%          H: 使x2 = H*x1的3x3单应性
    
    % 将输入分为x1和x2
    [x1, x2] = checkargs(varargin(:));
    % 归一化每一组点，使原点在质心和从原点的平均距离是√(2)。
    [x1, T1] = normalise2dpts(x1);
    [x2, T2] = normalise2dpts(x2);
    
    % 如果1在无穷远处，不能对这些点进行归一化，因此下面不假设尺度参数w = 1。
    Npts = length(x1);
    A = zeros(3*Npts,9);
    
    O = [0 0 0];
    for n = 1:Npts
        X = x1(:,n)';
        x = x2(1,n); 
        y = x2(2,n);
        w = x2(3,n);
        A(3*n-2,:) = [  O  -w*X  y*X];
        A(3*n-1,:) = [ w*X   O  -x*X];
        A(3*n  ,:) = [-y*X  x*X   O ];
    end
    % 以降序顺序返回矩阵 A 的奇异值
    [U,D,V] = svd(A,0); 
    % 提取单应性
    H = reshape(V(:,9),3,3)';
    % Denormalise
    H = T2\H*T1;
end

function [x1, x2] = checkargs(arg)
% checkargs--函数检查参数值并设置默认值

% 将输入分为x1和x2
if length(arg) == 2
    x1 = arg{1};
    x2 = arg{2};
    % 判断是否同维，且满足条件
    if ~all(size(x1)==size(x2))
        error('x1 and x2 must have the same size');
    elseif size(x1,1) ~= 3
        error('x1 and x2 must be 3xN');
    end
elseif length(arg) == 1
    % 将输入分为x1和x2
    if size(arg{1},1) ~= 6
        error('Single argument x must be 6xN');
    else
        x1 = arg{1}(1:3,:);
        x2 = arg{1}(4:6,:);
    end
else
    error('Wrong number of arguments supplied');
end
end
    