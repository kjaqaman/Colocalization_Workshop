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
function [msg, where, property, properties, default, icon, javaWindow,...
    choiceTitle, checkFnc, modal, pauseSecs, southWestComponent, ...
    rememberId, rememberOnly, checkBoxFnc, items]=...
    decodeMsg(msg, default, defaultWhere, app)
checkBoxFnc=[];
rememberId=[];
choiceTitle=[];
modal=true;
items=0;
if nargin<4
    properties=BasicMap.Global;
    if nargin<3
        where=[];
    else
        where=defaultWhere;
    end
else
    properties=app;
    where=defaultWhere;
end
if isempty(where)
    where=properties.whereMsgOrQuestion;
else
    where=defaultWhere;
end
property=[];
icon=[];
javaWindow=[];
checkFnc=[];
pauseSecs=[];
southWestComponent=[];
rememberOnly=[];
if isstruct(msg)
    if isfield(msg, 'rememberOnly')
        rememberOnly=msg.rememberOnly;
    end
    if isfield(msg, 'checkBoxFnc')
        checkBoxFnc=msg.checkBoxFnc;
    end
    if isfield(msg, 'checkFnc')
        checkFnc=msg.checkFnc;
    end
    if isfield(msg, 'pauseSecs')
        pauseSecs=msg.pauseSecs;
    end
    if isfield(msg, 'javaWindow')
        javaWindow=msg.javaWindow;
    end
    if isfield(msg, 'modal')
        modal=msg.modal;
    end
    if isfield(msg, 'property')
        property=msg.property;
    end
    if isfield(msg, 'properties')
        properties=msg.properties;
    end
    if isfield(msg, 'where')
        where=msg.where;
    end
    if isfield(msg, 'icon')
        icon=msg.icon;
    end
    if isfield(msg, 'choiceTitle')
        choiceTitle=msg.choiceTitle;
    end
    if isfield(msg, 'component')
        southWestComponent=msg.component;
    end
    if isfield(msg, 'remember')
        rememberId=msg.remember;
        if isempty(property)
            property=rememberId;
        end
    end
    
    if isfield(msg, 'items')
        items=msg.items;
    end
    msg=msg.msg;
end
if ~isempty(property)
    if isnumeric(default)
        default=str2num(properties.get(property, num2str(default)));
    else
        default=properties.get(property, default);
    end
end

end