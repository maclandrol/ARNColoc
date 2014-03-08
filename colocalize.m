function [out,each_coloc]=colocalize(arn1, arn2, disp_img)
%%Return the number of colocalize arn from arn1 and arn2
global res
global coloc_ind
coloc_ind={};
n= numel(arn1(:,1));
res=zeros(n,2);
slmin=0;
slmax=100;
figure,
imshow(disp_img);
hold on;
h= plot(arn1(:,1),arn1(:,2),'o','Color',[.88 .48 0],'MarkerSize',1);
hsl = uicontrol('Style','slider','Min',slmin,'Max',slmax,'SliderStep',[0.5 1]./(slmax-slmin),'Value',1,...
    'Position',[20 20 200 20], 'Tag', 'stupidSlider');

htext= uicontrol('Style', 'text', 'Position', [230 20 60 20], 'String', '1px', 'Tag', 'text');
set(hsl,'Callback',{@updateVal});

hbut=uicontrol('Style', 'pushbutton', 'String', 'Ok',...
    'Position', [300 20 50 20],...
    'Callback', {@doColoc, arn1, arn2});
waitfor(hbut, 'UserData')
out=res;
each_coloc=coloc_ind;

    function updateVal(~, ~)
        pix=get(hsl, 'Value');
        set(h,'MarkerSize', pix+0.0001)
        set(htext, 'String', [num2str(floor(pix*100)/100), 'px']);
    end

end

function doColoc(~,~,arn1, arn2)
global res
global coloc_ind
slider=findobj(0,'Tag','stupidSlider');
radius=get(slider, 'Value');
disp(['Radius : ',num2str(radius)]);
for i=1:length(res(:,1))
    dst= (arn2(:,1)-arn1(i,1)).^2 + (arn2(:,2)-arn1(i,2)).^2;
    coloc= dst<=(radius.^2);
    res(i,1:2)=[logical(nnz(coloc)), sum(coloc)];
    coloc_ind{i}=find(coloc);
end
close all;
end