classdef GatingMl
    methods(Static)
        function fullFile=GetFile(epp)
            argued=epp.args.gating_ml_file;
            [gatingMlFolder, f, ext]=fileparts(argued);
            if isempty(gatingMlFolder)
                fullFile=fullfile(epp.folder, [f ext]);
            else
                gatingMlFolder=File.ExpandHomeSymbol(gatingMlFolder);
                [ok,errMsg]=File.mkDir(gatingMlFolder);
                if ~ok
                    msg(['<html>Problems accessing folder ' ...
                        Html.FileTree(gatingMlFolder) '<br>'...
                        '<br>Your file system complaint is:<br>'...
                        '&nbsp;&nbsp;"<table width=300px><tr><td>'...
                        '<font color="red">' errMsg '</font>"</td>'...
                        '</td></table><br>THUS no gating ml XML has been '...
                        'deposited into your file<br><center>'...
                        '"<i>' [f ext] '</i>" !!</center><hr></html>'],12);
                    fullFile=[];
                else
                    fullFile=fullfile(gatingMlFolder, [f ext]);
                end
            end
        end
        
        function ok=Run(epp)
            fullFile=GatingMl.GetFile(epp);
            if isempty(fullFile)
                ok=false;
                return;
            end
            try
                javaMethodEDT('createGatingML','edu.stanford.facs.swing.EppProps',...
                    epp.properties_file, fullFile, epp.dataSet.columnPrefixes);
                msg(['<html>The Gating-ML for EPP is in'...
                    Html.FileTree(fullFile) '<br><br><center>NOTE: '...
                    Html.WrapBoldSmall(['You likely need'...
                    ' to add further XML to describe the data setup'...
                    '<br>(scaling, transformations etc.) done before'...
                    ' you passed the data to EPP.)']) ...
                    '</center><hr></html>'], 8, 'south west+', 'Gating-ML');
                ok=true;
            catch ex
                ex.getReport
                msgError(Html.WrapHr(['<table width="300px"><tr><tc>'...
                    ex.message '</td></tr></table>']), 8, 'center', ...
                    'Gating-ML error...');
                return;
            end
            
        end
        
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
