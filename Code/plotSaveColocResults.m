function plotSaveColocResults(PtOrBlob, plotting, saveRes, pathToSave, guiFlag, channelsToAnalyze, varargin)
%PLOTSAVECONDITIONALCOLOC plots and/or saves 2-color colocalization results
%
% SYNOPSIS plotSaveConditionalColoc(PtOrBlob,plotting, saveRes,pathToSave, guiFlag, varargin)
%
%INPUT
%   PtOrBlob:  1 for plotting Pt2Pt, 2 for Pt2Blob, or 3 for Blob2Blob
%
%   plotting:  1 to plot colocalization results, 0 otherwise
%              Default: 1
%
%   saveRes:   1 to save colocalization results and/or figures, 0 otherwise
%              When saveRes = 1 follow prompt in command window to
%              choose what to save.
%              Default: 0
%
%  pathToSave: desired path to save figures and/or mat files.
%              Optional: if left empty a dialog box will show asking user
%                        where to save. If saveRes = 0 path will be ignored.
%              Default: empty, that is, pathToSave = []
%
%    guiFlag:  1 if function is being used in the GUI, 0 if function is
%              being used in the console.
%              Default: 0
%
%              TP 240826: Added user inputted channels to analyze
%   channelsToAnalyze: user inputted channels to compile from the ML/MD
%                      (will ignore passed in parameter from MLMD)
%                      Default: []
%                      Format: [1 2]
%
%   varargin:  MovieList or MovieData files (minimum 1 file, no maximum)
%
%OUTPUT
% Function outputs plots (when plotting = 1) and compiled colocalization
% measures and number of objects (when saveRes = 1)). When saving files a
% window will ask user to select where to save results if pathToSave
% is empty. Otherwise, results are saved at pathToSave.
%
%   Saving MovieList information:
%       A mat file called compiledDataInfo will be saved at the specified
%       path containing:
%
%           dataCompiledFrom:   path from where each ML was taken
%
%           numOfCells:         number of cells that were compiled
%
%           searchRadius:       distance threshold used on each ML or MD (see
%                               colocAnalysisPt2PtMLMD or colocAnalysisPt2BlobMLMD
%                               documentation for details of this parameter)
%
%           detectionProcessID: dectection process used for each ML or MDfile
%                               (see colocAnalysisPt2PtMLMD or
%                               colocAnalysisPt2BlobMLMD documentation
%                               for details of this parameter).
%
%   Saving colocalizaition results:
%       A mat file with colocalization results will be saved in chosen
%       directory. See output of colocalMeasurePt2Pt and
%       colocalMeasurePt2Blob for details on each parameter
%
%       When saving results from Pt2Pt colocalization
%           Column1: Results when reference is channel 1 and target is
%                    channel 2.
%
%           Column2: Results when reference is channel 2 and target is
%                    channel 1.
%
%Jesus Vega-Lugo April 2022
%
%Mamerto Cruz July 2022 Added guiFlag parameter that determines whether or
%not the function is being used in the GUI or console and tells function to
%ignore the prompt asking for what to save. Also added Blob2Blob plotting
%fuctionality.
%
%Khuloud Jaqaman August 2024. Ordered variables read from colocalization
%analysis results in ASCII order, to make sure that the right results are
%concatenated across movies and movie lists.

%% Parse inputs

%check that type of colocalization to be plotted is specified correctly
if nargin < 1
    error('specify type of Colocalization to be plotted. Enter 1 for plotting Pt2Pt, 2 for Pt2Blob, or 3 for Blob2Blob.')
    
elseif PtOrBlob ~= 1 && PtOrBlob ~= 2 && PtOrBlob ~= 3
    error('Invalid entry. Enter 1 for plotting Pt2Pt, 2 for Pt2Blob, or 3 for Blob2Blob.')
    
    %display text showing the type of colocalization being plotted
elseif PtOrBlob == 1
    disp('Plotting Pt2Pt conditional colocalization')
    
elseif PtOrBlob == 2
    disp('Plotting Pt2Blob conditional colocalization')
    
elseif PtOrBlob == 3
    disp('Plotting Blob2Blob conditional colocalization')
    
end

%check plotting
if nargin < 2 || isempty(plotting)
    plotting = 1;
