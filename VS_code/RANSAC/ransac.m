function [M, inliers] = ransac(x, fittingfn, distfn, degenfn, s, t, feedback, ...
                               maxDataTrials, maxTrials)
% ransac--用RANSAC算法稳健地拟合一个模型到数据
% input:
%          x: 要拟合的数据。x为[2d，Npts]，d是一个数据的维数，Npts是点的数量。
%  fittingfn: homography2d函数句柄
%     distfn: homogdist2d函数句柄,计算从模型到数据x的距离
%             该函数计算点与模型之间的距离，返回x中内联元素的索引，即在模型距离t内的点。
%    degenfn: isdegenerate函数句柄,确定一组数据点是否会产生退化模型。
%              这被用来丢弃那些不能产生有用模型的随机样本
%          s: 拟合需要的最小的特征点数
%          t: 数据点与模型之间的距离阈值，用于判断该点是否为内嵌点。
%   feedback: 可选标志0/1。如果设置为1，则在每一步都打印出所需的试验计数和估计
%            的试验总数。默认值为0。
% maxDataTrials: 选择非退化数据集的最大次数。默认值为100。（循环的次数）
%  maxTrials: 最大迭代次数。该参数为可选参数，默认值为1000。
% output:
%          M: 内层数量最多的模型。
%    inliers: 一个x元素索引的数组，它是最佳模型的内部数组序号

    % 参数的数量，并设置默认值
    error ( nargchk ( 6, 9, nargin ) );
    if nargin < 9
        maxTrials = 1000;    
    end
    if nargin < 8
        maxDataTrials = 100; 
    end
    if nargin < 7
        feedback = 0;        
    end
    
    %特征点集合的维数
    [rows, npts] = size(x);
    % 初始化参数
    % 选择至少一个没有异常值的样本的期望概率(可能应该是一个参数)
    p = 0.99;         
    % 允许检测解决方案故障
    bestM = NaN;      
    trialcount = 0;
    bestscore =  0;
    N = 1;            
    
    while N > trialcount
        % 随机选择s个数据点组成一个试验模型M。
        % 在选择这些点时，我们必须检查它们是否处于退化配置中。
        degenerate = 1;
        count = 1;
        while degenerate
            % 从范围为1..npts中随机选s个数
            if ~exist('randsample', 'file')
                ind = randomsample(npts, s);
            else
                ind = randsample(npts, s);
            end
            % 测试这些点是否为退化模型,执行isdegenerate函数,
            % 即判断所有点是否共线
            degenerate = feval(degenfn, x(:,ind));
            
            if ~degenerate
                % 拟合模型到这个随机选择的数据点。注意，M可能代表一组适合数据的
                % 模型，在本例中M将是模型的单元数组.求单应性。
                M = feval(fittingfn, x(:,ind));
                
                % 根据您的问题，确定数据集是否退化的唯一方法可能是尝试拟合
                % 一个模型，看看它是否成功。如果失败，我们将degenerate重置为true。
                if isempty(M)
                    degenerate = 1;
                end
            end
                 
            % 通过count计数，防止无限循环
            count = count + 1;
            if count > maxDataTrials
                warning('Unable to select a nondegenerate data set');
                break
            end
        end
        % 计算点与返回x中内部线元素索引的模型之间的距离
        [inliers, M] = feval(distfn, M, x, t);
        
        % 找出这个模型中inliers的数量。
        ninliers = length(inliers);
        if ninliers > bestscore    
            bestscore = ninliers;  
            bestinliers = inliers;
            bestM = M;
            
            % 更新试验次数N的估计值，以确保我们以p的概率选择一个没有异常值的数据集。
            fracinliers =  ninliers/npts;
            pNoOutliers = 1 -  fracinliers^s;
            % 避免除数为Inf
            pNoOutliers = max(eps, pNoOutliers);
            % 避免除数为0
            pNoOutliers = min(1-eps, pNoOutliers);
            N = log(1-p)/log(pNoOutliers);
        end
        % 计数防止无限循环
        trialcount = trialcount+1;
        if feedback
            fprintf('trial %d out of %d         \r',trialcount, ceil(N));
        end

        % 防止无限循环
        if trialcount > maxTrials
            break
        end
    end
    if feedback
        fprintf('\n'); 
    end
    
    % 得到一个解决方案
    if ~isnan(bestM) 
        M = bestM;
        inliers = bestinliers;
    else
        M = [];
        inliers = [];
        warning('ransac was unable to find a useful solution');
    end
    
