function simplicial_set = reset_local_connectivity(simplicial_set)
%RESET_LOCAL_CONNECTIVITY Reset the local connectivity requirement -- each
% data sample should have complete confidence in at least one 1-simplex in
% the simplicial set. We can enforce this by locally rescaling confidences,
% and then remerging the different local simplicial sets together.
% 
% simplicial_set = RESET_LOCAL_CONNECTIVITY(simplicial_set)
%
% Parameters
% ----------
% simplicial_set: sparse matrix
%     The simplicial set for which to recalculate with respect to local
%     connectivity.
% 
% Returns
% -------
% simplicial_set: sparse matrix
%     The recalculated simplicial set, now with the local connectivity
%     assumption restored.
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
    
    n_cols = size(simplicial_set, 2);

    divisor = max(simplicial_set,[],2);
    if ~issparse(simplicial_set)
        simplicial_set = simplicial_set./repmat(divisor, [1 n_cols]);
    else
        simplicial_set = divide_sparse(simplicial_set, divisor);
    end

    transpose = simplicial_set';
    prod_matrix = simplicial_set.*transpose;
    simplicial_set = simplicial_set + transpose - prod_matrix;