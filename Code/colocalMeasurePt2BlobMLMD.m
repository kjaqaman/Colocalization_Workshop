function colocalMeasurePt2BlobMLMD(MLMD,varargin)
%COLOCALMEASUREPT2BLOBMLMD runs Pt2blob colocalization
%
%Synopsis colocalMeasurePt2BlobMLMD(MLMD,varargin)
%
%INPUT
%   Mandatory
%       MLMD: MovieList or MovieData object for movie(s) to be analyzed
%       
% Optional(entered as name-value pairs)
%
%   blobChannel:      blob channel index
%                     Defualt: 2
%
%   detectionChannel: detection channel index
%                     Default: 1
%
%   detectionProcessID: string with the name of the desired detection
%                       process used.
%                       Options: 'SubRes'and 'PointSource'
%                       Default: 'SubRes'
%
%   searchRadius:     distance threshold for possible interacting objects
%                     Default: 3
%
%   alpha:            alpha value for caluclating cCritical
%                     Default: 0.05
%
%OUTPUT
%   Colocalization measure see colocalMeasurePt2Blob for details. 
%   All results store in directory
%
%Jesus Vega-Lugo November 2019
%
%Jesus Vega-Lugo 07/2022 eliminated channelMask from inputs. Added
%detectionProcessID as input to allow the use of subRes and pointSource as
%acceptable detection processes.
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
ip = inputParser;
ip.CaseSensitive = false;
ip.FunctionName = 'colocalMeasurePt2BlobMLMD';

%required parameter 
addRequired(ip,'MLMD',@(x) isa(x,'MovieData') || isa(x,'MovieList'))


%optional parameters
addParameter(ip,'blobChannel',2,@isscalar)
addParameter(ip,'detectionChannel',1,@isscalar)
addParameter(ip,'detectionProcessID','subRes',@ischar)
addParameter(ip,'searchRadius',3,@isscalar)
addParameter(ip,'alpha',0.05,@isscalar)

parse(ip,MLMD,varargin{:})

%% Run movies

%determine if input is a MovieList or MovieData object
if isa(MLMD,'MovieList') %if it is a movieList
    
    listFlag = 1;
    
    %rename to ML
    ML = MLMD;
    clear MLMD
    
    %get number of movies
    numMovies = length(ML.movieDataFile_);
    
else %if it is a movieData
    
    listFlag = 0;
    
    %rename to MD
    MD = MLMD;
    clear MLMD
    
    %assign number of movies to 1
    numMovies = 1;
    
end

%go over all movies
for iM = 1 : numMovies
    %load movie from movielist
    if listFlag == 1
            MD = MovieData.load(ML.movieDataFile_{iM});
    end
    
%% Run Pt2Blob Colocalization
    
    %get process index
    iColoc = MD.getProcessIndex('ColocalizationPt2BlobProcess',1,0);
    
    %if thers no process add it
    if isempty(iColoc)
        iColoc = length(MD.processes_) + 1;
        MD.addProcess(ColocalizationPt2BlobProcess(MD))
    end
    
    %set parameters
    pColoc = MD.getProcess(iColoc).getParameters();
    
    pColoc.ChannelPt  = ip.Results.detectionChannel;
    pColoc.detectionProcessID = ip.Results.detectionProcessID;
    pColoc.ChannelBlob = ip.Results.blobChannel;
    pColoc.SearchRadius = ip.Results.searchRadius;
    pColoc.alphaValue = ip.Results.alpha;
    
    %run process
    MD.getProcess(iColoc).setParameters(pColoc)
    MD.getProcess(iColoc).run
end