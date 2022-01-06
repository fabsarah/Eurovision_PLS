%% Get the Music data

str='/Volumes/Seagate Expansion Drive/Eurovision'; %Finding the folder
folder_name=uigetdir(str);
files=dir(fullfile(folder_name,'*.mp3'));
cd(folder_name);
clear str folder_name curr_folder
%%
%for i = 1:21
%    Songs{i,:} = {files(i).name};
%end
%clear i %make look nice
Songs = files(~startsWith({files.name}, '._'));
%Songs = files;
clear files

%% Adapting MIR code
%The following is taken from the MIR Toolbox function 'miremotion'
%(Eerola, Lartillot, & Toiviainen, 2009). I adapted
%it to work as a series of loops rather than as a function for now, but can
%look at making it into a function to save time in the future.

% You will need:
    % 1) Songs.struct: a structure variable containing the file names of the
    % songs used in the study
    % 2) PC_study_Sounds: the folder with the songs in it (on the dropbox).
    % Remember to add it to the path.
    % 3) MIR_adapt_WS: this has the mouse tracker data already extracted
    % which you'll need if you want to plot participants vs. features.
addpath(genpath('/Volumes/NO NAME/MIRtoolbox1.7'))
%% 1: Extracting the features
x = cell(8,21); %pre-allocating cell to store the variables
Arousal = zeros(6,21);%where the values will eventually go
Valence = zeros(6,21);
for i = 1:length(Songs) %number of songs
%Adapted miremotion code starts here. Original authors' notes in parentheses
rm = mirrms(Songs(i).name);%rms
fl = mirfluctuation(Songs(i).name);%fluctuation
fp = mirpeaks(fl,'Total',1);%finding peak value from the fluctuation
s = mirspectrum(Songs(i).name);%general spectrum
sc = mircentroid(s); %spectral centroid
ss = mirspread(s); %spectral spread
c = mirchromagram(Songs(i).name);%chromagram (%%%%%%%%%%%%%%%%%%%% Previous frame size was too small.)
cp = mirpeaks(c,'Total',1);
ps = 0;
ks = mirkeystrength(c);%key strength
[k, kc] = mirkey(ks);%key
mo = mirmode(ks);%mode (major/minor)
se = mirentropy(mirspectrum(Songs(i).name)); %spectral entropy (%%%%%%%%% Why 'Frame'??) 
ns = mirnovelty(mirspectrum(Songs(i).name,'Frame',10,.5,'Max',5000),'Normal',0);% novelty
%ns = max(ns(1:end-30));
x = {rm,fp,sc,ss,kc,mo,se,ns};% storing the local values for song i

%
%Getting the values from the MIR objects
rm = get(x{1},'Data');
fpv = get(x{2},'PeakVal');
sc = get(x{3},'Data');
ss = get(x{4},'Data');
kc = get(x{5},'Data');
mo = get(x{6},'Data');
se = get(x{7},'Data');
ns = get(x{8},'Data');
% 
%Converting to matrices for *math*
rm = cell2mat(rm{1,1});
fpv = cell2mat(fpv{1,1}{1,1});

sc = cell2mat(sc{1,1}{1,1});
ss = cell2mat(ss{1,1}{1,1});
kc = cell2mat(kc{1,1});
mo = cell2mat(mo{1,1});
se = cell2mat(se{1,1});
ns = cell2mat(ns{1,1});
ns = max(ns);
% 
%Normalizing and Summing: Arousal
%Multiplication values are beta weights from Eerola, Lartillot, &
%Toiviainen (2009).
%(% In the code below, removal of nan values added by Ming-Hsu Chang)
Arousal(1,i) = 0.6664* ((mean(rm(~isnan(rm))) - 0.0559)/0.0337);%Putting the values into the allocated matrices
Arousal(2,i) =  0.6099 * ((mean(fpv(~isnan(fpv))) - 13270.1836)/10790.655);
Arousal(3,i) = 0.4486*((mean(sc(~isnan(sc))) - 1677.7)./570.34);
Arousal(4,i) = -0.4639*((mean(ss(~isnan(ss))) - (250.5574*22.88))./(205.3147*22.88)); % New normalisation proposed by Ming-Hsu Chang
Arousal(5,i) = 0.7056*((mean(se(~isnan(se))) - 0.954)./0.0258);

Arousal(isnan(Arousal)) = [];
Arousal(6,i) = sum(Arousal(:,i))+5.4861;

% 
%Normalizing and Summing: Valence
Valence(1,i) = -0.3161 * ((std(rm) - 0.024254)./0.015667);
tempfpv =  0.6099 * (squeeze(fpv) - 13270.1836)/10790.655;
Valence(2,i) =  mean(tempfpv);
Valence(3,i) = 0.8802 * ((mean(kc) - 0.5123)./0.091953);
Valence(4,i) = 0.4565 * ((mean(mo) - -0.0019958)./0.048664);
ns(isnan(ns)) = [];
Valence(5,i) = 0.4015 * ((mean(ns) - 131.9503)./47.6463);
Valence(isnan(Valence)) = [];
Valence(6,i) = sum(Valence(:,i))+5.2749;
end
%Adapted miremotion code ends here
%
clear rm fpv cp s x i sc ss kc ks psmo se ns fp tempfpv k fl c mo ps bar_handle % make look nice
%% Re-arrange the data into song order
old_order = [1,10:19,2,20,21,3:9];

