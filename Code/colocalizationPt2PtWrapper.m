function movieData = colocalizationPt2PtWrapper(movieData, paramsIn)
%COLOCALIZATIONPT2PTWRAPPER applies colocalization method described in colocalMeasurePt2Cnt to a single image or an image set
%
% movieData = colocalizationPt2PtWrapper(movieData, paramsIn)
%
% Applies colocalization method described in colocalMeasurePt2Pt to two
% channels (both punctate) of an image set and outputs the probability of
%   finding points in the observed channel that colocalize with points in the
%   reference channel
%
% Input:
%   movieData- A MovieData object describing the movie to be processed
%
%   paramsIn- Structure with inputs for required and optional parameters.
%   The parameters should be stored as fields in the structure, with the field
%   names and possible values as described below.
%       ChannelRef- reference channel.
%
%       ChannelBlob- observation channel.
%
%       ChannelMask- if masking process is used, indicate here which channel
%       was used for masking
%
%       SearchRadius- distance threshold used for colocalization used in
%       point2point, point2blob, and point2continuum methods
%
%
%
% Output: See core function, colocalMeasurePt2Pt
% for specific outputs. Outputs are saved in unique folder
% ColocalizationPt2Pt/colocalInfoMN.mat where M = reference channel and N=
% observation channel number used in analysis.
% 
%
% Anthony Vega 09/2017
% Modified by Khuloud Jaqaman to allow different detection processes/parameters
% for different channels: 02/2019
%
%Jesus Vega-Lugo 07/2022 Modified to define outfilepath for the process
%
%Khuloud Jaqaman 03/2024: Fixed handling of input "detectedChannels".
%Previously, code ignored this input and always analyzed
%channels 1 and 2, regardless of this input. This is related to a
%modification that JV-L made in colocAnalysisPt2PtMLMD (in 07/2022), but
%apparently did not propagate properly into this function.
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
% Will need to take previous process outputs from detection,segmentation and masking
% processes
%Check that input object is a valid moviedata
if nargin < 1 || ~isa(movieData,'MovieData')
    error('The first input argument must be a valid MovieData object!')
end

if nargin < 2
    paramsIn = [];
end
%Get the indices of any previous colocalization processes from this function
iProc = movieData.getProcessIndex('ColocalizationPt2PtProcess',1,0);

%If the process doesn't exist, create it
if isempty(iProc)
    iProc = numel(movieData.processes_)+1;
    movieData.addProcess(ColocalizationPt2PtProcess(movieData,movieData.outputDirectory_));
end

%Set outFilePath
pt2PtProcess = movieData.processes_{iProc};
outDir = fullfile(movieData.outputDirectory_,'ColocalizationPt2Pt','colocalInfo.mat');
pt2PtProcess.setOutFilePaths(outDir,1);

%Parse input, store in parameter structure
p = parseProcessParams(movieData.processes_{iProc},paramsIn);


checkMask = 1;
try
    warning('off', 'lccb:process')
    iM = movieData.getProcessIndex('MaskProcess',1,0);
    channelMask = movieData.getProcess(iM).funParams_.ChannelIndex;
    inMaskDir = movieData.processes_{iM}.outFilePaths_(channelMask);
    maskNames = movieData.processes_{iM}.getOutMaskFileNames(channelMask);
    warning('on', 'lccb:process')
catch
    try
        warning('off', 'lccb:process')
        iM = movieData.getProcessIndex('MultiThreshProcess',1,0);
        channelMask = movieData.getProcess(iM).funParams_.ChannelIndex;
        inMaskDir = movieData.processes_{iM}.outFilePaths_(channelMask);
        maskNames = movieData.processes_{iM}.getOutMaskFileNames(channelMask);
        warning('on', 'lccb:process')
    catch
        try
            % Try to use imported cell mask if no MaskProcess, Kevin Nguyen 7/2016
            iM = movieData.getProcessIndex('ImportCellMaskProcess',Inf,0);
            channelMask = movieData.getProcess(iM).funParams_.ChannelIndex;
            inMaskDir = movieData.processes_{iM}.outFilePaths_{channelMask};
            inMaskDir = fileparts(inMaskDir);
            inMaskDir = {inMaskDir}; % Below requires a cell
            maskNames = {{['cellMask_channel_',num2str(channelMask),'.tif']}};
        catch
            warning('No mask found. Using full image.')
            checkMask = 0;
        end
    end
end

