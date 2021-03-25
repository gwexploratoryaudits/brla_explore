MD_Data = [0.015	253	2425	203;
0.020	191	1355	191;
0.025	154	865	184;
0.030	127	600	179;
0.035	109	441	176;
0.040	96	338	173;
0.045	87	267	171;
0.050	78	216	170;
0.060	65	151	167;
0.070	57	111	165;
0.080	49	85	164;
0.090	44	67	163;
0.100	41	54	162;
0.120	34	38	161;
0.150	28	24	160;
0.200	21	14	159;
0.250	18	9	158;
0.300	15	6	157];

plot(100*MD_Data(:, 1), MD_Data(:, 2), 'b^-', 100*MD_Data(:, 1), MD_Data(:, 4), ...
    'r*-', 100*MD_Data(:, 1), MD_Data(:, 3), 'ks-', 'MarkerSize', 10, 'LineWidth', 2)
axis([0 30 0 250])
title('Person-hours as a function of margin', 'FontSize', 32)
xlabel('Percent Margin', 'FontSize', 28)
ylabel('Number of Person-hours', 'FontSize', 28)
legend('Batch Comparison', 'Ballot Comparison', 'Ballot Polling', 'FontSize', 24)
ax = gca;
ax.FontSize = 24;


