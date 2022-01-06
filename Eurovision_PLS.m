%%Import EurovisionJustNums and EV_JustNames
load('Eurovision_WS.mat');
labels = {'Year','Eurovisioniness','Score','Position',...
    'How Windy','Crimes Against Fashion','Mugging','Chemistry',...
    'Party','Key Change','Snow','Crimes Against Pianos','Battle Horn',...
    'Scanty Drummers','Elderly Drummers','Folk Tropes','Violin','DJ',...
    'Love','Peace'};
%% Running the PLS
addpath(genpath('Pls'))
data = Concensus;
Valence_R = Valence_R';
Arousal_R = Arousal_R';
Side1 = [data(:,5:9),Valence_R(:,6),Arousal_R(:,6)];
Side2 = data(:,1:4);%peace was 0 for all entries :(

option.method = 3;% behavioural PLS
option.num_perm = 500;
option.num_boot = 100;
option.stacked_behavdata = Side2;% the behaviour matrix

tempres = pls_analysis({Side1}, length(data),1,[option]);%running the PLS
%% Look at the results
res = tempres;
LV = 1;
pval = res.perm_result.sprob(LV);
x = (res.boot_result.compare_u(:,LV));
z = res.boot_result.orig_corr(:,LV);
yneg = res.boot_result.llcorr(:,LV);
ypos = res.boot_result.ulcorr(:,LV);



figure
subplot(1,2,1)
imagesc(x)
colorbar
yticks(1:length(x))
yticklabels({'Wind','Crimes Against Fashion','Mugging','Chemistry',...
    'Party','Valence','Arousal'})
xticks([])
title(sprintf('LV %d, Spectacle vs. Reception',LV),'FontSize',18)

subplot(1,2,2)
bar(z)
hold on
grid on
errorbar(1:length(z),z,yneg-z,ypos-z,'.')
ylabel('Design Scores')
xticks(1:4)
xticklabels(labels(1:4))
xtickangle(45)
title(sprintf('LV %d, p = %d',LV, pval),'FontSize',18)
hold off

clear subject res LV x z ypos yneg pval
%%
[r,p] = corrcoef(Side1);
%%
figure
imagesc(corrcoef(Side1))
colorbar
yticklabels({'Wind','Crimes Against Fashion','Mugging','Chemistry',...
    'Party','Valence','Arousal'})
xticklabels({'Wind','Crimes Against Fashion','Mugging','Chemistry',...
    'Party','Valence','Arousal'})
xtickangle(45)
title('Correlations, Audio-Vusial Elements','FontSize',18)