audit.name='bravo_like';
audit.margin = 0.1;
audit.alpha = 0.1;
audit.N = 1000;
[audit.n, audit.kmin, audit.LLR] = B2BRAVOLikekmin(audit.margin, audit.alpha, audit.N);
txt = jsonencode(audit);
%fname = audit_test_margin_alpha_N where margin and alpha are in digits after
%decimal
fname = 'audit_test_1_1_1000.json'; 
fid = fopen(fname,'w');
if fid == -1, error('Cannot create JSON file'); end
fwrite(fid,txt,'char');
fclose(fid);
