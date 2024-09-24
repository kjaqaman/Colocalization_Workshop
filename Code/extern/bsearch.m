% bsearch(x,var)
% Written by Aroh Barjatya
% Binary search for values specified in vector 'var' within data vector 'x'
% The data has to be pre-sorted in ascending or decending order
% There is no way to predict how the function will behave if there 
% are multiple numbers with same value.
% returns the index values of the searched numbers
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

function index = bsearch(x,var)

xLen = length(x);
xRow= size(x,1);
if x(1) > x(xLen)	% means x is in descending order
    if xRow==1
        x = fliplr(x);  
    else
        x = flipud(x);
    end
    flipped = 1;
elseif x(1) < x(xLen)	% means x is in ascending order
    flipped = 0;
else
    'badly formatted data. Type ''help bsearch\'')';
    return;
end
N=length(var);
index=zeros(1,N);
for i = 1:N
    low = 1;
    high = xLen;
    if var(i) <= x(low)
        index(i) = low;
        continue;
    elseif var(i) >= x(high)
        index(i) = high;
        continue;
    end
    flag = 0;
    while (low <= high)
        mid = round((low + high)/2);
        if (var(i) < x(mid))
            high = mid;
        elseif (var(i) > x(mid))
            low = mid;
        else
            index(i) = mid;
            flag = 1;
            break;
        end
        if (low == high - 1)
            break
        end
    end
    if (flag == 1)
        continue;
    end
    if (low == high)
        index(i) = low;
    elseif ((x(low) - var(i))^2 > (x(high) - var(i))^2)
        index(i) = high;
    else
        index(i) = low;
    end
end

if flipped
    index = xLen - index + 1;
end
