%% Cliff's Delta: KFV und Referenzmethoden
% Vergleich der 9 Geländeparameter aus SAGA zwischen KFV und
% Random-Buffer bzw. Random-Points.
%
% Positive Delta-Werte zeigen tendenziell höhere Werte in den KFV,
% negative Delta-Werte tendenziell höhere Werte im Referenzdatensatz.

clear; clc; close all;


%% 1) Daten- und Ausgabeordner

dataDir = 'C:\Users\simon\BA Ahrtal 2026';
outDir = fullfile(dataDir, 'plots_cliffs_delta');

if ~exist(outDir, 'dir')
    mkdir(outDir);
end


%% 2) Eingabedateien

files.kfvPoints = fullfile(dataDir, ...
    'Klassenstatistik KFV Pixelwerte SAGA 25 K.xlsx');

files.randomBufferPoints = fullfile(dataDir, ...
    'Klassenstatistik Random Buffer Pixelwerte SAGA 25 K.xlsx');

files.randomPoints = fullfile(dataDir, ...
    'Klassenstatistik Random Points Pixelwerte SAGA 25 K.xlsx');


%% 3) Tabellen einlesen

T_kfv = readAnyTable(files.kfvPoints);
T_randomBuffer = readAnyTable(files.randomBufferPoints);
T_randomPoints = readAnyTable(files.randomPoints);


%% 4) Parameter

% Bezeichnungen für Tabellen und Abbildungen
paramLabels = {
    'Slope', ...
    'VRM', ...
    'Plan Curvature', ...
    'Profile Curvature', ...
    'Mid-Slope Position', ...
    'Valley Depth', ...
    'Convergence Index', ...
    'TWI', ...
    'Flow Accumulation'
};

% Interne MATLAB-Namen
varNames = {
    'Slope', ...
    'VRM', ...
    'PlanCurvature', ...
    'ProfileCurvature', ...
    'MidSlopePosition', ...
    'ValleyDepth', ...
    'ConvergenceIndex', ...
    'TWI', ...
    'FlowAccumulation'
};

% Spaltennamen in den Eingangstabellen
sourceColumns = {
    'SLOPE_1', ...
    'VRM_1', ...
    'PLAN_1', ...
    'PROF_1', ...
    'MID_1', ...
    'VALLEY_1', ...
    'CONV_1', ...
    'TWI_1', ...
    'FLOW_1'
};


%% 5) Einheitliche Parametertabellen erzeugen

KFV = buildParameterTable( ...
    T_kfv, varNames, sourceColumns);

RBUF = buildParameterTable( ...
    T_randomBuffer, varNames, sourceColumns);

RPOINT = buildParameterTable( ...
    T_randomPoints, varNames, sourceColumns);


%% 6) Cliff's Delta berechnen

% Buffermethode: KFV vs. Random-Buffer
deltaBuffer = cliffsDeltaTable(KFV, RBUF);

% Punktmethode: KFV vs. Random-Points
deltaPoint = cliffsDeltaTable(KFV, RPOINT);

absBuffer = abs(deltaBuffer);
absPoint = abs(deltaPoint);


%% 7) Relative Trennstärke berechnen

% Anteil des absoluten Delta-Wertes eines Parameters an der
% Summe aller absoluten Delta-Werte der jeweiligen Referenzmethode.

shareBuffer = 100 * absBuffer ./ sum(absBuffer, 'omitnan');
sharePoint = 100 * absPoint ./ sum(absPoint, 'omitnan');


%% 8) Ergebnistabelle für die weitere Verarbeitung

results = table( ...
    paramLabels(:), ...
    deltaPoint(:), ...
    absPoint(:), ...
    sharePoint(:), ...
    deltaBuffer(:), ...
    absBuffer(:), ...
    shareBuffer(:), ...
    'VariableNames', { ...
        'Parameter', ...
        'Delta_Punktmethode', ...
        'AbsDelta_Punktmethode', ...
        'Anteil_Punktmethode_pct', ...
        'Delta_Buffermethode', ...
        'AbsDelta_Buffermethode', ...
        'Anteil_Buffermethode_pct'});


% Sortierung für die beiden gerichteten Delta-Abbildungen
resultsPointSorted = sortrows( ...
    results(:, { ...
        'Parameter', ...
        'Delta_Punktmethode', ...
        'AbsDelta_Punktmethode'}), ...
    'AbsDelta_Punktmethode', ...
    'descend');

resultsBufferSorted = sortrows( ...
    results(:, { ...
        'Parameter', ...
        'Delta_Buffermethode', ...
        'AbsDelta_Buffermethode'}), ...
    'AbsDelta_Buffermethode', ...
    'descend');


%% 9) Gerichtete Cliff's-Delta-Werte

makeDeltaBarFigure( ...
    resultsPointSorted.Parameter, ...
    resultsPointSorted.Delta_Punktmethode, ...
    'Cliff''s Delta: Punktmethode (KFV vs. Random-Points)', ...
    fullfile(outDir, '01_cliffs_delta_punktmethode'));

makeDeltaBarFigure( ...
    resultsBufferSorted.Parameter, ...
    resultsBufferSorted.Delta_Buffermethode, ...
    'Cliff''s Delta: Buffermethode (KFV vs. Random-Buffer)', ...
    fullfile(outDir, '02_cliffs_delta_buffermethode'));


%% 10) Methodenvergleich der relativen Trennstärke

makeMethodComparisonFigure( ...
    results.Parameter, ...
    results.Anteil_Punktmethode_pct, ...
    results.Anteil_Buffermethode_pct, ...
    fullfile(outDir, ...
    '05_cliffs_delta_trennschaerfe_methodenvergleich'));


