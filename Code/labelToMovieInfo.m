function movieInfo= labelToMovieInfo(label,vol)
% [feats,nFeats] = bwlabeln(label);
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
featsProp = regionprops(label,vol,'WeightedCentroid','MaxIntensity');
nFeats=numel(featsProp);
% centroid coordinates with 0.5 uncertainties
tmp = vertcat(featsProp.WeightedCentroid);
xCoord=[];yCoord=[];zCoord=[];amp=[];
if(~isempty(tmp))
xCoord = [tmp(:,1) 0.5*ones(nFeats,1)]; 
yCoord = [tmp(:,2) 0.5*ones(nFeats,1)]; 
zCoord = [tmp(:,3) 0.5*ones(nFeats,1)];
amp=[vertcat(featsProp.MaxIntensity) 0.5*ones(nFeats,1)];
end
% u-track formating
movieInfo=struct('xCoord',[],'yCoord',[],'zCoord',[],'amp',[],'int',[]);
movieInfo.xCoord= xCoord;movieInfo.yCoord=yCoord;movieInfo.zCoord=zCoord;
movieInfo.amp=amp;
movieInfo.int=amp;
