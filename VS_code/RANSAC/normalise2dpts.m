function [newpts, T] = normalise2dpts(pts)
% normalise2dpts--��׼����ά��ε�.����ƽ�Ʋ��淶��һ���ά��ε㣬
%                 ʹ���ǵ�������ԭ�㣬���ǵ�ԭ���ƽ�������ǡ�(2).
% input:
%             pts: ��ά��������3*N����
% output:
%          newpts: �任��Ķ�ά��������3xN���顣���Ų�����һ��Ϊ1.
%               T: 3x3�任����newpts = T*pts
    
    %����ά��
    if size(pts,1) ~= 3
        error('pts must be 3xN');
    end
    
    % �����������λ��
    finiteind = find(abs(pts(3,:)) > eps);
    
    % �ж�ȫΪ�������
    if length(finiteind) ~= size(pts,2)
        warning('Some points are at infinity');
    end
    
    % �������޵㣬��֤�������ĳ߶�Ϊ1
    pts(1,finiteind) = pts(1,finiteind)./pts(3,finiteind);
    pts(2,finiteind) = pts(2,finiteind)./pts(3,finiteind);
    pts(3,finiteind) = 1;
    
    % �����е�ÿһ�У�x��y����ƽ��ֵ(�ʵ�)
    c = mean(pts(1:2,finiteind)')';  
    % ��ԭ���Ƶ����ģ����ʵ�Ϊ���ģ�����ȥ����
    newp(1,finiteind) = pts(1,finiteind)-c(1); 
    newp(2,finiteind) = pts(2,finiteind)-c(2);
    % ��������ĵľ���
    dist = sqrt(newp(1,finiteind).^2 + newp(2,finiteind).^2);
    % ��ƽ��ֵ
    meandist = mean(dist(:)); 
    
    scale = sqrt(2)/meandist;
    % �仯����
    T = [scale   0   -scale*c(1)
         0     scale -scale*c(2)
         0       0      1      ];
    % �£�x,y��������
    newpts = T*pts;
    
    
    