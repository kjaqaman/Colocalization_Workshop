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
function pu=showMsg(msg, title, where, modal, showBusy, pauseSecs, addClose)
if nargin<7
    addClose=true;
    if nargin<6
        pauseSecs=0;
        if nargin<5
            showBusy=true;
            if nargin<4
                modal=true;
                if nargin<3
                    where='center';
                    if nargin<2
                        title='Note....';
                    end
                end
            end
        end
    end
end
pu=PopUp(msg, where, title, showBusy, [],[],modal);
if addClose
    pu.addCloseBtn;
end
if modal
    pu.dlg.setAlwaysOnTop(true);
    Gui.SetJavaVisible(pu.dlg);
    
elseif pauseSecs>0
    PopUp.TimedClose(pu.dlg, pauseSecs);
end
