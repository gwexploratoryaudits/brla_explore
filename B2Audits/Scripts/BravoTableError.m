% This script computes Bravo Table error
Bravo = [12	22	38	60	131	30;
23	38	66	108	236	53;
49	84	149	244	538	119;
77	131	231	381	840	184;
193	332	587	974	2157		469;
301	518	916	1520		3366		730;
531	914	1619		2700		5980		1294;
1188		2051		3637		6053		13455	2900;
4725		8157		14486	24149	53640	11556;
18839	32547	57838	96411	214491	46126];

% Put together our values computed as described in B2BRAVOTestScript
Estimate = [BTable1; BTable2; BTable3; BTable4];
Expected = [Expected1; Expected2; Expected3; Expected4];
FullTable = [Estimate.'; Expected.'].';