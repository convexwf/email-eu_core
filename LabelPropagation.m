function result = LabelPropagation(train_patterns, train_labels, validate_patterns, params)
    
    global train_identifiers;   
    global validate_identifiers; 
    global k_num;
    global patterns_matrix;     % 训练集和测试集合并在一起,去除标识符
    global weight_matrix;       % 相似性矩阵
    global probability_matrix;  % 转移概率矩阵
    global analysis_matrix;     % 数据矩阵
    
    %%% 相关参数
    max_iters = params(1);
    epsilon = params(2);
    k_num = params(3);
    train_samples_num = size(train_patterns, 1);
    validate_samples_num = size(validate_patterns, 1);
    fea_num = size(train_patterns, 2) - 1;
    
    train_identifiers = train_patterns(:, 1);
    validate_identifiers = validate_patterns(:, 1);   
    patterns_matrix = [train_patterns(:, 2:end); validate_patterns(:, 2:end)];
    
    generate_analysis(train_samples_num, validate_samples_num, train_labels);
    generate_weight(train_samples_num + validate_samples_num);
    generate_probability();
    labeled_matrix = analysis_matrix(1:train_samples_num, :);
    
    for iter = 1 : max_iters
        fprintf('LabelPropagation : iter %d\t', iter);
        next = propagation();
        next(1:train_samples_num, :) = labeled_matrix;
        diff = analysis_matrix - next;
        curr_diff = norm(diff, 2);
        fprintf('current diff : %f\n', curr_diff);
        if curr_diff > epsilon
            analysis_matrix = next;
        else
            break;
        end
    end
    result = get_labels(validate_patterns, analysis_matrix(train_samples_num + 1:end,:));
          
end

%%% 返回聚类标签
function result = get_labels(patterns, matrix)
    rows = size(matrix, 1);
    result = zeros(rows, 2);
    for index = 1 : rows
        point = patterns(index, 1);
        [~, label] = max(matrix(index,:));
        result(index, 1) = point;
        result(index, 2) = label - 1;
    end
end

%%% 权重计算
function weight = get_weight(vertex_u, vertex_v)
    global patterns_matrix;
    alpha = 1;
    diff = patterns_matrix(vertex_u, :)' - patterns_matrix(vertex_v, :)';
    similarity = exp(-norm(diff, 2) / (alpha^2));
    weight = similarity;
end

%%% 生成数据矩阵
function generate_analysis(train_num, validate_num, labels)
    global k_num;
    global analysis_matrix;
    analysis_matrix = zeros(train_num+validate_num, k_num);
    for i = 1 : train_num
        label = uint32(labels(i, 2));
        analysis_matrix(i, label + 1) = 1;
    end
end

%%% 生成相似性矩阵
function generate_weight(scale)
    global weight_matrix;
    weight_matrix = zeros(scale, scale);
    for i = 1 : scale
        for j = 1 : scale
            similarity = get_weight(i, j);
            weight_matrix(i, j) = similarity;
        end
    end   
end

%%% 生成转移概率矩阵
function generate_probability()
    global weight_matrix;
    global probability_matrix;
    [num, ~] = size(weight_matrix);
    probability_matrix = zeros(num, num);
    for i = 1 : num
        row_weight = sum(weight_matrix(i, :));
        for j = 1 : num
            weight = weight_matrix(i, j);
            probability_matrix(i, j) = weight / row_weight;
        end
    end   
end

%%% 传播算法
function next = propagation()
    global analysis_matrix;
    global probability_matrix;
    next = probability_matrix * analysis_matrix;
end