function Mask_Matcher()

[FileName,PathName] = uigetfile({'*.tif';'*.tiff';'*.png';'*.*'},'Upload cell mask');
if isequal(FileName,0)
   error('Select a file')
else
   cell_file=fullfile(PathName, FileName);
end

[FileName,PathName] = uigetfile({'*.tif';'*.tiff';'*.png';'*.*'},'Upload nuc mask');
if isequal(FileName,0)
   error('Select a file')
else
   nuc_file=fullfile(PathName, FileName);
end

cell=imread(cell_file);
nuc=imread(nuc_file);


cell_background = findbackground(cell);
nuc_background = findbackground(nuc);

bw_cell=cell~=cell_background;
bw_cell=bwmorph(bw_cell, 'clean',Inf);
bw_cell=bwmorph(bw_cell, 'fill');
bw_nuc= nuc~=nuc_background;
%cell=imreconstruct(bw_nuc, bw_cell);

if ~isequal(bw_nuc, (bw_nuc & bw_cell))
    warning('Problem with your segmentation, Nucleus out of cell')
    choice = questdlg('Nucleus out of cell, Abort or Attempt to shrink nucleus ?', 'Bad Segmentation', 'Abort','Shrink', 'Shrink');
% Handle response
    switch choice
        case 'Abort'
            return
        case 'Shrink'
           bw_nuc=(bw_nuc & bw_cell);
    end

end

cell_CC=bwconncomp(bw_cell,8);
cell_mask=labelmatrix(cell_CC);
nuc_mask= immultiply(bw_nuc, cell_mask);
Intenpos = int64(unique(sort(cell_mask(cell_mask>0))));
write_On_image(cell_mask, Intenpos(:,1), 'cell_counting');

cell_ind=unique(cell_mask); nuc_ind=unique(nuc_mask);
if(length(cell_ind) > length(nuc_ind))
    choice = questdlg('Cell without nucleus, Continue or remove cells?', 'Cell-Nucleus mismatch', 'Continue','Remove', 'Remove');
    % Handle response
    switch choice
        case 'Abort'
            disp('continue execution ...')
        case 'Remove'
           for i=1:length(cell_ind)
               if isempty(find(nuc_ind==cell_ind(i),1))
                   cell_mask(cell_mask==cell_ind(i))=0;
               end
           end
    end
    
end

cell_ind=unique(cell_mask); nuc_ind=unique(nuc_mask);
if ~(length(cell_ind)== length(nuc_ind) && all(ismember(cell_ind, nuc_ind)))
    error('Could not correct your files !')
else
    [cellfile,pathname] = uiputfile({'*.tif';'*.tiff';'*.*'},'Save Cell mask');
    imwrite(cell_mask,fullfile(pathname, cellfile));

    [nucfile,pathname] = uiputfile({'*.tif';'*.tiff';'*.*'},'Save Nuc mask');
    imwrite(nuc_mask,fullfile(pathname, nucfile));

end

end


function bg= findbackground(im)

pixel_int= unique(im(:));
pixel_int=sort(pixel_int);
for i=1:length(pixel_int)
    pixel_int(i, 2)=nnz(im(:)==pixel_int(i,1));
end

pixel_size= sort(pixel_int(:,2), 'descend');
coeff=zeros(numel(pixel_size,1));
for i=1:length(pixel_int(:,1))
    coeff(i)=i.*find(pixel_size==pixel_int(i,2),1 );
  
end
[winner, bg]= min(coeff);

end

function write_On_image(im, towrite,filename)
%ecrire sur l'image


f = figure,imshow(label2rgb(im), []);
set(f,'units','pixels','position',[0 0 size(im,1)  size(im,2)],'visible','off')
%truesize; %this would be great but since it doesn't really work, fuck
%off
axis off

for a= 1:length(towrite)
   [i, j]=(find(im==towrite(a,1),1)); % pour retourner les coord x et  y
   h= text('position',[j i] , 'FontWeight','bold' ,'fontsize',10,'string',int2str(a)) ;

end

% Capture the text image
% saveas(f, 'final_label', 'png');
X=getframe(gcf);
if isempty(X.colormap)
    imwrite(X.cdata,strcat(filename,'.png'));
else
    imwrite(X.cdata,X.colormap,strcat(filename,'.tif'));
end
close(f);


end