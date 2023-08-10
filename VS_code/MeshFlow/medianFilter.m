function M_median= medianFilter(M,th)
% medianFilter:对矩阵进行中值滤波
% input:
%   M:要进行中值滤波的矩阵
%   th:中值滤波的阈值
% output:
%   M_median:中值滤波后的矩阵

% 矩阵的大小
[width,len]=size(M);

% 阈值的一半
th_1=floor(th/2);
% 保存滤波后的矩阵元素
M_median=zeros(size(M));
% 进行中值滤波
for i=1:width
    for j=1:len
        % 矩阵的行的起止点
        head_i=max(1,i-th_1);
        tail_i=min(width,i+th_1);
        % 矩阵的列的起止点
        head_j=max(1,j-th_1);
        tail_j=min(len,j+th_1);

        % 局部矩阵
        M_local=M(head_i:tail_i,head_j:tail_j);
        % 局部矩阵的均值
        midian_value=median(reshape(M_local,[1,length(M_local(:))]));

        M_median(i,j)=midian_value;
    end
end

end