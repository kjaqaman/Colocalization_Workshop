function visualizeSegmentationAndMask(MLMD,varargin)
%VISUALIZESEGMENTATIONANDMASK plots the outline of segmentation and/or cell mask on top of the given image from a MovieData or MovieList
%
%SYNOPSIS visualizeSegmentationAndMask(MLMD,varargin)
%
%Plots segmentation and/or cell mask outline on top of image for the below
%scanrios:
% 1)Fixed cell (individual image or merged. In the merged case make sure to
%   input the proper channel index in imgIdx).
%
% 2)Live cell with segmentation done on an intensity projection of non-punctate objects
%
% 3)Live cell with imported segmentation. For this case enter parameter 'image' 
%   as 1 (a pop up window will show) and select the pax images. NOTE: when
%   using imported segmentation imgIdx must always be 1.
%
% 4) If you want to plot segmentation outline on top of a channel that was
%    not segmented, input 'image' as 1 and pick the image you want to plot 
%    the segmentation on and imgIdx as the channel that has
%    the segmentation.
%
% 5) If you only want to plot the cell mask enter show as 2 and imgIdx as
%    the channel you want to plot the mask on top. 
%
%   NOTE: When plotting live-cell imaging use 'atFrame' parameter to
%         specify in which frame you want to make the overlay. To use
%         maximum intensity projection enter 'atFrame',0. It will save a
%         projection inside the movieData file under 'stackTimeProjectProcess',
%         or, if you selected images manually it will do the projection
%         but it won't be saved.
%
%INPUT
%   imgIdx:  channel index of the segmented image
%              Default: 1
%
%   show: 1  for plot segmentation only. 2 for plotting mask only. 3 for
%            plotting both mask and segmentation
%            Default: 3
%
%   newfig:  1 if plot should be made in a new figure window, 0 otherwise
%            in which case it will be plotted in an existing figure window).
%            Default: 1
%
%   image:   1 to select multiple images using a pop up window or enter
%            whole image if only one will be plotted. Otherwise it will
%            load the image in the movieData file.
%            Default: empty (no image)
%
%   atFrame: frame number at which you want to overlay the segmentation
%            and/or cell mask. Enter zero (0) if you want to make a maximum
%            intensity projection and then overlay.
%            Default: 1
%
%OUTPUT
%   Figure showing image with segmentation and/or mask outlines plotted on
%   top
%
%NOTE: Image is always scaled! when mask is provided it will scale the
%      image using the intensities inside the mask, therefore, no objects
%      outside the mask will be visible. If mask is not provided it will
%      scale using the whole image.
%
%NOTE: If function plots the mask and segmentation on the wrong image you
%      can either put a break point at the end of the function and press
%      continue after each cell or run the code on the web gui.
%
%Jesus Vega-Lugo April 2020
%
%Jesus Vega-Lugo November, 2023 updated to include image scaling for better
%contrast and made function general to be used different scenarios
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

%% Parse Inputs

ip = inputParser;
ip.CaseSensitive = false;
ip.FunctionName = 'visualizeSegmentationAndMask';

addRequired(ip,'MLMD',@(x) isa(x,'MovieData') || isa(x,'MovieList'))

addParameter(ip,'imgIdx',1,@isscalar)
addParameter(ip,'show',3,@isscalar)
addParameter(ip,'newFig',1,@isscalar)
addParameter(ip,'image',[],@(x) ismatrix(x) || x==1)
addParameter(ip,'atFrame',1,@isscalar)

parse(ip,MLMD,varargin{:});

imgIdx = ip.Results.imgIdx;
show = ip.Results.show;
newFig = ip.Results.newFig;
image = ip.Results.image;
atFrame = ip.Results.atFrame;

%show pop up window to select images when image = 1
numImages  = [];
if image == 1
    
    [fileName,path] = uigetfile('*.tif','Select all desired images','MultiSelect','on');
    numImages = length(fileName);
end

%% Run movies

%determine if input is a MovieList or MD object
if isa(MLMD,'MovieList') %if it is a movieList
    
    listFlag = 1;
    
    %rename to ML
    ML = MLMD;
    clear MLMD
    
    %get number of movies
    numMovies = length(ML.movieDataFile_);
    
else %if it is a MD
    
    listFlag = 0;
    
    %rename to MD
    MD = MLMD;
    clear MLMD
    
    %assign number of movies to 1
    numMovies = 1;
    
end

%If images were loaded using pop up window make sure the number of images
%is the same as the number of movies in ML file
if ~isempty(numImages) && numImages ~= numMovies
    error(['Number of images input (' num2str(numImages) ') must be equal to number of movies in MLMD (' num2str(numMovies) ')'])
end

