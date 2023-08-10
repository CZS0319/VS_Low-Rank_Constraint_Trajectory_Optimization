function nx = hnormalise(x)
% hnormalise--将齐次坐标的数组归一化为1
% input:
%        x: 一个[N,npts]的齐次坐标数组。
% output: 
%       nx: 一个[N,npts]的齐次坐标数组重新缩放，使缩放值nx(N，:)都是1。

    % x的维数
    [rows,npts] = size(x);
    nx = x;

    % 找到非无穷点的序号
    finiteind = find(abs(x(rows,:)) > eps);

    % 归一化非无无穷大的点
    for r = 1:rows-1
        nx(r,finiteind) = x(r,finiteind)./x(rows,finiteind);
    end
    nx(rows,finiteind) = 1;
    
