function M=divide_sparse(M, by)
%DIVIDE_SPARSE Divide each row in the sparse matrix M by the number in the
% corresponding row of "by". In practice, this is much faster for large
% arrays than using normal MATLAB syntax.
%
% M = DIVIDE_SPARSE(M, by)
%
% Parameters
% ----------
% M: sparse matrix of size (m1, m2)
% 
% by: array of size (m1, 1)
% 
% Returns
% -------
% M: sparse matrix of size (m1, m2)
%     The result of diving the (i, j)-th entry of M by the i-th component of
%     "by".
%
%   AUTHORSHIP
%   Primary Developer: Stephen Meehan <swmeehan@stanford.edu>
%   Math Lead & Secondary Developer:  Connor Meehan <connor.gw.meehan@gmail.com>
%   Bioinformatics Lead:  Wayne Moore <wmoore@stanford.edu>
%   Provided by the Herzenberg Lab at Stanford University 
%   License: BSD 3 clause
%
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

[rows, cols]=find(M);
R=size(rows);

for r=1:R
    M(rows(r), cols(r))=M(rows(r), cols(r))/by(rows(r));
end

end