end

%check save
if nargin < 3 || isempty(saveRes) || saveRes == 0
    whatToSave = 0;
    
elseif saveRes == 1
    %whatToSave = 4;
    if guiFlag == 1
        whatToSave = 4; %KJ 240821: Made this 4 (instead of 3) to be equivalent to conditional coloc code and to allow for saving number of objects (would be option 3) down the road
    else
        whatToSave = input(['\n' 'Do you want to save the figures, the compiled data values, the number of objects per cell'...
            '\n' 'in a .mat file, or all?'...
            '\n' 'Enter 1 for figures, 2 for compiled data values, 4 for all'...
            '\n' '\n' 'Enter number: ']);
    end
end

%check path
if ~isempty(pathToSave) && ~ischar(pathToSave)
    error('Path must be of type char')
elseif ~isempty(pathToSave)
    pathSaveInfo = pathToSave;
end

%check that at least one movie list is input
if isempty(varargin)
    error('At least one MovieList or 2 MovieData files must be input.')
end

%% Check MovieData and MovieList input

numMLMDs = length(varargin);

dataCompiledFrom = cell(numMLMDs,1);

check = NaN(1,numMLMDs);
mls = NaN(1,numMLMDs);
mds = NaN(1,numMLMDs);
for i = 1:numMLMDs
    
    mls(i) = isa(varargin{i},'MovieList');
    mds(i) = isa(varargin{i},'MovieData');
    check(i) = (mls(i) || mds(i));
    
end
if ~all(check) %when not all entries of MLMD are MovieData or MovieList
    notMLMDIdx = find(check~=1);
    error(['All MLMD entries must be either MovieList or MovieData files. Files on indices ' num2str(notMLMDIdx) ' are not of these types'])
    
elseif numel(find(mls)) == numMLMDs %when all MLMD entries are MovieLists
    
    
    moviesPerML = NaN(numMLMDs,1);
    totalMovies = 0;
    
    for ml = 1:numMLMDs
        moviesPerML(ml) = length(varargin{ml}.movieDataFile_);
        totalMovies = totalMovies + moviesPerML(ml);
        dataCompiledFrom{ml} = varargin{ml}.movieListPath_;
    end
    
elseif numel(find(mds)) == numMLMDs %when all MLMD entires are MovieData
    
    totalMovies = numMLMDs;
    moviesPerML = ones(1,numMLMDs);
    
    for md = 1:numMLMDs
        dataCompiledFrom{md} = varargin{md}.outputDirectory_;
    end
    
else %when MLMD entries are a mix of MovieData and MovieList files
    
    
    moviesPerML = NaN(numMLMDs,1);
    totalMovies = 0;
    
    for ml = 1:numMLMDs
        if mls(ml)
            moviesPerML(ml) = length(varargin{ml}.movieDataFile_);
            totalMovies = totalMovies + moviesPerML(ml);
            dataCompiledFrom{ml} = varargin{ml}.movieListPath_;
        else
            moviesPerML(ml) = 1;
            totalMovies = totalMovies + 1;
            dataCompiledFrom{ml} = varargin{ml}.outputDirectory_;
        end
    end
end

%% Extract and store colocalization results

colocSummary = cell(totalMovies,11); %KJ 240821: Proper initialization. 11 columns, not 6.

searchRadius = NaN(numMLMDs,1);
detectionProcessID = cell(numMLMDs,1);

