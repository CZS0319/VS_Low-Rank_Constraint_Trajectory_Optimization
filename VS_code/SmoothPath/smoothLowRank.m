function opt_transforms = smoothLowRank(transforms)
% smoothLowRank():利用低秩约束进行一次完整的路径平滑
% input:
%   n_transforms:原始路径(x方向和y方向的路径序列)
% output:
%   opt_transforms:平滑后的各个顶点的运动路径


%% 初始化各种参数
% -------初始化平滑路径参数---------
alpha=1000;
beta=10;
lambda=1;
epsilon=1;
eta=1;
mike=20;


% --------设置局部窗口参数----------
% 权重窗口半径
c=5;
% 高斯核半径
v=4;


% 可选择的局部窗口
r_W=[25,20,15,10,5];
% r_W=[30,25,20,15,10];
r_index=1;

% --------设置迭代参数-----------
% 迭代停止的标准
tol = 1e-2;

% 路径序列长度
[width,len]=size(transforms);


%% 变换矩阵序列的平滑
% 构造一个拓展的变换矩阵序列
% copy_transforms=[ones(width,length_W)*planedPath(1),transforms,ones(width,length_W)*planedPath(end)];
opt_transforms=zeros(width,len);
i=1;
while i~=(len+1)
   
    if i==51
        nnnn=1;
    end
    % 确定局部窗口的长度
    r=r_W(r_index);

    %% 根据窗口的长度选择起止帧
    % 记录局部窗口的起止位置
    head=max(i-r,1);
    tail=min(i+r,len);

    % 窗口的长度
    nn=tail-head+1;

    if i<=r
        flag=i;
    else
        flag=1+r;
    end
    
    %% 构造确定矩阵参数
    % 根据窗口长度选取局部窗口
    F=transforms(:,head:tail);

    % 构造权重矩阵
    W=weightKernel(F,c,v);

    % 构造平滑度系数D
    D=zeros(nn,nn-2);
    for index=1:nn-2
        D(index,index)=1;
        D(index+1,index)=-2;
        D(index+2,index)=1;
    end

    % 构造秩1约束L
    L=zeros(width,nn);
    for index=1:width
        L_row=linspace(F(index,1),F(index,end),nn);
        L(index,:)=L_row;
    end

    % 构造相似性约束
    C=zeros(nn,nn);
    for index=1:min(r,head-1)
        C(index,index)=1;
    end
    M=opt_transforms(:,head:tail);

    
    % 构造A
    A=F;

    % 构造S,Z,B
    S=zeros(width,nn);
    Z=zeros(width,nn);
    B=zeros(width,nn);

    % 迭代的次数以及标志
    iter      = 0;
    converged = false;

    %% 局部窗口的运动平滑
    while ~converged
        % 迭代次数增加
        iter=iter+1;

        % 计算H
        H=(F*W'+mike*M*C'+Z+epsilon*(L+S)+B+eta*A)/(W*W'+alpha*D*D'+mike*C*C'+epsilon*eye(nn)+eta*eye(nn));

        % 计算A
        [U,N,V]=svd(H-B/eta);
        A=U*soft(N,beta/eta)*V';

        % 计算S
        S=soft(H-Z/epsilon-L,lambda/epsilon);

        % 计算Z和B
        Z=Z+epsilon*(L+S-H);
        B=B+eta*(A-H);

        if iter~=1
            % 判断迭代停止的条件
            h=abs(norm(H,'fro')-norm(H_0,'fro'));
            a=abs(norm(A,'fro')-norm(A_0,'fro'));
            s=abs(norm(S,'fro')-norm(S_0,'fro'));
            if h<tol && a<tol && s<tol
                converged=true;
            end
        end
        % 用于判断相邻两次的差异
        H_0=H;
        A_0=A;
        S_0=S;
    end

    % 自适应确定窗口
    %S1=abs(H-F);
    if max(max(abs(S)))>10 && r_index<5
        r_index=r_index+1;
        disp("S的最大值："+num2str(max(max(abs(S)))));
    else
        % 取局部窗口的中心值
        opt_transforms(:,i)=H(:,flag);
        disp("帧序号："+num2str(i)+"   iter的次数："+num2str(iter)+"   r的值"+num2str(r)+"    H的秩:"+num2str(rank(H)));
        i=i+1;
        r_index=1;
    end
end

end