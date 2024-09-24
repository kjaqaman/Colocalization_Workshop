classdef SegmentBlobsPlusLocMaxSimpleProcess < ImageProcessingProcess
    % A concrete class for detecting large and diffraction-limited objects using thresholding and local maxima detection
    % Tony Vega 09/2017
    % Orginal Khuloud Jaqaman
    %
    %Jesus Vega-Lugo Modified November 2023 the process inheritance from <
    %detectionProcess to < ImageProcessingProcess (no conflicts where found
    %by making this change)
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
    
    methods (Access = public)
        function obj = SegmentBlobsPlusLocMaxSimpleProcess(owner, varargin)
            % Input check
            ip = inputParser;
            ip.addRequired('owner',@(x) isa(x,'MovieData'));
            ip.addOptional('outputDir',owner.outputDirectory_,@ischar);
            ip.addOptional('funParams',[],@isstruct);
            ip.parse(owner,varargin{:});
            outputDir = ip.Results.outputDir;
            funParams = ip.Results.funParams;
            
            
            % Constructor of the SegmentBlobsPlusLocMaxSimpleProcess
            
            super_args{1} = owner;
            super_args{2} = SegmentBlobsPlusLocMaxSimpleProcess.getName;
            super_args{3} = @segmentLocMaxWrapper;
            if isempty(funParams)  % Default funParams
                funParams = SegmentBlobsPlusLocMaxSimpleProcess.getDefaultParams(owner,outputDir);
            end
            super_args{4} = funParams;
            if(nargin > 4)
                super_args{5:nargin} = varargin{5:nargin};
            end
            obj = obj@ImageProcessingProcess(super_args{:});            
        end
        function varargout = loadChannelOutput(obj,iChan,varargin)
            
            % Input check
            outputList = {'maskBlobs','labels','maskBlobsVis'};
            ip =inputParser;
            ip.StructExpand = true;
            ip.addRequired('iChan',@(x) isscalar(x) && obj.checkChanNum(x));
            ip.addOptional('iFrame',1:obj.owner_.nFrames_,@(x) all(obj.checkFrameNum(x)));
            ip.addParamValue('useCache',false,@islogical);
            ip.addParamValue('output',outputList,@(x) all(ismember(x,outputList)));
            ip.parse(iChan,varargin{:})
            iFrame = ip.Results.iFrame;
            output = ip.Results.output;
            if ischar(output),output={output}; end
            
            % Data loading
            % load outFilePaths_{1,iChan}
            %
            s = cached.load(obj.outFilePaths_{1,iChan}, '-useCache', ip.Results.useCache, output{:});
           
            if numel(ip.Results.iFrame)>1,
                varargout{1}=s.(output{1});
            else
                switch(output{1})
%                     case 'movieInfo'
%                         if numel(ip.Results.iFrame)>1,
%                             varargout{1}=s.(output{1});
%                         else
%                             varargout{1}=s.(output{1})(iFrame);
%                         end
                    case 'maskBlobsVis'
                        if(iFrame <= obj.funParams_.lastImageNum)
                            varargout{1}=s.(output{1})(:,:,iFrame);
                        else
                            varargout{1} = zeros(size(s.(output{1})(:,:,1)));
                        end
                end
            end
        end
         function output = getDrawableOutput(obj)
%             nOutput = 2;
% %             colors = parula(numel(obj.owner_.channels_)*nOutput);
            % Rename default detection output
%             output(1) = getDrawableOutput@DetectionProcess(obj);
%             output(1).name='Sub-resolution objects';
            
            output(1).name='Segmented Objects';
            output(1).var='maskBlobsVis';            
            output(1).type='overlay';
%             if isempty(obj.maxIndex_)            
            output(1).formatData=@MaskProcess.getMaskBoundaries;
%             colors = hsv(numel(obj.owner_.channels_));
%             output(2).defaultDisplayMethod=@(x) LineDisplay('Color',colors(x,:));
            output(1).defaultDisplayMethod=@(x) LineDisplay('Color','m');
%             else
%                 cMap = randomColormap(obj.maxIndex_,42);%random colors since index is arbitrary, but constant seed so we are consistent across frames.
%                 output(2).formatData=@(x)(MaskProcess.getMaskOverlayImage(x,cMap));
%                 %If index values for diff channels are to be differentiated
%                 %they must be done at the level of the indexes.
%                 output(2).defaultDisplayMethod=@ImageOverlayDisplay;
%                 
%                 output(3).name='Object Number';
%                 output(3).var = 'number';
%                 output(3).type = 'overlay';
%                 output(3).formatData=@(x)(MaskProcess.getObjectNumberText(x,cMap));
%                 output(3).defaultDisplayMethod=@TextDisplay;
%                 
%                 
%             end
% %             output(1).name='Meshwork';
% %             output(1).var='S4';
% %             output(1).formatData=@(x) x.getEdgeXY;
% %             output(1).type='overlay';
% %             output(1).defaultDisplayMethod=@(x) LineDisplay('Marker','none',...
% %                 'Color',colors((x-1)*nOutput+1,:));
% %             
% %             output(2).name = 'Junctions';
% %             output(2).var='S4v';
% %             output(2).formatData=@(x) x.getVertexXY;
% %             output(2).type='overlay';
% %             output(2).defaultDisplayMethod=@(x) LineDisplay('Marker','x',...
% %                 'LineStyle','none','Color',colors((x-1)*nOutput+2,:));

        end 
%         function output = getDrawableOutput(obj)
%             % Rename default detection output
%             output = getDrawableOutput@DetectionProcess(obj);
%             output(1).name='Sub-resolution objects';
%         end
        
    end
    methods (Static)
        
        function name = getName()
            name = 'SegmentBlobsPlusLocMaxSimple';
        end

        function funParams = getDefaultParams(owner,varargin)
            % Input check
            ip=inputParser;
            ip.addRequired('owner',@(x) isa(x,'MovieData'));
            ip.addOptional('outputDir',owner.outputDirectory_,@ischar);
            ip.parse(owner, varargin{:})
            outputDir=ip.Results.outputDir;
            
            % Set default parameters
            % moviePara  
            funParams.ChannelIndex =1;
            funParams.OutputDirectory = [outputDir  filesep 'SegmentBlobsPlusLocMaxSimple'];

            numChan = numel(owner.channels_);
            % detectionParam           
            funParams.detectionParam.thresholdMethod = cell(1,numChan);
            funParams.detectionParam.methodValue = NaN(1,numChan);
            funParams.detectionParam.filterNoise = NaN(1,numChan);
            funParams.detectionParam.filterBackground = NaN(1,numChan);
            funParams.detectionParam.minSize = NaN(1,numChan);
            funParams.detectionParam.locMax = zeros(1,numChan);
            funParams.plotRes = zeros(1,numChan);
        end

    end
    
end