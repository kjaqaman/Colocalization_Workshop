function movieData = colocalizationBlob2BlobWrapper(movieData, paramsIn)
%COLOCALIZATIONBLOB2BLOBWRAPPER applies colocalization method described in colocalMeasureBlob2Blob to a single image or an im
%
% movieData = colocalizationBlob2BlobWrapper(movieData, paramsIn)
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
% Mamerto Cruz (July, 2022)
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
iProc = movieData.getProcessIndex('ColocalizationBlob2BlobProcess',1,0);

%If the process doesn't exist, create it
if isempty(iProc)
    iProc = numel(movieData.processes_)+1;
    movieData.addProcess(ColocalizationBlob2BlobProcess(movieData,movieData.outputDirectory_));
end

%Parse input, store in parameter structure
p = parseProcessParams(movieData.processes_{iProc},paramsIn);

nChan = numel(movieData.channels_);

%Set outFilePath
blob2BlobProcess = movieData.processes_{iProc};
outDir = fullfile(movieData.outputDirectory_,'ColocalizationPt2Blob','colocalInfo.mat');
blob2BlobProcess.setOutFilePaths(outDir,1);

%% Get Mask
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

%% Get channel info

channelInfo = cell(1,nChan);

%Load blob channels segmentation data
for ch = 1:nChan
    try
        iS = movieData.getProcessIndex('SegmentBlobsPlusLocMaxSimpleProcess',Inf,0); % 
        inBlobSegDir = movieData.processes_{iS}.outFilePaths_(ch);
        load(inBlobSegDir{1},'maskBlobs');
        channelInfo{1,ch} = maskBlobs;
    catch
        error(['No segmentation data found for channel ' num2str(ch) '! Segmentation process must be run first!'])
    end
end

%% Run Colocalization Analysis
%Load the mask for this frame/channel
if checkMask 
    currMask = imread([inMaskDir{1} filesep maskNames{1}{1}]);
else
    currMask = ones(movieData.imSize_);
end
currMask = logical(currMask);

% Tien Pham 240820 - Changed cT and cNull to have 1 and 2 to indicate
% channels used
[cT12, cNull12] = colocalMeasureBlob2Blob(channelInfo{1,p.detectedChannels(1)},channelInfo{1,p.detectedChannels(2)},currMask,p.SearchRadius,p.numRandomizations);
[cT21, cNull21] = colocalMeasureBlob2Blob(channelInfo{1,p.detectedChannels(2)},channelInfo{1,p.detectedChannels(1)},currMask,p.SearchRadius,p.numRandomizations);

% Tien Pham 240821 - Save output with channels analyzed
channelsAnalyzed = p.detectedChannels;

%TP 240910: save the threshold (search radius) used in output
thresholdUsed = p.SearchRadius;

mkdir(fullfile(p.OutputDirectory, 'ColocalizationBlob2Blob'));
save(fullfile(p.OutputDirectory, 'ColocalizationBlob2Blob', ['colocalInfo' num2str(p.detectedChannels(1)) num2str(p.detectedChannels(2)) '.mat']), 'cT12','cNull12','cT21','cNull21',...
    'channelsAnalyzed','thresholdUsed');

%% Save Results
movieData.processes_{iProc}.setDateTime;
movieData.save; %Save the new movieData to disk

disp('Finished Colocalization Analysis!')
