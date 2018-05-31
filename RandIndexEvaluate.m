function RI = RandIndexEvaluate(guess)
    global label_matrix;
    A = 0;
    B = 0;
    C = 0;
    D = 0;
    [rows, ~] = size(guess);
    for i = 1 : rows - 1
        for j = i : rows
            point_i = guess(i ,1);
            point_j = guess(j ,1);
            i_label = find_label_by_id(label_matrix, point_i);
            j_label = find_label_by_id(label_matrix, point_j);
            guess_i_label = guess(i, 2);
            guess_j_label = guess(j, 2);
            
            if i_label == j_label && guess_i_label == guess_j_label
                A = A + 1;
            elseif i_label == j_label
                B = B + 1;
            elseif guess_i_label == guess_j_label
                C = C + 1;
            else
                D = D + 1;
            end
        end
    end
    RI = (A + D)/(A+B+C+D);
    
    correct = 0;
    for k = 1 : rows
        point_k = guess(k ,1);
        k_label = find_label_by_id(label_matrix, point_k);
        guess_k_label = guess(k, 2);
        if k_label == guess_k_label
            correct = correct + 1;
        end
    end
    correct
    correct / rows
end

function label = find_label_by_id(vector, id)
    num = size(vector, 1);
    for i = 1 : num
        if vector(i, 1) == id
            label = vector(i, 2);
            break;
        end
    end
end

        
    


