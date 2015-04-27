function corr_file=correct_shift(locfile, mean_shift, locdata, sens, datatype)
if(sens==0)
    locdata(:,1:datatype)= bsxfun(@minus,locdata(:,1:datatype),mean_shift(1:datatype));
else
    locdata(:,1:datatype)= bsxfun(@plus,locdata(:,1:datatype),mean_shift(1:datatype));
end

corr_file=strcat(locfile, 'C_');
dlmwrite(corr_file,locdata, 'delimiter','\t');
end