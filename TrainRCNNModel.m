% train the deep model of RCNN
clear all;
reset(gpuDevice());
% set up the parameters
Nfold4tr = 4;
NitersExterEpoch = 5;%8
NitersInterEpoch = 3;%5
lr = 1e-3;%1e-2

% -------------------------------------------------------------------------
%                                                    Network initialization
% -------------------------------------------------------------------------
net = rcnnInit();
% load('data\rcnn-dag-11_10_16_45.mat','netStruct');
% net = dagnn.DagNN.loadobj(netStruct);

% -------------------------------------------------------------------------
%                                                                   Trainig
% -------------------------------------------------------------------------
% search casme2 and replace with "samm" or "smic" for other two datasets
for k = 1:NitersExterEpoch
    for i = 1:Nfold4tr
        imdbPath = ['data\casme2_epoch_' num2str(i) '.mat'];
        imdb = [];
        if exist(imdbPath,'file') == 2
            fprintf('Loading imdb...\n');
            if exist(imdb,'var') == 1, clear imdb; end
            imdb = load(imdbPath) ; % input variable¡®imdb¡¯
            fprintf('The %d-th epoch begin...\n',i);
            net = rcnnTrain(net,imdb.data,imdb.labels,NitersInterEpoch,lr);
            fprintf('The %d-th epoch done...\n',i);
        else
            fprintf('Can''t find the %d-th fold data.\n',i); continue;
        end
    end
end
% % train a model for single time
% net = rcnnTrain(net,imdb.data,imdb.labels,Niters,lr);

%% save trained model    
currenttime = datevec(now);
timestamp = [ num2str(currenttime(2)) '_' num2str(currenttime(3)) '_' num2str(currenttime(4)) '_' num2str(currenttime(5))];
% net.move('cpu') ;
netStruct = net.saveobj();
save(['data\rcnn-dag-casme2-' timestamp '.mat'],'netStruct','-v7.3');
fprintf('The model has been saved.\n');