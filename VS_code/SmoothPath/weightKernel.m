function weight = weightKernel(path,C,V)
% weightKernal():计算局部窗口的各个项的权重
% input:
%   path:局部窗口的运动轨迹
%   C:权重矩阵的窗口长度
%   V:高斯核的长度
% output:
%   weight:局部窗口的权重矩阵


% 局部窗口的长度
len=size(path,2);


% 设置高斯函数的均值和标准差
G_value=[2*V/3,0];

% 构造高斯平滑权重矩阵
G=zeros(len,len);
for i=1:len
    % 为高斯矩阵的每一列进行赋值
    for j=i-V:i+V
        if j>0 && j<=len && abs(j-i)<=min(min(i-1,len-i),V)
            G(j,i)=gaussmf(abs(j-i),G_value);
        end
    end
    G(:,i)=G(:,i)./sum(G(:,i));
end

% 表示原始轨迹一阶导数，即相邻帧的位移差
h=mean(path,1)*G;

% 权重矩阵的均值和方差
W_value=[2*C/3,0];
% 构造局部窗口的权重矩阵
weight=zeros(len,len);
for i=1:len
    % 为权重矩阵的每一列进行赋值
    for j=i-C:i+C
        if j>0 && j<=len && abs(j-i)<=min(min(i-1,len-i),C)
            value=abs((j-i)*(h(j)-h(i)));
            weight(j,i)=gaussmf(value,W_value);
        end
    end
    weight(:,i)=weight(:,i)./sum(weight(:,i));
end

end