tempNumMovies = 0;
%go through all movielist
for ml = 1:numMLMDs
    
    %go through every movie on the current MovieList
    for mv = 1:moviesPerML(ml)
        
        if mls(ml)
            MD = MovieData.load(varargin{ml}.movieDataFile_{mv});
        else
            MdPath = fullfile(varargin{ml}.movieDataPath_,varargin{ml}.movieDataFileName_);
            MD = MovieData.load(MdPath);
        end
        
        %check if plotting Pt2Pt2Pt or Pt2Pt2Blob
        if PtOrBlob == 1 %Pt2Pt
            
            iProc = MD.getProcessIndex('ColocalizationPt2PtProcess',1);
            p = MD.getProcess(iProc).funParams_;
            % TP 240826: Switch to user inputted channels if passed
            if ~isempty(channelsToAnalyze)
                p.detectedChannels = channelsToAnalyze;
            end
            % TP 240826: concat detectedChannels to colocalInfo to read correct filename
            currentDirC = fullfile(MD.getProcess(iProc).funParams_.OutputDirectory,...
                'ColocalizationPt2Pt', ['colocalInfo' num2str(p.detectedChannels(1)) num2str(p.detectedChannels(2)) '.mat']);
            
            %will be used for figure titles
            saveTitle = {['Ref' num2str(p.detectedChannels(1)) 'Target' num2str(p.detectedChannels(2))],...
                ['Ref' num2str(p.detectedChannels(2)) 'Target' num2str(p.detectedChannels(1))]};
            
        elseif PtOrBlob == 2 %Pt2Blob
            
            iProc = MD.getProcessIndex('ColocalizationPt2BlobProcess',1);
            p = MD.getProcess(iProc).funParams_; %added to be able to recognize names of Pt2Blob results
            % Switch to user inputted channels if passed
            if ~isempty(channelsToAnalyze)
                p.ChannelPt = channelsToAnalyze(1);
                p.ChannelBlob = channelsToAnalyze(2);
            end
            p.detectedChannels = [p.ChannelPt p.ChannelBlob];
            currentDirC = fullfile(MD.getProcess(iProc).funParams_.OutputDirectory,...
                'ColocalizationPt2Blob',['colocalInfo' num2str(p.ChannelPt) num2str(p.ChannelBlob) '.mat']);
            
            %will be used for figure titles
            saveTitle = {['Ref' num2str(p.ChannelBlob) 'Target' num2str(p.ChannelPt)], []};
            
        elseif PtOrBlob == 3 %Blob2Blob
            
            iProc = MD.getProcessIndex('ColocalizationBlob2BlobProcess',1);
            p = MD.getProcess(iProc).funParams_; % TP, added to mirror above
            % Switch to user inputted channels if passed
            if ~isempty(channelsToAnalyze)
                p.detectedChannels = channelsToAnalyze;
            end
            % TP 240822: concat detectedChannels to colocalInfo to read correct filename
            currentDirC = fullfile(MD.getProcess(iProc).funParams_.OutputDirectory,...
                'ColocalizationBlob2Blob',['colocalInfo' num2str(p.detectedChannels(1)) num2str(p.detectedChannels(2)) '.mat']);
            
            %Old comment by Jesus:
            %This process doesn't take channel index as input, thus, it
            %doesn't store channel info. MLMD and wrapper function will
            %need to be modified so channel indices are stored so saveTitle
            %can be defined as above
            
            % TP 20240821, added detectedChannels as input, so saveTitle
            % functionality now added to Blob2Blob
            saveTitle = {['Ref' num2str(p.detectedChannels(1)) 'Target' num2str(p.detectedChannels(2))],...
                ['Ref' num2str(p.detectedChannels(2)) 'Target' num2str(p.detectedChannels(1))]};
            
        end
        
        if PtOrBlob == 3
            detectionProcessID{ml} = {'Segmentation','Segmentation'};
            searchRadius(ml) = MD.getProcess(iProc).funParams_.SearchRadius;
            %numRandomizations(ml) = MD.getProcess(iProc).funParams_.numRandomizations;
        else
            searchRadius(ml) = MD.getProcess(iProc).funParams_.SearchRadius;
            %detectionProcessID{ml} = MD.getProcess(iProc).funParams_.DetectionProcessID;
        end
        
        %colocalization values
        %KJ 240821: Sort the fields of tempC in ASCII order to avoid
        %nonsensical concatenation of values when the variables in the
        %colocalization output file are not stored in the same order
        %between different movies.
        tempC = load(currentDirC);
        tempC = orderfields(tempC);
        fieldNamesC = fieldnames(tempC);
        numCategories = length(fieldNamesC);
        
        %store colocalization values of each movie
        c = 1;
        for f = 1:numCategories
            colocSummary{mv+tempNumMovies,c} = tempC.(fieldNamesC{f});
            c = c + 1;
        end
    end
    tempNumMovies = tempNumMovies + mv;
    
end

%% Preamble for results assembly and plotting

