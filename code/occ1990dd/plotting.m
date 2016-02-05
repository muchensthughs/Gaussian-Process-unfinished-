
filename4 = '/Users/muchen/Desktop/Gaussian-Process/code/data_matching.xlsx';

D = xlsread(filename4,4);
changes = [];
for i = 1:701,
    if ~isnan(D(i,10))
        changes = [changes;D(i,10)];
    end
end

h = histogram(changes)
title('Histogram of changes in automatability from 1990 to 2010')
xlabel('Change in automatability')
ylabel('Number of occupations')


figure
plot(D(:,9),D(:,10),'b+')
% t = 0:1/100:1;
% hold on;
% plot(t,0*t,'color','r')
% hold on;
% t = -1:1/50:1;
% plot(0.5+0*t,t,'color','r')
title('Change vs Automatability')
xlabel('Automatability in 1990')
ylabel('Changes in automatability from 1990 to 2010')


%(automatability of each occ1990dd occupation is assigned to all corresponding 2010SOC occupation)


figure
a = D(:,9);
a = sort(a);
plot(1:length(a),a)
title('Automatability in 1990')
ylabel('automatability')

figure
a = D(:,8);
a = sort(a);
plot(1:length(a),a)
title('Automatability in 2010')
ylabel('automatability')

figure
a = D(:,4);
a = sort(a);
plot(1:length(a),a)
title('Automatability in 2010(MO)')
ylabel('automatability')