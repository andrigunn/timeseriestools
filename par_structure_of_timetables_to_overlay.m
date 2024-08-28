function par_structure_of_timetables_to_overlay(structure_of_tables,baseline_period)
% Input is a structure of timetables. Each timetable contains variables
% that have individual overlay structures made

% note to cd into the dir to save tha data to
%%
fn = fieldnames(structure_of_tables);

parfor i = 1:length(fn)
    ttbl = structure_of_tables.(string(fn(i)))
    disp((string(fn(i))))

    [Rt,...
        Rc,...
        tbl] = timetable2overlaystructure(ttbl,baseline_period);

    fname = [char((fn(i))),'_overlay.mat']
    parsave(fname, Rt,Rc,tbl);

end

end

function parsave(fname, Rt,Rc,tbl)
  save(fname, 'Rt', 'Rc','tbl')
end