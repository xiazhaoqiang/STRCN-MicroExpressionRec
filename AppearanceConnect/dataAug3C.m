function imgTensor = dataaug3c(imgMatrix,targCols,varargin)
%DATAAUG performs the data augmentation

if isempty(varargin), issampling = true; else issampling = varargin{1};end

rsmethods = {'nearest','bilinear','bicubic','box','triangle','cubic','lanczos2','lanczos3'};
rows = size(imgMatrix,1);
cols = size(imgMatrix,2);
numM = numel(rsmethods);
imgTensor = [];

if(issampling), sr = 0:0.05:0.55; else sr = 0; end

for ratio = sr
    rmN = ceil(cols*ratio);
    resMatrix = [];
    if rmN > 0
        indperm = randperm(cols);
        indrm = indperm(rmN);
        indres = setdiff(1:cols,indrm);
        resMatrix = imgMatrix(:,indres,:);
    else
        resMatrix = imgMatrix;
    end
    for j = 1:numM
        imgTensor = cat(4,imgTensor,imresize(resMatrix,[rows targCols],rsmethods{j}));
    end
end

end