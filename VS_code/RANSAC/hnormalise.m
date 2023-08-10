function nx = hnormalise(x)
% hnormalise--���������������һ��Ϊ1
% input:
%        x: һ��[N,npts]������������顣
% output: 
%       nx: һ��[N,npts]��������������������ţ�ʹ����ֵnx(N��:)����1��

    % x��ά��
    [rows,npts] = size(x);
    nx = x;

    % �ҵ������������
    finiteind = find(abs(x(rows,:)) > eps);

    % ��һ�����������ĵ�
    for r = 1:rows-1
        nx(r,finiteind) = x(r,finiteind)./x(rows,finiteind);
    end
    nx(rows,finiteind) = 1;
    
