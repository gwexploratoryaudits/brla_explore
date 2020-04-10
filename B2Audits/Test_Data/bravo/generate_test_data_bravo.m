audit.name='bravo';
audit.margin = 0.1;
audit.alpha = 0.1;
[audit.kmslope, audit.kmintercept, audit.n, audit.kmin] = B2BRAVOkmin(audit.margin, audit.alpha);
txt = jsonencode(audit);
%fname = audit_test_margin_alpha where margin and alpha are in digits after
%decimal
fname = 'audit_test_1_1.json'; 
fid = fopen(fname,'w');
if fid == -1, error('Cannot create JSON file'); end
fwrite(fid,txt,'char');
fclose(fid);
