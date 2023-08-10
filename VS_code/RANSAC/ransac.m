function [M, inliers] = ransac(x, fittingfn, distfn, degenfn, s, t, feedback, ...
                               maxDataTrials, maxTrials)
% ransac--��RANSAC�㷨�Ƚ������һ��ģ�͵�����
% input:
%          x: Ҫ��ϵ����ݡ�xΪ[2d��Npts]��d��һ�����ݵ�ά����Npts�ǵ��������
%  fittingfn: homography2d�������
%     distfn: homogdist2d�������,�����ģ�͵�����x�ľ���
%             �ú����������ģ��֮��ľ��룬����x������Ԫ�ص�����������ģ�;���t�ڵĵ㡣
%    degenfn: isdegenerate�������,ȷ��һ�����ݵ��Ƿ������˻�ģ�͡�
%              �ⱻ����������Щ���ܲ�������ģ�͵��������
%          s: �����Ҫ����С����������
%          t: ���ݵ���ģ��֮��ľ�����ֵ�������жϸõ��Ƿ�Ϊ��Ƕ�㡣
%   feedback: ��ѡ��־0/1���������Ϊ1������ÿһ������ӡ���������������͹���
%            ������������Ĭ��ֵΪ0��
% maxDataTrials: ѡ����˻����ݼ�����������Ĭ��ֵΪ100����ѭ���Ĵ�����
%  maxTrials: �������������ò���Ϊ��ѡ������Ĭ��ֵΪ1000��
% output:
%          M: �ڲ���������ģ�͡�
%    inliers: һ��xԪ�����������飬�������ģ�͵��ڲ��������

    % ������������������Ĭ��ֵ
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
    
    %�����㼯�ϵ�ά��
    [rows, npts] = size(x);
    % ��ʼ������
    % ѡ������һ��û���쳣ֵ����������������(����Ӧ����һ������)
    p = 0.99;         
    % ����������������
    bestM = NaN;      
    trialcount = 0;
    bestscore =  0;
    N = 1;            
    
    while N > trialcount
        % ���ѡ��s�����ݵ����һ������ģ��M��
        % ��ѡ����Щ��ʱ�����Ǳ����������Ƿ����˻������С�
        degenerate = 1;
        count = 1;
        while degenerate
            % �ӷ�ΧΪ1..npts�����ѡs����
            if ~exist('randsample', 'file')
                ind = randomsample(npts, s);
            else
                ind = randsample(npts, s);
            end
            % ������Щ���Ƿ�Ϊ�˻�ģ��,ִ��isdegenerate����,
            % ���ж����е��Ƿ���
            degenerate = feval(degenfn, x(:,ind));
            
            if ~degenerate
                % ���ģ�͵�������ѡ������ݵ㡣ע�⣬M���ܴ���һ���ʺ����ݵ�
                % ģ�ͣ��ڱ�����M����ģ�͵ĵ�Ԫ����.��Ӧ�ԡ�
                M = feval(fittingfn, x(:,ind));
                
                % �����������⣬ȷ�����ݼ��Ƿ��˻���Ψһ���������ǳ������
                % һ��ģ�ͣ��������Ƿ�ɹ������ʧ�ܣ����ǽ�degenerate����Ϊtrue��
                if isempty(M)
                    degenerate = 1;
                end
            end
                 
            % ͨ��count��������ֹ����ѭ��
            count = count + 1;
            if count > maxDataTrials
                warning('Unable to select a nondegenerate data set');
                break
            end
        end
        % ������뷵��x���ڲ���Ԫ��������ģ��֮��ľ���
        [inliers, M] = feval(distfn, M, x, t);
        
        % �ҳ����ģ����inliers��������
        ninliers = length(inliers);
        if ninliers > bestscore    
            bestscore = ninliers;  
            bestinliers = inliers;
            bestM = M;
            
            % �����������N�Ĺ���ֵ����ȷ��������p�ĸ���ѡ��һ��û���쳣ֵ�����ݼ���
            fracinliers =  ninliers/npts;
            pNoOutliers = 1 -  fracinliers^s;
            % �������ΪInf
            pNoOutliers = max(eps, pNoOutliers);
            % �������Ϊ0
            pNoOutliers = min(1-eps, pNoOutliers);
            N = log(1-p)/log(pNoOutliers);
        end
        % ������ֹ����ѭ��
        trialcount = trialcount+1;
        if feedback
            fprintf('trial %d out of %d         \r',trialcount, ceil(N));
        end

        % ��ֹ����ѭ��
        if trialcount > maxTrials
            break
        end
    end
    if feedback
        fprintf('\n'); 
    end
    
    % �õ�һ���������
    if ~isnan(bestM) 
        M = bestM;
        inliers = bestinliers;
    else
        M = [];
        inliers = [];
        warning('ransac was unable to find a useful solution');
    end
    
