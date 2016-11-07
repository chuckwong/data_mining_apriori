% ����C_k
function C_k = apriori_gen(L_k_1, k_1)

C_k = [];

% L_k-1����
len = size(L_k_1, 1);

% ���� & ����
for i=1:len
    for j=1:len
        % l_1� �� l_2�
        l_1 = L_k_1(i,:);
        l_2 = L_k_1(j,:);
        
        % �ж��Ƿ��������
        can_connect = 0;
        if k_1 == 1
            if l_1(1) < l_2
                can_connect = 1;
            end
        elseif k_1 > 1
            % 2+
            flag = 1;
            for m=1:k_1-1
                if l_1(m) ~= l_2(m)
                    % �����
                    flag = 0;
                end
            end
            
            if (l_1(k_1) < l_2(k_1)) && flag
                can_connect = 1;
            end
        end
        
        if can_connect            
            c = union(l_1, l_2);
            % ����
            if has_infrequent_subset(c, L_k_1)
                C_k = [C_k; c];
            end
        end
    end
end

end