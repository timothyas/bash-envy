function [ ] = avgForcingFields()
% Want to time average ECCO forcing fields for convolution / reconstruction
% -------------------------------------------------------------------------

%% Preliminaries
establish_mygrid; 
adjFields = {'lwdown','swdown','precip','aqh','atemp','tauu','tauv'};
forceFields = {'dlw','dsw','rain','spfh2m','tmp2m_degC','ustr','vstr'};
Nadj = length(adjFields);
yrs = 1992:2011;
Nyrs = length(yrs);
nrecs = 1460*ones(1,Nyrs);
nrecs(1:4:end) = nrecs(1:4:end)+4;
nrecs(end)=1459;
avgPeriod = 2635200/3600/6; % Average period in 6 hr increments (i.e. nrecs per iter)
nRecsCtrl = 240;

for i = 1:Nadj
    %% Initialize
    exfStart = 3;  % Start at 1200hrs, 3rd record
    iyr = 1;
    
    exfCount = exfStart;
    ctrlCount = 1;
    xx_fld = 0*repmat(mygrid.mskC(:,:,1),[1 1 nRecsCtrl]);
    xx_fld(isnan(xx_fld)) = 0;
    
    while iyr <= Nyrs
        %% Read in this time step and add to control vector
        exfFile = sprintf('../../forcing_baseline2/eccov4r2_%s_%d.data',forceFields{i},yrs(iyr));
        exf = read_bin(exfFile, exfCount,0);
        xx_fld(:,:,ctrlCount) = xx_fld(:,:,ctrlCount) + exf;
        
        %% Increment exf counter and check leap year, end of year, end of avgperiod
        exfCount = exfCount + 1;
        if exfCount-exfStart == avgPeriod
            % At end of averaging period, take avg and get next ctrl rec
            xx_fld(:,:,ctrlCount) = xx_fld(:,:,ctrlCount)/avgPeriod;
	    fprintf('\t-Done with Avg. Pd. %d / %d -\n',ctrlCount,nRecsCtrl);
	    fprintf('\t ExfStart for next period: %d\n',exfCount);
            ctrlCount = ctrlCount + 1;
            exfStart = exfCount;
        elseif exfCount-exfStart > avgPeriod
            fprintf('Error: exfCount went above avg period...\n');
            keyboard
        end
        
        if exfCount > nrecs(iyr)
            % Hit the end of the year, need to increment year counter
            exfStart = exfStart - exfCount;
            exfCount = 1;

            fprintf('\t--Done with yr %d--\n',yrs(iyr));
            iyr = iyr + 1;
        end
    end
    if exfCount-exfStart<avgPeriod
        % Ended with fewer than avgPeriod records in last ctrl element
        xx_fld(:,:,ctrlCount) = xx_fld(:,:,ctrlCount) / (exfCount - exfStart);
    end
    
    %% Save averaged forcing field
    ctrlFile = ['xx_' adjFields{i} '.mat'];
    save(ctrlFile,'xx_fld');
    fprintf('## Saved averaged file for %s ##\n',adjFields{i});
end
