function colocAnalysisPt2PtMLMD(MLMD, varargin)
%colocAnalysisPt2PtMLMD run colocalization analysis for punctate objects
%
%SYNOPSIS function colocAnalysisPt2PtMLMD(MLMD, varargin) 
%
%INPUT 
%   Mandatory
%       MLMD: MovieList or MovieData object for movie(s) to be analyzed
%       
% Optional(entered as name-value pairs)
%
%       detectedChannels = 1x2 vector containing the channel index of
%                          detected objects.
%                          Default: [1 2]
%
%       detectionProcessID: cell containing desired detection process for 
%                           colocalization for each channel.
%                           {ProceesForChannel1 ProcessForChannel2}
%                           Options: 'SubRes'and 'PointSource'
%                           Defaul: {'SubRes' 'SubRes'}
%
%       searchRadius: distance threshold for colocalization (in pixels)
%                     Defualt: 3
%
%       alphaValue: alpha value for comparing real data to random
%                   Default: 0.05
%
%OUTPUT 
%All results stored in directory. See function colocalMeasurePt2Pt for
%details on outputs.
%
%Jesus Vega-Lugo (May, 2019) 
%
%Jesus Vega-Lugo 07/2022 modified to use input parser. Added
%detectedChannels as a parameter to allow 2-way colocalization on images
%with more than two channels.
%
%Khuloud Jaqaman 03/2024: Related to Jesus' modification above, it turns
%out he did not properly propagate that detectedChannels option into the
%Wrapper function colocalizationPt2PtWrapper. I fixed this bug, and now
%this option is properly utilized in that function. See Wrapper function
%for more details.
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
ip.FunctionName = 'colocAnalysisPt2PtMLMD';

%reuired parameters
addRequired(ip,'MLMD',@(x) isa(x,'MovieData') || isa(x,'MovieList'))

%optinal parameters
addParameter(ip,'detectedChannels',[1 2],@isvector)
addParameter(ip,'detectionProcessID',{'SubRes' 'SubRes'},@iscell)
addParameter(ip,'searchRadius',3,@isscalar)
addParameter(ip,'alpha',0.05,@isscalar)

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

%go over all movies and run Pt2Pt colocalization
for iM = 1 : numMovies
    
    %get movieData of current movie
    if listFlag == 1
        MD = MovieData.load(ML.movieDataFile_{iM});
    end
    
    %add detection process if never run before
    iProc = MD.getProcessIndex('ColocalizationPt2PtProcess',1,0);
    if isempty(iProc)
        iProc=numel(MD.processes_)+1;
        MD.addProcess(ColocalizationPt2PtProcess(MD));
    end
    
    
    
    p = MD.getProcess(iProc).getParameters();
    
    p.detectedChannels = ip.Results.detectedChannels;
    p.DetectionProcessID = ip.Results.detectionProcessID;
        
    p.SearchRadius = ip.Results.searchRadius;
    p.AlphaValue = ip.Results.alpha;

    MD.getProcess(iProc).setParameters(p);
    MD.getProcess(iProc).run
    
end

