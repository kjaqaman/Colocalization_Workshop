function eigenvectors = spectral_layout(a_graph, dim, eigen_limit, round_limit)
%SPECTRAL_LAYOUT Given a graph compute the spectral embedding of the graph.
% This is simply the eigenvectors of the Laplacian of the graph. Here we
% use the normalized Laplacian.
%
% eigenvectors = SPECTRAL_LAYOUT(a_graph, dim)
%
% Parameters
% ----------
% a_graph: sparse matrix of size (n_samples, n_samples)
%     The (weighted) adjacency matrix of the graph as a sparse matrix.
% 
% dim: double
%     The dimension of the space into which to embed.
% 
% Returns
% -------
% eigenvectors: array of shape (n_samples, dim)
%     The spectral embedding of the graph.
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
        round_limit = 1e5;
    end

    n_samples = size(a_graph, 1);
    
    try
        n_components = max(conncomp(graph(a_graph)));

        if n_components > 1
              warning('The adjacency graph is not connected!');
        end

        degrees = full(sum(a_graph)');
        D_Neg_Half = spdiags(degrees.^(-1/2), 0, n_samples, n_samples);
        L = speye(n_samples) - D_Neg_Half * a_graph * D_Neg_Half;
        sL = (L + L')/2;
        k = dim+1;
        if n_samples<=eigen_limit|| ~exist('lobpcg.m', 'file')
            num_lanczos_vectors = floor(max(2*k + 1, sqrt(n_samples)));    
            opts.p = num_lanczos_vectors;
            opts.v0 = ones(n_samples, 1);
            opts.maxit = 5*n_samples;
            opts.tol = 1e-4;
            [eigenvectors,  ~] = eigs(sL, k, 'sm',opts);
        else
            null_eigenvector = sqrt(degrees);
            null_eigenvector = null_eigenvector/norm(null_eigenvector);
            init_guess = [null_eigenvector randn(n_samples, dim)];
            if n_samples >=round_limit
                sL = round(sL,6);
            end
            [eigenvectors,  ~] = lobpcg(init_guess, sL, 1e-4,5*n_samples);
        end

        eigenvectors = eigenvectors(:, 2:end);
        
    catch ex
        ex.getReport
        warning(['WARNING: spectral initialisation failed! The eigenvector solver '...
            'failed. This is likely due to too small an eigengap. Consider '...
            'adding some noise or jitter to your data. '...
            'Falling back to random initialisation!']);

        eigenvectors = -10 + 20*rand(n_samples, dim);
    end
end