function ARN_coloc(imgfile, s_ernafile, as_ernafile, mrnafile,k, threshold)
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


narginchk(4,6);
if ~exist('threshold', 'var') || isempty(threshold)
    threshold=-1;
end
if ~exist('k', 'var') || isempty(threshold)
    k=1.5;
end


img=imread(imgfile);
disp_img=ind2rgb(gray2ind(im2bw(mat2gray(img),0),255), gray(255));
img=bwlabel(im2bw(mat2gray(img),0),4);

%TRouver la nouvelle distribution en intensité des noyaux
inten_dist=int64(unique(sort(img(img>0))));

%Lecture des fichier de coordonnées des arn
s_erna=round(load (s_ernafile));
s_erna=s_erna((s_erna(:,3)>=threshold),1:3);
as_erna=round(load (as_ernafile));
as_erna=as_erna((as_erna(:,3)>=threshold),1:3);
mrna=round(load (mrnafile));
mrna=mrna((mrna(:,3)>=threshold),1:3);

%Displaying spot on img
for i=1:length(mrna(:,1))
    if(mrna(i,2)-2>0 && mrna(i,1)-2>0)
        disp_img(mrna(i,2)-2:mrna(i,2)+2, mrna(i,1)-2:mrna(i,1)+2, 1:3)=0;
        disp_img(mrna(i,2)-2:mrna(i,2)+2, mrna(i,1)-2:mrna(i,1)+2, 1)=1;
    else
        disp_img(mrna(i,2), mrna(i,1), 1:3)=0;
        disp_img(mrna(i,2), mrna(i,1), 1)=1;
    end
end

for i=1:length(s_erna(:,1))
    if(s_erna(i,2)-2>0 && s_erna(i,1)-2>0)
        disp_img(s_erna(i,2)-2:s_erna(i,2)+2, s_erna(i,1)-2:s_erna(i,1)+2, 1:3)=0;
        disp_img(s_erna(i,2)-2:s_erna(i,2)+2, s_erna(i,1)-2:s_erna(i,1)+2, 3)=1;
    else
        disp_img(s_erna(i,2), s_erna(i,1), 1:3)=0;
        disp_img(s_erna(i,2), s_erna(i,1), 3)=1;
    end
    
end

for i=1:length(as_erna(:,1))
    if(as_erna(i,2)-2>0 && as_erna(i,1)-2>0)
        
        disp_img(as_erna(i,2)-2:as_erna(i,2)+2, as_erna(i,1)-2:as_erna(i,1)+2, 1:3)=0;
        disp_img(as_erna(i,2)-2:as_erna(i,2)+2, as_erna(i,1)-2:as_erna(i,1)+2, 2)=1;
    else
        disp_img(as_erna(i,2), as_erna(i,1), 1:3)=0;
        disp_img(as_erna(i,2), as_erna(i,1), 2)=1;
    end
end

%Setting nucleus for each rna
mrna=nucleus(mrna, img, inten_dist);
s_erna=nucleus(s_erna, img, inten_dist);
as_erna=nucleus(as_erna, img, inten_dist);

mrna=transite(mrna, 0,k);

disp('*Colocalization s-erna vs as-erna');
[s_erna_coloc_as_erna, serna_aserna_coloc]= colocalize(s_erna, as_erna, disp_img);
disp('*Colocalization mrna vs s-erna');
[mrna_coloc_s_erna, mrna_serna_coloc]= colocalize(mrna, s_erna, disp_img);
disp('*Colocalization mrna vs as-erna');
[mrna_coloc_as_erna, mrna_aserna_coloc]= colocalize(mrna, as_erna, disp_img);
three_coloc= all_coloc(s_erna_coloc_as_erna,mrna_serna_coloc,mrna_aserna_coloc,serna_aserna_coloc);

