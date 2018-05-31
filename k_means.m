 %% 聚类的集合数， 迭代次数
function result = k_means(train_patterns, params) 
    % train_patterns 输入特征，每一行为一个样本，每一列为一个特征（除了第一列为唯一标识）
    % train_labels 输入标签（n*2),第一列为唯一标识，第二列为样本标签
    % params 算法相关参数:
    %   max_iters   最大迭代次数
    %   k_num       分类数
    % result 第一列为唯一标识，第二列为标签
    
    %%% 全局变量定义
    global k_num;
    global identifier;
    global patterns;
    global analysis_matrix;
    global samples_num;
    global fea_num;
    
    %%% 初始化
    k_num = params(1);
    max_iters = params(2);
    identifier = train_patterns(:, 1);
    patterns = train_patterns(:, 2:end);
    init_center = sampling(1:1:samples_num, k_num);    % 选取初始中心点
    %init_center = [200:1:k + 199];
    samples_num = size(train_patterns, 1); % sampels_num 样本数
    fea_num = size(train_patterns, 2) - 1; % fea_num 特征数
    analysis_matrix = zeros(k_num, samples_num + 3);
    analysis_matrix(:, end) = zeros(k_num, 1);    % 倒数第一列为类内个体数
    analysis_matrix(:, end-1) = init_center;  % 倒数第二列为类内中心点
    analysis_matrix(:, end-2) = 0:1:k_num-1;    % 倒数第三列为类标签
    
    get_distance = @get_distance_1;     % 选择度量函数
    cal_kernel = @cal_kernel_1;     % 选择聚类准则
    get_center = @get_center_1;     % 选择聚类中心函数
    
    %%% 开始迭代
    pre = +inf;
    for iter = 1 : max_iters
        fprintf('k-means : iters %d\t', iter);
        gather(get_distance);
        estimate = sum(cal_kernel(analysis_matrix, get_distance));
        fprintf('estimate-value %f\n', estimate);
        if estimate < pre
            pre = estimate;
        else
            break;
        end
        
        get_center(get_distance);
        
    end
    result = get_labels();
end

%% 返回聚类标签
function result = get_labels()
    global k_num;
    global identifier;
    global samples_num;
    global analysis_matrix;
    result = zeros(samples_num, 2);
    for i = 1 : k_num
        vextex_num = analysis_matrix(i, end);
        label = analysis_matrix(i, end-2);
        for index = 1 : vextex_num
            point = analysis_matrix(i, index);
            result(point, 1) = identifier(point);
            result(point, 2) = label;
        end
    end
end

%% 度量函数1（ 当前度量定义为相似度的倒数 ）
function distance = get_distance_1(vertex_u, vertex_v)
    % vertex_u, vertex_v 输入两个节点的序号（非标识符）
    global patterns;
    alpha = 5;
    diff = patterns(vertex_u, :)' - patterns(vertex_v, :)';
    similarity = exp(-norm(diff, 2) / (alpha^2));
    distance = 1 / similarity;
    %fprintf('%d\t%d\t%f\n', vertex_u, vertex_v, distance);
end

%% 聚类准则1（ 当前准则定义为距离和 ）
function estimate = cal_kernel_1(rows, get_distance)
    % rows 输入矩阵，对矩阵的每一行计算（即每个聚类）计算指标
    % get_distgance 规定度量函数
    % estimate 列向量，每行为各个聚类的指标
    
    num = size(rows, 1);
    estimate = zeros(num, 1);
    
    for i = 1 : num
        vertex_center = rows(i, end - 1);
        vertex_num = rows(i, end);
        for point_index = 1 : vertex_num
            point = rows(i, point_index);
            estimate(i, 1) = estimate(i, 1) + get_distance(vertex_center, point)^2;
        end
    end
end

%% 聚类中心1（ 当前中心定义为 遍历类内每一个点，选取使聚类准则最小的中心点 ）
function get_center_1(get_distance)
    global k_num;
    global analysis_matrix;
    for i = 1 : k_num
        min_kernel = +inf;
        min_center = -1;
        vertex_num = analysis_matrix(i, end);
        for point_index = 1 : vertex_num
            analysis_matrix(i, end - 1) = analysis_matrix(i, point_index);
            kernel = cal_kernel_1(analysis_matrix(i, :), get_distance);
            if kernel < min_kernel
                min_kernel = kernel;
                min_center = analysis_matrix(i, end - 1);
            end
        end
        analysis_matrix(i, end - 1) = min_center;
    end
end

%% 根据最短距离聚类
function gather(get_distance)
    % 遍历所有点，所有点根据度量函数分配到最近的中心点
    global k_num;
    global analysis_matrix;
    global samples_num;
    
    analysis_matrix(:, end) = zeros(k_num, 1);
    
    for point = 1 : samples_num
        min_distance = +inf;
        min_center_index = -1;
        for center_index = 1 : k_num
            center = analysis_matrix(center_index, end-1);
            distance = get_distance(center, point);
            if distance < min_distance
                min_distance = distance;
                min_center_index = center_index;
            end
        end
        analysis_matrix(min_center_index, end) = analysis_matrix(min_center_index, end) + 1;
        analysis_matrix(min_center_index, analysis_matrix(min_center_index, end)) = point;
    end
end        
        