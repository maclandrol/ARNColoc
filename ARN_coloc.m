function ARN_coloc(imgfile, s_ernafile, as_ernafile, mrnafile, k, threshold, convert, intronsig, prefix, number)
%ARN_coloc, took 4 to 6 , Use:
%**ARN_coloc(imgfile, s_ernafile, as_ernafile, mrnafile)
%**ARN_coloc(imgfile, s_ernafile, as_ernafile, mrnafile,k)
%**ARN_coloc(imgfile, s_ernafile, as_ernafile, mrnafile,k, threshold)
%  - imgfile = a string indicating the path to the nucleus mask file (tif or tiff)
%  - s_ernafile= a string indicating the path to the sense erna loc file
%  - as_ernafile= a string indicating the path to the anti-sense erna loc file
%  - mrnafile= a string indicating the path to the mrna loc file
%  - k, this is the intensity coefficient to use for transcription site
%  detection, not mandatory, default=1.5
%  - threshold, this is not mandatory,it's used to discard any spot with intensity
%below threshold, default value =-1
%
%3 files will be saved:
%  - 'final_label.png' : an image labelling nucleus and spot:
%        +red spot = mrna
%        +blue spot = sense erna
%        +green spot = anti-sense erna
%  - 'trans_coloc_analysis.txt' : output with only transcription site mrna
%  - 'spot_coloc_analysis.txt' : output with all spot analysis
%
% EXAMPLE:
% ARN_coloc('mask.tif', 's_eRNA.loc', 'as_eRNA.loc', 'mRNA.loc' )


narginchk(4,10);
if ~exist('threshold', 'var') || isempty(threshold)
    threshold=-1;
end
if ~exist('k', 'var') || isempty(k)
    k=1.5;
end

if ~exist('convert', 'var') || isempty(convert)
    convert=100;
end

if ~exist('intronsig', 'var') || isempty(intronsig)
    intronsig=false;
end

if ~exist('prefix', 'var') || isempty(prefix)
    prefix='';
end

if ~exist('number', 'var') || isempty(number)
    number=false;
end


img=imread(imgfile);
disp_img= imcomplement(ind2rgb(gray2ind(im2bw(mat2gray(img),0),255), gray(255)));
img=bwlabel(im2bw(mat2gray(img),0),4);

%TRouver la nouvelle distribution en intensité des noyaux
inten_dist=int64(unique(sort(img(img>0))));
s_erna=[];
as_erna=[];
mrna=[];
indexing=floor(1:3);
im_xsize=size(disp_img,1);
im_ysize=size(disp_img,2);
%Lecture des fichier de coordonnées des arn
if(~isempty(as_ernafile))
    as_erna=load (as_ernafile);
    as_erna=as_erna((as_erna(:,3)>=threshold),indexing);
    
    %display as_erna spots
    %Displaying spot on img
    for i=1:size(as_erna,1)
        x_2=round(as_erna(i,2)-2);
        y_2=round(as_erna(i,1)-2);
        if(x_2>0 && x_2<=im_xsize && y_2>0 && y_2<=im_ysize)
            x_size=round(as_erna(i,2)-2:as_erna(i,2)+2);
            y_size=round(as_erna(i,1)-2:as_erna(i,1)+2);
            disp_img(x_size,y_size, indexing)=0;
            disp_img(x_size, y_size, 2)=1;
        else
            disp_img(findRound(as_erna(i,2), im_xsize), findRound(as_erna(i,1), im_ysize), indexing)=0;
            disp_img(findRound(as_erna(i,2), im_xsize), findRound(as_erna(i,1), im_ysize), 2)=1;
        end
    end
    
    %setting nucleus spots
    as_erna=nucleus(as_erna, img, inten_dist);
end

