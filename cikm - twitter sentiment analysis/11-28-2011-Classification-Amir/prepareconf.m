function conf = prepareconf(resultdir, confdir, databasedir, conffile)    
    mkdir(resultdir,conffile)
    conf = loadconfiguration(confdir, conffile);
    conf.resdir = resultdir;
    conf.conffile = conffile;    
    conf.databasedir = databasedir;
end