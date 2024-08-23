function [Rt,Rc,tbl] = timetable2overlaystructure(ttbl)
% The function creates a structure of timetables in the overlay 
% furher plotting
%%
disp('Making a overlay structure for a timetable')

varnames = ttbl.Properties.VariableNames;
% add vars to vars2omitt that should not be processed
vars2omitt = [{'date'}    {'year'}    {'month'}    {'day'} ];

for i = 1:length(varnames)

    varname = varnames(i);

    switch string(varname)
        case vars2omitt
            continue
        otherwise
            % Do processing
            disp([' => Making overlay for ',char(varname)])
    end

    time = ttbl.Time;
    data = ttbl.(string(varname));

    [Rt.(string(varname)),...
        Rc.(string(varname)),...
        tbl.(string(varname))] = makeOverlayDataStack(time,data);


end

disp('Done making a overlay structure for a timetable')
