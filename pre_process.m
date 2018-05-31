function pre_process()  
    global adjacent_matrix;  %% 邻接矩阵
    global distance_matrix;  %% 距离矩阵
    global label_matrix;     %% 标签矩阵
    
    %%% 文件路径
    data_file = 'dataset/email-Eu-core.txt';
    label_file = 'dataset/email-Eu-core-department-labels.txt';
    
    %%% 预分配内存
    adjacent_matrix = zeros(1005, 1005);
    distance_matrix = zeros(1005, 1005);
    label_matrix = zeros(1005, 2);
    
    
    if ~exist('dataset/adjacent_matrix.txt', 'file')
        read_data(data_file, label_file);
        cal_graph(adjacent_matrix);
        write_file();
    else
        adjacent_matrix = importdata('dataset/adjacent_matrix.txt');
        distance_matrix = importdata('dataset/distance_matrix.txt');
        label_matrix = importdata('dataset/label_matrix.txt');
    end
    
    post_process();
end

%%% 根据文件初始化邻接矩阵和标签向量
function read_data(data_file, label_file)
    global label_matrix;
    global adjacent_matrix;
    
    distance_object = importdata(data_file);
    label_object = importdata(label_file);
    [rows, ~] = size(distance_object);
    for i = 1 : rows
        vertex_u = uint32(distance_object(i, 1));
        vertex_v = uint32(distance_object(i, 2));
        %fprintf('%d\t%d\n', vertex_u, vertex_v);
        adjacent_matrix(vertex_u + 1, vertex_v + 1) = 1;
    end
    for j = 1 : 1005
        label_matrix(j, 1) = label_object(j, 1);
        label_matrix(j, 2) = label_object(j, 2);
    end
end

%%% 计算幂矩阵
function cal_graph(matrix)
    global distance_matrix;
    adjacent_matrix = matrix;
    
    for count = 1 : 10
        fprintf('count%d\n', count);
        for x = 1 : 1005
            for y = 1 : 1005
                if distance_matrix(x, y) <= 0 && adjacent_matrix(x, y) > 0 
                	distance_matrix(x, y) = count;
                end
            end
        end
        adjacent_matrix = adjacent_matrix * adjacent_matrix;
    end
end

%%% 后续处理
function post_process()
    global distance_matrix;
    [rows, cols] = size(distance_matrix);
    for i = 1 : rows
        for j = 1 : cols
            if i == j
                distance_matrix(i, j) = 0;
            elseif distance_matrix(i, j) == 0
                distance_matrix(i, j) = -1;
            end
        end
    end
end

%%% 写入txt文件
function write_file()
    global adjacent_matrix;
    global distance_matrix;
    global label_matrix;
    adjacent_fid = fopen('dataset/adjacent_matrix.txt','w');
    distance_fid = fopen('dataset/distance_matrix.txt','w');
    label_fid = fopen('dataset/label_matrix.txt','w');
    for i=1:1005 
        for j=1:1005 
            fprintf(adjacent_fid,'%d\t',adjacent_matrix(i,j));  
            fprintf(distance_fid,'%d\t',distance_matrix(i,j));  
        end  
        fprintf(adjacent_fid,'\n'); 
        fprintf(distance_fid,'\n');  
        fprintf(label_fid, '%d\t%d\n', label_matrix(i,1), label_matrix(i,2));  
    end  
    fclose(adjacent_fid);
    fclose(distance_fid); 
    fclose(label_fid);
end
