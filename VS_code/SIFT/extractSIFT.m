function [ features, descriptors ] = extractSIFT( images )
% extrectSIFT():��ȡͼ��������ÿ��ͼ���SIFT����
% input:
%   images:ͼ������
% output:
%   features:ͼ��������ÿ��ͼ����������x(��),y(��)����
%   descriptors:ͼ���������������������

% ͼ�����Ŀ
n = size(images, 1);

% ����һ��n*1�������������ӵ�cell����
features = cell(n, 1);
descriptors = cell(n, 1);

fprintf('Ϊÿһ֡��ȡSIFT������:\n');
for k = 1:n
    % ������ڴ����ͼ�����
    fprintf('%5d',k);
    if mod(k,20)==0
        fprintf('\n');
    end
    % ��K��ͼ��ľ�����Ϣ
    curr_image = images{k};  
    % �ж�ͼ���Ƿ�Ϊ��ɫͼ��
    [~, ~, chan] = size(curr_image); 
    % ÿ��ͼ���SIFT��������������
    if(chan == 3)
        [features{k}, descriptors{k}] = vl_sift(single(rgb2gray(curr_image)),'PeakThresh', 1);
    else
        % [features{k}, descriptors{k}] = vl_sift(single(curr_image),'Levels',3,'PeakThresh', 3);
        [features{k}, descriptors{k}] = vl_sift(single(curr_image),'PeakThresh', 1);
    end
end
fprintf('\n');
end