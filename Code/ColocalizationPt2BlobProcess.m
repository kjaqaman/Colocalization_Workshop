classdef ColocalizationPt2BlobProcess < ImageAnalysisProcess
   % A concreate class for measuring colocalization between two images
   % Anthony Vega 09/2014
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
        function obj = ColocalizationPt2BlobProcess(owner,varargin)
            
            if nargin == 0
                super_args = {};
            else
                % Input check
                ip = inputParser;
                ip.addRequired('owner',@(x) isa(x,'MovieData'));
                ip.addOptional('outputDir',owner.outputDirectory_,@ischar);
                ip.addOptional('funParams',[],@isstruct);
                ip.parse(owner,varargin{:});
                outputDir = ip.Results.outputDir;
                funParams = ip.Results.funParams;
                
                % Define arguments for superclass constructor
                super_args{1} = owner;
                super_args{2} = ColocalizationPt2BlobProcess.getName;
                super_args{3} = @colocalizationPt2BlobWrapper;
                if isempty(funParams)
                    funParams = ColocalizationPt2BlobProcess.getDefaultParams(owner,outputDir);
                end
                super_args{4} = funParams;
                if(nargin > 4)
                    super_args{5:nargin} = varargin{5:nargin};
                end
            end
            
            obj = obj@ImageAnalysisProcess(super_args{:});
        end
        
    end
    methods (Static)
        function name = getName()
            name = 'ColocalizationPt2Blob';
        end

        function methods = getMethods(varargin)
            colocalizationMethods(1).name = 'Point2Blob';
            colocalizationMethods(1).func = @colocalMeasurePt2Blob;            
            
            ip=inputParser;
            ip.addOptional('index',1:length(colocalizationMethods),@isvector);
            ip.parse(varargin{:});
            index = ip.Results.index;
            methods=colocalizationMethods(index);
        end
        
        function funParams = getDefaultParams(owner,varargin)
            % Input check
            ip=inputParser;
            ip.addRequired('owner',@(x) isa(x,'MovieData'));
            ip.addOptional('outputDir',owner.outputDirectory_,@ischar);
            ip.parse(owner, varargin{:})
            outputDir=ip.Results.outputDir;
            
            % Set default parameters
            funParams.ChannelPt = 1;
            funParams.detectionProcessID = 'subRes';
            funParams.ChannelBlob = 2;
            funParams.SearchRadius = 3;
            funParams.alphaValue = 0.05;
            funParams.blobSize = [];
            funParams.sizeThresh = [];
            funParams.OutputDirectory = [outputDir  filesep];
            funParams.ProcessIndex = [];
        end
    end
end