%Load detection data
try
    switch p.DetectionProcessID{1} 

        case {'SubRes' 'Subres' 'subRes' 'subres'}
            iD = movieData.getProcessIndex('SubResolutionProcess',Inf,0);

            channelInDetProc = NaN(size(iD));
            if channelInDetProc > 1 %KJ 240322: I am not sure what this option is about or when the code will ever enter this section
                for iProc = 1 : length(iD)
                    channelInDetProc(iProc) = movieData.processes_{iD(iProc)}.funParams_.ChannelIndex;
                end
                iD = iD(channelInDetProc == 1);
                inDetectDir1 = movieData.processes_{iD}.outFilePaths_(p.detectedChannels(1));

            else
                inDetectDir1 = movieData.processes_{iD}.outFilePaths_(p.detectedChannels(1));
            end

        case {'PointSource' 'Pointsource' 'pointSource' 'pointsource'}
            iD = movieData.getProcessIndex('PointSourceDetectionProcess',Inf,0);

            inDetectDir1 = movieData.processes_{iD}.outFilePaths_(p.detectedChannels(1));

    end
catch
    %Insert some error about no detection file
    error(['No detection data found for channel ' num2str(p.detectedChannels(1)) ' ! Detection process must be run first!'])
end

%Load channel 2 detection data
try
    switch p.DetectionProcessID{2} 
        
        case {'SubRes' 'Subres' 'subRes' 'subres'}
            iD = movieData.getProcessIndex('SubResolutionProcess',Inf,0);
            
            channelInDetProc = NaN(size(iD));
            if channelInDetProc > 1 %KJ 240322: I am not sure what this option is about or when the code will ever enter this section
                for iProc = 1 : length(iD)
                    channelInDetProc(iProc) = movieData.processes_{iD(iProc)}.funParams_.ChannelIndex;
                    
                    iD = iD(channelInDetProc == 2);
                    inDetectDir2 = movieData.processes_{iD}.outFilePaths_(p.detectedChannels(2));
                end
            else
                inDetectDir2 = movieData.processes_{iD}.outFilePaths_(p.detectedChannels(2));
            end
            
            
        
        case {'PointSource' 'Pointsource' 'pointSource' 'pointsource'}
            iD = movieData.getProcessIndex('PointSourceDetectionProcess',Inf,0);

            inDetectDir2 = movieData.processes_{iD}.outFilePaths_(p.detectedChannels(2));

    end
    
catch
    %Insert some error about no detection file
    error(['No detection data found for channel ' num2str(p.detectedChannels(2)) ' ! Detection process must be run first!'])
end

%load detection coordinates of each channel
load(inDetectDir1{1});
detectionCh1 = movieInfo;

load(inDetectDir2{1});
detectionCh2 = movieInfo;

%% Run Colocalization Analysis
    

%Load the mask for this frame/channel
if checkMask 
    currMask = imread([inMaskDir{1} filesep maskNames{1}{1}]);
else
    currMask = ones(movieData.imSize_);
end
currMask = logical(currMask);

%Run Function
[cT12, cNull12, cCritical12,estimatorM12, estimatorC12] = ...
    colocalMeasurePt2Pt(detectionCh1, detectionCh2, p.SearchRadius, currMask, p.alphaValue);

[cT21, cNull21, cCritical21,estimatorM21, estimatorC21] = ...
    colocalMeasurePt2Pt(detectionCh2, detectionCh1, p.SearchRadius, currMask, p.alphaValue);

%Save output
%KJ 240322: as part of output, save which channels were analyzed
channelsAnalyzed = p.detectedChannels;
%mkdir([p.OutputDirectory 'ColocalizationPt2Pt' ])
%save(fullfile(p.OutputDirectory,'ColocalizationPt2Pt','colocalInfo.mat'),'cT12','cNull12','cCritical12','estimatorM12','estimatorC12',...
%                                                                'cT21','cNull21','cCritical21','estimatorM21','estimatorC21',...
%                                                                'channelsAnalyzed')

%TP 240910: save the threshold (search radius) used in output
thresholdUsed = p.SearchRadius;

%TP 240826: updated with fullfile and file name to include channel numbers
mkdir(fullfile(p.OutputDirectory, 'ColocalizationPt2Pt'));
save(fullfile(p.OutputDirectory,'ColocalizationPt2Pt',['colocalInfo' num2str(p.detectedChannels(1)) num2str(p.detectedChannels(2)) '.mat']),...
   'cT12','cNull12','cCritical12','estimatorM12','estimatorC12',...
   'cT21','cNull21','cCritical21','estimatorM21','estimatorC21',...
   'channelsAnalyzed', 'thresholdUsed');


%% Save Results
movieData.processes_{iProc}.setDateTime;
movieData.save; %Save the new movieData to disk

disp('Finished Colocalization Analysis!')