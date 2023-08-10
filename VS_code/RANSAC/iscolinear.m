function r = iscolinear(p1, p2, p3, flag)
% iscolinear--判断三点是否共线
% input:
%       p1,p2,p3: 点的坐标
%           flag: 可选参数设置为'h'或'homog'，表示p1, p2, p3是具有任意比例的同质坐标
% output:
%              r: 如果点共线为1，否则为0

    if nargin == 3
        flag = 'inhomog';
    end
    % 判断维数是否相同
    if ~all(size(p1)==size(p2)) | ~all(size(p1)==size(p3)) | ...
        ~(length(p1)==2 | length(p1)==3)                              
        error('points must have the same dimension of 2 or 3');
    end
    % 如果数据是二维的，则假定它们是二维非齐次坐标。使它们均匀，尺度为1。
    if length(p1) == 2    
        p1(3) = 1; 
        p2(3) = 1; 
        p3(3) = 1;
    end

    if flag(1) == 'h'
	% p1xp2生成一个由原点p1和p2定义的平面的法向量。
    % 如果法线与p3的点积为零，那么p3也在平面上，因此共线。
	r =  abs(dot(cross(p1, p2),p3)) < eps;
    else
	% 假设非齐次坐标，或具有相同尺度的齐次坐标。
	r =  norm(cross(p2-p1, p3-p1)) < eps;
    end
end
    
