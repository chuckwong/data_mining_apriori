% ��ȡԭʼ����
D_raw = load('data.txt');
% ��������ɢ��
D = preprocess(D_raw);
max_order = max(D(:));  % �������� 1~max

% ��С֧�ֶ�, ��С���Ŷ�
min_sup = 0.1;     % rel = 0.05, abs = 7
min_sup_abs = ceil(size(D,1) * min_sup);    % ������С֧�ֶ�
min_conf = 0.4;

% �����
[freq, orders] = hist(D(:), [1:max_order]);

% ��ʾC_1
fprintf('********* C_1 *********\norder     freq\n');

for i=1:length(orders)
    fprintf('%2.d        %d\n', orders(i), freq(i)); 
end

% ����L_1
L_1 = [];
L_1_count = [];
for i=1:length(orders)
    if(freq(i) >= min_sup_abs)
        L_1 = [L_1; orders(i)];
        L_1_count = [L_1_count; freq(i)];
    end
end

fprintf('\n');

% ��ʾL_1
fprintf('********* L_1 ******F***\n<Item>     <req> \n');
for i=1:length(L_1)
    fprintf('%2.d        %d\n', L_1(i), L_1_count(i)); 
end


% ���k-��Ƶ����
K = 3;  % ����������Ϊ3
L_result = []; % ���
L_result_count = []; % ����

% ��ʼ��
L_k_1 = L_1;
L_k_1_count = L_1_count;

for k=2:K  % ʵ��ҪL_k-1�Ƿ�Ϊ�ռ�, ��������������ֱ�ӽ����ó�K
    
    % ����C_k
    C_k = apriori_gen(L_k_1, k - 1);
    count = zeros(size(C_k, 1), 1);
    
    % ����
    for i=1:size(C_k,1)
        c = C_k(i,:);
        for j=1:size(D,1)
            d = D(j,:);
            % ��all()������, �ж��ǲ����Ӽ�
            if all(ismember(c,d))
                count(i) = count(i) + 1;
            end
        end
    end
    
    % ɸѡ
    L_k = C_k(find(count >= min_sup_abs),:);
    L_k_count = count(find(count >= min_sup_abs),:);
    
    % ******************* ��ʾ��ʼ **********************
    
    % C_k
    print_C(C_k, count, k)
    
    % L_k
    print_L(L_k, L_k_count, k);
    
    % ******************* ��ʾ���� **********************
    
    %  ��������
    
    if size(L_k,1) > 0
        L_k_1= L_k;
        L_result = L_k;
        L_result_count = L_k_count;
    else 
        % ����, ������
        if k == 2 % ��Ե�һ�־����������⴦��
            L_result = L_k_1;
            L_result_count = L_k_1_count;
        end
        break;
    end
    
end

% ********* ��ʾ��� **********
print_L(L_result, L_result_count, 0);

% ��ʾ֧�ֶ�,���Ŷ�
fprintf('\nMinimum Support: %.2f  (absolute support = %d)  \nMinimum Confidence: %.1f%%\n\n', min_sup, min_sup_abs, min_conf * 100);

% ���Ŷȴ���
% ����L_result�õ�ÿ��Ƶ���, �������ɷǿ��Ӽ�
fprintf('Rules:\n');
rules = {};
numOfRules = 1;
for i=1:size(L_result,1)
    % �洢�Ӽ�
    subset = {};
    % ��1��k-1���Ӽ�
    l = L_result(i,:);
    for j=1:length(l) - 1
        % �ҵ������Ӽ�, ����ȫ���Ž�subset����
        new_set = nchoosek(l, j);
        for k=1:size(new_set,1)
            subset = [subset new_set(k,:)];
        end
    end
    
    % ����subset, ����ÿһ���ǿ����Ӽ�s, �õ�s->(l-s)�Ĺ���
    for k=1:length(subset)
        s = subset{k};
        % r = l - s
        r = setdiff(l, s);
        
        % �������Ŷ�, conf = support_count(l) / support_count(s)
        % ��L_result_count���Ե�֪support_count(l)
        support_count_l = L_result_count(i);
        % ����support_count(l), ��ʵ������õķ���Ӧ�ô�����֮ǰ��Ƶ����
        % ��������
        support_count_s = 0;
        for m=1:size(D,1)
            d = D(m,:);
            % ��all()������, �ж��ǲ����Ӽ�
            if all(ismember(s,d))
                support_count_s = support_count_s + 1;
            end
        end
        conf = support_count_l / support_count_s;
        
        % ���ɹ�����ַ���
        s_str = strrep(num2str(s), '  ', ', ');
        r_str = strrep(num2str(r), '  ', ', ');
        rule_str = ['[', s_str, ']', ' -> ', '[', r_str, ']'];
        
        % ���뵽rules����
        rules{numOfRules, 1} = rule_str;
        rules{numOfRules, 2} = conf;
        numOfRules = numOfRules + 1;
    end
end

% ��rules��������
confs = rules(:,2);
[temp, ind] = sort(cell2mat(confs), 'descend');
rules_sorted = rules(ind,:);

% ɸѡ
confs_sorted = rules_sorted(:,2);
ind = find(cell2mat(confs_sorted) >= min_conf);
rules_sorted_filtered = rules_sorted(ind,:);

% ���
for i=1:size(rules_sorted_filtered, 1)
    rule_str = rules_sorted_filtered{i, 1};
    conf = rules_sorted_filtered{i, 2};
    fprintf('%s   %.1f%%\n', rule_str, conf * 100);
end

fprintf('\n');


