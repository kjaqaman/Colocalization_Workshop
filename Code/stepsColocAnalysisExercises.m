
%(1) Open u-quantify GUI and visualize detections of punctate channel(s)
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
u_quantify

%(2) Load the MovieData object of movie being analyzed (first navigate to
%its subdirectory)
MD = MovieData.load('CS-01.mat');

%(3) Visualize segmentations of non-punctate channel (channel 3 in this
%example)
visualizeSegmentationAndMask(MD,'imgIdx',3)

%(4) Run 2-color colocalization analysis
colocGUI

%(5) Run 3-color conditional colocalization analysis
condColocGUI

%(6) Compare 2-color colocalization extent between different conditions
%(compensates for different number/distribution of reference objects)

%This uses the function "compColocNorm", as illustrated in example below

%(6a) Navigate to directory where compiled results of first condition are
%saved
load('compiledColocResults12.mat')
colocData{1,1} = cT(:,1); %if opposite colocalization is of interest, use cT(:,2)
colocNullTR{1,1} = cNull(:,1); %if opposite colocalization is of interest, use cNull(:,2)

%(6b) Navigate to directory where compiled results of second condition are
%saved
load('compiledColocResults12.mat')
colocData{2,1} = cT(:,1); %if opposite colocalization is of interest, use cT(:,2)
colocNullTR{2,1} = cNull(:,1); %if opposite colocalization is of interest, use cNull(:,2)

%(6c) Navigate to directory where compiled results of third condition are
%saved
load('compiledColocResults12.mat')
colocData{3,1} = cT(:,1); %if opposite colocalization is of interest, use cT(:,2)
colocNullTR{3,1} = cNull(:,1); %if opposite colocalization is of interest, use cNull(:,2)

%(6d) Repeat until all conditions of interest, to be compared to each
%other, have been collected

%(6e) Call comparison function
%NOTE: the results and figure (if plotted) must be saved manually
[pValueComp,sigOrNot,colocDataNorm,colocNullTRNorm] = compColocNorm(colocData,colocNullTR,0.05,1);

%(7) Compare colocalization measures from 3-color conditional
%colocalization analysis between different conditions
%(compensates for different number/distribution of reference objects)

%This involves calling the same function "compColocNorm" as in 6. 
%The only difference is how the compiled results are collected, due to
%differences in how they are saved between 2-color and 3-color
%colocalization analysis

%Here we will use example of getting p(TwR) from Cond1Ref2Tar3

%(7a) Navigate to directory where compiled results of first condition are
%saved
load('colocalMeasureCond1Ref2Tar3.mat')
colocData{1,1} = pTwR(:,1,1);
colocNullTR{1,1} = pTwR(:,2,1);

%(7b) Navigate to directory where compiled results of second condition are
%saved
load('colocalMeasureCond1Ref2Tar3.mat')
colocData{2,1} = pTwR(:,1,1);
colocNullTR{2,1} = pTwR(:,2,1);

%(7c) Navigate to directory where compiled results of second condition are
%saved
load('colocalMeasureCond1Ref2Tar3.mat')
colocData{3,1} = pTwR(:,1,1);
colocNullTR{3,1} = pTwR(:,2,1);

%(7d) Repeat until all conditions of interest, to be compared to each
%other, have been collected

%(7e) Call comparison function
%NOTE: the results and figure (if plotted) must be saved manually
[pValueComp,sigOrNot,colocDataNorm,colocNullTRNorm] = compColocNorm(colocData,colocNullTR,0.05,1);

