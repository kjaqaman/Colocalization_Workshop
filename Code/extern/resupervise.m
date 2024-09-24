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

function [lbls, lblMap]=resupervise(umap, inData, newSubsetIdxs)
supervisors=umap.supervisors;
R=size(inData, 1);
subsetIds=unique(supervisors.labels);
subsetIds=subsetIds(subsetIds~=0);
mx=max(subsetIds)+1;
nSubsets=length(subsetIds);
a=zeros(nSubsets, R);
lblMap=java.util.TreeMap;
key=num2str(mx);
lblMap.put(java.lang.String(key), 'Previously unsupervised');
key=[key '.color'];
perc=.4;
clr=num2str([perc perc perc]);
lblMap.put(key, clr);
for i=1:nSubsets
    gid=subsetIds(i);
    updateMap(gid)
    r=umap.raw_data(supervisors.labels==gid,:);
    means_=mean(r);
    stds_=std(r);
    B=(abs(inData-means_(1,:)))./stds_(1,:);
    a(i,:)=sum(B,2);
end
lbls=zeros(R, 1);
[~, I]=min(a);
%lbls(unknownIdxs)=0;%mx;%0-subsetIds(I(unknownIdxs));
lbls(~newSubsetIdxs)=subsetIds(I(~newSubsetIdxs));
lbls(newSubsetIdxs)=mx;
disp([unique(lbls)'; LabelBasics.DiscreteCount(lbls, unique(lbls))]);
disp([unique(supervisors.labels)'; LabelBasics.DiscreteCount(supervisors.labels, unique(supervisors.labels))]);

    function updateMap(gid)
        key=num2str(gid);
        jKey=java.lang.String(key);
        name=supervisors.labelMap.get(jKey);
        lblMap.put(jKey, name);
        key=[key '.color'];
        lblMap.put(key, supervisors.labelMap.get(key));
        
    end
end