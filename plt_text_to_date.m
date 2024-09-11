function plt_text_to_date(tbl_time,tbl_data,...
    date_to_plt,text_to_plt,x_offset,y_offset,text_rotation)

%%
%date_to_plt = [datetime(2024,05,19),datetime(2024,05,24)];
% tbl_time = Rt.smb_mmWeq.Time;
% tbl_data = Rt.smb_mmWeq.HY_2023;
% text_to_plt = 'test'
% x_offset = 0;
% y_offset = 0;

%%
x = size(date_to_plt);

for i = 1:(x(2))

    ix = find(date_to_plt(i)==tbl_time);
    scatter(tbl_time(ix),tbl_data(ix),...
    'k','HandleVisibility','off')

    if isempty(text_to_plt(i,:)) 
        disp('No text to plot')
    else
        text(tbl_time(ix)+x_offset,tbl_data(ix)+y_offset,[text_to_plt(i,:)],...
            'Units','data','HorizontalAlignment','left',...
            'VerticalAlignment','bottom','FontSize',14,'FontWeight','normal',...
            'Interpreter','none','Rotation',text_rotation);
    end

end



