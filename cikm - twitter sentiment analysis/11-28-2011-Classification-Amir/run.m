function [result] = run(resultdir, confdir, databasedir)
    %load/run each conf file from confdir.    
    confdirstruct = dir(confdir);
    for i = 1:length(confdirstruct)
        if ~strcmp(confdirstruct(i).name,'.') && ~strcmp(confdirstruct(i).name,'..')
            conffile = confdirstruct(i).name;
            conffile = conffile(1:(length(conffile)-2)); %delete ".m"
            fprintf('conf = %s\n', conffile);  
            conf = prepareconf(resultdir, confdir, databasedir, conffile);
            %generate [data matrix (row observation & col features), label
            %vector]
            [ data label ] = preparedata(conf); 
            [result] = traintest(conf, data, label);
            cd(conf.resdir);
            save([conf.conffile '_' 'result' eval('date') '_' num2str(eval('clock')) '.mat'],'result');
            cd('..');
        end
    end                   
end



