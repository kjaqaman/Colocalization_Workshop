function embedding=spectral_layout_binned(data, init, limit, ...
    n_components, eigen_limit)
%SPECTRAL_LAYOUT_BINNED Given a large set of data, bin the samples into
% 8192 bins, then compute the adjacency graph of the bin means according to
% UMAP defaults. Then compute the spectral embedding as in
% spectral_layout.m. If the graph is not sufficiently large, this returns
% an empty array.
%
% embedding = SPECTRAL_LAYOUT_BINNED(data, init, limit)
%
% Parameters
% ----------
% data: array of shape (n_samples, n_features)
%     The source data
% 
% init: char array
%     How to initialize the low dimensional embedding.
% 
% limit: double
%     If there are fewer than "limit" data points, return an empty array.
% 
% Returns
% -------
% embedding: array of shape (8192, dim)
%     The spectral embedding of the binned data points.
%
% See also: SPECTRAL_LAYOUT
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

embedding=[];
if ~strcmp(init, UMAP.INIT_EIGEN) && limit>=0
    sz=size(data,1);
    needLobpcg=sz>eigen_limit && ~exist('lobpcg.m', 'file');
    if sz>limit || needLobpcg
        probability_bins=probability_means_weights_ptrs(data);
        umap=UMAP('n_components', n_components);
        umap.init=UMAP.INIT_EIGEN;
        try
            umap.fit_transform(probability_bins.means);
            embedding=umap.embedding(probability_bins.ptrs, :);
            if needLobpcg
                showMsg(Html.WrapHr([...
                    'Larger samples are faster with lobpcg.m.<br>Download it from ' ...
                    'MathWorks File Exchange<br><br>Google "<b>MATLAB LOBPCG</b>"']), ...
                    'MathWorks File Exchange', 'north east+', false, false, 22);
            end
        catch ex
            ex.getReport
        end
    end
end
end