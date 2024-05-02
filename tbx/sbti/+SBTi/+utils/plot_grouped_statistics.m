function plot_grouped_statistics(aggregated_portfolio, company_contributions, analysis_parameters)

    [timeframe, scope, grouping] = deal(analysis_parameters{:});

    G = groupsummary(company_contributions, grouping, 'sum', ["investment_value","contribution"]);
    
    sector_investments = G.sum_investment_value;
    sector_contributions = G.sum_contribution;
    
    sector_names = categorical(G.sector);
    sector_temp_scores = [aggregated_portfolio.mid.S1S2.grouped.values];
    sector_temp_scores = [sector_temp_scores{:}];
    sector_temp_scores = [sector_temp_scores.score];
    [~, iA] = sort(sector_temp_scores, 2, 'descend');
    sector_names = reordercats(sector_names, G.sector(iA));

    fig = figure('Units','normalized','Position',[0 0 1 1]);
    t = tiledlayout(fig, 'flow','TileSpacing','tight');
    ax1 = nexttile(t);
    pie(ax1, sector_investments)
    title(ax1, 'Investments')
    colormap('turbo')

    ax2 = nexttile(t);
    pie(ax2, sector_contributions);
    title(ax2, 'Contributions')
    
    legend(sector_names, 'Location','eastoutside');

    ax3 = nexttile(t,[1 2]);
    
    bar(sector_names, sector_temp_scores)
    ylim(ax3, [0 3.5])
    yline(1.5,'k--', 'LineWidth',1.5)