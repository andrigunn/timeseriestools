% Overlay daily stack to montlhy
function plt_oly_to_heatmap(oly,timestep,type,aggtype)
% oly: overlay structure to use
% timestep: daily or monthly
% type: original or anomalies
% aggtype: mean or csum
%% Make the data
switch aggtype
    case 'mean'
        oly_mm = retime(oly,"monthly",'mean');
    case 'csum'
        oly_mm = retime(oly,"monthly",'sum');
end
%%
                mm_mean = oly_mm.AY_mean;
                ix = contains(fieldnames(oly_mm),'HY_');
                oly_hy = oly_mm(:,ix);
                
                fn = fieldnames(oly_hy);
                numbers = regexp(fn, 'HY_(\d+)', 'tokens')
                
                hy_yrs = cellfun(@(x) str2double(x{1}), numbers(~cellfun('isempty', numbers)))
%%
switch timestep
    case 'month'
        switch type
            case 'original'
                %% case month_data
                % original data
                figure
                yvar = string(hy_yrs)
                xvar = (datestr(oly_mm.Time,'mmm'))
                cvar = oly_hy{:,1:end}';
                h = heatmap(xvar,yvar,cvar)
            case 'anomalies'
                %% anomalies
                
                oly_hy_ano = oly_hy-mm_mean;
                figure
                yvar = string(hy_yrs)
                xvar = (datestr(oly_hy_ano.Time,'mmm'))
                cvar = oly_hy_ano{:,1:end}';
                h = heatmap(xvar,yvar,cvar)
                clim([-10 10])
                cmocean('-balance','pivot',0)     

                
        end
end
%%
                oly_hy_ano = (oly_hy./mm_mean);
                oly_hy_ano = oly_hy_ano.*100;
                %%
                figure
                yvar = string(hy_yrs)
                xvar = (datestr(oly_hy_ano.Time,'mmm'))
                cvar = oly_hy_ano{:,1:end}';
                h = heatmap(xvar,yvar,cvar)
                cmocean('-balance','pivot',0)     

                caxis([50 150])
%%
litir_rvm = ...
[[113,173,71,255];...
[254,193,0,255];...
[237,125,49,255];...
[192,0,0,255];...
[0,0,0,255]]



