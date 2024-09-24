function [ varargout ] = aliveMask( obj )
%aliveMask creates a binary mask of when the segments in the compound track
%are active
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
    if(isscalar(obj))
        mask = false(size(obj.tracksFeatIndxCG));
        startFrames = obj.segmentStartFrame - obj.startFrame +1;
        endFrames = obj.segmentEndFrame - obj.startFrame +1;
        for i = 1:obj.numSegments
            mask(i,startFrames(i):endFrames(i)) = true;
        end
        varargout{1} = mask;
    else
        [varargout{1:nargout}] = cellfun(@aliveMask,num2cell(obj(1:nargout)),'UniformOutput',false);
    end

end

