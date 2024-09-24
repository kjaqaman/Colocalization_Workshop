function ok=CheckUmapFolder(curPath, fileName, doGrandParent)
ok=true;
whereIsFile=fileparts(which(fileName));
if nargin>2 && doGrandParent
    check1=fileparts(curPath);
    [check2, p]=fileparts(whereIsFile);
else
    check1=curPath;
    check2=whereIsFile;
end
if ~isempty(whereIsFile) && ~strcmp(check1, check2)
    if nargin>2 && doGrandParent
        should=fullfile(check1, p);
    else
        should=curPath;
    end
    ok=askYesOrNo(Html.Wrap(['<b>' fileName ...
        '</b> should only be found in '...
        '<br>&nbsp;&nbsp;&nbsp;&nbsp;<b>'...
        should '</b><br><br>...but is also found in'...
        '<br>&nbsp;&nbsp;&nbsp;&nbsp;<b>' whereIsFile ...
        '</b><br><br><i>This could lead to problems, consider first'...
        '<br>clearing your MATLAB paths before running run_umap.</i>'...
        '</b><br><br><center><font color="red"><b>'...
        'Continue?</b> </font></center>']), 'Path CONFLICT !!!');
    
end

end
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
