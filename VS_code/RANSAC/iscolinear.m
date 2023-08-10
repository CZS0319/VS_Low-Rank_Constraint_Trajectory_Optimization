function r = iscolinear(p1, p2, p3, flag)
% iscolinear--�ж������Ƿ���
% input:
%       p1,p2,p3: �������
%           flag: ��ѡ��������Ϊ'h'��'homog'����ʾp1, p2, p3�Ǿ������������ͬ������
% output:
%              r: ����㹲��Ϊ1������Ϊ0

    if nargin == 3
        flag = 'inhomog';
    end
    % �ж�ά���Ƿ���ͬ
    if ~all(size(p1)==size(p2)) | ~all(size(p1)==size(p3)) | ...
        ~(length(p1)==2 | length(p1)==3)                              
        error('points must have the same dimension of 2 or 3');
    end
    % ��������Ƕ�ά�ģ���ٶ������Ƕ�ά��������ꡣʹ���Ǿ��ȣ��߶�Ϊ1��
    if length(p1) == 2    
        p1(3) = 1; 
        p2(3) = 1; 
        p3(3) = 1;
    end

    if flag(1) == 'h'
	% p1xp2����һ����ԭ��p1��p2�����ƽ��ķ�������
    % ���������p3�ĵ��Ϊ�㣬��ôp3Ҳ��ƽ���ϣ���˹��ߡ�
	r =  abs(dot(cross(p1, p2),p3)) < eps;
    else
	% �����������꣬�������ͬ�߶ȵ�������ꡣ
	r =  norm(cross(p2-p1, p3-p1)) < eps;
    end
end
    
