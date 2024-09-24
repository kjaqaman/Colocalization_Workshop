function simplicial_set = categorical_simplicial_set_intersection(simplicial_set, target, unknown_dist, far_dist)
%CATEGORICAL_SIMPLICIAL_SET_INTERSECTION Combine a fuzzy simplicial set
% with another fuzzy simplicial set generated from categorical data using
% categorical distances. The target data is assumed to be categorical label
% data (a vector of labels), and this will update the fuzzy simplicial set
% to respect that label data.
%
% simplicial_set = CATEGORICAL_SIMPLICIAL_SET_INTERSECTION(simplicial_set, target, unknown_dist, far_dist)
% 
% Parameters
% ----------
% simplicial_set: sparse matrix
%     The input fuzzy simplicial set.
% 
% target: array of shape (n_samples, 1)
%     The categorical labels to use in the intersection.
% 
% unknown_dist: double (optional, default 1)
%     The distance an unknown label (-1) is assumed to be from any point.
% 
% far_dist: double (optional, default 5)
%     The distance between unmatched labels.
% 
% Returns
% -------
% simplicial_set: sparse matrix
%     The resulting intersected fuzzy simplicial set.
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
    
    if nargin < 4
        far_dist = 5;
        if nargin < 3
            unknown_dist = 1;
        end
    end
    
    [n_rows, n_cols] = size(simplicial_set);
    
    simplicial_set = sparse(simplicial_set);
    [row,col,data] = find(simplicial_set);

    values = fast_intersection(row, col, data, target, unknown_dist, far_dist);
    
    simplicial_set = sparse(row, col, values, n_rows, n_cols);
    
    simplicial_set = reset_local_connectivity(simplicial_set);
    
    
    