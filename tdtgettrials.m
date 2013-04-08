function [starts, stops] = tdtgettrials(index)

trl1 = find(index.icode == icode('TRL1'));
trl2 = find(index.icode == icode('TRL2'));
starts = index.timestamp(trl1);
stops = index.timestamp(trl2);

