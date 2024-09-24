%   AUTHORSHIP
%   Developer: Stephen Meehan <swmeehan@stanford.edu>,
%              Connor Meehan <connor.gw.meehan@gmail.com>
%   Funded by the Herzenberg Lab at Stanford University 
%   License: BSD 3 clause
%
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
classdef MlpPyRun < handle
    properties(Constant)
        MATLAB_VERSION='9.7';
    end
    
    methods(Static)
        function ok=CanDo()
            if ~verLessThan('matLab', MlpPyRun.MATLAB_VERSION)&&~isdeployed
                ok=MlpPyRun.Flag;
            else
                ok=false;
            end
        end

        function ok=Flag(setting)
            ok=true;
            app=BasicMap.Global;
            if isfield(app.python, 'pyRun')
                ok=app.python.pyRun;
            end
            if nargin>0
                app.python.pyRun=setting;
            end
        end
        
        function InitEnv(tellUser)
            try
                [~,~,cmd]=MlpPython.IsAvailable;
                pyenv;
                pyenv('Version', cmd);
            catch ex
                if nargin> 0 && tellUser
                    ex.getReport;
                    msg(Html.WrapTable([ex.message '<br>' ...
                        '<br>So after restarting MATLAB the next time type:<br>'...
                        '<br><b>pyenv;<br>pyenv(''Version'', ''' cmd...
                        ''')</b><hr><br><b>NOTE</b>:  You only have to'...
                        'do this ONCE....but for <b>NOW</b> we can proceed ' ...
                        '(<i>albeit more slowly</i>) by calling Python '...
                        'externally...no problem!' ], ...
                        3, 5, '0', 'left', 'in'), 12, 'south+');
                end
            end
        end
        
        function Init
            try
                MlpPyRun.InitEnv(false);
                P = py.sys.path;
                directory = fileparts(mfilename('fullpath'));
                if count(P,directory) == 0
                    insert(P,int32(0),directory);
                end
                py.importlib.import_module('mlp')
            catch ex
                ex.getReport
            end
        end

        function [labels, confidenceMatrix]=Predict(inputData, model, verbose)
            if nargin < 3
                verbose = true;
            end
            labels=[];
            confidenceMatrix=[];
            if ~MlpPyRun.Flag
                return;
            end
            if verLessThan('matLab', MlpPyRun.MATLAB_VERSION)
                msgError('You need MATLAB r2019b or later!')
                return;
            end
            try
                npInputData = py.numpy.array(inputData);
                values = py.mlp.mlp_predict2(npInputData, model);
            catch
                MlpPyRun.Init;
                try
                    npInputData = py.numpy.array(inputData);
                    values = py.mlp.mlp_predict2(npInputData, model);
                catch ex
                    if ~contains(ex.message, 'h5py is not available')
                        MlpPyRun.InitEnv(true);
                    else
                        ex.getReport
                    end
                    MlpPyRun.Flag(false);
                    return;
                end
            end
            MlpPyRun.Flag(true);
            labels = double(values{1})';
            confidenceMatrix = double(values{2});
            if verbose
                msg('You are using MlpPyRun... debugging still in progress!!');
            end
        end
    end
end