cT = NaN(totalMovies,2);
cNull = NaN(totalMovies,2);
cCritical = NaN(totalMovies,2);
estimatorM = NaN(totalMovies,2);
estimatorC = NaN(totalMovies,2);


for mv = 1:totalMovies
    if PtOrBlob == 1
        
        %KJ 240821: This is the old extraction, without ordering the fields
        %         cT(mv,:) = horzcat(colocSummary{mv,[1 6]});
        %         cNull(mv,:) = horzcat(colocSummary{mv,[2 7]});
        %         cCritical(mv,:) = horzcat(colocSummary{mv,[3 8]});
        %         estimatorM(mv,:) = horzcat(colocSummary{mv,[4 9]});
        %         estimatorC(mv,:) = horzcat(colocSummary{mv,[5 10]});
        
        
        %KJ 240821: New extraction, with fields ordered by ASCII order
        cT(mv,:) = horzcat(colocSummary{mv,[5 6]});
        cNull(mv,:) = horzcat(colocSummary{mv,[3 4]});
        cCritical(mv,:) = horzcat(colocSummary{mv,[1 2]});
        estimatorM(mv,:) = horzcat(colocSummary{mv,[10 11]});
        estimatorC(mv,:) = horzcat(colocSummary{mv,[8 9]});
        
    elseif PtOrBlob == 2
        
        %KJ 240821: This is the old extraction, without ordering the fields
        %         cT(mv,:) = colocSummary{mv,1};
        %         cNull(mv,:) = colocSummary{mv,2};
        %         cCritical(mv,:) = colocSummary{mv,3};
        
        %KJ 240821: New extraction, with fields ordered by ASCII order
        cT(mv,:) = colocSummary{mv,3};
        cNull(mv,:) = colocSummary{mv,2};
        cCritical(mv,:) = colocSummary{mv,1};
        
    else
        
        %KJ 240821: This is the old extraction, without ordering the fields
        %ALSO, THIS EXTRACTION IS INCOMPLETE. Blob2Blob is symmetric, like
        %Pt2Pt
        %           cT(mv,:) = colocSummary{mv,1};
        %           cNull(mv,:) = colocSummary{mv,2};
        
        %TP 240822: Updated with new extraction method
        cT(mv,:) = horzcat(colocSummary{mv, [3 4]});
        cNull(mv,:) = horzcat(colocSummary{mv, [1 2]});
        
    end
end

%get the scale for y axis
%cTMaxY = max(vertcat(cT(:),cNull(:)),[],'omitnan');

% maxYVals = round(cTMaxY + 0.5,1);
% minY = -0.01;
%
labelX = {'p(TwR)' 'nullTR'};

%% Plotting

