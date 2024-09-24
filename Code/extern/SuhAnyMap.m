%  AUTHORSHIP
%   Primary Developer: Stephen Meehan <swmeehan@stanford.edu> 
%   Math/Statistics:   Connor Meehan <connor.gw.meehan@gmail.com>
%                      Guenther Walther <gwalther@stanford.edu>
%   Primary inventors: Wayne Moore <wmoore@stanford.edu>
%                      David Parks <drparks@stanford.edu>
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
classdef SuhAnyMap < handle
    properties(SetAccess=private)
        keys={};
        values{};
    end
    
    methods
        function this=SuhAnyMap()
            this.keys={};
        end
        
        function ok=containsKey(this, key)
            ok=this.indexOf(key)>0;
        end
        
        function idx=indexOf(this,key)
            N=length(this.keys);
            for idx=1:N
                if isequal(this.keys{idx}, key)
                    return;
                end
            end
            idx=0;
        end
        
        function N=size(this)
            N=length(this.keys);
        end
        
        function [value, key]=item(this, idx)
            value=this.values{idx};
            if nargout>1
                key=this.keys{idx};
            end
        end
        function value=get(this, key)
            idx=this.indexOf(key);
            if idx==0
                value=[];
            else
                value=this.values{idx};
            end
        end
        
        function priorValue=set(this, key, value)
            idx=this.indexOf(key);
            if idx==0
                priorValue=[];
                this.keys{end+1}=key;
                this.values{end+1}=value;
            else
                priorValue=this.values{idx};
                this.values{idx}=value;
            end
        end
        
        function priorValue=remove(this, key)
            idx=this.indexOf(key);
            if idx==0
                priorValue=[];
            else
                priorValue=this.values{idx};
                this.keys(idx)=[];
                this.values(idx)=[];
            end
        end
        
        function clear(this)
            this.keys={};
            this.values={};
        end
        
        
    end
    
end