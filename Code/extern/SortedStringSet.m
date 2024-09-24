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
classdef SortedStringSet < handle
    properties(SetAccess=private)
        ts;
    end
    methods
        function this=SortedStringSet(caseInsensitive, isVararginNamedValues, varargin)
            if nargin==0 || ~caseInsensitive
                this.ts=java.util.TreeSet;
            else
                this.ts=java.util.TreeSet(java.lang.String.CASE_INSENSITIVE_ORDER);
            end
            if nargin>1
                if ischar(isVararginNamedValues)
                    a=[isVararginNamedValues varargin];
                    this.addAll(a{:});
                else
                    assert(islogical(isVararginNamedValues));
                    if nargin>2
                        if isVararginNamedValues
                            this.addNames(varargin{:});
                        else
                            this.addAll(varargin{:});
                        end
                    end
                end
            end
        end
        
        function ok=contains(this, item)
            ok=this.ts.contains(java.lang.String(item));
        end

        function [ok, idxs]=containsStartsWithI(this, search)
            sa=this.strings;
            idxs=StringArray.StartsWith(sa, search);
            ok=~isempty(idxs);
        end

        function ok=add(this, item)
            ok=this.ts.add(java.lang.String(item));
        end
        
        function ok=remove(this, item)
            ok=this.ts.remove(java.lang.String(item));
        end
        
        function addAll(this, varargin)
            N=length(varargin);
            for i=1:N
                if isa(varargin{i},'SortedStringSet')
                    this.ts.addAll(varargin{1}.ts);
                else
                    this.ts.add(java.lang.String(varargin{i}));
                end
            end
        end
        
        function addNames(this, varargin)
            N=length(varargin);
            for i=1:2:N
                this.ts.add(java.lang.String(varargin{i}));
            end
        end
        
        function strs=strings(this)
            N=this.ts.size;
            strs=cell(1,N);
            it=this.ts.iterator;
            i=1;
            while it.hasNext
                strs{i}=char(it.next);
                i=i+1;
            end
        end
        
        function sz=size(this)
            sz=this.ts.size;
        end
    end
    
    methods(Static)
        function this=New(p)
            s=p.Results;
            params=p.Parameters;
            ud=StringArray.Set(p.UsingDefaults, java.util.HashSet);
            argued={};
            N=length(params);
            for i=1:N
                if ~ud.contains(java.lang.String(params{i}))
                    argued{end+1}=params{i};
                end
            end
            this=SortedStringSet(true, false, argued{:});
        end
    end
end