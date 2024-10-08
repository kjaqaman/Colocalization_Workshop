%
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

classdef TopItems <handle
    properties(SetAccess=private)
        tm;
        top=10;
        highestWins=true;
    end
    methods
        function this=TopItems(topNumber, highestWins)
            if nargin>1
                this.highestWins=highestWins;
            end
            this.tm=java.util.TreeMap;
            if nargin>0
                this.top=topNumber;
            end
        end
        
        function N=size(this) 
            N=this.tm.size;
        end
        
        function add(this, item, idx)
            this.tm.put(item, idx);
            if this.tm.size>this.top
                this.tm.remove(this.worst);
            end
        end
        
        function [item, idx]=worst(this)
            if this.highestWins
                item=this.tm.firstKey;
            else
                item=this.tm.lastKey;
            end
            if nargout>1
                idx=this.tm.get(item);
            end
        end
        
        function [item, idx]=last(this)
            if this.highestWins
                item=this.tm.firstKey;
            else
                item=this.tm.lastKey;
            end
            idx=this.tm.get(item);
        end
        
        function [item, idx]=best(this)
            if this.highestWins
                item=this.tm.lastKey;
            else
                item=this.tm.firstKey;
            end
            if nargout>1
                idx=this.tm.get(item);
            end
        end 
        
        function idx=first(this)
            if this.highestWins
                item=this.tm.lastKey;
            else
                item=this.tm.firstKey;
            end
            idx=this.tm.get(item);
        end 
        
        function [idxs, items]=all(this)
            N=this.tm.size;
            idxs=zeros(1, N);
            items=cell(1,N);
            i=1;
            if this.highestWins
                it=this.tm.descendingKeySet.iterator;
            else
                it=this.tm.keySet.iterator;
            end
            while it.hasNext
                items{i}=it.next;
                idxs(i)=this.tm.get(items{i});
                i=i+1;
            end
        end
    end
end