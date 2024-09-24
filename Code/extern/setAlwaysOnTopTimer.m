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

function setAlwaysOnTopTimer(jd, time, focus, ignoreIfPc)
if nargin<4
    ignoreIfPc=true;
    if nargin<3
        focus=[];
        if nargin<2
            time=1;
        end
    end
end
if isempty(jd)
    return;
end
if isa(jd,'matlab.ui.Figure')
    jd=Gui.JWindow(jd);
end
    
jd.toFront;
if ispc && ignoreIfPc
    return;
end
%disp(['Setting window on top for ' num2str(time) ' seconds']);
javaMethodEDT( 'setAlwaysOnTop', jd, true);
tmr=timer;
tmr.StartDelay=time;
tmr.TimerFcn=@(h,e)dismiss;
start(tmr);

    function dismiss
        javaMethodEDT('setAlwaysOnTop', jd, false);
        if ~isempty(focus)
            try
                if isjava(focus)
                    javaMethodEDT('requestFocus', focus);
                elseif Gui.IsFigure(focus)
                    figure(focus);
                end
            catch ex
                ex.getReport
            end
        end
    end
end
