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


function [answer, cancelled]=inputDlg(msg,title,varargin)
if nargin==1
    title='Input required';
end
[msgType, jsa,default,~,isNumerics]=getMsgTypeAndOptions(...
    javax.swing.JOptionPane.QUESTION_MESSAGE, varargin);
[msg, where, property, properties, default, myIcon, javaWin,~,~,modal]...
    =decodeMsg(msg, default);
hasProp=~isempty(properties) && ~isempty(property);
inputValue='';
if hasProp
    inputValue=properties.get(property);
end

if isempty(inputValue) && ~isempty(jsa)
    inputValue=char(jsa(1));
end
if msgType==0
    myIcon='error.png';
elseif msgType==1
    myIcon = 'facs.gif';
elseif msgType==2
    myIcon='warning.png';
else
    myIcon='question.png';
end
pane=javaObjectEDT('javax.swing.JOptionPane', msg, msgType);
pane.setWantsInput(true);
pane.setInitialSelectionValue(inputValue);
pane.selectInitialValue();
pane.setIcon(Gui.Icon(myIcon));
pane.setOptionType(javax.swing.JOptionPane.OK_CANCEL_OPTION);
PopUp.Pane(pane, title,where, javaWin, modal);
answer=pane.getInputValue;
cancelled=strcmp(answer,'uninitializedValue');
if cancelled
    answer='';
else
    if hasProp
        properties.set(property, answer);
    end
end
end
