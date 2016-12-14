function[obs] = readObs()
% Function reads in observation data as follows:
%   t       : time [s]
%   dt      : time step [s]
%   range   : range [km]
%   wt      : data weighting [km^2]
%   sid     : station ID
% Fills 'obs' struct with those variables as fields

readStr = '    %f    %f    %f    %d';
[t, range, weight, sid] = textread('obs.txt',readStr);

dt = diff(t);

obs = struct('t',t,'dt',dt,'range',range,'wt',weight,'sid',sid);
end
