function [im_array,files_array,filesname_array] = readImages(impath,fmt)
% readimages:��ȡimpath·���µ��ļ���������fmt��ʽ��ͼ��
% input:
%   impath:����ͼ�񼯵��ļ���·��
%   fmt:Ҫ��ȡ��ͼ��ĸ�ʽ
% output:
%   im_array:��ȡ��ͼ����������(��Ԫ����)
%   file_array:��ȡ��ͼ��·������(��Ԫ����)
%   filesname_array:��ȡ��ͼ���ļ�������(��Ԫ����)

% ѡ��Ҫ��ȡ���ݼ���·��
frame_dir = uigetdir(impath,'ѡ������ͼ������·��');
if frame_dir==0
    disp('·��ѡ�����');
    return;
end

% ��ȡ�ļ����µ�ͼ��
% im_array��ͼ�����飻files_array:ͼ��·�����飻filesname_array��ͼ���ļ�������
[im_array,files_array,filesname_array] = readDirImages(frame_dir,fmt);
% �ж�ͼ�����ݼ��Ƿ�Ϊ��
if isempty(im_array)
    disp('invalid path for input image sequence selected!');    
    return;
end

end

