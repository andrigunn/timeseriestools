% Overlay data stack and plot generator. This version of overlay is
% intended for use with time series data for overlay ploting.
%
%RELEASE NOTES
%   Written by Andri Gunnarsson (andrigun@lv.is).
%   Version 1.0 Released on 22 AUG 2024
%   Updates:
%   baseline functionality added - 26.08.2024

function [Rt,Rc,TB] = makeOverlayDataStack(time,data,baseline_period,...
    nan_treatment,zero_treatment)
% time is datenum on input
% data is same lnght as time
% %% TESTING
% time = WData.Hraunvotn.Time;
% data = WData.Hraunvotn.ResLVL;
% baseline_period = period used to calculate stats:
% Median, mean, quantiles
% baseline_period = [datetime(1990,01,01),datetime(2020,12,31)];
% nan_treatment details what to replace NaN values with
% zero_treatment

disp('############# Making time series structure #############')
disp(['## Proccess started at ',datestr(now)])

TB = timetable(data,'rowtimes',time);

full_period_for_baseline = [TB.Time(1),TB.Time(end)];

if ~exist('baseline_period','var') || isempty(baseline_period)
    baseline_period = full_period_for_baseline;
end

disp(['## Baseline period from ',datestr(baseline_period(1),'dd.mm.yyyy'),...
    ' to ',datestr(baseline_period(end),'dd.mm.yyyy')])

if ~exist('nan_treatment','var') || isempty(nan_treatment)
    nan_treatment = '';
    disp(['## NaN values are NaN values - NaNs are NaNs'])

else
    disp(['## NaN values are interpolated linear'])
    nan_treatment = 'linear';

end

if ~exist('zero_treatment','var') || isempty(zero_treatment)
    zero_treatment = 0;
    disp(['## Zero values are not adjusted - Os are Os'])

else
    disp(['## Zero values are replaced by', num2str(zero_treatment)])
end

% Hreinsun og fiff á röðum
% Hreinsum út hlaupaár
ix = find((TB.Time.Month == 2)&(TB.Time.Day == 29));
TB(ix,:) = [];
if isempty(ix)
    %disp(['## No values removed for leap year'])
else
    %disp(['## Total ',num2str((ix)),' values removed for leap year'])
end
%%
% NaN treatment - interpolation
switch nan_treatment
    case 'linear'
        disp(['## NaN values are interpolated linear'])
        % Step 1: Identify NaN values
        isNan = isnan(TB.data);

        % Step 2: Find the start and end of each NaN period
        diffIsNan = [false; diff(isNan) ~= 0]; % Find where the NaN state changes
        nanPeriods = find(diffIsNan & isNan); % Start of NaN periods
        nonNanPeriods = find(diffIsNan & ~isNan); % End of NaN periods

        % If the timetable starts with NaN, adjust the periods
        if isNan(1)
            nanPeriods = [1; nanPeriods];
        end

        % If the timetable ends with NaN, adjust the periods
        if isNan(end)
            nonNanPeriods = [nonNanPeriods; length(TB.data) + 1];
        end

        % Step 3: Count the periods and timesteps
        numPeriods = length(nanPeriods);
        timestepsPerPeriod = nonNanPeriods - nanPeriods;

        % Display the results
        disp(['### Number of interpolated periods: ', num2str(numPeriods)]);
        

        for i = 1:numPeriods
            startDate = TB.Time(nanPeriods(i));
            endDate = TB.Time(nonNanPeriods(i)-1);
            disp(['### Period ', num2str(i), ': ', datestr(startDate), ' to ', datestr(endDate)]);
        end
            TB.data = fillmissing(TB.data, 'linear');
    otherwise
end
%% Treat zero values if needed
switch zero_treatment
    case 'NaN'
        disp(['## Convert zero values to NaN'])
        ix = find(TB.data==0);
        if isempty(ix)
            disp(['### No zero values in series'])
        else
            disp(['### ',num2str(numel(ix)),' zero values converted to NaN'])
         TB.data(TB.data==0)=NaN;
        end
    otherwise

end
%%
% Check what the current hydrological year is

if month(now) < 10
    chy = year(now)-1;
else
    chy = year(now);
end

%% R = timetable(TB);
disp(['## Making data cube for time series'])
uqy = unique(TB.Time.Year);
disp(['## Total of ',num2str(numel(uqy)),' hydrological years'])
% Make a sorted table for all years in a cube
clear R

for i = 1:length(uqy)

    if i == 1
        tr = datenum([chy,10,01]):1:datenum([chy+1,09,30]);
        ix = find(datenum([chy+1,02,29])==tr); % fiff fyrir hlaupaár
        tr(ix) = [];
        R = timetable(ones(1,length(tr))','RowTimes',datetime(tr,'ConvertFrom','datenum'));
    else
    end

    tr = timerange( datetime(['10/01/',num2str(uqy(i))],...
        'InputFormat','MM/dd/yyyy'),datetime(['10/01/',num2str(uqy(i)+1)],...
        'InputFormat','MM/dd/yyyy'));

    r = TB(tr,:);

    for ii = 1:height(R);
        ix = find((R.Time.Month(ii) ==  r.Time.Month)&(R.Time.Day(ii) ==  r.Time.Day));
        if isempty(ix);
        else
            R.(string(['HY_',num2str(uqy(i))]))(ii) = r.data(ix);
            
        end
    end
end

%%
disp(['## Making Rt structure with stats'])

R = removevars(R, 'Var1');
Rt = R;

% Check what periods to use based on baseline

uqy_baseline_years = [baseline_period.Year(1):1:baseline_period.Year(end)];

fnames = Rt.Properties.VariableNames;
ix = contains(fnames, string(uqy_baseline_years));

% Filter stack to collect data from
Rstats = Rt(:,ix);

stats = timetable2table(Rstats);
stats(:,1) = [];
Stats = table2array(stats);

Rt.AY_mean = mean(Stats,2,'omitmissing');
Rt.AY_max = max(Stats,[],2,'omitmissing');
Rt.AY_min = min(Stats,[],2,'omitmissing');
Rt.AY_median = median(Stats,2,'omitmissing');

Rt.Q05 = quantile(Stats,[0.05],2);
Rt.Q10 = quantile(Stats,[0.10],2);
Rt.Q25 = quantile(Stats,[0.25],2);
Rt.Q50 = quantile(Stats,[0.50],2);
Rt.Q75 = quantile(Stats,[0.75],2);
Rt.Q90 = quantile(Stats,[0.90],2);
Rt.Q95 = quantile(Stats,[0.95],2);

%% Stats for cumulative time series
disp(['## Making Rc structure with stats'])
Rc = cumsum(R,'omitmissing');
%
fnames = Rc.Properties.VariableNames;
ix = contains(fnames, string(uqy_baseline_years));
% Filter stack to collect data from
Rcstats = Rc(:,ix);
%
Stats = table2array(Rcstats);
%
Rc.AY_mean = mean(Stats,2,'omitmissing');
Rc.AY_max = max(Stats,[],2,'omitmissing');
Rc.AY_min = min(Stats,[],2,'omitmissing');
Rc.AY_median = median(Stats,2,'omitmissing');

Rc.Q05 = quantile(Stats,[0.05],2);
Rc.Q10 = quantile(Stats,[0.10],2);
Rc.Q25 = quantile(Stats,[0.25],2);
Rc.Q50 = quantile(Stats,[0.50],2);
Rc.Q75 = quantile(Stats,[0.75],2);
Rc.Q90 = quantile(Stats,[0.90],2);
Rc.Q95 = quantile(Stats,[0.95],2);

disp('#############             DONE             #############')

end
