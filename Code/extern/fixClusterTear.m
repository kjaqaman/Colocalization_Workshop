%   AUTHORSHIP
%   Primary Developer: Stephen Meehan <swmeehan@stanford.edu> 
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
function [P, tears]=fixClusterTear(M, P, neighborHood, ids)
if nargin<4
    ids=unique( P(P<-1) );
end
tears=[];
fix;

    function fix        
        MM=M^2;
        N=length(ids);
        for i=1:N
          %  if i==71
          %      disp('uh')
          %  end
            id=ids(i);
            idCnt=1;
            p=find(P==id, 1, 'first');
            while ~isempty(p)
                newId=id-(idCnt*MM);
                done=[];
                toDo=p;
                while ~isempty(toDo)
                    P(toDo)=newId;
                    done=[done toDo];
                    neighbors=unique(cell2mat( neighborHood(toDo) ));
                    neighbors=neighbors(P(neighbors)==id);
                    toDo=setdiff(neighbors,done);
                end
                p=find(P==id, 1, 'first');
                idCnt=idCnt+1;
                %if sum(P==newId)<4
                %    P(P==newId)=-1;
                %end
            end
            if idCnt>2
                tears(end+1,:)=[id, idCnt-1];
            end
        end
        disp(['check sum=' sum(P)]);
    end
end