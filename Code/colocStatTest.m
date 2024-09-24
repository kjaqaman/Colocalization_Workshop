function statTestResult = colocStatTest(saveRes,fileToLoad,saveResPath)
%STATTESTRESULT takes compiled results from plotSaveConditionalColoc.m and do ranksum test on the results
%
%SYNOPSIS statTestResult = colocStatTest(saveRes)
% Function does a ranksum test comparing each colocalization  
% measure to its corresponding cT and cNull. When prompted user
% should select the mat file with the compiled results saved from
% plotSaveColocResults
%
% Function will open a dialog box for user to select the mat file of
% interest. Then, it will show another dialog box asking where to save the output 
%
%INPUT
%   saveRes:    1 for saving results. 0 otherwise
%
% Optional:
%   fileToLoad: full path of the file to be analyzed or name of file
%               (enetered as type char) if the file is on you current path.
%               NOTE: If empty, a dialog box will show asking for the file
%               to be loaded.
%
%   saveResPath: path where stats table will be saved
%                NOTE: If empty, a dialog box will show asking where to
%                save stats table
%               
%
%OUTPUT
%   statTestResult: Table containing p-values from ranksum tests
%                   NOTE: AbvBel_ columns show 1 when median of data is
%                         above median of its respective comparison and 0
%                         when below
%
% Mamerto Cruz July 2022
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

%% Input
if isempty(saveRes)
    saveRes = 0;
end

if nargin < 2 || isempty(fileToLoad)
    % Load mat file
    [file,path] = uigetfile('*.mat','Select compiled condColoc results to be tested');

    if path == 0
        error('No file was input! Rerun function to input file')
    else
        load(fullfile(path,file))
    end
    
elseif nargin > 1 && ~isempty(fileToLoad)
    try 
        load(fileToLoad)
        [~,fileName,ext] = fileparts(fileToLoad);
        file = [fileName ext];
    catch
        load(fullfile(cd,fileToLoad))
        file = fileToLoad;
    end
end
%% Do tests

%prealocate space for above/below vector
AbvBel_cT12 = NaN;
AbvBel_cT21 = NaN;
%AbvBel_cNull = NaN(7,1);
%AbvBel_RandC = NaN(7,1);

%test for p(TwR) vs its nullTR (1 - 2)
cTcNullTest12 = ranksum(cT(:,1),cNull(:,1));

mediancT12 = median(cT(:,1),'omitnan');
mediancNull12 = median(cNull(:,1),'omitnan');


AbvBel_cT12(1) = mediancT12 > mediancNull12;

%test for p(TwR) vs its nullTR (2 - 1)
cTcNullTest21 = ranksum(cT(:,2),cNull(:,2));

mediancT21 = median(cT(:,2),'omitnan');
mediancNull21 = median(cNull(:,2),'omitnan');


AbvBel_cT21(1) = mediancT21 > mediancNull21;

statTestResult = table(cTcNullTest12, AbvBel_cT12, cTcNullTest21, AbvBel_cT21);
% 
% disp(statTestResult);
%% Save output
if saveRes
    % TP 240828: Regular expression to extract numbers from input file to
    % use in output file (this assumes that the numbers are contiguous and
    % there are only one set of numbers)
    chNums = regexp(file, '\d*', 'match');
    if isempty(chNums)
        chNums = {''}; % Just in case a file with no numbers is inputted
    end
    saveFileName = ['statTest' chNums{1} '.mat'];
    
    if nargin < 3 || isempty(saveResPath)
        
        [fileSaved, path] = uiputfile('*.mat','Choose where to save table with test results',saveFileName);
        
        save(fullfile(path, fileSaved),'statTestResult')
        
    elseif nargin > 2 && ~isempty(saveResPath)

            save(fullfile(saveResPath, saveFileName),'statTestResult')
    end      
end
