function [x_mesh_motion,y_mesh_motion] = motionPropagate(transform,X_matched,Y_matched,num_mesh,img_size,motion_median)
% motionPropagate():计算当前帧到下一帧各个顶点的运动矢量
% input:
%   transform:全局单应性变换
%   X_matched:当前帧中相互匹配的特征点坐标
%   Y_matched:下一帧中相互匹配的特征点坐标
%   num_mesh:划分的网格数
%   img_size:图像的高宽
%   motion_median:用于填充x和y方向的运动边缘,进行中值滤波
% output:
%   x_mesh_motion:各个网格顶点的x(水平)方向的运动矢量
%   y_mesh_motion:各个网格顶点的y(竖直)方向的运动矢量

% 中值滤波的阈值
th=3;

% 半径的网格数
r=2;

% 求网格的边长
x_mesh_length=ceil(img_size(2)/num_mesh(2));
y_mesh_length=ceil(img_size(1)/num_mesh(1));

% 圆的半径(与该顶点相邻的两层顶点有关)
radius=ceil(r*sqrt(x_mesh_length^2+y_mesh_length^2));

% 生成每个网格的顶点坐标(x:列坐标,y:行坐标)(不是10的话,有可能不是整数)
[x_vertice,y_vertice]=meshgrid(ceil(linspace(1, img_size(2), num_mesh(2)+1)), ...
    ceil(linspace(1, img_size(1), num_mesh(1)+1)));

% 对图像进行分格,分别保存x(水平)和y(竖直)方向的运动矢量
x_mesh_motion=zeros(num_mesh(1)+1,num_mesh(2)+1);
y_mesh_motion=zeros(num_mesh(1)+1,num_mesh(2)+1);

% 为各个顶点分配全局运动
for i=1:num_mesh(1)+1
    for j=1:num_mesh(2)+1

        % 计算全局运动
        % 当前顶点坐标
        pt=[x_vertice(i,j),y_vertice(i,j),1];
        % 全局运动后的顶点坐标
        ptrans=pt*transform;
        ptrans=ptrans./ptrans(3);

        % 当前顶点的全局运动矢量（上一帧到当前帧的运动矢量）
        x_motion=ptrans(1)-pt(1);
        y_motion=ptrans(2)-pt(2);
%         x_motion=pt(1)-ptrans(1);
%         y_motion=pt(2)-ptrans(2);

        %------------- 计算剩余运动-------------------------
        % 各个特征点到顶点的距离
        dst=sqrt(sum((X_matched-pt(1:2)).^2,2));
        % 找到小于radius的特征点的位置
        M_flag=find(dst<=radius);
        if ~isempty(M_flag)
            local_motions=[X_matched(M_flag,:),ones(length(M_flag),1)]*transform;
            local_motions=local_motions(:,1:3)./local_motions(:,3);
            % 该顶点周围的剩余运动
            temp_motion=Y_matched(M_flag,:)-local_motions(:,1:2);
            % x和y方向的剩余运动
            temp_x_motion=temp_motion(:,1);
            temp_y_motion=temp_motion(:,2);

            % 计算顶点的运动矢量
            temp_x_motion=sort(temp_x_motion);
            temp_y_motion=sort(temp_y_motion);
            x_mesh_motion(i,j)=x_motion+temp_x_motion(round(size(temp_x_motion,1)/2));
            y_mesh_motion(i,j)=y_motion+temp_y_motion(round(size(temp_y_motion,1)/2));
        else
            x_mesh_motion(i,j)=x_motion;
            y_mesh_motion(i,j)=y_motion;
        end
        % ------------------------------------------------------------------
        
    end
end
 
% 对x和y方向进行中值滤波
for i=1:3
    x_mesh_motion= medianFilter(x_mesh_motion,th);
    y_mesh_motion= medianFilter(y_mesh_motion,th);
end

end