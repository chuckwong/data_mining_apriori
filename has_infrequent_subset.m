% c���Ӽ��Ƿ���L����
function flag = has_infrequent_subset(c, L)

% c��n-�Ӽ�
subset = nchoosek(c, size(L,2));

flag = 1;
for i=1:size(subset,2)
    if ~ismember(subset(i,:), L, 'rows')
        flag = 0;
        break;
    end
end

end