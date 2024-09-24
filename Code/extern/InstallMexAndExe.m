%   AUTHORSHIP
%   Primary Developer: Stephen Meehan <swmeehan@stanford.edu> 
%   Math Lead & Secondary Developer:  Connor Meehan <connor.gw.meehan@gmail.com>
%   Bioinformatics Lead:  Wayne Moore <wmoore@stanford.edu>
%   Provided by the Herzenberg Lab at Stanford University 
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
function InstallMexAndExe
[mexFileName, mexFile, umapFolder]=UmapUtil.LocateMex('sgd');
if exist(mexFile, 'file')
    warning(['You already have the MEX file: ' mexFile]);
    fprintf('If you wish to rebuild then first remove this!\n\n');
    return;
end
disp('This allows you to invoke run_umap with ''method''=''MEX'' which');
disp('provides our fastest version of stochastic gradient descent');
fprintf('... otherwise it is done slower with Java\n\n');
cppFile=fullfile(umapFolder, 'sgdCpp_files', 'mexStochasticGradientDescent.cpp');
if ~exist(cppFile, 'file')
    error('Cannot find the C++ file ... sigh');
end
try
    disp('Building MEX-ecutable for stochastic gradient descent!!!')
    mex(cppFile)
catch ex
    ex.getReport
    msg('Setup C++ compiler correctly with "mex -setup"!');
end

if ~exist(mexFile, 'file')
    m=fullfile(pwd, mexFileName);
    if exist(m, 'file')
        movefile(m, umapFolder);
    end
end
if exist(mexFile, 'file')
    fprintf(['\nGOOD...The build created "' mexFileName ...
        '"\n\t in folder "' umapFolder '"\n' ]);
    fprintf('\nIf you distribute this to other computers, remember to sign it!!\n');
    fprintf('For example,at the Herzenberg lab on Mac computers we type:\n');
    fprintf('codesign -s "Stanford University" mexStochasticGradientDescent.mexmaci64\n\n');
else
    warning(['Could not build ' mexFile '???']);
end
disp('The exe is the same C++ for doing stochastic gradient descent. But ');
disp('it runs slower. We keep it available for MATLAB acceleration education');
disp('so that you can build it with Clang++ and the build script in the ');
fprintf('sgdCpp_files subfolder of umap... then invoke run_umap ''method''=''C++'' !\n\n');
fprintf('Have fun reducing with UMAP!!\n\n');
end