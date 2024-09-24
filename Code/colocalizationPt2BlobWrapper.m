function movieData = colocalizationPt2BlobWrapper(movieData, paramsIn)
%COLOCALIZATIONPT2BLOBWRAPPER applies colocalization method described in colocalMeasurePt2Cnt to a single image or an image set
%
% movieData = colocalizationPt2BlobWrapper(movieData, paramsIn)
%
% Applies colocalization method described in colocalMeasurePt2Blob to two
% channels (punctate and blob(segmentable objects)) of an image set and outputs average and
% sometimes individual colocalization measures
%
% Input:
%   movieData- A MovieData object describing the movie to be processed
%
%   paramsIn- Structure with inputs for required and optional parameters.
%   The parameters should be stored as fields in the structure, with the field
%   names and possible values as described below.
%       ChannelPt- reference channel. For point2point and continuum2continuum
%       methods, this refers to what fraction of the objects in ChannelObs colocalize
%       with objects in ChannelRef. For point2continuum and point2object,
%       this is always the point channel (Punctate Channel)
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
% Output: See core function, colocalMeasurePt2Blob
% for specific outputs. Outputs are saved in unique folder
% ColocalizationPt2Blob/colocalInfoMN.mat where M = punctate channel and N=
% continuum channel number used in analysis.
%
%
% Anthony Vega 09/2017
%
%Jesus Vega-Lugo 07/2022 Modified to extract mask index from metadata, if
%no maskif found, it will use whole image. Added option to choose subRes or
%PointSource for detections. Defined outputdirectory for results which was
%not defined before.
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
iProc = movieData.getProcessIndex('ColocalizationPt2BlobProcess',1,0);

%If the process doesn't exist, create it
if isempty(iProc)
    iProc = numel(movieData.processes_)+1;
    movieData.addProcess(ColocalizationPt2BlobProcess(movieData,movieData.outputDirectory_));
end


%Parse input, store in parameter structure
p = parseProcessParams(movieData.processes_{iProc},paramsIn);

%Set outFilePath
pt2BlobProcess = movieData.processes_{iProc};
outDir = fullfile(movieData.outputDirectory_,'ColocalizationPt2Blob','colocalInfo.mat');
pt2BlobProcess.setOutFilePaths(outDir,1);

%Define which process was masking process
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Jesus Vega-Lugo 07/2022  modified to extract channel index from metadata
%instead of needing it as an input. Added warning when no mask found code
%will use full image.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Jesus Vega-Lugo 07/2022 modified to allow subres and point source as
%acceptable detection processes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
    switch p.detectionProcessID 

        case {'SubRes' 'Subres' 'subRes' 'subres'}
            iD = movieData.getProcessIndex('SubResolutionProcess',Inf,0);

            channelInDetProc = NaN(size(iD));
            if channelInDetProc >1
                for iProc = 1 : length(iD)
                    channelInDetProc(iProc) = movieData.processes_{iD(iProc)}.funParams_.ChannelIndex;
                end
                iD = iD(channelInDetProc == 1);
                inDetectDir = movieData.processes_{iD}.outFilePaths_(p.ChannelPt);

            else
                inDetectDir = movieData.processes_{iD}.outFilePaths_(p.ChannelPt);
            end

        case {'PointSource' 'Pointsource' 'pointSource' 'pointsource'}
            iD = movieData.getProcessIndex('PointSourceDetectionProcess',Inf,0);

            inDetectDir = movieData.processes_{iD}.outFilePaths_(p.ChannelPt);

    end
catch
    %Insert some error about no detection file
    error('No detection data found for Ref channel! Detection process must be run first!')
end


%Load blob channel segmentation data
try
    iS = movieData.getProcessIndex('SegmentBlobsPlusLocMaxSimpleProcess',Inf,0);
    inBlobSegDir = movieData.processes_{iS}.outFilePaths_{p.ChannelBlob};
catch
    try
        iSeg = movieData.getProcessIndex('ImportSegmentationProcess',1);
        segDir = movieData.getProcess(iSeg).outFilePaths_(p.ChannelBlob);
        inBlobSegDir = [segDir{1}(1:end-13) 'segmentation_' num2str(p.ChannelBlob) '.mat'];
    catch
        error('No segmentation found. SegmentBlobsProjectionProcess must be run first!')
    end
end

%load data
load(inDetectDir{1});
load(inBlobSegDir);

%% Run Colocalization Analysis

%Load the mask for this frame/channel
if checkMask 
    currMask = imread([inMaskDir{1} filesep maskNames{1}{1}]);
else
    currMask = ones(movieData.imSize_);
end
currMask = logical(currMask);

%Get segmenation coordinates from segmentation data
%[segmentationData] = segmentationCoordinates(imageBlob,maskBlobs,p.blobSize,p.sizeThresh,[],[]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Jesus Vega-Lugo 07/2022 added below line to get segmentation coordinates
%instead of using segmentationCoordinates fucntion
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
segmentationData = regionprops(logical(maskBlobs),'PixelList');
segmentationData = vertcat(segmentationData.PixelList);
segmentationData = flip(segmentationData,2);

%Run Function
[cT, cNull, cCritical] = colocalMeasurePt2Blob(segmentationData,movieInfo, p.SearchRadius,currMask, p.alphaValue);

%TP 240910: save the threshold (search radius) used in output
thresholdUsed = p.SearchRadius;

mkdir(fullfile(p.OutputDirectory,'ColocalizationPt2Blob'))
save(fullfile(p.OutputDirectory,'ColocalizationPt2Blob',['colocalInfo' num2str(p.ChannelPt) num2str(p.ChannelBlob) '.mat']),'cT','cNull','cCritical','thresholdUsed');

%% Save Results
movieData.processes_{iProc}.setDateTime;
movieData.save; %Save the new movieData to disk

disp('Finished Colocalization Analysis!')