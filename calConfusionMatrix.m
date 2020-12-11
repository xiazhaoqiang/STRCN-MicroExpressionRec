function confMatrix = calConfusionMatrix(tarData,gtData,totalElements)
%CALCONFUSIONMATRIX calculate the confusion matrix

% tarElements = unique(tarData);
% gtElements = unique(gtData);
% totalElements = union(tarElements,gtElements);
N = numel(totalElements);
confMatrix = zeros(N,N);
for i = 1:N
    idx1 = find(gtData == totalElements(i));
    if isempty(idx1), continue; end
    for j = 1:N
        idx2 = find(tarData(idx1) == totalElements(j));
        if isempty(idx2), continue; end
        confMatrix(i,j) = numel(idx2)/numel(idx1);
    end
end

end