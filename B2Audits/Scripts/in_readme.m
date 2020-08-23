[~, ~, n1, kmin1] = B2BRAVOkmin(0.4, 0.1);
plot(n1, kmin1)
[n2, kmin2, ~] = B2BRAVOLikekmin(0.4, 0.1, 200);
plot(n2, kmin2)
plot_bravos(0.4, 0.1, 200)
margins = [0.4, 0.3, 0.2, 0.16, 0.1];
alpha = [0.1];
[nBRAVO, kminBRAVO] = B2BRAVOkminMany(margins, alpha);
alpha2 = [0.1,0.05];
[nBRAVO2, kminBRAVO2] = B2BRAVOkminMany(margins, alpha2);
N=[1000];
for i=1:size(margins,2)
for s=1:size(alpha2,2)
    plot(nBRAVO2{i,s}, kminBRAVO2{i,s})
    hold on
end
end