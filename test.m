%%% 设置全局变量
global adjacent_matrix;
global distance_matrix;
global label_matrix;

%%% 预处理
pre_process();

%%% 抽取样本
samples = [(0:1:1004)', distance_matrix, distance_matrix'];
train_patterns = [];
train_labels = [];
validate_patterns = [];
validate_labels = [];

%%% k-means
% result = k_means(samples, [42, 100]);

%%% DecisionTree-C4.5
% encode_patterns_label =  [samples(:,2:end),label_matrix(:, 2:end)];
% createPatternModel(encode_patterns_label);
% patterns = encodePattern(encode_patterns_label);
result = DecisionTree_C4_5([(0:1:199)',patterns(1:200,1:end-1)], [(0:1:199)',patterns(1:200,end)]);

%%% LinearPropagation
% r = 0.20;
% train_num = uint32(1005 * r);
% ranIndex = sampling(1:1:1005, train_num);
% % ranIndex = 1 : 1 : train_num;
% for i = 1 : 1005
%     if ismember(i, ranIndex)
%         train_patterns = [train_patterns; samples(i,:)];
%         train_labels = [train_labels; label_matrix(i, :)];
%     else
%         validate_patterns = [validate_patterns; samples(i,:)];
%         validate_labels = [validate_labels; label_matrix(i, :)];
%     end
% end
% result = LabelPropagation(train_patterns, train_labels, validate_patterns, [1000, 0.000001, 42]);

% train_data = zeros(1005, 42);
% train_point = 1:1:1005;
% for i = 1 : 100
%     label = label_vector(i, 1);
%     train_data(i, label) = 1;
% end
% result = LabelPropagation(train_point', train_data(1:100, :), train_data(101:end, :),1000, 0.0004);
% run_time = toc;
estimate = RandIndexEvaluate(result);
