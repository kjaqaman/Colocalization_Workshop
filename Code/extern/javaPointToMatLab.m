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

function [mlY, mlScrPos]=javaPointToMatLab(javaX, javaY)
screens=javaScreens;
N=length(screens);
defaultIdx=1;
for i=1:N
    pe=screens{i};
    if pe.y==0 && pe.x==0
        defaultIdx=i;
        defaultPe=pe;
    end
end
idx=0;
for i=1:N
    pe=screens{i};
    if javaX>=pe.x &&  javaX<pe.x+pe.width
        if javaY>=pe.y && javaY<pe.y+pe.height
            idx=i;
            break;
        end
    end
end
if idx==0
    if nargin<4
        mlScrPos=[];
        mlY=javaY;
        return;
    end
    idx=defaultIdx;
end
pe=screens{idx};
mlTopY=defaultPe.height-pe.y;
tmp=(defaultPe.height-javaY)-mlTopY;
mlY=mlTopY+tmp;
idx=0;
if idx==defaultIdx
    mlScrPos=[1, 1, pe.width, pe.height];
else
    if pe.y<0
        y=defaultPe.height-(pe.height+pe.y);
    else
        y=(defaultPe.height-pe.y)-pe.height;
    end
    mlScrPos=[pe.x+1, y+1, pe.width, pe.height];
end

end
