function imgTensor = dataaug(imgMatrix,targCols)
%DATAAUG performs the data augmentation

rsmethods = {'nearest','bilinear','bicubic','box','triangle','cubic','lanczos2','lanczos3'};
[rows,cols] = size(imgMatrix);
numM = length(rsmethods);
imgTensor = [];

for ratio = 0:0.05:0.55
    rmN = ceil(cols*ratio);
    resMatrix = [];
    if rmN > 0
        indperm = randperm(cols);
        indrm = indperm(rmN);
        indres = setdiff(1:cols,indrm);
        resMatrix = imgMatrix(:,indres);
    else
        resMatrix = imgMatrix;
    end
    for j = 1:numM
        imgTensor = cat(3,imgTensor,imresize(resMatrix,[rows targCols],rsmethods{j}));
    end
end

end