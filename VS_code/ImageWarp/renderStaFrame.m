function [ori_array,imwarp_array,D,Crop]=renderStaFrame(img_array,new_x_motion_meshes,new_y_motion_meshes,gap,path,path_syn,scale)
% renderStaFrames():逐帧渲染图像序列,生成稳定图像
% input
%  
% output
% 



% 图像序列的长度
im_len=length(img_array);
% 图像的高框
[im_height,im_width,~]=size(img_array{1});
% 网格顶点的行列数
[num_mesh_height,num_mesh_width,num_frames]=size(new_x_motion_meshes);
% 每帧图像网格数
num_mesh=[num_mesh_height-1,num_mesh_width-1];
% 判断路径的帧数与图像序列的帧数是否相等
if im_len~=num_frames
    disp("路径数与图像序列的帧数不相等!");
    exit(0);
end

% 每个网格中像素点的个数
% num_pixel_height=floor(im_height/num_mesh);
% num_pixel_width=floor(im_width/num_mesh);
% ----------------- 保存结果图像---------------
imwarp_array=cell(im_len,1);
new_array=cell(im_len,1);
ori_array=cell(im_len,1);
% ---------------------------------------------

% ----------评价指标--------------
D=[];
Crop=[];
% --------------------------------

fprintf('渲染图像序列:\n');
% 逐帧扭曲图像
for i=1:im_len

    % ----------评价指标--------------
    % D=[];
    D_affine=[];
    % --------------------------------

    fprintf('%5d',i);
    if mod(i,20)==0
        fprintf('\n');
    end

    % 要进行扭曲的原始图像
    I=img_array{i};
    
    % 新的网格顶点的运动矢量
    new_x_motion_mesh=new_x_motion_meshes(:,:,i);
    new_y_motion_mesh=new_y_motion_meshes(:,:,i);

    % 生成原始图像中每个网格的顶点坐标(x:列坐标,y:行坐标)(不是10的话,有可能不是整数)
    [x_vertice,y_vertice]=meshgrid(ceil(linspace(1, im_width+1, num_mesh(2)+1)), ...
        ceil(linspace(1, im_height+1, num_mesh(1)+1)));

    % 为扭曲后的图像创建模板，含一定边界
    imwarp=zeros(im_height+2*gap,im_width+2*gap,3);

    % 对每个网格分别进行扭曲
    for row=1:num_mesh(1)
        for col=1:num_mesh(2)
            % 原始图像的网格顶点(四个)
            src=[x_vertice(row,col),     y_vertice(row,col);
                x_vertice(row,col+1)-1,  y_vertice(row,col+1);
                x_vertice(row+1,col),  y_vertice(row+1,col)-1;
                x_vertice(row+1,col+1)-1,y_vertice(row+1,col+1)-1];

            % 变换后的图像的网格顶点(四个)
            dst=[x_vertice(row,col)+new_x_motion_mesh(row,col),         y_vertice(row,col)+new_y_motion_mesh(row,col);
                x_vertice(row,col+1)-1+new_x_motion_mesh(row,col+1),    y_vertice(row,col+1)+new_y_motion_mesh(row,col+1);
                x_vertice(row+1,col)+new_x_motion_mesh(row+1,col),    y_vertice(row+1,col)-1+new_y_motion_mesh(row+1,col);
                x_vertice(row+1,col+1)-1+new_x_motion_mesh(row+1,col+1),y_vertice(row+1,col+1)-1+new_y_motion_mesh(row+1,col+1)];

            % 估计新的变换矩阵
            H=fitgeotrans(dst,src,'projective').T;
            
            
            % ------------扭曲评价指标-------------
            H_1=H./H(3,3);
            S=svd(H_1(1:2,1:2));
            S=sort(S,'descend');
            D_affine=[D_affine,S(2)/S(1)];
            % -------------------------------------

            % 变换后四个顶点的x(列)和y(行)的最大和最小值
            minx=min(dst(:,1));
            maxx=max(dst(:,1));
            miny=min(dst(:,2));
            maxy=max(dst(:,2));

            % 对网格进行扭曲(含边界)
            imwarp = myWarp(minx,maxx,miny,maxy,double(I),imwarp,H,gap);
            imwarp = uint8(imwarp);
        end
    end

    % 保存中心稳定区域
    height_center=round(size(imwarp,1)/2);
    width_center=round(size(imwarp,2)/2);
    % 中心高宽度
    H=round(im_height*scale/2);
    W=round(im_width*scale/2);

    % 去除边缘部分，保留90%的视野
    imwarp_1=imwarp(height_center-H+1:height_center+H,width_center-W+1:width_center+W,:);
    imwarp_new=imresize(imwarp_1,[im_height,im_width]); 

    % --------扭曲评价指标---------------
    D=[D,mean(D_affine)];
    [C_R,im_new]= croppingRatio_1(imwarp,im_height,im_width);
    Crop=[Crop,C_R];
    % -----------------------------------
    
    % -----------------------------------------------
    % 保存局部图像
    imwarp_array{i}=imwarp_1;
    % 保存原始图像的局部区域
    height_I=round(size(I,1)/2);
    width_I=round(size(I,2)/2);
    ori_array{i}=I(height_I-H+1:height_I+H,width_I-W+1:width_I+W,3);
    % -------------------------------------------------

    % 将扭曲的图像保存到文件夹中
    img_name=num2str(i)+".png";
    img_path=strcat(path,img_name);
    imwrite(imwarp_new,img_path);

    % 保存合成图像
%     syn_path=strcat(path_syn,img_name);
%     % syn=uint8(ones(im_height,20,3)*255);
%     % syn_im=cat(2,I,syn,imwarp);
%     imwrite(im_new,syn_path);

end

end