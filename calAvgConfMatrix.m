function confMatrixM = calAvgConfMatrix(confMatrixT)

[rows,cols,deps] = size(confMatrixT);
confMatrixM = zeros(rows,cols);
for i = 1:rows
    for j = 1:cols
        confMatrixM(i,j) = mean(confMatrixT(i,j,confMatrixT(i,j,:)~= 0));
    end
end

end