%   AUTHORSHIP
%   Primary Developer: Stephen Meehan <swmeehan@stanford.edu> 
%   Math Lead & Secondary Developer:  Connor Meehan <connor.gw.meehan@gmail.com>
%   Bioinformatics Lead:  Wayne Moore <wmoore@stanford.edu>
%   Provided by the Herzenberg Lab at Stanford University 
%   License: BSD 3 clause
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

function [cnt, unsupervisedIdxs]=detectUnsupervised(umap, inData, ...
    sduLimit, parameterLimit)
supervisors=umap.supervisors;
subsetIds=unique(supervisors.labels);
subsetIds=subsetIds(subsetIds>0);
nSubsets=length(subsetIds);

a=zeros(nSubsets, size(inData,1));
for i=1:nSubsets
    r=umap.raw_data(supervisors.labels==subsetIds(i),:);
    means_=mean(r);
    stds_=std(r);
    B=(abs(inData-means_(1,:)))./stds_(1,:);
    a(i,:)=(sum(B>sduLimit, 2)>parameterLimit)';
end
S=sum(a);
unsupervisedIdxs=S==nSubsets;
cnt=sum(unsupervisedIdxs);
end
        