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
classdef ToolBar < handle
    properties
        ht=[];
        comboBoxes;
        bag=[];
        firstItems={};
        jToolbar=[];
    end
    methods
        function setEnabled(tb, yes)
            N=tb.jToolbar.getComponentCount;
            for i=0:N-1
                btn=tb.jToolbar.getComponentAtIndex(i);
                btn.setRequestFocusEnabled(false);
                if isa(btn, 'javax.swing.JPanel')
                    btn.setVisible(yes);
                else
                    btn.setEnabled(yes);
                end
            end
        end
        function this=ToolBar(ht)
            this.comboBoxes=[];
            this.bag=struct();
            this.jToolbar=ToolBarMethods.getJ(ht);
            this.ht=ht;
        end
    end
    
    methods(Static)
        
        function this=Get(fig)
            this=ToolBar(findall(fig,'tag','FigureToolBar'));
        end
            
        function this=New(fig, first, removeZoom, removeRotate3D, removeEdit)
            if nargin<5
                removeEdit=true;
                if nargin<4
                    removeRotate3D=true;
                    if nargin<3
                        removeZoom=true;
                    end
                end
            end
            if first
                set(fig, 'Toolbar', 'figure');
                Gui.removeToolbarExcess(fig, removeRotate3D, removeEdit);
                if nargin>2 && removeZoom
                    Gui.removeForTooltip(fig, 'Zoom In');
                    Gui.removeForTooltip(fig, 'Zoom Out');
                    Gui.removeForTooltip(fig, 'Pan');
                end
                drawnow;      
                this=ToolBar(findall(fig,'tag','FigureToolBar'));
            else
                ht_=uitoolbar(fig);
                drawnow;      
                this=ToolBar(ht_);
            end
        end
    end
    
end