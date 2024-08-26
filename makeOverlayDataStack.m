% Overlay data stack and plot generator. This version of overlay is
% intended for use with time series data for overlay ploting. 
%
%RELEASE NOTES
%   Written by Andri Gunnarsson (andrigun@lv.is).
%   Version 1.0 Released on 22 AUG 2024
%
function [Rt,Rc,TB] = makeOverlayDataStack(time,data,baseline_period)
% time is datenum on input
% data is same lnght as time
% %% TESTING
% time = WData.Hraunvotn.Time;
% data = WData.Hraunvotn.ResLVL;
% baseline_period = period used to calculate stats:
% Median, mean, quantiles 
%baseline_period = [datetime(1990,01,01),datetime(2020,12,31)];

disp('############# Making time series structure #############')
disp(['## Proccess started at ',datestr(now)])

TB = timetable(data,'rowtimes',time);

full_period_for_baseline = [TB.Time(1),TB.Time(end)];


    if ~exist('baseline_period','var') || isempty(baseline_period)
      baseline_period = full_period_for_baseline;
    end

disp(['## Baseline period from ',datestr(baseline_period(1),'dd.mm.yyyy'),...
    ' to ',datestr(baseline_period(end),'dd.mm.yyyy')])    

% Check what the current hydrological year is

if month(now) < 10
    chy = year(now)-1;
else
    chy = year(now);
end

%% R = timetable(TB);
uqy = unique(TB.Time.Year);
% Make a sorted table for all years in a cube
clear R

for i = 1:length(uqy)

    if i == 1
        tr = datenum([chy,10,01]):1:datenum([chy+1,09,30]);
        R = timetable(ones(1,length(tr))','RowTimes',datetime(tr,'ConvertFrom','datenum'));
    else
    end
 
    tr = timerange( datetime(['10/01/',num2str(uqy(i))],...
        'InputFormat','MM/dd/yyyy'),datetime(['10/01/',num2str(uqy(i)+1)],...
        'InputFormat','MM/dd/yyyy'));
    
    r = TB(tr,:);

    for ii = 1:height(R);
        %ix = find(day(R.Time(ii),'dayofyear') ==  day(r.Time,'dayofyear'));
        ix = find((R.Time.Month(ii) ==  r.Time.Month)&(R.Time.Day(ii) ==  r.Time.Day));
        %R.(string(['HY_',num2str(uqy(i))])) = ones(height(R),1)*NaN;
        if isempty(ix);
        else
            R.(string(['HY_',num2str(uqy(i))]))(ii) = r.data(ix);
            % Change zeros from missing data in dates to NAN
            R.(string(['HY_',num2str(uqy(i))]))(R.(string(['HY_',num2str(uqy(i))]))==0)=NaN;
        end
    end
end

%%  
R = removevars(R, 'Var1');
%% Make stats tables 
% Stats for time series
Rt = R;
% Remove leap years
ix = find((Rt.Time.Month == 2)&(Rt.Time.Day == 29));
R(ix,:) = [];
%% Check what periods to use based on baseline 
% 
uqy_baseline_years = [baseline_period.Year(1):1:baseline_period.Year(end)];

fnames = Rt.Properties.VariableNames;
ix = contains(fnames, string(uqy_baseline_years));

% Filter stack to collect data from
Rstats = Rt(:,ix);

%%
stats = timetable2table(Rstats);
stats(:,1) = [];
Stats = table2array(stats);

Rt.AY_mean = nanmean(Stats,2);
Rt.AY_max = nanmax(Stats,[],2);
Rt.AY_min = nanmin(Stats,[],2);

Rt.AY_median = median(Stats,2,'omitnan');
Rt.Q05 = quantile(Stats,[0.05],2);
Rt.Q10 = quantile(Stats,[0.10],2);
Rt.Q25 = quantile(Stats,[0.25],2);
Rt.Q50 = quantile(Stats,[0.50],2);
Rt.Q75 = quantile(Stats,[0.75],2);
Rt.Q90 = quantile(Stats,[0.90],2);
Rt.Q95 = quantile(Stats,[0.95],2);

%% Stats for cumulative time series
Rc = R;

Stats = table2array(Rc);
StatsCsum = cumsum(Stats); % Þarf að vera meðvitaður um hvernig omitnan virkar við að teikna raðir
%%
Rc = array2timetable(Rc,'RowTimes',R.Time);
vname = R.Properties.VariableNames;
Rc.Properties.VariableNames = vname;
%%
% 
uqy_baseline_years = [baseline_period.Year(1):1:baseline_period.Year(end)];

fnames = Rc.Properties.VariableNames;
ix = contains(fnames, string(uqy_baseline_years));

% Filter stack to collect data from
Rstats = Rt(:,ix);
Stats = table2array(Rstats);
StatsCsum = cumsum(Stats); 
%%
Rc.AY_mean = nanmean(StatsCsum,2);
Rc.AY_max = nanmax(StatsCsum,[],2);
Rc.AY_min = nanmin(StatsCsum,[],2);
Rc.AY_median = median(StatsCsum,2,'omitnan');

Rc.Q05 = quantile(StatsCsum,[0.05],2);
Rc.Q10 = quantile(StatsCsum,[0.10],2);
Rc.Q25 = quantile(StatsCsum,[0.25],2);
Rc.Q50 = quantile(StatsCsum,[0.50],2);
Rc.Q75 = quantile(StatsCsum,[0.75],2);
Rc.Q90 = quantile(StatsCsum,[0.90],2);
Rc.Q95 = quantile(StatsCsum,[0.95],2);

disp('#############             DONE             #############')

end
