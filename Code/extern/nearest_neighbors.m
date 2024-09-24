function [knn_indices, knn_dists] = nearest_neighbors(X, knnsearch_args)
%NEAREST_NEIGHBORS Compute the "n_neighbors" nearest points for each data
% point in "X" under "metric". Currently, in most cases, this simply
% involves calling the MATLAB function knnsearch.m on the data.
%
% [knn_indices, knn_dists] = NEAREST_NEIGHBORS(X, n_neighbors, metric)
%
% Input arguments
% ---------------
% X: array of size (n_samples, n_features)
%     The input data of which to compute the k-neighbor graph.
% knnsearch_args: struct or object containing name-value pair arguments 
%   required by MATLAB knnsearch. 
%
% Output arguments
% ----------------
% knn_indices: array of size (n_samples, n_neighbors)
%     The indices on the "n_neighbors" closest points in the dataset.
% 
% knn_dists: array of size (n_samples, n_neighbors)
%     The distances to the "n_neighbors" closest points in the dataset.
%
%   AUTHORSHIP
%   Math Lead & Primary Developer:  Connor Meehan <connor.gw.meehan@gmail.com>
%   Secondary Developer: Stephen Meehan <swmeehan@stanford.edu>
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

try
    metric=knnsearch_args.metric;
catch
    metric=knnsearch_args.Distance;
end
try
    n_neighbors=knnsearch_args.n_neighbors;
catch
    n_neighbors=knnsearch_args.K;
end
    if strcmpi(metric, 'precomputed')
        [knn_dists, knn_indices] = sort(X,2);
        knn_indices = knn_indices(:, 1:n_neighbors);
        knn_dists = knn_dists(:, 1:n_neighbors);
    else
        if isa(metric, 'function_handle')  
            [knn_indices, knn_dists] = knnsearch(X,X, ...
                'K', n_neighbors, 'Distance', metric);
        else
            if ~ismember(metric, ['euclidean', 'cityblock', 'seuclidean',...
                    'chebychev', 'minkowski', 'mahalanobis', 'cosine',...
                    'correlation', 'hamming', 'jaccard', 'mahalanobis'])
                error('Metric is neither callable, nor a recognised string');
            end
            
            if issparse(X)
                warning(['knnsearch.m runs much faster on full matrices. '...
                    'Converting data to full matrix!']);
                X = full(X);
            end
            [knn_indices, knn_dists]=KnnFind.Determine(X,X,knnsearch_args);
        end
        if any(knn_indices < 0)
            warning(['Failed to correctly find n_neighbors for some samples. '...
                'Results may be less than ideal. Try re-running with different parameters.']);
        end
    end
end