Valence_R = nan(6,21);
Arousal_R = nan(6,21);

for i = 1:length(old_order)
    Valence_R(:,old_order(i)) = Valence(:,i);
    Arousal_R(:,old_order(i)) = Arousal(:,i);
end
clear i

%Valence = Valence_R;
%Arousal = Arousal_R;
%% Arousal/Valence Labels
Music_Labs ={'Loudness';'Flux';'Centroid';'Spread';'Entropy';...
    'Std Loudness';'Mean Flux';'Key Clarity';'Mode';'Novelty'};
%% 2: Visualizing the Valence/Arousal data
Labels = {'Wild Dances';
'Party for Everybody';
'Only Love Survives';
'Tick-Tock';
'I''m Yours';
'Boonika Bate Toba';
'Spirit in the Sky';
'Believe';
'Hard Rock Hallelujia';
'Fairytale';
'Grab the Moment';
'Time';
'Dancing';
'Yodel It!';
'Amar Pelos Duis';
'We Are Slavic';
'O Jardim';
'Rhythm Inside';
'Non mi avete fatto niente';
'You Let me walk alone';
'Hey Mama'};

%% We will only be using the first nine (9)
Concensus_Labs = {'Year';'Eurovisioniness';'Score';'Position';'How Windy';...
    'Crimes Fashion';'Mugging';'Chemistry';'Party';'Key Change';'Snow';...
    'Crimes Against Pianos';'Battle Horn';'Scanty Drummers';'Elderly Drummers';...
    'Folk Tropes';'Violin';'DJ';'x Love';'x Peace'};
%%
figure
set(gca,'FontSize',16)
scatter(Valence_R(6,:),Arousal_R(6,:),25,linspace(1,10,length(Valence_R(6,:))),'filled','d');%the plot
grid on
text(Valence_R(6,:), Arousal_R(6,:), Labels,'FontSize',14);%adding the text
ylabel('Arousal','FontSize',16)
xlabel('Valence','FontSize',16)
title('All Songs, Arousal and Valence','FontSize',18)
hold off
clear x y
%% The PLS together: Updated!
addpath(genpath('pls'));
Side_1 = Concensus(:,1:4);
Side_2 = ([Concensus(:,5:9),Arousal_R(6,:)',Valence_R(6,:)']);

option.num_perm = 500;
option.num_boot = 100;
option.method = 3;
option.stacked_behavdata = Side_1;% the behaviou matrix

evres = pls_analysis({Side_2}, 21,1,[option]);%running the PLS
%% Plotting Syntax
res = evres;
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
yticklabels(Concensus_Labs(1:9))
xticks([])
set(gca,'FontSize',16)
title(sprintf('Audience Behaviour, p = %d', pval),'FontSize',18)

subplot(1,2,2)
bar(z)
hold on
grid on
errorbar(1:length(z),z,yneg-z,ypos-z,'.')
ylabel('Design Scores')
xticklabels({'Arousal';'Valence';'How Windy';...
    'Crimes Fashion';'Mugging';'Chemistry';'Party'})
xlim([0 length(z)+1])
%xticklabels(Music_Labs)
xtickangle(45)
set(gca,'FontSize',16)
title(sprintf('LV %d, p = %d Music Features',LV, pval),'FontSize',18)
hold off

clear subject res LV x z ypos yneg pval% make look nice
%% Plot the original matrices!
figure
subplot(1,2,1)
imagesc(zscore(Side_1,[],1));
colorbar
yticks(1:21)
yticklabels(Labels)
xticks(1:9)
xticklabels(Concensus_Labs(1:9))
xtickangle(45)
title('Audience Behaviour Scores','FontSize',18)

subplot(1,2,2)
imagesc(zscore(Side_2,[],1));
colorbar
yticks(1:21)
yticklabels(Labels)
xticks(1:7)
xticklabels({'Arousal';'Valence';'How Windy';...
    'Crimes Fashion';'Mugging';'Chemistry';'Party';})
xtickangle(45)
title('Music Scores','FontSize',18)
%% Spot plots: Eurovisioniness 
figure
bar(Concensus(:,2))
grid on
ylim([0 9])
xticks(1:21)
xticklabels(Labels)
xtickangle(45)
set(gca,'FontSize',16)
title('Eurovisioniness by Song','FontSize',18)

%% Spot plots: Other Features
figure
imagesc(Concensus(:,10:end)')
colorbar
yticks(1:11)
yticklabels(Concensus_Labs(10:end))
xticks(1:21)
xticklabels(Labels)
xtickangle(45)
set(gca,'FontSize',16)
title('Eurovisioniness by Song','FontSize',18)
%% EV mean-centred PLS
addpath(genpath('pls'));
Side_1 = [Concensus(:,2:9),Arousal_R(6,:)',Valence_R(6,:)'];
Side_1 = zscore(Side_1,[],1);
clear option
%%
option.num_perm = 500;
option.num_boot = 100;
%option.method = 1;
%option.stacked_behavdata = Side_2;% the behaviou matrix

ev_zres = pls_analysis({Side_1}c, 21,1,[option]);%running the PLS
