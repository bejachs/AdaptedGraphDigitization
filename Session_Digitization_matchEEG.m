%% digitize TET files and match them with EEG file
% This script requires the TET folder names to correspond with the 
% EEG sessions original .h5 filename.
% It also requires the participant (or other grouping variable) to be
% formatted the same for TET and EEG data.
% eg: 
% TET: /Users/jachs/Desktop/Vanessa/TETDataVHKRenamed/10-Hypnosis/523893/
% EEG:
% /Users/jachs/Desktop/Vanessa/DreemEEG/Vanessa_DreemEEG/10-Hypnosis/5-rej_by_epochs/523893_etc.set
%%

% DEFINE TET filepath
Directory='/Users/jachs/Desktop/Vanessa/TETDataVHKRenamed/';
Participant='13-Vipassana/';

% Print the names of TET files
TETFiles=dir ([Directory Participant]);
TETFiles.name

%% Manually call each TETfile
TETfileID='882599';

inputpath=[Directory Participant TETfileID '/'];
outputpath=[Directory Participant 'Digitised/'];

EEGinpath=['/Users/jachs/Desktop/Vanessa/DreemEEG/Vanessa_DreemEEG/' Participant '5-rej_by_epochs/'];
    
% mkdir(outputpath) 

cd (inputpath)

files=dir ('*.png');

%load the outputfile if it exists already
outputfile=[outputpath TETfileID '_dimensionsdata.mat'];

if exist (outputfile)~=0
    load (outputfile);
    zer=find (dimensions(1,:)==0)
else
    dimensions=[];
end

%  Load the EEG to find out length of file

findfiles=dir([EEGinpath '/*' TETfileID '*.set']);
% if isempty(findfiles)
%     continue
% end
EEGfilename=findfiles.name;
EEG=[];
EEG = pop_loadset('filename',EEGfilename,'filepath',EEGinpath);

n_epochs=length(EEG.urevent); %number of epochs before rejection
rej_epochs=EEG.rejepoch; %vector of rejected epochs

% Digitize the images

for f= 1:length(files)
    
    try
        y=digitize_graph(files(f).name,[0:1/(n_epochs-1):1]);
        close all
        dimensions(:,f)=y;
        disp(files(f).name)
    catch
        disp (['couldnt digitise ' files(f).name ', attempting with automatically cropped image'])
        
        try
            close all
            y=digitize_graph_autocrop(files(f).name,[0:1/(n_epochs-1):1]);
            dimensions(:,f)=y;
            disp(files(f).name)

            
        catch
            
            disp (['couldnt digitise ' files(f).name ', attempting again with cropped image'])
            
            try
                
                close all
                y=digitize_graph_crop(files(f).name,[0:1/(n_epochs-1):1]);
                dimensions(:,f)=y;
                disp(files(f).name)
            catch
                disp (['couldnt digitise ' files(f).name])
                
            end
        end
        
    end    
   
%     save(outputfile,'dimensions');
 
end

% Check if the files were digitized correctly, if not, correct the image

% plot the image next to the vector
close all

for f=1:length(files) %this next
    
    I = imread(files(f).name);
    fig_position = [400 400 1200 300];
    figure('Position', fig_position)
    
    subplot(1,2,1)
    imshow(I);
    subplot(1,2,2)
    plot(dimensions(:,f));
    ylim([0 1])
    xlim([0 n_epochs]);
    sgtitle(files(f).name);
    
end

% Now remove the epochs removed in cleaning and save

dimensions(rej_epochs,:)=[];
%
if length(EEG.epoch)~=size(dimensions,1)
    warning (['The TET and EEG epochs are not the same length in file ' TETfileID])
else
    save(outputfile,'dimensions');
end

%% Now load all the dimensionfiles and concatenate into one 
% Directory='/Users/jachs/Desktop/Jamyang_Project/Drawings/Pretend/';
% Participant='2743/';
% inputpath=[Directory Participant 'Digitised/'];
% outputfile=[Directory Participant 'AllData.mat'];
% cd(inputpath)
% 
% AllData=[];
% files=dir ('*.mat');
% for i=1:length(files)
%     load(files(i).name)
%     %check it's all in correct order
%     disp(files(i).name)
%     AllData=[AllData; dimensions];
% end
% 
% save(outputfile,'dimensions');
 