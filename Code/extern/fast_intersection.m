function values = fast_intersection(rows, cols, values, target, unknown_dist, far_dist)
%FAST_INTERSECTION Under the assumption of categorical distance for the
% intersecting simplicial set perform a fast intersection.
% 
% values = FAST_INTERSECTION(rows, cols, values, target, unknown_dist, far_dist)
%
% Parameters
% ----------
% rows: array
%     An array of the row of each non-zero in the sparse matrix
%     representation.
% 
% cols: array
%     An array of the column of each non-zero in the sparse matrix
%     representation.
% 
% values: array
%     An array of the value of each non-zero in the sparse matrix
%     representation.
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
% values: array
%     The non-zero entries resulting from the intersection.
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

    if nargin < 6
        far_dist = 5;
        if nargin < 5
            unknown_dist = 1;
        end
    end
    
    row_labels = target(rows);
    col_labels = target(cols);
    
    unknown = row_labels == -1 | col_labels == -1;
    far = (row_labels ~= col_labels) & ~unknown;
    
    values(unknown) = values(unknown)*exp(-unknown_dist);
    values(far) = values(far)*exp(-far_dist);
            
    end