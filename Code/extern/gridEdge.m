%   AUTHORSHIP
%   Primary Developer: Stephen Meehan <swmeehan@stanford.edu> 
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

function [H, edgeBinIdxs]=gridEdge(fgOrDensityObject, allBorders, ...
    clusterIds, color, ax, markerSize, marker, lineStyle, lineWidth)
H=0;
if nargin<7
    lineStyle='-';
    lineWidth=.5;
end
if isa(fgOrDensityObject, 'Density')
    density=fgOrDensityObject;
else
    if ischar(clusterIds)
        clusterIds=fgOrDensityObject.toClust(clusterIds);
    end
    density=fgOrDensityObject.density;
    if isempty(density.pointers)
        fgOrDensityObject.dbm(false, false);
        density=fgOrDensityObject.density;
    end
end
binIdxs=[];
for i=1:length(clusterIds)
    binIdxs=[binIdxs find(density.pointers==clusterIds(i))];
end

gce=edu.stanford.facs.swing.GridClusterEdge(density.M);
if ~allBorders
    gce.compute(binIdxs, nargout>1, density.mins, density.deltas)
    [xx, yy]=clockwise([gce.x gce.y]);
else
    try
        useMex=FcsTreeGater.MEX_BORDER;
    catch
        useMex=false; % AutoGate not installed
    end
    if useMex
        [edgeBinIdxs, xx, yy]=mexSptx('cluster border', int32(density.M), ...
            int32(binIdxs), 'mins', density.mins, 'deltas', ...
            density.deltas);
        if ~strcmp('none', lineStyle)
            [xx, yy]=clockwise([xx yy]);
        end
    else
        gce.computeAll(binIdxs, density.mins, density.deltas)
        if strcmp('none', lineStyle)
            xx=gce.x;
            yy=gce.y;
        else
            [xx, yy]=clockwise([gce.x gce.y]);
        end
    end
end
if nargout>1 && ~FcsTreeGater.MEX_BORDER
    edgeBinIdxs=gce.edgeBins;
end %xxx  [edgeMex,mxX,mxY]=mexSptx('cluster border', int32(density.M), int32(binIdxs), 'mins', density.mins, 'deltas', density.deltas);
if ~isa(fgOrDensityObject, 'Density')
    if length(clusterIds)==1
        fgOrDensityObject.edgeX{clusterIds}=xx;
        fgOrDensityObject.edgeY{clusterIds}=yy;
    end
end
if nargin>3
    if isempty(color)
        color=[.6 .6 .6];
    end
    if nargin<7 || isempty(marker)
        marker='d';
    end
    if nargin<6 || isempty(markerSize)
        markerSize=3;
    end
    if nargin<4 || isempty(ax)
        H=plot(xx, yy, 'marker', marker, 'MarkerSize', markerSize, ...
            'Color', color, 'LineStyle', lineStyle, 'LineWidth', lineWidth);
    else
        H=plot(ax, xx, yy, 'marker', marker, 'MarkerSize', markerSize, ...
            'Color', color, 'LineStyle', lineStyle, 'LineWidth', lineWidth);
    end
end
end
