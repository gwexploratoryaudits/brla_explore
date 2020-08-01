% script to add to a particular Bravo graph. Not really for reuse 
%
%---
% Draw vertical line at 20 and label it
xl = xline(20, '-.', {sprintf('n=%d', 20)});
xl.LineWidth=1;
xl.FontSize=14;
xl.LabelVerticalAlignment='middle';

% Draw vertical line at 22 and label it
xl = xline(22, '-.', {sprintf('n=%d', 22)});
xl.LineWidth=1;
xl.FontSize=14;
xl.LabelVerticalAlignment='middle';

% Draw vertical line at 40 and label it
xl = xline(40, '-.', {sprintf('n=%d', 40)});
xl.LineWidth=1;
xl.FontSize=14;
xl.LabelVerticalAlignment='middle';

% Draw vertical line at 60 and label it
xl = xline(60, '-.', {sprintf('n=%d', 60)});
xl.LineWidth=1;
xl.FontSize=14;
xl.LabelVerticalAlignment='middle';

% Draw vertical line at 80 and label it
xl = xline(80, '-.', {sprintf('n=%d', 80)});
xl.LineWidth=1;
xl.FontSize=14;
xl.LabelVerticalAlignment='middle';

% Delete parts of the legend corresponding to the lines. 
hleg = legend([plot1 plot3], 'Location', 'NorthWest');
hleg.FontSize = 14;


