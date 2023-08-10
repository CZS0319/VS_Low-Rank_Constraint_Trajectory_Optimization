function  matched_F= matchFeatures(features, descriptors)
%  matchFeatures():得到相邻图像相互匹配的特征点序列
%  input: 
%    features:图像序列中每幅图像的特征点坐标(x列,y行)
%    descriptors:特征点对应的特征描述符
%  output:
%    matched_F:图像序列的变换矩阵序列


% 图像序列的帧数
num_frames=length(features);
% 保存相互匹配的特征点
matched_F = cell(num_frames-1,1);

fprintf('在相邻帧之间匹配特征点:\n');
for k = 1:num_frames - 1
    fprintf('%5d',k);
    if mod(k,20)==0
        fprintf('\n');
    end

    % 只有当距离d(D1,D2)乘以THRESHOLD不大于D1到所有其他描述符的距离时，
    % 描述符D1才匹配到描述符D2。threshold的默认值为1.5。
    [matches, scores] = vl_ubcmatch(descriptors{k}, descriptors{k+1});
    % 根据匹配的分数升序排列
    [~, perm] = sort(scores, 'ascend') ;
    matches=matches(:,perm(:));
    % matched_a和matched_b是k帧和k + 1帧图像的匹配特征点
    matched_a = features{k}(1:2, matches(1, :));
    matched_b = features{k + 1}(1:2, matches(2, :));

    % 如果特征点的数量大于600，则选择匹配程度最高的特征点
    if size(matched_a,2)>600
        matched_a=matched_a(:,1:600);
        matched_b=matched_b(:,1:600);
    end
    
    % 保存相互匹配的特征点
    matched_F{k}=[matched_a',matched_b'];

    % 去掉完全相同的匹配特征点
    matched_F{k}=unique(matched_F{k},'rows');
    
end
fprintf('\n');

end