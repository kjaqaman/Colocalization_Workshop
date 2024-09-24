function statTestResult = condColocStatTest(saveRes,fileToLoad,saveResPath)
%STATTESTRESULT takes compiled results from plotSaveConditionalColoc.m and do ranksum test on the results
%
%SYNOPSIS statTestResult = condColocStatTest(saveRes)
% Function does a ranksum test comparing each conditional colocalization  
% measure to its corresponding nulTR and randC and to pTwR. When prompted user
% should select the mat file with the compiled results saved from
% plotSaveConditionalColoc
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
%Jesus Vega-Lugo April 2021
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
AbvBel_TwR = NaN(7,1);
AbvBel_NullTR = NaN(7,1);
AbvBel_RandC = NaN(7,1);

%test for p(TwR) vs its nullTR [1]
pTwRTest = ranksum(pTwR(:,1,1),pTwR(:,2,1));

medianTwR = median(pTwR(:,1,1),'omitnan');
medianNullTr = median(pTwR(:,2,1),'omitnan');

AbvBel_NullTR(1) = medianTwR > medianNullTr;

%test for p(TwR|TwC) vs nullTR and RandC [2]
try
    pTwRgivenTwCVSpTwR = ranksum(pTwRgivenTwC(:,1,1),pTwR(:,1,1));
    pTwRgivenTwCVSNullpTwRgivenTwC = ranksum(pTwRgivenTwC(:,1,1),pTwRgivenTwC(:,2,1));
    pTwRgivenTwCVSRandpTwRgivenTwC = ranksum(pTwRgivenTwC(:,1,1),pTwRgivenTwC(:,1,2));
    
     medianData = median(pTwRgivenTwC(:,1,1),'omitnan');
     medianNullTr = median(pTwRgivenTwC(:,2,1),'omitnan');
     medianRandC = median(pTwRgivenTwC(:,1,2),'omitnan');
    
     AbvBel_TwR(2) = medianData > medianTwR;
     AbvBel_NullTR(2) = medianData > medianNullTr;
     AbvBel_RandC(2) = medianData > medianRandC;
     
catch
    pTwRgivenTwCVSpTwR = nan;
    pTwRgivenTwCVSNullpTwRgivenTwC = nan;
    pTwRgivenTwCVSRandpTwRgivenTwC = nan;
end

%test for p(TwR|TnC) vs nullTR and RandC [3]
try
    pTwRgivenTnCVSpTwR = ranksum(pTwRgivenTnC(:,1,1),pTwR(:,1,1));
    pTwRgivenTnCVSNullpTwRgivenTnC = ranksum(pTwRgivenTnC(:,1,1),pTwRgivenTnC(:,2,1));
    pTwRgivenTnCVSRandpTwRgivenTnC = ranksum(pTwRgivenTnC(:,1,1),pTwRgivenTnC(:,1,2));
    
    medianData = median(pTwRgivenTnC(:,1,1),'omitnan');
     medianNullTr = median(pTwRgivenTnC(:,2,1),'omitnan');
     medianRandC = median(pTwRgivenTnC(:,1,2),'omitnan');
    
     AbvBel_TwR(3) = medianData > medianTwR;
     AbvBel_NullTR(3) = medianData > medianNullTr;
     AbvBel_RandC(3) = medianData > medianRandC;
catch
    pTwRgivenTnCVSpTwR = nan;
    pTwRgivenTnCVSNullpTwRgivenTnC = nan;
    pTwRgivenTnCVSRandpTwRgivenTnC = nan;
end

%test for p^rs(Tw(RwC))vs NullTr and RandC [4] 
try
    pTwRwCVSpTwR = ranksum(pTwRwC(:,1,1),pTwR(:,1,1));
    pTwRwCVSNullpTwRwC = ranksum(pTwRwC(:,1,1),pTwRwC(:,2,1));
    pTwRwCVSRandpTwRwC = ranksum(pTwRwC(:,1,1),pTwRwC(:,1,2));
    
    medianData = median(pTwRwC(:,1,1),'omitnan');
     medianNullTr = median(pTwRwC(:,2,1),'omitnan');
     medianRandC = median(pTwRwC(:,1,2),'omitnan');
    
     AbvBel_TwR(4) = medianData > medianTwR;
     AbvBel_NullTR(4) = medianData > medianNullTr;
     AbvBel_RandC(4) = medianData > medianRandC;
     