if(~isempty(s_ernafile))
    s_erna=load (s_ernafile);
    s_erna=s_erna((s_erna(:,3)>=threshold),indexing);
    % display s_erna spot
    for i=1:size(s_erna,1)
        x_2=round(s_erna(i,2)-2);
        y_2=round(s_erna(i,1)-2);
        if(x_2>0 && x_2<=im_xsize && y_2>0 && y_2<=im_ysize)
            x_size=round(s_erna(i,2)-2:s_erna(i,2)+2);
            y_size=round(s_erna(i,1)-2:s_erna(i,1)+2);
            disp_img(x_size, y_size, indexing)=0;
            disp_img(x_size, y_size, 3)=1;
        else
            disp_img(findRound(s_erna(i,2), im_xsize), findRound(s_erna(i,1), im_ysize), indexing)=0;
            disp_img(findRound(s_erna(i,2), im_xsize), findRound(s_erna(i,1), im_ysize), 3)=1;
        end
        
    end
    s_erna=nucleus(s_erna, img, inten_dist);
end

if(~isempty(mrnafile))
    mrna=load(mrnafile);
    mrna=mrna((mrna(:,3)>=threshold),indexing);
    
    %display mrna spot
    for i=1:size(mrna,1)
        x_2=round(mrna(i,2)-2);
        y_2=round(mrna(i,1)-2);
        if(x_2>0 && x_2<=im_xsize && y_2>0 && y_2<=im_ysize)
            x_size=round(mrna(i,2)-2:mrna(i,2)+2);
            y_size=round(mrna(i,1)-2:mrna(i,1)+2);
            disp_img(x_size, y_size, indexing)=0;
            disp_img(x_size, y_size, 1)=1;
        else
            disp_img(findRound(mrna(i,2), im_xsize), findRound(mrna(i,1), im_ysize), indexing)=0; %impossible to represent 0,0 coordinate so I shift it by 1 pixel
            disp_img(findRound(mrna(i,2), im_xsize), findRound(mrna(i,1), im_ysize), 1)=1;
        end
    end
    
    %Setting nucleus for each rna
    mrna=nucleus(mrna, img, inten_dist);
    mrna=transite(mrna, 0,k, intronsig);
    
end

s_erna_coloc_as_erna=[];
serna_aserna_coloc = {};
mrna_coloc_s_erna=[];
mrna_serna_coloc={};
mrna_coloc_as_erna=[];
mrna_aserna_coloc={};
three_coloc=[];

input_type='';
if (~isempty(as_ernafile) &&  ~isempty(s_ernafile))
    disp('*Colocalization s-erna vs as-erna');
    input_type='as';
    [s_erna_coloc_as_erna, serna_aserna_coloc]= colocalize(s_erna, as_erna, disp_img, convert, [prefix,' colocalization as-erna vs s-erna']);
end

if (~isempty(mrnafile) &&  ~isempty(s_ernafile))
    disp('*Colocalization mrna vs s-erna');
    input_type='ms';
    [mrna_coloc_s_erna, mrna_serna_coloc]= colocalize(mrna, s_erna, disp_img, convert, [prefix,' colocalization mrna vs s-erna']);
end

if (~isempty(as_ernafile) &&  ~isempty(mrnafile))
    disp('*Colocalization mrna vs as-erna');
    input_type='ma';
    [mrna_coloc_as_erna, mrna_aserna_coloc]= colocalize(mrna, as_erna, disp_img, convert,[prefix,' colocalization mrna vs as-erna']);
end

if (~isempty(as_ernafile) &&  ~isempty(mrnafile) && ~isempty(s_ernafile))
    three_coloc= all_coloc(s_erna_coloc_as_erna,mrna_serna_coloc,mrna_aserna_coloc,serna_aserna_coloc);
    input_type='mas';
end

if(strcmp(input_type, 'mas'))
    allInput(img,disp_img,inten_dist, mrna, s_erna, as_erna, s_erna_coloc_as_erna, mrna_coloc_as_erna, three_coloc,mrna_coloc_s_erna, prefix, convert, number);
elseif (strcmp(input_type, 'ms'))
    mrna_ernaInput(img,disp_img,inten_dist, mrna, s_erna, mrna_coloc_s_erna, 's_erna', prefix, convert, number);
elseif (strcmp(input_type, 'ma'))
     mrna_ernaInput(img,disp_img,inten_dist, mrna, as_erna, mrna_coloc_as_erna, 'as_erna', prefix, convert, number);
