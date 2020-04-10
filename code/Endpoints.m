function g = Endpoints(f)
%Endpoints: Detect endpoints in a binary image
% fig0914_Endpoint
% DIPUM, p354
% Jianjiang Feng
% 2016-11-18

persistent lut

if isempty(lut)% perform only once
    lut = makelut(@endpoint_fcn, 3);
end

g = bwlookup(f, lut);

%----------------------
function is_endpoint = endpoint_fcn(nhood)
% nhood is 3x3 binary neighborhood
is_endpoint = nhood(2,2) && (sum(nhood(:))==2);