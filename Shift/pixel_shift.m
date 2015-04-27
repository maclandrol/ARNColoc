function [ref, mean_shift]=pixel_shift(locfile1, locfile2, datatype, correct_file, distance)
% pixel_shift(locfile1, locfile2, datatype, fileToCorrect)
%
% locfile1/locfile2 (filename) : .loc or loc3 file
%
% datatype (integer) : 2 for 2D and 3 for 3D, default 3D if not provided
%
% fileToCorrect (integer) : the locfile you want to correct, 1 for locfile1
% and 2 for locfile2. No correction if not provided by default
%
% distance, max distance between spot to consider

narginchk(2,5);
if ~exist('correct_file', 'var') || isempty(correct_file)
    correct_file=0;
end
if ~exist('datatype', 'var') || isempty(datatype)
    datatype=3;
end
if ~exist('distance', 'var') || isempty(distance)
    distance=-1;
end


loc1 = load(locfile1);
loc2 = load(locfile2);
if(size(loc1,2)>5 || size(loc2,2)>5)
    error('DATA incorrect')
end

ref=1;
disp('**Reference File = ');
%Swap so locdata1 is the largest
if(size(loc1,1)<size(loc2,1))
    locdata1=loc2(:,1:datatype);
    locdata2=loc1(:,1:datatype);
    disp(locfile2)
    ref=2;
else
    locdata1=loc1(:,1:datatype);
    locdata2=loc2(:,1:datatype);
    disp(locfile1);
end

%Extract coordinate from each spot data

locdata= [locdata1; locdata2];
m= size(locdata1,1);%number of spot in data1
n= size(locdata2,1);%number of spot in data2, m>=n

[IDX, C, SUMD]= kmeans(locdata, [], 'EmptyAction', 'singleton', 'Start', locdata1);

result=zeros(max(IDX),2);
for i=1:length(IDX)
    result(IDX(i),1)=result(IDX(i),1)+1;
end

shift=[];
already_seen=[];
for i=1:size(result,1)
    if(result(i,1)==2)
        indices= find(IDX==i);
        %Check if each duo is formed by 2 differents spots
        if(indices(1)<=m && indices(2)>m || indices(2)<=m && indices(1)>m)
            %if(isempty(find(already_seen==max(indices), 1)))
                %result(i,2)=1;
                %Now check the distance requirement
                if(distance<0 || distance.^2>=computeDistance(locdata(indices(1),:), locdata(indices(2),:)))
                    %already_seen=[already_seen;max(indices)];
                    shift=[shift;locdata(indices(1),:)-locdata(indices(2),:)];
                end
            %end
        end
    end
end

%Joint spot duo(data1, data2)
count_result=result(result(:,2)==1);
fprintf('\n\n**Spots informations\n');
disp([num2str(size(loc1,1)),' spots dans ', locfile1, ' et ', num2str(size(loc2,1)) ' spots dans ', locfile2 ]);
duo=num2str(size(count_result,1));
duo_percent= num2str(duo*100/n);
disp([duo, ' duos trouvés pour le shift soit : ', duo_percent, '%'])
%Find pixel shif mean and pixel shift distribution ===> substraction
%between spot 1 and spot2 distance
disttest=sum(shift.^2,2);
disp('Distance moyenne')
disp(mean(disttest));
mean_shift=mean(shift,1);
disp('Shift moyenne distance');
disp(sum(mean_shift.^2))
disp('***DEBUG***');
%disp(disttest);

shift_sens= ref~=correct_file;
if(correct_file==1)
    saveToFile(locfile1, mean_shift, loc1, shift_sens, datatype);
elseif(correct_file==2)
    saveToFile(locfile2, mean_shift, loc2, shift_sens, datatype);
end

fprintf('\n\n**Shift X, Y, Z\n');
disp('Mean');
disp(mean_shift)
disp('Std');
std_shift=shift_std(shift);
disp(std_shift');
%fprintf('\n\n**Normality test X, Y, Z at alpha=0.01\n');

%plotting

%disp('X');
%[hypo, p, stats]= chi2gof(shift(:,1));
h1=figure;
subplot(2,1,1);
normplot(shift(:,1))
title('Norm plot X shift');
subplot(2,1,2);
binranges = min(shift(:,1)):0.1:max(shift(:,1));
[bincounts] = histc(shift(:,1),binranges);
% bar(binranges,bincounts,'histc');
histfit(shift(:,1), numel(bincounts));
f = findobj(gca,'Type','patch');
set(f,'FaceColor',[0 .5 .5],'EdgeColor','w');
xlabel('shift size');
ylabel('Count');
title('X shift distribution');

%disp('Y');
%[hypo, p, stats]= chi2gof(shift(:,2));
h2=figure;
subplot(2,1,1);
normplot(shift(:,2));
title('Norm plot Y shift');
subplot(2,1,2);
binranges = min(shift(:,2)):0.1:max(shift(:,2));
[bincounts] = histc(shift(:,2),binranges);
histfit(shift(:,2), numel(bincounts));
% bar(binranges,normalizedCounts,'histc');
f = findobj(gca,'Type','patch');
set(f,'FaceColor',[0 .5 .5],'EdgeColor','w');
xlabel('shift size');
ylabel('Count');
title('Y shift distribution');

if datatype==3
    %disp('Z');
    %[hypo, p, stats]= chi2gof(shift(:,3));
    h3=figure;
    subplot(2,1,1);
    normplot(shift(:,3))
    title('Norm plot Z shift');
    subplot(2,1,2);
    binranges = min(shift(:,3)):0.1:max(shift(:,3));
    [bincounts] = histc(shift(:,3),binranges);
    %bar(binranges,bincounts,'histc');
    histfit(shift(:,3), numel(bincounts));
    f = findobj(gca,'Type','patch');
    set(f,'FaceColor',[0 .5 .5],'EdgeColor','w');
    xlabel('shift size');
    ylabel('Count');
    title('Z shift distribution');
end

end


function saveToFile(locfile, mean_shift, locdata, shift_sens, datatype)
if(shift_sens==0)
    locdata(:,1:datatype)= bsxfun(@minus,locdata(:,1:datatype),mean_shift(1:datatype));
else
    locdata(:,1:datatype)= bsxfun(@plus,locdata(:,1:datatype),mean_shift(1:datatype));
end

dlmwrite(strcat('corrected_', locfile),locdata, 'delimiter','\t');
end

function std_shift=shift_std(shift)
std_shift=[];
for i=1:size(shift,2)
    std_shift=[std(shift(:,i));std_shift];
end
end


function dist=computeDistance(spot1, spot2)
dist=sum((spot1-spot2).^2);
end

