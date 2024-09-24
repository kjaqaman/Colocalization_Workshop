classdef StackTimeProjectProcess < ImageProcessingProcess
   % A concreate class for making an intensity projection over time stack
   %Original Anthony Vega 09/2014
   %Jesus Vega-Lugo 09/2019 adapted for image intensity projection
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
        function obj = StackTimeProjectProcess(owner,varargin)
            
            if nargin == 0
                super_args = {};
            else
                % Input check
                ip = inputParser;
                ip.addRequired('owner',@(x) isa(x,'MovieData') || isa(x,'MovieList'));
                ip.addOptional('outputDir',owner.outputDirectory_,@ischar);
                ip.addOptional('funParams',[],@isstruct);
                ip.parse(owner,varargin{:});
                outputDir = ip.Results.outputDir;
                funParams = ip.Results.funParams;
                
                % Define arguments for superclass constructor
                super_args{1} = owner;
                super_args{2} = StackTimeProjectProcess.getName;
                super_args{3} = @stackTimeProjectWrapper;
                if isempty(funParams)
                    funParams = StackTimeProjectProcess.getDefaultParams(owner,outputDir);
                end
                super_args{4} = funParams;
                if(nargin > 4)
                    super_args{5:nargin} = varargin{5:nargin};
                end
            end
            
            obj = obj@ImageProcessingProcess(super_args{:});
        end
        
    
    
        function varargout = loadChannelOutput(obj,iChan,varargin)

                % Input check
                outputList = {'maskBlobs'};
                ip =inputParser;
                ip.StructExpand = true;
                ip.addRequired('iChan',@(x) isscalar(x) && obj.checkChanNum(x));
                ip.addOptional('iFrame',1:obj.owner_.nFrames_,@(x) all(obj.checkFrameNum(x)));
                ip.addParamValue('useCache',false,@islogical);
                ip.addParamValue('output',outputList,@(x) all(ismember(x,outputList)));
                ip.parse(iChan,varargin{:})
                % = ip.Results.iFrame;
                output = ip.Results.output;
                if ischar(output),output={output}; end

                s = cached.load(obj.outFilePaths_{1,iChan}, '-useCache', ip.Results.useCache, output{:});

                varargout = s;
        end     
   end
        
    methods (Static)
        function name = getName()
            name = 'StackTimeProject';
        end
        
        function output = getDrawableOutput()
            output(1).name='Images';
            output(1).var='';
            output(1).formatData=@mat2gray;
            output(1).type='image';
            output(1).defaultDisplayMethod=@ImageDisplay;
        end

        
        function funParams = getDefaultParams(owner,varargin)
            % Input check
            ip=inputParser;
            ip.addRequired('owner',@(x) isa(x,'MovieData') || isa(x,'MovieList'));
            ip.addOptional('outputDir',owner.outputDirectory_,@ischar);
            ip.parse(owner, varargin{:})
            outputDir=ip.Results.outputDir;
            
            %set default parameters
            
            %movie param
            funParams.ChannelIndex = 2;
            funParams.firstImageNum = 1;
            funParams.lastImageNum = owner.nFrames_;
            funParams.OutputDirectory = [outputDir  filesep 'StackTimeProject'];
            
            
            funParams.projectMethod = 'mean';
            funParams.plotRes = 0;
            
        end
    end
end