fprintf('\nFertig. Abbildungen gespeichert in:\n%s\n', outDir);


%% Lokale Hilfsfunktionen


function T = readAnyTable(filePath)

    if ~isfile(filePath)
        error('Datei nicht gefunden: %s', filePath);
    end

    T = readtable( ...
        filePath, ...
        'VariableNamingRule', 'preserve');

end


function P = buildParameterTable(T, varNames, sourceColumns)

    P = table();

    for i = 1:numel(varNames)

        columnName = sourceColumns{i};

        if ~any(strcmp(columnName, T.Properties.VariableNames))
            error('Spalte "%s" nicht gefunden.', columnName);
        end

        P.(varNames{i}) = makeNumeric(T.(columnName));

    end

end


function x = makeNumeric(x)

    if istable(x)
        x = table2array(x);
    end

    if iscell(x)
        x = string(x);
    end

    if isstring(x) || ischar(x) || iscategorical(x)
        x = str2double(string(x));
    end

    x = double(x);
    x = x(:);

end


function deltas = cliffsDeltaTable(T1, T2)

    vars = T1.Properties.VariableNames;
    deltas = nan(1, numel(vars));

    for i = 1:numel(vars)

        x = T1.(vars{i});
        y = T2.(vars{i});

        x = x(isfinite(x));
        y = y(isfinite(y));

        deltas(i) = cliffsDeltaFast(x, y);

    end

end


function delta = cliffsDeltaFast(x, y)

    x = x(:);
    y = y(:);

    nx = numel(x);
    ny = numel(y);

    if nx == 0 || ny == 0
        delta = NaN;
        return
    end

    % Gemeinsame Rangfolge beider Gruppen
    values = [x; y];
    groupX = [true(nx,1); false(ny,1)];

    [sortedValues, order] = sort(values);
    ranks = zeros(size(values));

    % Bei Bindungen wird der mittlere Rang vergeben
    n = numel(values);
    k = 1;

    while k <= n

        j = k;

        while j < n && sortedValues(j+1) == sortedValues(k)
            j = j + 1;
        end

        meanRank = (k + j) / 2;
        ranks(order(k:j)) = meanRank;

        k = j + 1;

    end

    % Cliff's Delta aus der Rangsumme der ersten Gruppe
    rankSumX = sum(ranks(groupX));
    U = rankSumX - nx * (nx + 1) / 2;

    delta = (2 * U / (nx * ny)) - 1;

end


function makeDeltaBarFigure(paramList, deltaValues, figTitle, outBase)

    fig = figure( ...
        'Color', 'w', ...
        'Position', [100 100 1100 650]);

    bar(deltaValues);

    yline(0, '-', ...
        'HandleVisibility', 'off');

    xticks(1:numel(deltaValues));
    xticklabels(paramList);
    xtickangle(35);

    ylabel('Cliff''s Delta');

    title( ...
        figTitle, ...
        'Interpreter', 'none', ...
        'FontWeight', 'bold');

    grid on;
    ylim([-1.12 1.12]);


    % Delta-Werte an den Balken ausgeben
    for i = 1:numel(deltaValues)

        if deltaValues(i) >= 0
            yText = deltaValues(i) + 0.04;
            verticalAlignment = 'bottom';
        else
            yText = deltaValues(i) - 0.04;
            verticalAlignment = 'top';
        end

        text( ...
            i, yText, sprintf('%.2f', deltaValues(i)), ...
            'HorizontalAlignment', 'center', ...
            'VerticalAlignment', verticalAlignment, ...
            'FontSize', 10);

    end


    exportgraphics( ...
        fig, ...
        [outBase '.png'], ...
        'Resolution', 300);

    close(fig);

end


function makeMethodComparisonFigure( ...
    paramList, sharePoint, shareBuffer, outBase)

    % Gemeinsame Sortierung nach dem mittleren Anteil beider Methoden
    combinedShare = mean( ...
        [sharePoint(:), shareBuffer(:)], ...
        2, ...
        'omitnan');

    [~, order] = sort(combinedShare, 'descend');

    parameterNames = paramList(order);

    values = [ ...
        sharePoint(order), ...
        shareBuffer(order)];


    fig = figure( ...
        'Color', 'w', ...
        'Position', [100 100 1200 680]);

    bar(values, 'grouped');

    xticks(1:numel(parameterNames));
    xticklabels(parameterNames);
    xtickangle(35);

    ylabel('Relativer Anteil an Summe |Delta| (%)');

    title( ...
        'Relative Trennstaerke nach |Cliff''s Delta|: Methodenvergleich', ...
        'Interpreter', 'none', ...
        'FontWeight', 'bold');

    legend( ...
        {'Punktmethode: KFV vs. Random-Points', ...
         'Buffermethode: KFV vs. Random-Buffer'}, ...
        'Location', 'northeast', ...
        'Interpreter', 'none');

    grid on;


    ymax = max(values, [], 'all', 'omitnan');
    ylim([0, ymax * 1.18]);


    % Prozentwerte oberhalb der Balken
    nBars = size(values, 2);
    groupWidth = min(0.8, nBars / (nBars + 1.5));

    for j = 1:nBars

        x = (1:numel(parameterNames)) ...
            - groupWidth / 2 ...
            + (2*j - 1) * groupWidth / (2*nBars);

        for i = 1:numel(parameterNames)

            text( ...
                x(i), ...
                values(i,j) + 0.015*ymax, ...
                sprintf('%.1f', values(i,j)), ...
                'HorizontalAlignment', 'center', ...
                'FontSize', 9);

        end

    end


    exportgraphics( ...
        fig, ...
        [outBase '.png'], ...
        'Resolution', 300);

    close(fig);

end
