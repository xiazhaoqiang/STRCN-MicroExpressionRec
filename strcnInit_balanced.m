function net = strcnInit_balanced( varargin )
%STRCNNINIT_BALANCED initialize the spatiotemporal deep net based on optical flow
%fields for cross-database micro-expression recognition.

% Copyright (C) 2018 Zhaoqiang Xia.
% All rights reserved.

if nargin < 1
    meta.imageSize = [300 245];
else % nargin == 1
    meta.imageSize = varargin{1};
end

opts.classNames = {'positive','negative','surprise','others'} ;
opts.classDescriptions = {'positive','negative','surprise','others'}  ;
opts.colorDeviation = zeros(3) ;
opts.cudnnWorkspaceLimit = 1024*1024*1204*2 ; % 2-GB
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% parameters need to be setup
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
opts.lr = 0.001;
opts.maps = 512; % 128, 256, 512
opts.layerDepth = 3; % 3
opts.batchSize = 10; % 20

opts = vl_argparse(opts,cell(0)) ;
%
net = dagnn.DagNN();
%
lastAdded.var = 'input' ;
lastAdded.depth = 2 ;

    function Conv(name, ksize, depth, varargin)
        % Helper function to add a Convolutional + BatchNorm + ReLU
        % sequence to the network.
        args.relu = true ;
        args.downsample = false ;
        args.bias = false ;
        args = vl_argparse(args, varargin) ;
        if args.downsample, stride = 2 ; else stride = 1 ; end
        if args.bias, pars = {[name '_f'], [name '_b']} ; else pars = {[name '_f']} ; end
        net.addLayer([name  '_conv'], ...
            dagnn.Conv('size', [ksize ksize lastAdded.depth depth], ...
            'stride', stride, ....
            'pad', (ksize - 1) / 2, ... % 0
            'hasBias', args.bias, ...
            'opts', {'cudnnworkspacelimit', opts.cudnnWorkspaceLimit}), ...
            lastAdded.var, ...
            [name '_conv'], ...
            pars) ;
        net.addLayer([name '_bn'], ...
            dagnn.BatchNorm('numChannels', depth, 'epsilon', 1e-5), ...
            [name '_conv'], ...
            [name '_bn'], ...
            {[name '_bn_w'], [name '_bn_b'], [name '_bn_m']}) ;
        lastAdded.depth = depth ;
        lastAdded.var = [name '_bn'] ;
        if args.relu
            net.addLayer([name '_relu'] , ...
                dagnn.ReLU(), ...
                lastAdded.var, ...
                [name '_relu']) ;
            lastAdded.var = [name '_relu'] ;
        end
    end

% -------------------------------------------------------------------------
% Add input section
% -------------------------------------------------------------------------
Conv('conv1', 3, opts.maps, ...
    'relu', true, ...
    'bias', false, ...
    'downsample', false) ;

net.addLayer(...
    'conv1_pool' , ...
    dagnn.Pooling('poolSize', [4 4], ...
    'stride', [4 4], ...
    'pad', 0,  ...
    'method', 'max'), ...
    lastAdded.var, ...
    'conv1') ;
lastAdded.var = 'conv1' ;
meta.globalPoolSize = floor(meta.imageSize./[4 4]);

% -------------------------------------------------------------------------
% Add intermediate sections
% -------------------------------------------------------------------------
for s = 2:4
    % sectionLen represents the depth of recurrent connections
    switch s
        case 2, sectionLen = opts.layerDepth ; poolS = [4 4] ;
        case 3, sectionLen = opts.layerDepth ; poolS = [2 2] ;
        case 4, sectionLen = opts.layerDepth ; poolS = [2 2] ;
%         case 5, sectionLen = opts.layerDepth ; poolS = [1 1] ;
    end
    
    % -----------------------------------------------------------------------
    % Add intermediate segments for each section
    sectionInput = lastAdded ;
    for l = 1:sectionLen
        name = sprintf('rconv%d_%d', s, l)  ;
        %lastAdded = sectionInput ;
        if l == 1,Conv(name, 1, opts.maps) ;
        else Conv(name, 3, opts.maps) ; end
        if(l == sectionLen), break;end
        % Sum layer
        sumInput.var{1} = lastAdded.var;
        sumInput.var{2} = sectionInput.var;
        net.addLayer([name '_sum'] , ...
            dagnn.Sum(), ...
            sumInput.var, ...
            [name '_sum']) ;
        lastAdded.var = [name '_sum'] ;
    end
    % Pooling layer
    name = sprintf('rconv%d', s) ;
    net.addLayer(...
        [name '_pool'] , ...
        dagnn.Pooling('poolSize', poolS, ...
        'stride', poolS, ...
        'pad', 0,  ...
        'method', 'max'), ...
        lastAdded.var, ...
        name) ;
    lastAdded.var = name ;
    meta.globalPoolSize = floor(meta.globalPoolSize./poolS);
end

net.addLayer('prediction_avg' , ...
    dagnn.Pooling('poolSize', meta.globalPoolSize, 'method', 'avg'), ...
    lastAdded.var, ...
    'prediction_avg') ;

net.addLayer('prediction' , ...
    dagnn.Conv('size', [1 1 opts.maps 4]), ...
    'prediction_avg', ...
    'prediction', ...
    {'prediction_f', 'prediction_b'}) ;

% net.addLayer('loss', ...
%     dagnn.Loss('loss', 'softmaxlog') ,...
%     {'prediction', 'label'}, ...
%     'objective') ;

net.addLayer('loss', ...
    dagnn.LossFL('loss', 'focalloss') ,...
    {'prediction', 'label'}, ...
    'objective') ;
% -------------------------------------------------------------------------
%                                                           Meta parameters
% -------------------------------------------------------------------------
net.meta.normalization.imageSize = meta.imageSize ;
net.meta.inputSize = [net.meta.normalization.imageSize, opts.batchSize] ;
net.meta.normalization.cropSize = net.meta.normalization.imageSize(1) / opts.maps ;
% net.meta.normalization.averageImage = meta.averageImage ;

net.meta.classes.name = opts.classNames ;
net.meta.classes.description = opts.classDescriptions ;

net.meta.augmentation.jitterLocation = false ;
net.meta.augmentation.jitterFlip = false ;
net.meta.augmentation.jitterBrightness = double(0.1 * opts.colorDeviation) ;
% net.meta.augmentation.jitterAspect = [3/4, 4/3] ;
% net.meta.augmentation.jitterScale  = [0.4, 1.1] ;
% net.meta.augmentation.jitterSaturation = 0.4 ;
% net.meta.augmentation.jitterContrast = 0.4 ;

net.meta.inputSize = {'input', [net.meta.normalization.imageSize opts.batchSize]} ;

% lr = logspace(-1, -3, 60) ;
% lr = [0.1 * ones(1,30), 0.01*ones(1,30), 0.001*ones(1,30)] ;
net.meta.trainOpts.learningRate = opts.lr ;
net.meta.trainOpts.momentum = 0.9 ;
net.meta.trainOpts.batchSize = opts.batchSize ;
net.meta.trainOpts.numSubBatches = 0 ;
net.meta.trainOpts.weightDecay = 0.0001 ;

% initilize parameters randomly
net.initParams() ;

p = net.getParamIndex('conv1_f') ;
net.params(p).value = net.params(p).value / 100 ;
net.params(p).learningRate = net.params(p).learningRate / 100^2 ;

for l = 1:numel(net.layers)
    if isa(net.layers(l).block, 'dagnn.BatchNorm')
        k = net.getParamIndex(net.layers(l).params{3}) ;
        net.params(k).learningRate = 0.3 ;
    end
end

end

