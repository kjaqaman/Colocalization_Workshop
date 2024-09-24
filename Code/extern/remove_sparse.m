function M=remove_sparse(M, op)
%REMOVE_SPARSE Set to zero the entries of M for which op(M) = 1.
%
% M = REMOVE_SPARSE(M, op)
%
% Parameters
% ----------
% M: sparse matrix of size (m1, m2)
% 
% op: a function accepting doubles as input and outputting a boolean.
% 
% Returns
% -------
% M: sparse matrix of size (m1, m2)
%     The result of setting to zero the entries of M for which op(M) = 1.
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

idxs=find(M);
logicalIdxs=feval(op, M(idxs));
removeIdxs=idxs(logicalIdxs);
M(removeIdxs)=0;
end