function importCellMaskOO(movieData,paramsIn)
%importCellMask imports a previously-defined cell mask to movieData
%
%Khuloud Jaqaman, March 2015
%JesusVega-Lugo, 05/2024 updated to allow for automated importing
%% Input
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

if nargin < 1 || ~isa(movieData,'MovieData')
    error('The first input argument must be a valid MovieData object!')
end

if nargin < 2
    paramsIn = [];
end

iProc = movieData.getProcessIndex('ImportCellMaskProcess',1);

%add process if it wasn't added yet
if isempty(iProc)
    iProc = numel(movieData.processes_)+1;
    movieData.addProcess(ImportCellMaskProcess(movieData));
end

%Parse input, store in parameter structure
p = parseProcessParams(movieData.getProcess(iProc),paramsIn);

%set output directory
importProc = movieData.getProcess(iProc);
outDir = fullfile(movieData.outputDirectory_,'ImportedCellMask',['channel_' num2str(p.ChannelIndex) '.mat']);

importProc.setOutFilePaths(outDir,p.ChannelIndex);

mkdir(fileparts(outDir))


%% --------------- cell mask import ---------------%%%

%ask for file to be imported when no impotFromMLMD file was input
if p.askUser
    [p.fileName,p.filePath,filterIndx] = uigetfile(fullfile(movieData.outputDirectory_,'*.tif'),...
        ['Cell mask file for Channel ' num2str(p.ChannelIndex) ' of Movie ' movieData.movieDataFileName_(1:end-4)]);
else
    filterIndx = 1;
end

%load and save segmentation if found or show error if no file is input
if filterIndx == 0
    error('No file selected');
else
    filePath = p.filePath;
    fileName = p.fileName;
    
    copyfile(fullfile(filePath,fileName),fullfile(p.OutputDirectory,['cellMask_channel_' num2str(p.ChannelIndex) '.tif']));
    save(outDir,'fileName','filePath');
end

movieData.save();

