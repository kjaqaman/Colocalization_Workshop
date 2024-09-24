%   AUTHORSHIP
%   Primary Developer: Stephen Meehan <swmeehan@stanford.edu> 
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

classdef SuhAbstractClass< handle
    methods(Static)
        function AssertIsA(this, className)
            assert(isa(this, className),...
                'set arg must be instance of %s', className);

        end
    end
    
    properties(SetAccess=private)
        sac_createdWhen;
        sac_id;
        sac_updatedWhen;
    end
    
    methods(Sealed)
        function this=SuhAbstractClass()
           this.sac_createdWhen=now;
        end
        
        function set_sac_id(this, id)
            this.sac_id=id;
        end
        
        function warnNotImplemented(this)
            funCallStack = dbstack;
            if length(funCallStack)>1
                methodName = funCallStack(2).name;
            else
                methodName='commandConsole';
            end
            warning('%s has not implemented function %s()', ...
                class(this), methodName);
        end
    end
    
    methods
        function noteUpdated(this)
            this.sac_updatedWhen=now;
        end
                    
    end
end