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
function [type, found]=getMessageType(arg, dflt)
if nargin<2
        dflt=javax.swing.JOptionPane.PLAIN_MESSAGE;
end
found=true;
if strcmpi(arg, 'error')
        type=javax.swing.JOptionPane.ERROR_MESSAGE;
    elseif strcmpi(arg, 'question')
        type=javax.swing.JOptionPane.QUESTION_MESSAGE;
    elseif strcmpi(arg, 'warning') || strcmpi(arg, 'warn');
        type=javax.swing.JOptionPane.WARNING_MESSAGE;
    elseif strcmpi(arg, 'information')
        type=javax.swing.JOptionPane.INFORMATION_MESSAGE;
    elseif strcmpi(arg, 'plain')
        type=javax.swing.JOptionPane.PLAIN_MESSAGE;
else
        found=false;
        type=dflt;
end
end