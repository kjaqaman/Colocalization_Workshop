function colocalMeasureBlob2BlobMLMD(MLMD, varargin)
%colocMeasureBlob2BlobMLMD runs Blob2Blob colocalization analysis
%
%SYNOPSIS function colocMeasureBlob2BlobMLMD(MLMD, varargin) 
%
%INPUT 
%   Mandatory
%       MLMD: MovieList or MovieData object for movie(s) to be analyzed
%       
% Optional(entered as name-value pairs)
%
%       detectedChannels: which 2 channels to analyze
%                      Default: [1 2]
%
%       searchRadius: distance threshold for colocalization (in pixels)
%                     Defualt: 3
%
%       numRandomizations: number of randomizations to be used for calculating
%                      randC value. (see vega-Lugo et al. for randC defintion)
%                      Default: 1
%
%
%OUTPUT 
%All results stored in directory. See function colocalMeasurePt2Pt for
%details on outputs.
%
%Mamerto Cruz (July, 2022)
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
ip.FunctionName = 'colocMeasureBlob2BlobMLMD';

%reuired parameters
addRequired(ip,'MLMD',@(x) isa(x,'MovieData') || isa(x,'MovieList'))

%optinal parameters
addParameter(ip,'detectedChannels',[1 2],@isvector); % TP 240820
addParameter(ip,'searchRadius',3,@isscalar)
addParameter(ip,'numRandomizations',1,@isscalar)
%addParameter(ip,'alpha',0.05,@isscalar)

parse(ip,MLMD,varargin{:})


%% Analysis

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

%go over all movies and run Blob2Blob colocalization
for iM = 1 : numMovies
    
    %get movieData of current movie
    if listFlag == 1
        MD = MovieData.load(ML.movieDataFile_{iM});
    end
    
    %add detection process if never run before
    iProc = MD.getProcessIndex('ColocalizationBlob2BlobProcess',1,0);
    if isempty(iProc)
        iProc=numel(MD.processes_)+1;
        MD.addProcess(ColocalizationBlob2BlobProcess(MD));
    end
    
    
    
    p = MD.getProcess(iProc).getParameters();
    
    p.detectedChannels = ip.Results.detectedChannels; %TP 240820 Pulled out from comment
%     p.DetectionProcessID = ip.Results.detectionProcessID;
        
    p.SearchRadius = ip.Results.searchRadius;
    p.NumRandomizations = ip.Results.numRandomizations;
%    p.AlphaValue = ip.Results.alpha;

    MD.getProcess(iProc).setParameters(p);
    MD.getProcess(iProc).run
    
end