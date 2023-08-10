function [new_x_mesh_motion,new_y_mesh_motion] = getFrameWarp(x_original,y_original,x_smooth,y_smooth)
% getFrameWarp():得到新的网格运动矢量
% input
%    x_original,y_original:各个顶点的原始运动轨迹
%    x_smooth,y_smooth:平滑后各个顶点的运动轨迹
% output
%   new_x_mesh_motion,new_y_mesh_motion:渲染各个顶点的运动轨迹

new_x_mesh_motion=x_smooth-x_original;
new_y_mesh_motion=y_smooth-y_original;
end