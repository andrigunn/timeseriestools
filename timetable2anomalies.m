function [ttblM, ttblY] = timetable2anomalies(time, data,varname,baseline_period)
% reads a timetalble, montly or yearly and makes anomalies according to the
% baseline_period

%%
% time = S.Time; % datetime of the vector
% data = S.t; % data at the same size as time
% varname = 't' % name to rename the varieble
% baseline_period = [datetime(2000,01,01),datetime(2010,12,31)];
%
ttbl = timetable(time,data);

% Assuming your timetable is called 'ttbl'
timeInfo = ttbl.Properties.RowTimes;
% Extract year and month from row times
[year, month, ~] = ymd(timeInfo);
% Check if the data is monthly or yearly
if numel(unique(month)) > 1
     disp('The data is monthly.');
    for i = 1:12
        %Filter years to use
        ix = find(...
            (ttbl.time.Year>=baseline_period.Year(1))&...
            (ttbl.time.Year<=baseline_period.Year(2))&...
            (ttbl.time.Month==i));

        mmean = mean(ttbl.data(ix),'omitmissing'); % mean for the period, month

        jx = find(...
            (ttbl.time.Month==i));
        ttbl.time(jx);
        ttbl.data_ano(jx) = ttbl.data(jx)-mmean;

    end

    ttblM = timetable(ttbl.time,ttbl.data,ttbl.data_ano);
    ttblM.Properties.VariableNames(1) = string(varname);
    ttblM.Properties.VariableNames(2) = string([varname,'_ano']);

    ttblY = retime(ttblM,'yearly','mean');

elseif all(month == 1) && numel(unique(year)) == numel(year)

        disp('The data is yearly.');
        ttblY = retime(ttblM,'yearly','mean');
else
    disp('Unable to determine if data is monthly or yearly.');
end







