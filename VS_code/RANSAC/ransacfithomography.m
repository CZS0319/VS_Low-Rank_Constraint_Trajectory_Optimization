function [H, inliers] = ransacfithomography(x1, x2, t)
% ransacfithomography--ʹ��RANSAC���2D��Ӧ��
% input:
%        x1: (ά��)[2,N]��[3,N]��ε㼯�ϡ����������[2,N]���������γ߶�����Ϊ1
%        x2: ͬx1
%         t: ���ݵ���ģ��֮��ľ�����ֵ����������һ�����Ƿ�Ϊ���ߡ�
%            ע�⣬�����걻��һ��Ϊ���ǵ�ԭ���ƽ�������ǡ�(2)��
%            t��ֵӦ������ڴ����ã�������0.001 - 0.01�ķ�Χ��
% output:
%         H: ʹx2 = H*x1��3x3��Ӧ�ԡ�
%   inliers: һ����x1, x2Ԫ�ص�������ɵ����飬���������ģ�͵�����Ԫ�ء�

    % �ж�x1��x2ͬά
    if ~all(size(x1)==size(x2))
        error('Data sets x1 and x2 must have the same dimension');
    end
    % ��x1��ά������ά�����������
    [rows,npts] = size(x1);
    if rows~=2 & rows~=3
        error('x1 and x2 must have 2 or 3 rows');
    end
    if npts < 4
        error('Must have at least 4 points to fit homography');
    end
    % ��γ߶�����Ϊ1��Pad����
    if rows == 2     
        x1 = [x1; ones(1,npts)];
        x2 = [x2; ones(1,npts)];        
    end
        
    % ��һ��ÿһ��㣬ʹԭ�������ĺʹ�ԭ���ƽ�������ǡ�(2)
    [x1, T1] = normalise2dpts(x1);
    [x2, T2] = normalise2dpts(x2);
    
    % ƥ�䵥Ӧʽ��������С�������㡣
    s = 4;  
    
    fittingfn = @homography2d;
    distfn    = @homogdist2d;
    degenfn   = @isdegenerate;
    % x1��x2���Ϊһ�����飬Ϊransac����һ��6xN����
    [H, inliers] = ransac([x1; x2], fittingfn, distfn, degenfn, s, t);
    
    % �����������ݵ���������С�������
    H = homography2d(x1(:,inliers), x2(:,inliers));
    % Denormalise
    H = T2\H*T1;  
end

%----------------------------------------------------------------------
% ����RANSAC�����һ��ƥ�����������Ӧ�ԵĶԳƴ������ĺ�����
function [inliers, H] = homogdist2d(H, x, t)
    %��x����ȡx1��x2
    x1 = x(1:3,:);   
    x2 = x(4:6,:);    
    
    % �������������ת�Ƶĵ�   
    Hx1    = H*x1;
    invHx2 = H\x2;
    
    % ��һ����ʹ�����������γ߶Ȳ���Ϊ1��
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

    % ��x����ȡx1��x2
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
    
