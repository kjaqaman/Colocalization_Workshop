function stackTimeProjectWrapper(movieData, varargin)
%DETECTMOVIETHRESHLOCMAX compiles detection data from movie frames
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

%% ----------- Input ----------- %%

%Check input
ip = inputParser;
ip.CaseSensitive = false;
ip.addRequired('movieData', @(x) isa(x,'MovieData'));
ip.addOptional('paramsIn',[], @isstruct);
ip.parse(movieData,varargin{:});
paramsIn=ip.Results.paramsIn;

%Get the indices of any previous speckle detection processes                                                                     
iProc = movieData.getProcessIndex('StackTimeProjectProcess',1,0);

%If the process doesn't exist, create it
if isempty(iProc)
    iProc = numel(movieData.processes_)+1;
    movieData.addProcess(StackTimeProjectProcess(movieData,...
        movieData.outputDirectory_));                                                                                                 
end
stackTimeProjectProc = movieData.processes_{iProc};
%Parse input, store in parameter structure
p = parseProcessParams(stackTimeProjectProc,paramsIn);
 

%% --------------- Initialization ---------------%%

nChan=numel(movieData.channels_);
% Set up the input directories
inFilePaths = cell(1,nChan);
for i = p.ChannelIndex
    inFilePaths{1,i} = movieData.getChannelPaths{i};
end
stackTimeProjectProc.setInFilePaths(inFilePaths);
    
% Set up the output directories
outFilePaths = cell(1,nChan);
saveResults(nChan,1)=struct();
dName = 'time_projection_for_channel_';

for i = p.ChannelIndex
    currDir = [p.OutputDirectory filesep dName num2str(i)];
    saveResults(i).dir = currDir ;
    saveResults(i).filename = 'imgProjection.tif';
    %Create string for current directory
    outFilePaths{1,i} = [saveResults(i).dir filesep saveResults(i).filename ];
    stackTimeProjectProc.setOutFilePaths(outFilePaths{1,i},i);
    mkClrDir(currDir);
end


%% --------------- Segmentation Local maxima detection ---------------%%% 

for i = p.ChannelIndex
    disp(['Please wait, making a' p.projectMethod 'intensity projection for channel ' num2str(i)])
    disp(inFilePaths{1,i});
    disp('Results will be saved under:')
    disp(outFilePaths{1,i});
    
    I = NaN(movieData.imSize_(1),movieData.imSize_(2),p.lastImageNum);
    
    %Load Image
    for k = p.firstImageNum:p.lastImageNum
        I(:,:,k) = movieData.channels_(i).loadImage(k);
    end
    
        %Run Detection    
    imgProjection = stackTimeProject(I,p.projectMethod,p.plotRes);
    
    imwrite(uint16(imgProjection),strcat(saveResults(i).dir,'/','imgProjection.tif')) 
end

disp(['Finished time ' p.projectMethod ' intensity projection'])
end