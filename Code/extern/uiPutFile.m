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
function [folder, file]=uiPutFile(dfltFolder, ...
    dfltFile, props, property, ttl)
if nargin<5
    ttl='Save to which folder & file?';
    if nargin<4
        property='uiPutFile';
        if nargin<3
            props=BasicMap.Global;
        end
    end
    
end
if isempty(dfltFolder)
    dfltFolder=File.Documents;
end
    File.mkDir(dfltFolder);
if ~isempty(props)
    lastFolder=props.get(property, dfltFolder);
    if ~exist(lastFolder, 'dir')
        lastFolder = dfltFolder;
    end
else
    lastFolder=dfltFolder;
end
[~,~,ext]=fileparts(dfltFile);
done=false;
if ismac
    jd=Gui.MsgAtTopScreen(ttl, 25);
else
    jd=[];
end
if startsWith(ttl, '<html>')
    ttl=char(edu.stanford.facs.swing.Basics.RemoveXml(ttl));
end
while ~done
    done=true;
    [file, folder]=uiputfile(['*' ext], ttl, fullfile(lastFolder, dfltFile));
    if ~isempty(jd)
        jd.dispose;
    end
    if isempty(folder) || isnumeric(folder)
        folder=[];
        file=[];
        if isequal(dfltFolder, lastFolder)
            return;
        end
        if isequal([dfltFolder filesep], lastFolder)
            return;
        end
        if isequal(dfltFolder, [lastFolder filesep])
            return;
        end
        if ~File.WantsDefaultFolder(dfltFolder) 
            return;
        end
        [file, folder]=uiputfile(['*' ext], ...
            'Save to which folder & file?', ...
            fullfile(dfltFolder, dfltFile));
        if isempty(folder)|| isnumeric(folder)
            folder=[];
            file=[];
            return;
        end
    end
end
props.set(property, folder);
end