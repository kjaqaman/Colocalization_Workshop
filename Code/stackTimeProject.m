function imgProject = stackTimeProject(image,projectMethod,plotRes)
%STACKTIMEPROJECT make a intensity projection over an image time stack with the selected projection method
%
%SYNOPSIS  imgProject = stackTimeProject(image,projectMethod,plotRes)
%
%INPUT
%   image:         image stack over time
%
%Optional
%   projectMethod: method to be used for projection
%
%                  'mean':   for mean intensity projection
%                  'median': for median intensity projection
%                  'max':    for maximum intensity projection 
%                  Default: 'mean'
%
%   plotRes:       1 for plotting projection, 0 otherwise
%                  Default: 0
%
%OUTPUT
%   imageProject: projected image
%
%Jesus Vega-Lugo September 2019
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
          
%% Input
%parse input

%show error if no stack is input
if isempty(image) || size(image,3) < 2
    error('Image stack must be input')
end

%projection Method
if nargin < 2 || isempty(projectMethod )
    projectMethod = 'mean';
end

%plot results
if nargin < 3 || isempty(plotRes)
    plotRes = 0;
end

%% Projection 

%convert to double if necessary
if ~isa(image,'double')
    image = double(image);
end

%make the projection with the selested method
switch projectMethod 
    case 'mean'
        imgProject = mean(image,3);
        
    case 'median'
        imgProject = median(image,3);
        
    case 'max'
        imgProject = max(image,[],3);
end

%% Visualization
%plot projection

if plotRes
    figure, imshow(imgProject,[])
end

end