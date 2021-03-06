% Prints the path generated by the greedy algorithm where the next step is
% always chosen to obtain the largest performance increase. 
% Also prints all simple paths that have monotonically increasing
% performance where the cost of each step is below some cost. Generates
% a figure with the ncff and cost of these simple paths plotted.

% distance: NxN, distances between engineering states (use gen_distance()
% to create this matrix)
% ncff: Nx1, the performance of each state
% cost: Nx1, the cost, in ATP per CO2 fixed, of each state
% start: the number of the start node

function engineering(distance, ncff, cost, start)

N = size(ncff, 1);
global_max = find(ncff == max(ncff));
% print node with global max ncff 
disp(global_max);
% set max cost of path here
max_cost = 10;

A = distance == 1;
G = graph(A);
G.Nodes.Values = ncff;

% initialize figure 
fig1 = figure();
figure(fig1);
left_color = [0 0 0];
right_color = [0.458823529411765,0.0274509803921569,0.423529411764706];
set(fig1,'defaultAxesColorOrder',[left_color; right_color]);
% change xlim based on length of shortest paths
xlim([-0.5 5.5]);ylim([0 1]);
set(gca,'Fontname','Helvetica','Fontsize',18,'Fontweight','normal','Linewidth',2);
set(gcf,'position',[10,10,570,350])
hold on

current = start;
next = start;

i = 0;

x = [];
y = [];

% find greedy path forward from baseline (alg will always choose the next
% step with the largest increase in ncff)
disp("Greedy path: ");

while i >= 0
    disp(strcat("Step ", num2str(i), ": ", num2str(current), ...
        ", ncff = ", num2str(ncff(current)), ", cost: ", num2str(cost(current))));
 
    
    % record pathLength from baseline
    x(i+1) = i;
    y(i+1) = ncff(current);


    adj = neighbors(G, current);
    for node = 1:size(adj,1)

        if ncff(adj(node)) > ncff(next)
            next = adj(node);
        else
            continue;
        end 
    end
    
    if current == next
        break;
    else
        current = next;
        i = i + 1;
    end 
end

% find all simple paths from baseline to global max shorter than the length
% specified by arg 5 of all_simple_path()
edges = table2array(G.Edges);
paths = all_simple_path(edges, N, start, global_max, 6);
min = 25;

for i = 1:size(paths,2)
    
    % arrays of node indices, distance, ncff, cost, and color for all paths
    arr = cell2mat(paths(i));
    d = zeros(1,size(arr,2));
    n = zeros(1,size(arr,2));
    c = zeros(1,size(arr,2));
    
    % fill the arrays 
    for j = 1: size(arr, 2)
        d(j) = j-1;
        n(j) = ncff(arr(j));
        c(j) = cost(arr(j));
    end
    
    
    % here we only plot the path if ncff increases monotonically at each
    % step
    
    n_round = round(n, 2);
    if sort(n_round) == n_round
        
        % find minimum cost path within the set of paths with monotonically
        % increasing performance
        if max(c) < min
            min = max(c);
        end 
        
%         if a path is below a certain cost, print out that path.
%         this will print multiple paths unless you choose a maximum cost.
        if all(c<max_cost)
            disp("Simple paths: ");
            plot(d, n, 'Color', 'k', 'Linewidth', 2.5);
            scatter(d, n, 80, 'k', 'filled');
            
            yyaxis right
            plot(d, c, 'Color', right_color, 'Linewidth', 2.5);
            scatter(d, c, 80, right_color, 'filled');
            ylim([-0.8 20]);
            set(gca,'ycolor',right_color)
            
            for j = 1:size(arr,2)
                disp(strcat("Step ", num2str(d(j)), ": ", num2str(arr(j)), ...
                  ", ncff = ", num2str(n(j)), ", cost: ", num2str(c(j))));    
            end
            
%             add a break here to only plot one path on the figure.
        end 
    end 
    hold on
end 