catch
    pTwRwCVSpTwR = nan;
    pTwRwCVSNullpTwRwC = nan;
    pTwRwCVSRandpTwRwC = nan;
end

%test for p^rs(Tw(RnC)) vs NullTR and RandC [5]
try
    pTwRnCVSpTwR = ranksum(pTwRnC(:,1,1),pTwR(:,1,1));
    pTwRnCVSNullpTwRnC = ranksum(pTwRnC(:,1,1),pTwRnC(:,2,1));
    pTwRnCVSRandpTwRnC = ranksum(pTwRnC(:,1,1),pTwRnC(:,1,2));
    
    medianData = median(pTwRnC(:,1,1),'omitnan');
     medianNullTr = median(pTwRnC(:,2,1),'omitnan');
     medianRandC = median(pTwRnC(:,1,2),'omitnan');
    
     AbvBel_TwR(5) = medianData > medianTwR;
     AbvBel_NullTR(5) = medianData > medianNullTr;
     AbvBel_RandC(5) = medianData > medianRandC;
catch
    pTwRnCVSpTwR = nan;
    pTwRnCVSNullpTwRnC = nan;
    pTwRnCVSRandpTwRnC = nan;
    
end

%test for p(TwC) vs its randC [6]
try
    pTwCTest = ranksum(pTwC(:,:,1),pTwC(:,:,2));
    
    medianData = median(pTwC(:,:,1),'omitnan');
    medianRandC = median(pTwC(:,:,2),'omitnan');
    
    AbvBel_RandC(6) = medianData > medianRandC;
catch
    pTwCTest = nan;
end

%test for p(RwC) vs its randC [7]
try
    pRwCTest = ranksum(pRwC(:,:,1),pRwC(:,:,2));
    
    medianData = median(pRwC(:,:,1),'omitnan');
    medianRandC = median(pRwC(:,:,2),'omitnan');
    
    AbvBel_RandC(7) = medianData > medianRandC;
catch
    pRwCTest = nan;
end

VSAll = [nan;pTwRgivenTwCVSpTwR;pTwRgivenTnCVSpTwR;pTwRwCVSpTwR;pTwRnCVSpTwR;nan;nan];
  
VSNull = [pTwRTest;pTwRgivenTwCVSNullpTwRgivenTwC;pTwRgivenTnCVSNullpTwRgivenTnC;pTwRwCVSNullpTwRwC;...
          pTwRnCVSNullpTwRnC;nan;nan];
      
VSRand = [nan;pTwRgivenTwCVSRandpTwRgivenTwC;pTwRgivenTnCVSRandpTwRgivenTnC;pTwRwCVSRandpTwRwC;...
          pTwRnCVSRandpTwRnC;pTwCTest;pRwCTest];
  
statTestResult = table(VSAll,AbvBel_TwR,VSNull,AbvBel_NullTR,VSRand,AbvBel_RandC,'VariableNames',...
    {'VS_p(TwR)','AbvBel_TwR','VS_NullTR','AbvBel_NullTR','VS_RandC','AbvBel_RandC'},...
    'RowNames',{'p(TwR)','p(TwR|TwC)','p(TwR|TnC)','p^rs(Tw(RwC))','p^rs(Tw(RnC))','p(TwC)','p(RwC)'});


%% Save output
if saveRes
    if nargin < 3 || isempty(saveResPath)
        
        [fileSaved, path] = uiputfile('*.mat','Choose where to save table with test results',['statTest' file(15:end)]);
        
        save([path fileSaved],'statTestResult')
        
    elseif nargin > 2 && ~isempty(saveResPath)

            save([saveResPath '/statTest' file(15:end)],'statTestResult')
    end      
end

end