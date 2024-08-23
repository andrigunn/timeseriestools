
function plt_overlay(overlay_tbl,tbl,...
    years2plot,fig_title,unit,...
    ylabel_name,text_lower_right)

%% Inputs
% overlay_tbl,tbl => outputs from makeoverlay
% years2plot, hydrological years to plot individually
% NOTE: Years to plot are HYDROLOGICAL YEARS not CALANDER YEARS
% fig_title
% unit => ylabel unit if any
% ylabel_name
% 
% ylabel_name = 'Sjávarhiti';
% unit = '°C'
%  years2plot = [2014,2023,2022,2021,2018]
% fig_title = 'testing'
% text_lower_right ='SST from NOAA'

% Make the 25/75 and 10/90 quantiles

bnds_rvm(:,:,1) = [overlay_tbl.AY_median-overlay_tbl.Q10,...
    overlay_tbl.Q90-overlay_tbl.AY_median];

bnds_rvm(:,:,2) = [overlay_tbl.AY_median-overlay_tbl.Q25,...
    overlay_tbl.Q75-overlay_tbl.AY_median];

bnds_rvm = double(bnds_rvm)

[hl, hp]  = boundedline(datenum(overlay_tbl.Time)',...
    [double(overlay_tbl.AY_median),double(overlay_tbl.AY_median)]',...
    bnds_rvm,'alpha');

hold on

hm = plot(datenum(overlay_tbl.Time),double(overlay_tbl.AY_median),...
    'k','LineWidth',1.5...
    ,'Displayname','Miðgildi');

Legend=cell(3+length(years2plot),1);
Legend{1} = '10/90%';
Legend{2} = '25/75%';
Legend{3} = 'Miðgildi';

% viðmiðunarár til að teikna með


if isempty(years2plot)

else
    cmap = lines(length(years2plot)+1);
    cmap(2,:) = [];
    for i = 1:length(years2plot)

        % Ef við erum á núgildandi vatnsárið notum við sama lit til að
        % teikna
        if years2plot(i) == overlay_tbl.Time.Year(1) 

            hy(i) = plot(datenum(overlay_tbl.Time),overlay_tbl.(...
                string(['HY_',num2str(years2plot(i))])),...
                'r','LineWidth',1.5,...
                'Displayname',num2str(years2plot(i)));
        else
            hy(i) = plot(datenum(overlay_tbl.Time),overlay_tbl.(...
                string(['HY_',num2str(years2plot(i))])),...
                'Color',cmap(i,:),'LineWidth',1.3,...
                'Displayname',num2str(years2plot(i)));
        end


        appy = num2str(years2plot(i)+1);

        Legend{3+i}=[num2str(years2plot(i)),'-',appy(3:4)];

    end
end

vline(datenum(tbl.Time(end)),'k');

%Legend stuff
lgn = legend([hp(1:2);hm;hy'],Legend);

lgn.Location ="southoutside";
lgn.Orientation ="horizontal"

k = [hp(1:2);hm;hy'],Legend;
ks = size(k);

if ks(1) < 7
    lgn.NumColumns = ks(1)
else
    lgn.NumColumns = ceil(ks(1)/2)
end

title(fig_title);
ylabel([ylabel_name,' ',unit]);
datetick('x','dd.mm');
grid on
grid minor

text(0.01,0.96,['Nýjustu gögn: ',datestr(tbl.Time(end))],...
    'Units','normalized','HorizontalAlignment','left',...
    'VerticalAlignment','bottom','FontSize',12,'FontWeight','bold',...
    'Interpreter','none');

text(0.01,0.93,['Uppfært: ',datestr(now,'dd.mm.yyyy')],...
    'Units','normalized','HorizontalAlignment','left',...
    'VerticalAlignment','bottom','FontSize',12,'FontWeight','bold',...
    'Interpreter','none');

text(0.99,0.01,[text_lower_right],...
    'Units','normalized','HorizontalAlignment','right',...
    'VerticalAlignment','bottom','FontSize',12,'FontWeight','bold',...
    'Interpreter','none');

ax = gca;
xtickangle(45);
set(gca,'TickDir','out');
set(gca, ...
    'Box'         , 'off'     , ...
    'TickDir'     , 'out'     , ...
    'TickLength'  , [.02 .02] , ...
    'XMinorTick'  , 'on'      , ...
    'YMinorTick'  , 'on'      , ...
    'YGrid'       , 'on'      , ...
    'XColor'      , [.3 .3 .3], ...
    'YColor'      , [.3 .3 .3], ...
    'LineWidth'   , 1         );

set(gcf, 'Color', 'w');
set(gca,'FontSize',16);
%% l egend show




