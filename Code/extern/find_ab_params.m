function [a,b] = find_ab_params(spread, min_dist)
%FIND_AB_PARAMS Fit a and b parameters for the differentiable curve used in
% lower dimensional fuzzy simplicial complex construction. We want the
% smooth curve (from a pre-defined family with simple gradient) that best
% matches an offset exponential decay.
%
% [a,b] = FIND_AB_PARAMS(spread, min_dist)
%
% Parameters
% ----------
% spread: double
%     The effective scale of embedded points.
%
% min_dist: double
%     The effective minimum distance between embedded points. Smaller values
%     will result in a more clustered/clumped embedding where nearby points
%     on the manifold are drawn closer together, while larger values will
%     result on a more even dispersal of points. The value should be set
%     relative to the "spread" value, which determines the scale at which
%     embedded points will be spread out.  
% 
% Returns
% -------
% a: double
%     Parameter of differentiable approximation of right adjoint functor.
% 
% b: double
%     Parameter of differentiable approximation of right adjoint functor.
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

    
curve = @(a,b,x) (1./(1 + a*x.^(2*b)));

    xv = linspace(0, 3*spread, 300);
    yv = (xv < min_dist) + ~(xv < min_dist).*exp(-(xv - min_dist) / spread);
    params=[];
    if license('test','curve_fitting_toolbox')
        try
            f = fit(xv', yv', curve, 'StartPoint', [1 1]);
            params = coeffvalues(f);
        catch
        end
    end
    if isempty(params)
        %If the user does not have the Curve Fitting Toolbox, use fminsearch instead
        err = @(v) trapz(xv,(yv - curve(v(1),v(2),xv)).^2);
        params = fminsearch(err, [1 1]);
    end
    a = params(1);
    b = params(2);
end