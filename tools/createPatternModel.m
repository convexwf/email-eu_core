function createPatternModel(patterns)
    feaNum = size(patterns, 2);
    patterns_fid = fopen('dataset/patterns_model.txt','w', 'n','utf-8');
    for feaIndex = 1 : feaNum
        features = unique(patterns(:, feaIndex));
        for i = 1 : length(features)
            fprintf(patterns_fid, '%d\t', features(i));
        end
        fprintf(patterns_fid,'\n'); 
    end
    fclose(patterns_fid);
end