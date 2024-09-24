function elimIdxs = ln_freq_var(labels,mean)
%LN_FREQ_VAR Given a set of class labels and a desired mean, multiply the
% incidence of each class label by a frequency sampled from a random
% variable with a log-normal distribution and the given mean (frequency
% capped at 1).
%
% elimIdxs = ln_freq_var(labels,mean)
%
% Parameters
% ----------
% labels: integer vector
%     A set of class labels
%
% mean: double (optional, default 0.5)
%     The mean of the variable with log-normal distribution that determines
%     the frequency of each class
%
% Returns
% -------
% elimIdxs: logical vector, same size as "labels"
%     A logical array indicating the indices of the labels to be
%     eliminated.
%
%   AUTHORSHIP
%   Math Lead & Primary Developer:  Connor Meehan <connor.gw.meehan@gmail.com>
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

if nargin < 2
    normMean = -log(2)-1/2; %lognrnd(normMean, 1) has mean 1/2.
else
    normMean = log(mean)-1/2; %lognrnd(normMean, 1) has mean "mean".
end

subsetIds=unique(labels);
nIds = length(subsetIds);
elimIdxs=false(size(labels));

for i = 1:nIds
    id = subsetIds(i);
    
    freq = min(lognrnd(normMean, 1), 1);
    idxs= labels==id;
    nIdxs=nnz(idxs);
    nEliminating=floor((1-freq)*nIdxs);
    if nEliminating > 0
        elimIdxs(find(idxs,nEliminating))=true;
    end
end
end

