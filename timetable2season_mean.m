

function [oTable, oTTable] = timetable2season(iTable)

oTable = struct;
oTTable = struct;

oTable.ONDJFMA = table();
oTable.SON = table();
oTable.MJJA = table();
oTable.MJJAS = table();
oTable.AM = table();
oTable.DJF = table();
oTable.hY = table();
oTable.mM = table();
oTable.mY = table();

uqy = unique(iTable.Time.Year);
vars = iTable.Properties.VariableNames;

% Winter mean ONDJFMA
for ii = 1:length(vars)
        var = vars(ii);
    for i = 1:length(uqy)
        oTable.ONDJFMA.from(i) = datetime(uqy(i),10,1);
        oTable.ONDJFMA.to(i) = datetime(uqy(i)+1,04,31);

        tr = timerange(oTable.ONDJFMA.from(i),oTable.ONDJFMA.to(i));
        
        oTable.ONDJFMA.(string(var))(i) = mean(iTable.(string(var))(tr,:));
    end
end

oTTable.ONDJFMA = splitvars(timetable(oTable.ONDJFMA,...
    'RowTimes',oTable.ONDJFMA.from));

oTTable.ONDJFMA.from = [];
oTTable.ONDJFMA.to = [];

% Fall mean SON
for ii = 1:length(vars)
        var = vars(ii);
    for i = 1:length(uqy)
        oTable.SON.from(i) = datetime(uqy(i),9,1);
        oTable.SON.to(i) = datetime(uqy(i),11,31);

        tr = timerange(oTable.SON.from(i),oTable.SON.to(i));
        
        oTable.SON.(string(var))(i) = mean(iTable.(string(var))(tr,:));
    end
end

oTTable.SON = splitvars(timetable(oTable.SON,...
    'RowTimes',oTable.SON.from));

oTTable.SON.from = [];
oTTable.SON.to = [];

% Summer mean MJJA
for ii = 1:length(vars)
        var = vars(ii);
    for i = 1:length(uqy)
        oTable.MJJA.from(i) = datetime(uqy(i),5,1);
        oTable.MJJA.to(i) = datetime(uqy(i),08,31);

        tr = timerange(oTable.MJJA.from(i),oTable.MJJA.to(i));
        
        oTable.MJJA.(string(var))(i) = mean(iTable.(string(var))(tr,:));
    end
end

oTTable.MJJA = splitvars(timetable(oTable.MJJA,...
    'RowTimes',oTable.MJJA.from));

oTTable.MJJA.from = [];
oTTable.MJJA.to = [];

% Summer mean MJJAS
for ii = 1:length(vars)
        var = vars(ii);
    for i = 1:length(uqy)
        oTable.MJJAS.from(i) = datetime(uqy(i),5,1);
        oTable.MJJAS.to(i) = datetime(uqy(i),09,30);

        tr = timerange(oTable.MJJAS.from(i),oTable.MJJAS.to(i));
        
        oTable.MJJAS.(string(var))(i) = mean(iTable.(string(var))(tr,:));
    end
end

oTTable.MJJAS = splitvars(timetable(oTable.MJJAS,...
    'RowTimes',oTable.MJJAS.from));

oTTable.MJJAS.from = [];
oTTable.MJJAS.to = [];

% Spring mean AM
for ii = 1:length(vars)
        var = vars(ii);
    for i = 1:length(uqy)
        oTable.AM.from(i) = datetime(uqy(i),04,1);
        oTable.AM.to(i) = datetime(uqy(i),05,31);

        tr = timerange(oTable.AM.from(i),oTable.AM.to(i));
        
        oTable.AM.(string(var))(i) = mean(iTable.(string(var))(tr,:));
    end
end

oTTable.AM = splitvars(timetable(oTable.AM,...
    'RowTimes',oTable.AM.from));

oTTable.AM.from = [];
oTTable.AM.to = [];

% Winter mean DJF
for ii = 1:length(vars)
        var = vars(ii);
    for i = 1:length(uqy)
        oTable.DJF.from(i) = datetime(uqy(i),12,1);
        oTable.DJF.to(i) = datetime(uqy(i)+1,03,31);

        tr = timerange(oTable.DJF.from(i),oTable.DJF.to(i));
        
        oTable.DJF.(string(var))(i) = cd(iTable.(string(var))(tr,:));
    end
end

oTTable.DJF = splitvars(timetable(oTable.DJF,...
    'RowTimes',oTable.DJF.from));

oTTable.DJF.from = [];
oTTable.DJF.to = [];

% Mánaðarmeðaltöl
oTTable.mM = retime(iTable,'monthly','mean');

% Ársmeðaltöl
oTTable.mY = retime(iTable,'yearly','mean');

% HY mean ONDJFMAMJJAS
for ii = 1:length(vars)
        var = vars(ii);
    for i = 1:length(uqy)
        oTable.hY.from(i) = datetime(uqy(i),10,1);
        oTable.hY.to(i) = datetime(uqy(i)+1,09,30);

        tr = timerange(oTable.hY.from(i),oTable.hY.to(i));
        
        oTable.hY.(string(var))(i) = mean(iTable.(string(var))(tr,:));
    end
end

oTTable.hY = splitvars(timetable(oTable.hY,...
    'RowTimes',oTable.hY.from));

% Upphafleg tafla
oTTable.TT = iTable;

end