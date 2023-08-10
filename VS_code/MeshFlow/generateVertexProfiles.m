function [x_paths,y_paths] = generateVertexProfiles(x_path,y_path,x_mesh_motion,y_mesh_motion)
% generateVertexProfiles():计算各个顶点在当前帧的运动路径
% input
%   x_path:上一帧x方向的各个顶点路径
%   y_path:上一帧y方向的各个顶点路径
%   x_mesh_motion:当前帧的运动矢量(x,y)
% output
%   x_mesh_motion:当前帧x方向的各个顶点路径
%   y_mesh_motion:当前y方向的各个顶点路径

% 计算各个顶点轮廓
x_paths=x_path+x_mesh_motion;
y_paths=y_path+y_mesh_motion;

end