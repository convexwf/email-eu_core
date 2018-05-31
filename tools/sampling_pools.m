%%% 从序列中随机抽取n次，保证全部抽取，每次抽取作为一个列向量
function s = sampling_pools(sequence, n)
    len = length(sequence);
    quotient = len / n;
    if quotient ~= floor(quotient)
        quotient = ceil(quotient);
    end
    s = zeros(quotient, n);
    for i = 1 : n-1
        temp = sampling(sequence, quotient);
        s(:, i) = temp;
        sequence = setdiff(sequence, temp);
    end
    s(1:length(sequence), n) = sequence;
end