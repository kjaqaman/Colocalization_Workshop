%   AUTHORSHIP
%   Math Lead & Primary Developer:  Connor Meehan <connor.gw.meehan@gmail.com>
%   Secondary Developer: Stephen Meehan <swmeehan@stanford.edu>
%   Bioinformatics Lead:  Wayne Moore <wmoore@stanford.edu>
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
function [commaFormattedString] = CommaFormat(value)
  % Split into integer part and fractional part.
  [integerPart, decimalPart]=strtok(num2str(value),'.'); 
  % Reverse the integer-part string.
  integerPart=integerPart(end:-1:1); 
  % Insert commas every third entry.
  integerPart=[sscanf(integerPart,'%c',[3,inf])' ... 
      repmat(',',ceil(length(integerPart)/3),1)]'; 
  integerPart=integerPart(:)'; 
  % Strip off any trailing commas.
  integerPart=deblank(integerPart(1:(end-1)));
  % Piece the integer part and fractional part back together again.
  commaFormattedString = [integerPart(end:-1:1) decimalPart];
  return; % CommaFormat
end