mrnaDATA=[(1:size(mrna,1))' mrna];
trans_w_s_erna=mrnaDATA((mrna_coloc_s_erna(:,1)>0 & mrnaDATA(:,end-1)==1),:);
trans_w_as_erna=mrnaDATA((mrna_coloc_as_erna(:,1)>0 & mrnaDATA(:,end-1)==1),:);
trans_wo_erna= mrnaDATA((mrna_coloc_as_erna(:,1)==0 & mrna_coloc_s_erna(:,1)==0 & mrnaDATA(:,end-1)==1),:);

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
    trans_data(i,10)= sum(round(trans_w_s_erna(trans_w_s_erna(:,5)==inten_dist(i),end)));
    trans_data(i,11)= sum(round(trans_w_as_erna(trans_w_as_erna(:,5)==inten_dist(i),end)));
    trans_data(i,12)= sum(round(trans_wo_erna(trans_wo_erna(:,5)==inten_dist(i),end)));

end

write_On_image(disp_img, inten_dist, img, mrna(mrna(:,end-1)~=0,1:end));
header={'Nuc','s_erna-as_erna','s_erna-mrna','as_erna-mrna','as_erna-s_erna-mrna', '#mrna', '#s_erna', '#as_erna'};
writeToFile(data, 'spot_coloc_analysis.txt', header);
header={'Nuc','s_erna-as_erna','s_erna-t_mrna','as_erna-t_mrna','as_erna-s_erna-t_mrna','trans_number', 'nascent_mrna','#s_erna', '#as_erna', '#mRNAnascent_coloc_s_erna', '#mRNAnascent_coloc_as_erna', '#mRNAnascent_noColoc_erna'};
writeToFile(trans_data, 'trans_coloc_analysis.txt', header);

header={'mRNA_Trans', 'intensity', '#nascent', 'is_also_Coloc with_as-erna'};
s_ernaData= zeros(size(trans_w_s_erna,1),4);
a=size(trans_w_s_erna,1);
if(a>0)
    s_ernaData(:,1)=1:size(trans_w_s_erna,1);
    s_ernaData(:,2:3)=[trans_w_s_erna(:,4) round(trans_w_s_erna(:,end))];
    s_ernaData(:,4)=three_coloc(trans_w_s_erna(:,1));
end
writeToFile(s_ernaData,'Trans_with_s_erna.txt', header);

header={'mRNA_Trans', 'intensity', '#nascent', 'is_also_Coloc with_s-erna'};
as_ernaData= zeros(size(trans_w_as_erna,1),4);
a=size(trans_w_as_erna,1);
if(a>0)
    as_ernaData(:,1)=1:size(trans_w_as_erna,1);
    as_ernaData(:,2:3)=[trans_w_as_erna(:,4) round(trans_w_as_erna(:,end))];
    as_ernaData(:,4)=three_coloc(trans_w_as_erna(:,1));

end
writeToFile(as_ernaData,'Trans_with_as_erna.txt', header);

header={'mRNA_Trans', 'intensity', '#nascent'};
no_ernaData= zeros(size(trans_wo_erna,1),3);
a=size(trans_wo_erna,1);
if(a>0)
    no_ernaData(:,1)=1:size(trans_wo_erna,1);
    no_ernaData(:,2:3)=[trans_wo_erna(:,4) round(trans_wo_erna(:,end))];
end
writeToFile(no_ernaData,'Trans_without_erna.txt', header);

end

function mrna=transite(mrna, background,k)
% mrna:  x, y, intensity,, noyau, is_trans, number of mrna per spot
mrna_int= mrna(:,3);
idx= kmeans(mrna_int, 2);
[~, min_ind] =min(mrna_int);
single_cat= idx(min_ind);
mean_single = mean(mrna_int(mrna(:,4)==background & idx==single_cat));
mrna(:,end+1)=(double(mrna(:,3)/mean_single)>k) & (mrna(:,4)~=background);
mrna(:,end+1)=mrna(:,3)/mean_single;

% I will be able to use the gui wrote for imaris here, Let's just assume
% that user don't need to correct for the moment

end

function coor=nucleus(coor, label_img, nuc_int)
coor(:,end+1)= zeros(size(coor(:,end)));
for i=1:length(coor(:,1))
    i_nuc=label_img(coor(i,2),coor(i,1));
    proche_nuc= label_img(coor(i,2)-1:coor(i,2)+1,coor(i,1)-1:coor(i,1)+1);
    if(i_nuc>0)
        coor(i,end)= find(nuc_int==i_nuc);
    elseif(coor(i,2)>1 && coor(i,1)>1 && sum(proche_nuc(:))>0)
        coor(i, end)= find(nuc_int==proche_nuc(find(proche_nuc~=0,1)));
    end
end
end

%% Ecrire les ids des cellules sur l'image
function write_On_image(disp_im, towrite, nuc, trans)

%ecrire sur l'image
f = figure('color','white','units','normalized','position',[.1 .1 .8 .8]);
imagesc(disp_im);
set(f,'units','pixels','position',[0 0 size(disp_im,1)  size(disp_im,2)],'visible','off')
%truesize; %this would be great but since it doesn't really work, fuck
%off
axis off
for a= 1:length(towrite)
    [i, j]=(find(nuc==towrite(a,1),1)); % pour retourner les coord x et  y
    text('position',[j i] , 'FontWeight','bold' ,'fontsize',10,'string',int2str(a)) ;
end

if nargin>3
    hold on;
    plot(trans(:,1),trans(:,2), 'k+', 'MarkerSize', 2);
end

% Capture the text image
saveas(f, 'final_label', 'png');

close(f);
end

function writeToFile(data, outfile, header)

fid = fopen(outfile,'w');
if fid == -1; error('Cannot open file: %s', outfile); end
fprintf(fid, '%s\t', header{:});
fprintf(fid, '\n');
fclose(fid);
dlmwrite(outfile, data,'delimiter', '\t', '-append');

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
