function H = homography2d(varargin)
% homography2d--����2D��Ӧ��
%          H = homography2d(x1, x2)
%          H = homography2d(x)
% input:
%         x1: [3,N]��ε㼯��
%         x2: ͬx1
%          x: x = [x1;x2]
% output:
%          H: ʹx2 = H*x1��3x3��Ӧ��
    
    % �������Ϊx1��x2
    [x1, x2] = checkargs(varargin(:));
    % ��һ��ÿһ��㣬ʹԭ�������ĺʹ�ԭ���ƽ�������ǡ�(2)��
    [x1, T1] = normalise2dpts(x1);
    [x2, T2] = normalise2dpts(x2);
    
    % ���1������Զ�������ܶ���Щ����й�һ����������治����߶Ȳ���w = 1��
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
    % �Խ���˳�򷵻ؾ��� A ������ֵ
    [U,D,V] = svd(A,0); 
    % ��ȡ��Ӧ��
    H = reshape(V(:,9),3,3)';
    % Denormalise
    H = T2\H*T1;
end

function [x1, x2] = checkargs(arg)
% checkargs--����������ֵ������Ĭ��ֵ

% �������Ϊx1��x2
if length(arg) == 2
    x1 = arg{1};
    x2 = arg{2};
    % �ж��Ƿ�ͬά������������
    if ~all(size(x1)==size(x2))
        error('x1 and x2 must have the same size');
    elseif size(x1,1) ~= 3
        error('x1 and x2 must be 3xN');
    end
elseif length(arg) == 1
    % �������Ϊx1��x2
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
    