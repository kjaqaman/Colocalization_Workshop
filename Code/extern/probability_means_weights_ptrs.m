%
%   AUTHORSHIP
%
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
function bins=probability_means_weights_ptrs(data)
% DEPRECATED .... use util/SuhProbabilityBins(data)

MIN_BINS=8192;
MIN_EVENTS_PER_BIN=4;
MAX_EVENTS_PER_BIN=34;
N=size(data, 1);
events_per_bin=floor(2*log(N));
number_of_bins=floor(N/events_per_bin);
if number_of_bins<MIN_BINS
    events_per_bin=floor(N/MIN_BINS);
end
if events_per_bin<MIN_EVENTS_PER_BIN
    events_per_bin=MIN_EVENTS_PER_BIN;
elseif events_per_bin>MAX_EVENTS_PER_BIN
    events_per_bin=MAX_EVENTS_PER_BIN;
end
if number_of_bins>2^14 %16384
    events_per_bin=MAX_EVENTS_PER_BIN;
end
[bins.means, bins.ptrs, ~, bins.weights]=...
    probability_bin(data, data, events_per_bin, false);

end