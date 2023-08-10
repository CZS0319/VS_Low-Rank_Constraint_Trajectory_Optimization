function  matched_F= matchFeatures(features, descriptors)
%  matchFeatures():�õ�����ͼ���໥ƥ�������������
%  input: 
%    features:ͼ��������ÿ��ͼ�������������(x��,y��)
%    descriptors:�������Ӧ������������
%  output:
%    matched_F:ͼ�����еı任��������


% ͼ�����е�֡��
num_frames=length(features);
% �����໥ƥ���������
matched_F = cell(num_frames-1,1);

fprintf('������֮֡��ƥ��������:\n');
for k = 1:num_frames - 1
    fprintf('%5d',k);
    if mod(k,20)==0
        fprintf('\n');
    end

    % ֻ�е�����d(D1,D2)����THRESHOLD������D1�����������������ľ���ʱ��
    % ������D1��ƥ�䵽������D2��threshold��Ĭ��ֵΪ1.5��
    [matches, scores] = vl_ubcmatch(descriptors{k}, descriptors{k+1});
    % ����ƥ��ķ�����������
    [~, perm] = sort(scores, 'ascend') ;
    matches=matches(:,perm(:));
    % matched_a��matched_b��k֡��k + 1֡ͼ���ƥ��������
    matched_a = features{k}(1:2, matches(1, :));
    matched_b = features{k + 1}(1:2, matches(2, :));

    % ������������������600����ѡ��ƥ��̶���ߵ�������
    if size(matched_a,2)>600
        matched_a=matched_a(:,1:600);
        matched_b=matched_b(:,1:600);
    end
    
    % �����໥ƥ���������
    matched_F{k}=[matched_a',matched_b'];

    % ȥ����ȫ��ͬ��ƥ��������
    matched_F{k}=unique(matched_F{k},'rows');
    
end
fprintf('\n');

end