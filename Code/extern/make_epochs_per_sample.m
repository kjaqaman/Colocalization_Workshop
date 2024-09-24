function result = make_epochs_per_sample(weights)
%MAKE_EPOCHS_PER_SAMPLE Given a set of weights generate the number of
% epochs per sample for each weight.
%
% result = MAKE_EPOCHS_PER_SAMPLE(weights)
%
% Parameters
% ----------
% weights: array of size (n_1_simplices, 1)
%     The weights of how much we wish to sample each 1-simplex.
%
% Note that the total number of epochs does not impact this result.
% 
% Returns
% -------
% result: array of size (n_1_simplices, 1)
%     The number of epochs per sample, one for each 1-simplex.
%
%   AUTHORSHIP
%   Math Lead & Primary Developer:  Connor Meehan <connor.gw.meehan@gmail.com>
%   Secondary Developer: Stephen Meehan <swmeehan@stanford.edu>
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

result = -1*ones(size(weights, 1), 1);
L = weights > 0;
result(L) = max(weights)*ones(sum(L), 1)./weights(L);