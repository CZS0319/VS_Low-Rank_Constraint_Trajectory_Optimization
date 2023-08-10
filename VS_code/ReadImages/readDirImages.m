function [images_array,files_array,filesname_array] = readDirImages( image_dir, fmt )
% readDirImages:��ȡͼ�����ݼ��е�����fmt��ʽ��ͼ��
% input:
%   image_dir:����ͼ�����ݼ���·��
%   fmt:ͼ��ĸ�ʽ
% output:
%   images_array:��ȡ��ͼ����������(��Ԫ����)
%   files_array:��ȡ��ͼ��·������(��Ԫ����)
%   filesname_array:��ȡ��ͼ���ļ�������(��Ԫ����)

%% ��ȡ�����ļ��µ�ͼ���������Ϣ��image_files��
% �жϱ����Ƿ����
if ~exist('fmt','var')
    fmt='png';
end
% ͼ��ĸ�ʽ
fmt=['*.',fmt];
file_names = fullfile(image_dir, fmt);
% ��ȡ����ļ�����file_namesͼƬ��������Ϣ
image_files = dir(file_names);
% �ж�image_files�Ƿ�Ϊ��
if isempty(image_files)
    images_array={};
    disp(['No image files found in dir: ', image_dir]);
    return;
end

%% ��ȡ�ļ����µ�����ͼ��(images_array;file_array)
% ͼ�����ݼ���ͼ�������
n = length(image_files);
% ��ʼ������ͼ���Ԫ���������飨images_array:ͼ������;
%     file_array:ͼ��·������;filesname_array:�ļ������飩
images_array = cell(n, 1); 
files_array=cell(n,1);
filesname_array=cell(n,1);
% ���������ļ��ж�ȡͼ��
for k = 1:n
    base_name = image_files(k).name;
    % base_name=num2str(k)+".png";
    % ÿ��ͼ��ĵ�ַ
    full_name = fullfile(image_dir, base_name);
    if ~endsWith( base_name,'fits')
        % ��.fits��ʽ��ͼ��
        im = imread(full_name);
    else
        % .fits��ʽ��ͼ��
        im=fitsread(full_name);
    end
    % ͼ������
    images_array{k} = im;
    % ͼ��·������
    files_array{k}=full_name;
    % ��ȡ��ͼ���ļ�������
    filesname_array{k}=base_name;
end

end