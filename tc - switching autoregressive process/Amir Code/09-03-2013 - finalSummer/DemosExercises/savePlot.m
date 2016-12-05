function savePlot(directory, innerDir, sarObj, id)
        fileName = [directory '/' innerDir num2str(sarObj.histLength) '_' ...
            num2str(sarObj.maxIt) '_user' num2str(id)];
        saveas( gcf, [fileName '.fig'] );    
        print('-dpdf', '-r2400', [fileName '.pdf']);
        close(gcf);        
end