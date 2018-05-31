function result=DecisionTree_C4_5(train_patterns, train_labels) %, validate_patterns, params)
    global train_dataset;
    global AutoMatrix;
    
    samplesNum = size(train_patterns, 1);
    feaNum = size(train_patterns, 2) -1;
    
    fea_header = [1:1:feaNum, 0];
    train_dataset = [fea_header;[train_patterns(:, 2:end), train_labels(:, 2:end)]];   
    AutoMatrix = zeros(feaNum, 10); 
    
    result = createTree(train_dataset);
    
end

%%% 计算给定数据集的香农熵
function shannonEnt = calcShannonEnt(dataset)
    numEntries = size(dataset, 1) - 1; % 样本数
    labelCounts = containers.Map('keyType','double','valueType','double');
    for index = 1 + 1 : numEntries + 1
        currentLabel = dataset(index, end);
        if ~ismember(currentLabel, cell2mat(labelCounts.keys()))
            labelCounts(currentLabel) = 0;
        end
        labelCounts(currentLabel) = labelCounts(currentLabel) + 1;
    end
    shannonEnt = 0.0;
    labelKeys = cell2mat(labelCounts.keys); % 标签集
    for keyIndex = 1 : length(labelKeys)
        key = labelKeys(keyIndex);
        value = labelCounts(key);
        prob = double(value) / numEntries;
        shannonEnt = shannonEnt - prob * log2(prob);
    end
end

%%% 按照给定特征划分数据集
function retDataset = splitDataset(dataset, axis, value)
    numEntries = size(dataset, 1) - 1;
    retIndex = 1;
    for index = 1 + 1 : numEntries + 1
        feat = dataset(index, axis);
        if feat == value
            retIndex = [retIndex;index];
        end
    end
    %retDataset = dataset(retIndex, :);
    retDataset = [dataset(retIndex, 1:axis-1),dataset(retIndex, axis+1:end)];
end

%%% 选择最好的数据集划分方式
function bestFeature = chooseBestFeatureToSplit(dataset)
    numEntries = size(dataset, 1) - 1;
    baseEntropy = calcShannonEnt(dataset);
    bestInfoGain = 0.0; bestFeature = -1;
    for featIndex = 1 : size(dataset, 2) - 1
        featList = dataset(2:end, featIndex);
        uniqueVals = unique(featList);
        newEntropy = 0.0;
        punish = 0.0;
        for valueIndex = 1 : length(uniqueVals)
            value = uniqueVals(valueIndex);
            subDataset = splitDataset(dataset, featIndex, value); 
            prob = double(size(subDataset, 1) - 1) / numEntries;
            newEntropy = newEntropy + prob * calcShannonEnt(subDataset);
            punish = punish - prob * log2(prob);
        end
        infoGain = baseEntropy - newEntropy / punish;
        if infoGain > bestInfoGain
            bestInfoGain = infoGain;
            bestFeature = featIndex;
        end
    end
end


%%% 递归建立决策树
function myTree = createTree(dataset)
    global AutoMatrix;
    labelList = dataset(2:end, end);
    if length(unique(labelList)) == 1
        myTree = -labelList(1,1);
        return;
    end
    if size(dataset, 2) <= 2
        myTree = -mode(labelList);
        return;
    end
    bestFeatIdx = chooseBestFeatureToSplit(dataset);
    bestFeat = dataset(1, bestFeatIdx);
    featValues = dataset(2:end, bestFeatIdx);
    uniqueVals = unique(featValues);
    for i = 1 : length(uniqueVals)
        value = uniqueVals(i);
        AutoMatrix(bestFeat, value) = createTree(splitDataset(dataset, bestFeatIdx, value));
    end
    myTree = bestFeat;
end
