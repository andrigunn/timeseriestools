function [Rt,TB] = makeOverlayDataStackMM(time,data,baseline_period)

TB = timetable(time,data);

% Check the current dimension names
dimNames = TB.Properties.DimensionNames;

% Check if the time dimension is named 'time' (with small t)
if strcmp(dimNames{1}, 'time')
    % Rename it to 'Time' (with capital T)
    TB.Properties.DimensionNames{1} = 'Time';
end

disp(['## Making data cube for time series'])
uqy = unique(TB.Time.Year);
disp(['## Total of ',num2str(numel(uqy)),' hydrological years'])
% Make a sorted table for all years in a cube
clear R
chy = 2024

for i = 1:length(uqy)

    if i == 1
        tr = datetime([chy,10,01]):calmonths(1):datetime([chy+1,09,30])       
        % ix = find(datetime([chy+1,02,29])==tr); % fiff fyrir hlaupaár
        % tr(ix) = [];
        R = timetable(ones(1,length(tr))','RowTimes',tr);
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
