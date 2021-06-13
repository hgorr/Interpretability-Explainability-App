function [ytickidx, ylabels, valEta] = localEffectsOverloaded(mdl, x, varargin)
[varargin{:}] = convertStringsToChars(varargin{:});
% Categorical Predictors
catpred = mdl.DataSummary.CategoricalPredictors;

% Call the function from CompactGAMImpl package
[ytickidx, ylabels, valEta] = plotLocalEffects(...
    mdl.Impl,...
    x,...
    catpred,...
    mdl.VariableRange,...
    mdl.TableInput,...
    mdl.PredictorNames,...
    varargin{:});
end

function [ytickidx, ylabels, valEta] = plotLocalEffects(mdl,x,catpred,vrange,isTbl,PredictorNames,varargin)
%PLOTLOCALEFFECTS plot local effects.
%   BAR = PLOTLOCALEFFECTS(MODEL,X) plots the local effects of the
%   predictor variable values of a single observation X on the
%   fitted classification or regression GAM model MODEL.

% Total Number of Effects
[T,D] = size(mdl.TreesPerPredictor);
K = size(mdl.TreesPerInteraction,2);

% Parse IncludeInteractions/IncludeIntercept
% Default for include interactions
if isempty(mdl.TreesPerInteraction)
    defaultui = false;
else
    defaultui = true;
end

% Note: Default for IncludeIntercept = false.
args = {'IncludeInteractions', 'IncludeIntercept'};
defs = {            defaultui               false};
[incinteractions,incintercept,~,extraArgs] = internal.stats.parseArgs(args,defs,varargin{:});

% Validate optional parameter values for GAM
internal.stats.parseOnOff(incinteractions,'IncludeInteractions');
internal.stats.parseOnOff(incintercept,'IncludeIntercept');

if ((incinteractions) && isempty(mdl.TreesPerInteraction))
    error(message('stats:classreg:learning:impl:CompactGAMImpl:parseIncludeArgs:BadIncludeInteractions'))
end

if incinteractions
    tolEffects = K + D;
else
    tolEffects = D;
end

% Default for NumTerms
defnumterms = min(tolEffects,10);

% Parse Other NameValue Pairs
args = {'NumTerms'    'usepredictors'};
defs = { defnumterms            'all'};

[numterms,usepred] = internal.stats.parseArgs(args,defs,extraArgs{:});

isok = classreg.learning.modelparams.GAMParams.isNumericRealScalarNoNaNInf(numterms,1);
isok = isok && ~(numterms<1) && ~(numterms>tolEffects);
if ~isok
    error(message('stats:classreg:learning:impl:CompactGAMImpl:plotLocalEffects:BadNumTerms',tolEffects))
end

% Check UsePredictors (Internal NVP)
if ~isempty(usepred)
    [isok,usepred] = classreg.learning.impl.CompactGAMImpl.validateNumericLogicalOrCharVector(usepred,D,'UsePredictors');
    if ~isok
        error(message('stats:classreg:learning:impl:CompactGAMImpl:plotLocalEffects:BadUsePredictors'))
    end
end

% Categorical indexes
iscat = false(D,1);
iscat(catpred) = true;

% Prepare Data
if isTbl || istable(x)
    x = classreg.learning.internal.table2PredictMatrix(x,[],[],...
        vrange,catpred,PredictorNames);
end

% Get required properties
learnRates1d = mdl.LearnRatesPredictorTrees;
learnRates2d = mdl.LearnRatesInteractionTrees;
pairs = mdl.Interactions';
intercept  = mdl.PrivInterceptPredictorTrees;

eta = zeros(1,tolEffects,'like',mdl.Intercept);
numLabels    = numel(eta);
plotidx      = 1:numLabels;
tickLabels   = cell(1,numLabels);
prednames    = PredictorNames(usepred);
tickLabels(1:numel(usepred)) = prednames;

% 1D
for j=1:numel(usepred)
    d = usepred(j);
    trees = mdl.TreesPerPredictor(:,d);
    
    catpred = [];
    if iscat(d)
        catpred = 1;
    end
    
    for t=1:T
        if ~isempty(trees{t})
            node = findNode(trees{t},x(d),catpred,0,false);
            eta(j) = eta(j) + learnRates1d(t)*trees{t}.NodeMean(node);
        end
    end
end

% 2D
if incinteractions
    intercept  = mdl.Intercept;
    [T,~] = size(mdl.TreesPerInteraction);
    for k =1 :K
        idx = pairs(:,k);
        z = x(idx);
        trees = mdl.TreesPerInteraction(:,k);
        catpred = find(iscat(idx));
        ij = numel(usepred) + k;
        
        tf = ismember(idx,usepred);
        if all(~tf)
            continue
        end
        if any(~tf)
            z(:,~tf) = NaN;
        end
        
        tmp = PredictorNames(idx);
        tickLabels{ij} = strjoin(tmp,' - ');
        
        for t=1:T
            if ~isempty(trees{t})
                node = findNode(trees{t},z,catpred,0,false);
                eta(ij) = eta(ij) + learnRates2d(t)*trees{t}.NodeMean(node);
            end
        end
    end
end

% Create Plot
validx = numterms:-1:1;
[~,newidx] = sort(abs(eta),'descend');
kEtas = eta(newidx(validx));

if incintercept
    bintercept    = intercept;
    ytickidx      = [plotidx(1:numterms) plotidx(numterms)+1];
    ylabels       = [tickLabels(newidx(validx)) "Intercept"];
else
    bintercept = [];
    ytickidx   = plotidx(1:numterms);
    ylabels    = tickLabels(newidx(validx));
end

valEta = [kEtas bintercept];
end
