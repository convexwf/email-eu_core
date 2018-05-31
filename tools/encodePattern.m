function encode_result = encodePattern(patterns)
    model_matrix = cell(size(patterns, 2), 10);
    %%% 读取映射模型
    fid=fopen('dataset/patterns_model.txt','r+','n','utf-8');
    tline=fgetl(fid);
    tline=native2unicode(tline);
    lineIdx = 1;
    while tline 
        parts = strsplit(tline, '\t');
        model_matrix(lineIdx, 1:length(parts)) = parts;
        lineIdx = lineIdx + 1;
        tline=fgetl(fid);
        tline = native2unicode(tline);
    end
    fclose(fid);
    
    encode_result = zeros(size(patterns));
    for i = 1 : size(patterns, 2)
        matchVec = model_matrix(i, :);
        matchVec(cellfun(@isempty,matchVec)) = [];
        for j = 1 : size(patterns, 1)
            currPattern = num2str(patterns(j, i));
            idx = strmatch(currPattern, matchVec, 'exact');
            encode_result(j, i) = idx;
        end
    end
end