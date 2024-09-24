function [pValueComp,sigOrNot,colocDataNorm,colocNullTRNorm] = compColocNorm(colocData,colocNullTR,alphaValue,plotFlag)
%COMPCOLOCNORM compares colocalization extent between different datasets after normalizing to get equivalent NullTR for all datasets
%
%SYNOPSIS [pValueComp,sigOrNot,colocDataNorm,colocNullTRNorm] = compColocNorm(colocData,colocNullTR,alphaValue,plotFlag)
%
%INPUT
%
%colocData      : Cell array with n rows, 1 for each dataset to be
%                 compared. Each cell contains a column vector of the data
%                 colocalization values for one dataset. This would be the
%                 compiled dataset of multiple experiments, as obtained for
%                 example by running the function plotSaveColocResults or
%                 plotSaveConditionalColoc.
%colocNullTR    : Cell array with n rows, 1 for each dataset to be
%                 compared. Each cell contains a column vector of the
%                 NullTR colocalization values for one dataset. This would
%                 be the compiled dataset of multiple experiments, as
%                 obtained for example by running the function
%                 plotSaveColocResults or plotSaveConditionalColoc.
%alphaValue     : Alpha-value to assess significance. Note that this is
%                 done after correcting for multiple tests.
%                 Optional. Default: 0.05.
%plotFlag       : 1/0 flag indicating whether to plot normalized
%                 colocalization values or not. 
%                 Optional. Default: 0.
%
%OUTPUT
%
%pValueComp     : nxn matrix of comparison p-values. Only the top triangle
%                 will be populated.
%sigOrNot       : nxn matrix of significant (1 = significantly different,
%                 0 = not significantly different). Significance is
%                 assessed after correcting the input alphaValue for
%                 multiple tests.
%colocDataNorm  : Same as input colocData, but normalized.
%colocNullTRNorm: Same as input colocNullTR, but normalized.
%
%Khuloud Jaqaman, 2024-09-04
%
% Copyright (C) 2024, Jaqaman Lab - UTSouthwestern 
%
% This file is part of ColocalizationAnalysis_Package.
% 
% ColocalizationAnalysis_Package is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% ColocalizationAnalysis_Package is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with ColocalizationAnalysis_Package.  If not, see <http://www.gnu.org/licenses/>.
% 
% 


%% Input

if nargin < 3 || isempty(alphaValue)
    alphaValue = 0.05;
end

if nargin < 4 || isempty(plotFlag)
    plotFlag = 0;
end

%number of datasets to be compared
nDatasets = length(colocData);

%make sure that colocData and colocNullTR have same number of entries
if length(colocNullTR) ~= nDatasets
    error('colocData and colocNullTR must have same number of entries.')
end

%make sure that the colocData and colocNullTR of each dataset have the same
%length
numCellsData = cellfun(@length,colocData);
numCellsNullTR = cellfun(@length,colocNullTR);
numCellsDiff = abs(numCellsData - numCellsNullTR);
if any(numCellsDiff ~= 0)
    error('Make sure that each entry in colocData and its corresponding entry in colocNullTR have same number of datapoints');
end

%adjust alpha-value for multiple tests (Dunn-Sidak correction)
alphaCorrected = 1 - (1-alphaValue)^(1/nDatasets);

%% Normalization of colocalization values

%median of each dataset NullTR
medNullTR = cellfun(@nanmedian,colocNullTR);

%smallest median
medNullTRMin = min(medNullTR);

%calculate normalization factor for each dataset using smallest median as reference
%smallest median keeps normalized colocalization probabilities < 1
normFactor = medNullTRMin ./ medNullTR;

%calculate normalized colocData and colocNullTR
colocDataNorm = colocData;
colocNullTRNorm = colocNullTR;
for i = 1 : nDatasets
    colocDataNorm{i} = colocData{i} * normFactor(i);
    colocNullTRNorm{i} = colocNullTR{i} * normFactor(i);
end

%% Hypothesis testing

%ranksum test to get p-value
pValueComp = NaN(nDatasets);
for i = 1 : nDatasets-1
    for j = i+1 : nDatasets
        pValueComp(i,j) = ranksum(colocDataNorm{i},colocDataNorm{j});
    end
end

%significance
sigOrNot = pValueComp <= alphaCorrected;

%% Plotting

if plotFlag
    
    %collect all data into matrix
    [data4Plot,groupVal] = deal(NaN(max(numCellsData),nDatasets*3));
    for i = 1 : nDatasets
        data4Plot(1:numCellsData(i),3*i-2) = colocDataNorm{i};
        data4Plot(1:numCellsData(i),3*i-1) = colocNullTRNorm{i};
    end
    for i = 1: 3*nDatasets
        groupVal(:,i) = i;
    end
    
    %boxplots
    figure, hold on
    boxplot(data4Plot(:),groupVal(:),'notch','on',...
        'color',repmat([0 0 1;0 0 0;0 0 0],nDatasets,1),'Width',0.8,...
        'OutlierSize',10,'Symbol','mo');
    
    %individual data points
    tmp1 = groupVal(:,1:3:end);
    tmp2 = data4Plot(:,1:3:end);
    plot(tmp1(:),tmp2(:),'bo')
    tmp1 = groupVal(:,2:3:end);
    tmp2 = data4Plot(:,2:3:end);
    plot(tmp1(:),tmp2(:),'ko')
    
    ylabel('Coloc extent (standardized by min NullTR)')
    
end
