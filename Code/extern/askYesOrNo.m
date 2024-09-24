%   AUTHORSHIP
%   Primary Developer: Stephen Meehan <swmeehan@stanford.edu> 
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
function [yes, cancelled, raIfRemembered]...
    =askYesOrNo(theMsg, title, where, ...
    defaultIsYes, rememberId, property)
if nargin<4
    defaultIsYes=true;
    if nargin<3
        where=[];
    if nargin<2
        title=[];
    end
    end
end
raIfRemembered=[];
if isempty(title)
    title= 'Please confirm...';
end
if nargin>2
    if isempty(where)
        where='center';
    end
    if ~isstruct(theMsg)
        m.msg=theMsg;
        m.where=where;
        if nargin>4 
            if ~isempty(rememberId)
                m.remember=rememberId;
            end
            if nargin>5
                m.property=property;
            end
        end
        theMsg=m;
    else
        theMsg.where=where;
        if nargin>4 && isempty(rememberId)
            theMsg.remember=rememberId;
        end
    end
end
if defaultIsYes
    dflt='Yes';
else
    dflt='No';
end
if nargout>1
    [~,yes,cancelled, raIfRemembered]=questDlg(theMsg, title, 'Yes', ...
        'No', 'Cancel', dflt);
else
    [~,yes,cancelled, raIfRemembered]=questDlg(theMsg, title, 'Yes',...
        'No', dflt);
end
end