if plotting
    
    for iFig = 1 : 2-(PtOrBlob==2) %KJ 240912: this loop end replaces the earlier if statement inside the loop
        
        %group boxes in quadruples
        group = repelem((1:2)',totalMovies);
        
        %space holder
        sh = repmat({'x1','x2'},totalMovies,1);
        
        resultBox = [cT(:,iFig) cNull(:,iFig)];
        
        figure, boxplot(resultBox(:),{group, sh(:)},'notch','on','factorgap',...
            6,'color',[0 0 1;0 0 0],'Width',1,'OutlierSize',10,'Symbol','mo')%[0 0 1;0 0 0;0 0.5 0;0.85 0.325 0.098]
        
        h = gca;
        
        annotation('textbox',[0.2 0.5 0.3 0.3],'string',{'Blue = Data',...
            'Black = nullTR'},'fitboxtotext','on')
        
        %get x coordinates to plot data points on top of boxes
        g = findobj(h,'Tag','Box');
        for i = 1:length(g)
            center(i) = mean(g(i).XData([1,6]));
        end
        
        %repaet x value as many times as there are y values on each box
        xScatter = flip(repelem(center',totalMovies));
        center = [];
        
        hold on
        
        blue = 1:totalMovies;
        
        scatter(xScatter(blue),resultBox(blue)','MarkerEdgeColor',[0 0 1],'LineWidth',0.75)
        
        black = totalMovies+1:totalMovies*2;
        
        scatter(xScatter(black),resultBox(black)','MarkerEdgeColor',[0 0 0],'LineWidth',0.75)
        
        h.XTick = [1 2.06];
        h.XTickLabel = labelX;
        h.FontWeight = 'bold';
        
        %    ylim([minY maxYVals])
        ylabel('Colocalization Fraction','fontweight','bold')
        title(saveTitle{iFig})
        
        hold off
        pause(0.5)
        
        %saving plot
        if (whatToSave == 1 || whatToSave == 4)
            
            %pick proper saveTitle
            currTitle = saveTitle{iFig};
            
            if isempty(pathToSave)%when no pathToSave was input ask for it
                [file, pathToSave] = uiputfile('*.fig','Choose where to save figure',['colocResult' currTitle '.fig']);
                
                if pathToSave == 0 %if no path enter on dialog box show warning and continue
                    warning('No path was enter, this figure will NOT be saved!')
                    pathToSave = [];
                else
                    savefig(fullfile(pathToSave,file))
                    pathToSave = [];
                end
            else %when pathToSave was input, save there
                savefig(fullfile(pathSaveInfo,['colocResult' currTitle '.fig']))
            end
            
        end%if saving plot
        
    end%%for plot
    
end%if plotting

%% Save results

if (whatToSave == 2 || whatToSave == 4)
    resFileName = ['compiledColocResults' num2str(p.detectedChannels(1)) num2str(p.detectedChannels(2)) '.mat'];
    
    if PtOrBlob == 1
        if isempty(pathToSave)%ask where to save if no path was input
            [file, pathToSave] = uiputfile('*.mat','Choose where to save compiled colocalization results',resFileName);
            
            if pathToSave == 0 %if no path enter on dialog box show warning and continue
                warning('No path was entered, this mat file will NOT be saved!')
                pathToSave = [];
            else
                save(fullfile(pathToSave,file),'cT','cNull','cCritical','estimatorM','estimatorC')
                pathToSave = [];
            end
        else
            save(fullfile(pathSaveInfo, resFileName),'cT','cNull','cCritical','estimatorM','estimatorC')
        end
        
    elseif PtOrBlob == 2
        
        if isempty(pathToSave)%ask where to save if no path was input
            [file, pathToSave] = uiputfile('*.mat','Choose where to save compiled colocalization results',resFileName);
            
            if pathToSave == 0 %if no path enter on dialog box show warning and continue
                warning('No path was entered, this mat file will NOT be saved!')
                pathToSave = [];
            else
                save(fullfile(pathToSave,file),'cT','cNull','cCritical')
                pathToSave = [];
            end
            
        else
            save(fullfile(pathSaveInfo,resFileName),'cT','cNull','cCritical')
        end
        
    elseif PtOrBlob == 3
        
        if isempty(pathToSave)%ask where to save if no path was input
            [file, pathToSave] = uiputfile('*.mat','Choose where to save compiled colocalization results',resFileName);
            
            if pathToSave == 0 %if no path enter on dialog box show warning and continue
                warning('No path was entered, this mat file will NOT be saved!')
                pathToSave = [];
            else
                save(fullfile(pathToSave,file),'cT','cNull')
                pathToSave = [];
            end
            
        else
            save(fullfile(pathSaveInfo,resFileName),'cT','cNull')
        end
        
    end
end

%% Save datasets info

if whatToSave
    
    numOfCells = totalMovies;
    
    if isempty(pathToSave)%ask where to save if no path was input
        
        [file, pathToSave] = uiputfile('*.mat','Choose where to save dataset metadata',...
            ['compiledDataInfo' num2str(p.detectedChannels(1)) num2str(p.detectedChannels(2)) '.mat']);
        
        if pathToSave == 0 %if no path enter on dialog box show warning and continue
            warning('No path was entered, this mat file will NOT be saved!')
            
        else
            save(fullfile(pathToSave,file),'dataCompiledFrom','searchRadius',...
                'detectionProcessID','numOfCells')
        end
        
    else
        
        save(fullfile(pathToSave,['compiledDataInfo' num2str(p.detectedChannels(1)) num2str(p.detectedChannels(2)) '.mat']),...
            'dataCompiledFrom','searchRadius','detectionProcessID','numOfCells')
    end
    
end

end