%go over all movies
for iM = 1 : numMovies
    if listFlag == 1
        MD = MovieData.load(ML.movieDataFile_{iM});
    end
    
    %load images when only the cell mask if going to be plotted
    if ~isempty(numImages) %when images where loaded manually
        
        if atFrame ~=0%read specific frame
            image = double(imread(fullfile(path,fileName{iM}),atFrame));
        
        else%make intensity projectio. Projection will not be saved
            imgInfo = imfinfo(fullfile(path,fileName{iM}));
            numFrames = length(imgInfo);
            image = zeros(imgInfo(1).Height,imgInfo(1).Width,numFrames);
            
            for iFrame = 1:numFrames
                image(:,:,iFrame) = imread(imgInfo(1).Filename,iFrame);
            end
                image = stackTimeProject(image,'max',0);
        end
        
    elseif show == 2 && atFrame ~= 0 %using MD file
        %load an specified frame
        image = double(MD.channels_(imgIdx).loadImage(atFrame));
        
    elseif show == 2 && atFrame == 0
        %make and/or load a maximum intensity projection of the movie
        iProjProc = MD.getProcessIndex('StackTimeProjectProcess',1);
        
        if ~isempty(iProjProc)%load
            projectPath = MD.getProcess(iProjProc).outFilePaths_{imgIdx};
            image = double(imread(projectPath));
            
        else%make
            iProjProc = length(MD.processes_) + 1;
            MD.addProcess(StackTimeProjectProcess(MD))
            
            p = MD.getProcess(iProjProc).getParameters();
            p.projectMethod = 'max';
            p.ChannelIndex = imgIdx;
            
            MD.getProcess(iProjProc).setParameters(p);
            MD.getProcess(iProjProc).run;
            
            projectPath = MD.getProcess(iProjProc).outFilePaths_{imgIdx};
            image = double(imread(projectPath));
        end
        
    end
    
    %load mask
    if show == 2 || show == 3
        try
            % Try to use imported cell mask if no MaskProcess, Kevin Nguyen 7/2016
            iM = MD.getProcessIndex('ImportCellMaskProcess',Inf,0);
            maskIdx = MD.processes_{iM}.funParams_.ChannelIndex;
            inMaskDir = MD.processes_{iM}.outFilePaths_{maskIdx};
            inMaskDir = fileparts(inMaskDir);
            inMaskDir = {inMaskDir}; % Below requires a cell
            maskNames = {{['cellMask_channel_',num2str(maskIdx),'.tif']}};
            
            
        catch
            try
                warning('off', 'lccb:process')
                iM = MD.getProcessIndex('MultiThreshProcess',1,0);
                maskIdx = MD.processes_{iM}.funParams_.ChannelIndex;
                inMaskDir = MD.processes_{iM}.outFilePaths_(maskIdx);
                maskNames = MD.processes_{iM}.getOutMaskFileNames(maskIdx);
                warning('on', 'lccb:process')
            catch
                try
                    warning('off', 'lccb:process')
                    iM = MD.getProcessIndex('MaskProcess',1,0);
                    maskIdx = MD.processes_{iM}.funParams_.ChannelIndex;
                    inMaskDir = MD.processes_{iM}.outFilePaths_(maskIdx);
                    maskNames = MD.processes_{iM}.getOutMaskFileNames(maskIdx);
                    warning('on', 'lccb:process')
                catch
                    warning(['No mask found on moive ' num2str(iM) '. Mask outline Will not be shown'])
                    continue
                end
            end
            
        end
        %get mask boundary
        mask = imread([inMaskDir{1} filesep maskNames{1}{1}]);
        boundMask = bwboundaries(mask);
    end
    
    %load segmentation and non-punctate object image
    if show == 1 || show == 3
        iSegProjProc = MD.getProcessIndex('SegmentBlobsProjectionProcess',1);
        
        iSegProc = MD.getProcessIndex('SegmentBlobsPlusLocMaxSimpleProcess',1);
        
        iSegImportProc = MD.getProcessIndex('ImportSegmentationProcess',1);
        
        if ~isempty(iSegProjProc)
            %when an intensity projection was used for segmentation
            if isempty(numImages)
                iProjProc = MD.getProcessIndex('StackTimeProjectProcess',1);
                projectPath = MD.getProcess(iProjProc).outFilePaths_{imgIdx};
                image = double(imread(projectPath));
            end
            
            segPath = MD.getProcess(iSegProjProc).outFilePaths_{imgIdx};
            
        elseif ~isempty(iSegProc) 
            %when segmentation was done on original image
            segPath = MD.getProcess(iSegProc).outFilePaths_{imgIdx};
            
            if isempty(numImages)
                image = double(MD.channels_(imgIdx).loadImage(1)); %KJ 240912: fixed bug in loading image when it is not first channel
            end
            
        elseif ~isempty(iSegImportProc)
            %when segmentation was imported
            segPath = MD.getProcess(iSegImportProc).outFilePaths_{imgIdx};
            
            if isempty(numImages)
                image = double(MD.channels_(imgIdx).loadImage(imgIdx));
            end
            
        elseif isempty(iSegProc) && isempty(iSegProjProc) && isempty(iSegImportProc)
            
            error('No segmentation process found! Please run a segmentation process.')
            
        end
        
        %get segmentation boundaries
        load(segPath,'maskBlobs')
        bound = bwboundaries(maskBlobs);
        
    end
    
    %scale image
    if show == 2 || show == 3
        if ~isempty(image)
            pxlInMask = mask.*image;
            pxlInMask(pxlInMask ==  0) = nan;
        end
    else
        pxlInMask = image;
             
    end
    
    imageScaled = (pxlInMask - prctile(pxlInMask(:),0.01)) / (prctile(pxlInMask(:),99.99) - prctile(pxlInMask(:),0.01));
    imageScaled(imageScaled<0) = 0;
    imageScaled(imageScaled>1) = 1;
    
    %plot segmentation outline
    if show == 1 || show == 3
        if newFig 
            figure, imshow(imageScaled,[])
            hold on, for i = 1:length(bound); plot(bound{i}(:,2),bound{i}(:,1),'r');end
            
            
        elseif ~newFig
            hold on, for i = 1:length(bound); plot(bound{i}(:,2),bound{i}(:,1),'r');end
        end
        
        %pause(1)
    end
    
    %plot cell mask ouline
    if show == 3 || ~newFig%plot already exist from above
        hold on, plot(boundMask{1}(:,2),boundMask{1}(:,1),'c')
        
    elseif (newFig|| show == 2) && show ~=1 %new figure with input image
        figure, imshow(imageScaled,[])
        hold on, plot(boundMask{1}(:,2),boundMask{1}(:,1),'c')
        
    end
    hold off
    pause(1)
end
end


