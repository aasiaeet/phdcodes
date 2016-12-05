% Graphical interface that asks user to label numOfPoints spike for
% semisupervision.
% 
% observedStates = semiSupervision(data, numOfPoints)
%
% Inputs:
% data :  Array of cells of aggregated and detrended data.
% numOfPoints   :  Number of points to label. 
%
% Outputs:
% observedStates: Observed state of numOfPoints time step. 
% 

function observedStates = semiSupervision(directory , data, numOfPoints)
    N = length(data); %number of users
    [G T] = size(data{1}); %assume all traces have the same length
    observedStates = cell(N, 1);            
    screen_size = get(0, 'ScreenSize');            
    for n = 1:N
        f1 = figure(1);
        set(f1, 'Position', [0 0 screen_size(3) screen_size(4) ] );
        colors = hsv(G);
        for g = 1:G                
            plot(data{n}(g,:), '-s', 'color',colors(G - g + 1,:),'MarkerEdgeColor','k',...
                'MarkerFaceColor','g','MarkerSize',3); 
            xlim([1, T]); 
            hold on;            
        end 
        [x, ~] = ginput(numOfPoints);
        x = round(x);
        x(x < 0) = 0; x(x > T) = T; 
        scatter(x, data{n}(g,x), 50, 'o', 'fill', 'MarkerEdgeColor','k',...
                'MarkerFaceColor','c')
        hold off;
        observedStates{n} = sort(x);  
        xlim([1, T]);         
        set( gcf, 'Name', 'Semisupervised');
        fileName = [directory '/Semisup for user' num2str(n)  num2str(clock)];
        saveas( gcf,  [fileName '.fig']);    
        print('-dpdf', '-r2400', [fileName '.pdf']);        
        close(gcf);
    end
end