else
    ernaInput(img, disp_img, inten_dist, s_erna, as_erna, s_erna_coloc_as_erna, prefix, number);
end

end


%% Cas de colocalisation a 2 (standard spot1 vs spot2)
function ernaInput(img, disp_img, inten_dist, s_erna, as_erna, s_erna_coloc_as_erna, prefix, number)

data=zeros(length(inten_dist),4);
data(:,1)=1:length(inten_dist);

%data: 'Nuc', 's_erna-as_erna', #s_erna	#as_erna
for i=1:length(inten_dist)
    data(i,2)=sum(s_erna_coloc_as_erna(s_erna(:,end)==inten_dist(i)));
    data(i,3)=nnz(s_erna(:,4)==inten_dist(i));
    data(i,4)=nnz(as_erna(:,4)==inten_dist(i));
end
write_On_image(disp_img, inten_dist, img, number);
header={'Nuc','s_erna-as_erna','#s_erna', '#as_erna'};
writeToFile(data, strcat(prefix,'spot_coloc_analysis.txt'), header);

end


%% Cas de colocalisation a 2 (erna, mrna)
function mrna_ernaInput(img,disp_img,inten_dist, mrna, erna, mrna_coloc_erna, message, prefix, convert, number)

%data: 'Nuc', 's_erna-mrna', #mrna	#s_erna
%trans_data: 'Nuc', 's_erna-mrna', trans_number, nascent_mrna, #s_erna, mRNAnascent_coloc_+message,	#mRNAnascent_noColoc_erna
mrnaDATA=double([(1:size(mrna,1))' mrna mrna_coloc_erna(:,end-1:end)]);
trans_w_erna=mrnaDATA((mrna_coloc_erna(:,1)>0 & mrnaDATA(:,end-3)==1),:);
trans_wo_erna= mrnaDATA((mrna_coloc_erna(:,1)==0 & mrnaDATA(:,end-3)==1),1:end-2);

data=zeros(length(inten_dist),4);
data(:,1)=1:length(inten_dist);

trans_data=zeros(length(inten_dist),7);
trans_data(:,1)=1:length(inten_dist);

for i=1:length(inten_dist)
    
    %Remplir les tables d'outputs
    data(i,2)=sum(mrna_coloc_erna(mrna(:,4)==inten_dist(i)));
    data(i,3)= nnz(mrna(:,4)==inten_dist(i));
    data(i,4)=nnz(erna(:,4)==inten_dist(i));
    trans_data(i,2)=sum(mrna_coloc_erna(mrna(:,4)==inten_dist(i) & mrna(:,end-1)==1));
    trans_data(i,3)=sum(mrna(mrna(:,4)==inten_dist(i),end-1));
    trans_data(i,4)= sum(round(mrna((mrna(:,4)==inten_dist(i) & mrna(:,end-1)==1),end)));
    trans_data(i,5)=nnz(erna(:,4)==inten_dist(i));
    trans_data(i,6)= sum(round(trans_w_erna(trans_w_erna(:,5)==inten_dist(i),end-2)));
    trans_data(i,7)= sum(round(trans_wo_erna(trans_wo_erna(:,5)==inten_dist(i),end)));
end

write_On_image(disp_img, inten_dist, img, mrna(mrna(:,end-1)~=0,1:end), number);
header={'Nuc',strcat('mrna-',message),'#mrna', strcat('#',message)};
writeToFile(data, strcat(prefix,'spot_coloc_analysis.txt'), header);
header={'Nuc',strcat('t_mrna-',message),'trans_number', 'nascent_mrna',strcat('#',message), strcat('#mRNAnascent_coloc_', message),'#mRNAnascent_noColoc_erna'};
writeToFile(trans_data, strcat(prefix,'trans_coloc_analysis.txt'), header);

%writing trans with erna

header={'mRNA_Trans','nuc' ,'intensity', '#nascent', ['closest_' message,'_dist(nm)'], 'erna #', 'erna intensity', 'erna nascent'};
as_ernaData= zeros(size(trans_w_erna,1),8);
erna_m=single_mean(erna(:,3), 0, 'Single erna intensity');
a=size(trans_w_erna,1);
if(a>0)
    as_ernaData(:,1)=1:a;
    as_ernaData(:,2)=trans_w_erna(:,5);
    as_ernaData(:,3:4)=[trans_w_erna(:,4) round(trans_w_erna(:,end-2))];
    as_ernaData(:,5)= trans_w_erna(:,end-1).*convert;
    as_ernaData(:,6)= trans_w_erna(:,end);
    as_ernaData(:,7)= erna(trans_w_erna(:,end),3);
    as_ernaData(:,8)= round(as_ernaData(:,7)./erna_m);

end
writeToFile(as_ernaData,[prefix, 'Trans_with_',message,'_.txt'], header);
mrnaLocx= [trans_w_erna(:,2:4) as_ernaData(:,4) as_ernaData(:,2)];
ernaLocx = [erna(trans_w_erna(:,end), 1:3) round(as_ernaData(:,7)./erna_m)  as_ernaData(:,2)];
generate_locx_files(mrnaLocx, [prefix,'mrna.locx']);
generate_locx_files(ernaLocx, [prefix,'erna.locx']);

%Writing trans without erna 
header={'mRNA_Trans', 'intensity', '#nascent'};
no_ernaData= zeros(size(trans_wo_erna,1),3);
a=size(trans_wo_erna,1);
if(a>0)
    no_ernaData(:,1)=1:size(trans_wo_erna,1);
    no_ernaData(:,2:3)=[trans_wo_erna(:,4) round(trans_wo_erna(:,end))];
end
writeToFile(no_ernaData,[prefix, 'Trans_without_',message,'_.txt'], header);

end


%% Cas de colocalisation a 3 (s_erna, as_erna, mrna)
function allInput(img,disp_img,inten_dist, mrna, s_erna, as_erna, s_erna_coloc_as_erna, mrna_coloc_as_erna, three_coloc,mrna_coloc_s_erna, prefix, convert, number)

mrnaDATA=double([(1:size(mrna,1))' mrna mrna_coloc_s_erna(:,end-1:end) mrna_coloc_as_erna(:,end-1:end)]);
trans_w_s_erna=mrnaDATA((mrna_coloc_s_erna(:,1)>0 & mrnaDATA(:,end-5)==1),1:end-2);
trans_w_as_erna=mrnaDATA((mrna_coloc_as_erna(:,1)>0 & mrnaDATA(:,end-5)==1),setdiff(1:end,end-3:end-2));
trans_wo_erna= mrnaDATA((mrna_coloc_as_erna(:,1)==0 & mrna_coloc_s_erna(:,1)==0 & mrnaDATA(:,end-5)==1),1:end-4);

data=zeros(length(inten_dist),8);
data(:,1)=1:length(inten_dist);
trans_data=zeros(length(inten_dist),9);
trans_data(:,1)=1:length(inten_dist);

%data: 'Nuc','s_erna-as_erna','s_erna-mrna','as_erna-mrna','as_erna-s_erna-mrna'
for i=1:length(inten_dist)
    data(i,2)=sum(s_erna_coloc_as_erna(s_erna(:,end)==inten_dist(i)));
    data(i,3)=sum(mrna_coloc_s_erna(mrna(:,4)==inten_dist(i)));
    data(i,4)=sum(mrna_coloc_as_erna(mrna(:,4)==inten_dist(i)));
    data(i,5)=sum(three_coloc(mrna(:,4)==inten_dist(i)));
    data(i,6)= nnz(mrna(:,4)==inten_dist(i));
    data(i,7)=nnz(s_erna(:,4)==inten_dist(i));
    data(i,8)=nnz(as_erna(:,4)==inten_dist(i));
    
    trans_data(i,2)=sum(s_erna_coloc_as_erna(s_erna(:,end)==inten_dist(i)));
    trans_data(i,3)=sum(mrna_coloc_s_erna(mrna(:,4)==inten_dist(i) & mrna(:,end-1)==1));
    trans_data(i,4)=sum(mrna_coloc_as_erna(mrna(:,4)==inten_dist(i) & mrna(:,end-1)==1));
    trans_data(i,5)=sum(three_coloc(mrna(:,4)==inten_dist(i) & mrna(:,end-1)==1));
    trans_data(i,6)=sum(mrna(mrna(:,4)==inten_dist(i),end-1));
    trans_data(i,7)= sum(round(mrna((mrna(:,4)==inten_dist(i) & mrna(:,end-1)==1),end)));
    trans_data(i,8)=nnz(s_erna(:,4)==inten_dist(i));
    trans_data(i,9)=nnz(as_erna(:,4)==inten_dist(i));
    trans_data(i,10)= sum(round(trans_w_s_erna(trans_w_s_erna(:,5)==inten_dist(i),end-2)));
    trans_data(i,11)= sum(round(trans_w_as_erna(trans_w_as_erna(:,5)==inten_dist(i),end-2)));
    trans_data(i,12)= sum(round(trans_wo_erna(trans_wo_erna(:,5)==inten_dist(i),end)));
    
end

write_On_image(disp_img, inten_dist, img, mrna(mrna(:,end-1)~=0,1:end), number);
header={'Nuc','s_erna-as_erna','s_erna-mrna','as_erna-mrna','as_erna-s_erna-mrna', '#mrna', '#s_erna', '#as_erna'};
writeToFile(data, [prefix,'spot_coloc_analysis.txt'], header);
header={'Nuc','s_erna-as_erna','s_erna-t_mrna','as_erna-t_mrna','as_erna-s_erna-t_mrna','trans_number', 'nascent_mrna','#s_erna', '#as_erna', '#mRNAnascent_coloc_s_erna', '#mRNAnascent_coloc_as_erna', '#mRNAnascent_noColoc_erna'};
writeToFile(trans_data, [prefix,'trans_coloc_analysis.txt'], header);

header={'mRNA_Trans','nuc', 'intensity', '#nascent', 'is_also_Coloc with_as-erna', 'closest s-erna dist','s_erna #', 's_erna intensity', 's_erna nascent'};
s_ernaData= zeros(size(trans_w_s_erna,1),9);
erna_m=single_mean(s_erna(:,3), 0, 'Single s_erna intensity');

a=size(trans_w_s_erna,1);
if(a>0)
    s_ernaData(:,1)=1:a;
    s_ernaData(:,2)=trans_w_s_erna(:,5);
    s_ernaData(:,3:4)=[trans_w_s_erna(:,4) round(trans_w_s_erna(:,end-1))];
    s_ernaData(:,5)=three_coloc(trans_w_s_erna(:,1));
    s_ernaData(:,6)=trans_w_s_erna(:,end-1).*convert;
    s_ernaData(:,7)= trans_w_s_erna(:,end);
    s_ernaData(:,8)=s_erna(trans_w_s_erna(:,end),3);
    s_ernaData(:,9)=round(s_ernaData(:,8)./erna_m);
end

mrnaLocx= [trans_w_s_erna(:,2:4) s_ernaData(:,4) s_ernaData(:,2)];
ernaLocx = [s_erna(trans_w_s_erna(:,end), 1:3) round(s_ernaData(:,8)./erna_m)  s_ernaData(:,2)];
generate_locx_files(mrnaLocx, [prefix,'mrna.locx']);
generate_locx_files(ernaLocx, [prefix,'erna.locx']);

writeToFile(s_ernaData,[prefix,'Trans_with_s_erna.txt'], header);

header={'mRNA_Trans', 'nuc', 'intensity', '#nascent', 'is_also_Coloc with_s-erna', 'closest as-erna dist','as_erna #', 'as_erna intensity', 'as_erna nascent'};
as_ernaData= zeros(size(trans_w_as_erna,1),9);
erna_m=single_mean(s_erna(:,3), 0, 'Single as_erna intensity');
a=size(trans_w_as_erna,1);
if(a>0)
    as_ernaData(:,1)=1:a;
    as_ernaData(:,2)=trans_w_as_erna(:,5);
    as_ernaData(:,3:4)=[trans_w_as_erna(:,4) round(trans_w_as_erna(:,end-2))];
    as_ernaData(:,5)=three_coloc(trans_w_as_erna(:,1));
    as_ernaData(:,6)=trans_w_as_erna(:,end-1).*convert;
    as_ernaData(:,7)= trans_w_as_erna(:,end);
    as_ernaData(:,8)=as_erna(trans_w_as_erna(:,end),3);
    as_ernaData(:,9)=round(as_ernaData(:,8)./erna_m);
    
end


mrnaLocx= [trans_w_as_erna(:,2:4) as_ernaData(:,4) as_ernaData(:,2)];
ernaLocx = [as_erna(trans_w_as_erna(:,end), 1:3) round(as_ernaData(:,8)./erna_m)  as_ernaData(:,2)];
generate_locx_files(mrnaLocx, [prefix,'mrna.locx']);
generate_locx_files(ernaLocx, [prefix,'erna.locx']);

writeToFile(as_ernaData,[prefix, 'Trans_with_as_erna.txt'], header);

header={'mRNA_Trans', 'intensity', '#nascent'};
no_ernaData= zeros(size(trans_wo_erna,1),3);
a=size(trans_wo_erna,1);
if(a>0)
    no_ernaData(:,1)=1:size(trans_wo_erna,1);
    no_ernaData(:,2:3)=[trans_wo_erna(:,4) round(trans_wo_erna(:,end))];
end
writeToFile(no_ernaData,[prefix,'Trans_without_erna.txt'], header);

end


%% Determiner les sites de transcription
function mrna=transite(mrna, background,k, intronsig)
% mrna:  x, y, intensity,, noyau, is_trans, number of mrna per spot
mrna_int= mrna(:,3);
idx= kmeans(mrna_int, 2);
[~, min_ind] =min(mrna_int);
single_cat= idx(min_ind);
if (intronsig==0)
    mean_single = mean(mrna_int(mrna(:,4)==background & idx==single_cat));
else
    mean_single = mean(mrna_int(mrna(:,4)~=background & idx==single_cat));
end

disp('mrna mean single intensity:')
disp(mean_single)
disp('mrna overall mean intensity:')
disp(mean(mrna_int))
dlmwrite('mrna_low_intensity.txt', mrna_int(idx==single_cat));
dlmwrite('mrna_high_intensity.txt', mrna_int(idx~=single_cat));
dlmwrite('mrna_single_intensity.txt', mrna_int(mrna(:,4)==background & idx==single_cat));


mrna(:,end+1)=(double(mrna(:,3)/mean_single)>k) & (mrna(:,4)~=background);
mrna(:,end+1)=mrna(:,3)/mean_single;

% I will be able to use the gui wrote for imaris here, Let's just assume
% that user don't need to correct for the moment

end


%% Trouver le noyau d'appartenance de chaque spot s'il existe
function coor=nucleus(coor, label_img, nuc_int)
coor(:,end+1)= zeros(size(coor(:,end)));
for i=1:length(coor(:,1))
    i_nuc=label_img(round(coor(i,2)),round(coor(i,1)));
    proche_nuc=zeros(2,2);
    if(coor(i,2)>1 && coor(i,1)>1)
        proche_nuc= label_img(round(coor(i,2))-1:round(coor(i,2))+1,round(coor(i,1))-1:round(coor(i,1))+1);
    end
    if(i_nuc>0)
        coor(i,end)= find(nuc_int==i_nuc);
    elseif sum(proche_nuc(:))>0
        coor(i, end)= find(nuc_int==proche_nuc(find(proche_nuc~=0,1)));
    end
end
end


%% Ecrire les ids des cellules sur l'image
function write_On_image(disp_im, towrite, nuc, trans, number)

%ecrire sur l'image
f = figure('color','white','units','normalized','position',[.1 .1 .8 .8]);
tmp_im = rgb2gray(disp_im);
tmp_im(tmp_im==0 | tmp_im==1) = 0;
tmp_im = im2bw(tmp_im, 0);
[im_D, ~] = bwdist(tmp_im);

imagesc(disp_im);
set(f,'units','pixels','position',[0 0 size(disp_im,1)  size(disp_im,2)],'visible','off')
%truesize; %this would be great but since it doesn't really work, fuck
%off

axis off
if(number)
    for a= 1:length(towrite)
        [i, j]=(find(nuc==towrite(a,1))); % pour retourner les coord x et  y
        idx = sub2ind(size(disp_im), i, j);
        im_idx = sort(im_D(idx), 'descend');
        moy = ceil((numel(im_idx)+1)/2);
        [i,j] = ind2sub(size(disp_im), idx(moy));
        text('position',[j i] , 'FontWeight','bold' ,'fontsize',10,'string',int2str(a), 'color', [0.5,0.5,0.5]) ;
    end
end

if nargin>3
    hold on;
    plot(trans(:,1),trans(:,2), '+', 'Color', [235, 197, 91]./255, 'MarkerSize', 3, 'LineWidth', 0.60);
end

% Capture the text image
print(f,'-depsc','-r150','final_label')

%saveas(f, 'final_label', 'png');

close(f);
end


%% Ecrire les données dans un fichier texte en utilisant header pour entête
function writeToFile(data, outfile, header)

fid = fopen(outfile,'w');
if fid == -1; error('Cannot open file: %s', outfile); end
fprintf(fid, '%s\t', header{:});
fprintf(fid, '\n');
fclose(fid);
dlmwrite(outfile, data,'delimiter', '\t', '-append');

end


function m=single_mean(intensity, method, message)
% This suppose that all the spot are currently in the  nucleus

[min_int, min_ind] =min(intensity);
[max_int, max_ind] =max(intensity);

m1=mean(intensity);

idx1= kmeans(intensity, 2);
m2=mean(intensity(idx1==idx1(min_ind)));

idx2=kmeans(intensity, 3);
m3= mean(intensity(idx2~=idx2(min_ind) & idx2~=idx2(max_ind)));
disp(message)
if(method==0)
    hf=figure,
    %hist(intensity);
    binranges = min_int:100:max_int+100;
    [bincounts] = histc(intensity,binranges);
    bar(binranges,bincounts,'histc');
    prompt = sprintf('Choose the %s calculation method between this 3 methods:\n -mean: %-0.5f\n -kmeans-2-center: %-0.5f\n -kmeans-3-center: %-0.5f\n',message, m1, m2, m3);
    answ=inputdlg(prompt,[message, ' calculation'],1);
    if isempty(answ)
        method=1;
    else
        method= str2double(answ{1});
    end
    close(hf);
end

if method==2
    m=m2;
    dlmwrite('k2_erna_low_intensity.txt', intensity(idx1==idx1(min_ind)));
    dlmwrite('k2_erna_high_intensity.txt', intensity(idx1==idx1(max_ind)));

elseif method==2
    m=m3;
    dlmwrite('k3_erna_low_intensity.txt', intensity(idx2==idx2(min_ind)));
    dlmwrite('k3_erna_high_intensity.txt', intensity(idx2==idx2(max_ind)));
    dlmwrite('k3_erna_middle_intensity.txt', intensity(idx2~=idx2(min_ind) & idx2~=idx2(max_ind)));

else
    m=m1;

end

end

function generate_locx_files(data, filename)
% the locx file is a extension of the loc file
% the format is the following: X Y INT NASC NUC
dlmwrite(filename, data,'delimiter', '\t', '-append');
end


function pos=findRound(x, maxX)
pos=round(x);
if(pos<1)
    pos=1;
elseif(pos>maxX)
    pos=maxX;
end

end

function coloc=all_coloc(srna_asrna, mrna_s, mrna_as, srna_asrna_coloc)

asrna_srna=[];
for i=1:numel(srna_asrna_coloc)
    asrna_srna=[asrna_srna;srna_asrna_coloc{i}(:)];
end

coloc=false(numel(mrna_s),1);
for i=1:numel(mrna_s)
    if(~isempty(mrna_s{i}) && ~isempty(mrna_as{i})) || (~isempty(mrna_s{i}) && nnz(srna_asrna(mrna_s{i},1))) || (~isempty(mrna_as{i}) && nnz(ismember(mrna_as{i},asrna_srna)))
        coloc(i)=true;
    end
end
end
