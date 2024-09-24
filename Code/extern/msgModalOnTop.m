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
function msgModalOnTop(txt, where, javaWnd, icon, title)
if nargin<5
    title='Note';
    if nargin<4
        icon='facs.gif';
        if nargin<3
            javaWnd=Gui.JFrame;
            if nargin<2
                where='center';
            end
        end
    end
end
pane=javaObjectEDT('javax.swing.JOptionPane', txt, 1);
jd=javaMethodEDT('createDialog', pane, javaWnd, title);
jd.setResizable(true);
jd.setModal(true);
if ~isempty(javaWnd)
    javaMethodEDT( 'setLocationRelativeTo', jd, javaWnd);
end
Gui.LocateJava(jd, javaWnd, where);
jd.setAlwaysOnTop(true);
pane.setIcon(Gui.Icon(icon));
jd.pack;
Gui.SetJavaVisible(jd);
end

