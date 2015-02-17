function [out,each_coloc]=colocalize(arn1, arn2, disp_img, convert, title)
%%Return the number of colocalize arn from arn1 and arn2
global res
global coloc_ind
coloc_ind={};
n= numel(arn1(:,1));
res=zeros(n,4);
slmin=0;
slmax=100;
figure('name',title),
imshow(disp_img);
hold on;
h= plot(arn1(:,1),arn1(:,2),'o','Color',[.88 .48 0],'MarkerSize',1);
hsl = uicontrol('Style','slider','Min',slmin,'Max',slmax,'SliderStep',[0.1 1]./(slmax-slmin),'Value',1,...
    'Position',[20 20 200 20], 'Tag', 'gslider');

htext= uicontrol('Style', 'text', 'Position', [230 20 100 20], 'String', [num2str(convert*1), 'nm'], 'Tag', 'text');
set(hsl,'Callback',{@updateVal});

hbut=uicontrol('Style', 'pushbutton', 'String', 'Ok',...
    'Position', [340 20 50 20],...
    'Callback', {@doColoc, arn1, arn2, convert});
waitfor(hbut, 'UserData')
out=res;
each_coloc=coloc_ind;

    function updateVal(~, ~)
        pix=get(hsl, 'Value');
        set(h,'MarkerSize', pix)
        set(htext, 'String', [num2str(pix*100*convert/100), 'nm']);
    end

end

function doColoc(~,~,arn1, arn2, convert)
global res
global coloc_ind
slider=findobj(0,'Tag','gslider');
radius=get(slider, 'Value');
disp(['Radius : ', num2str(radius*convert),'nm']);
for i=1:length(res(:,1))
    dst= double((arn2(:,1)-arn1(i,1)).^2 + (arn2(:,2)-arn1(i,2)).^2);
    coloc= dst<=(radius.^2);
    
    [min_val,min_index] = min(dst);
    res(i,1:4)=double([logical(nnz(coloc)), sum(coloc), sqrt(min_val), min_index]);
    coloc_ind{i}=find(coloc);
end
close gcf
end