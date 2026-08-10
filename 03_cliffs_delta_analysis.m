%% Cliff's Delta: KFV vs. Random-Buffer und KFV vs. Random-Points
% Datengrundlage: drei Klassenstatistik-Tabellen mit abgegriffenen Rasterwerten.
%
% Es werden keine Zonalstatistiken und keine separaten TWI-/Flow-Dateien verwendet.
% Die Spalte SK_1 wird ignoriert.
%
% Richtung der Delta-Werte:
%   + Delta: KFV-Werte sind tendenziell groesser als Referenzwerte.
%   - Delta: KFV-Werte sind tendenziell kleiner als Referenzwerte.
%
% Erzeugte Abbildungen:
%   01_cliffs_delta_punktmethode.png/pdf
%   02_cliffs_delta_buffermethode.png/pdf
%   03_cliffs_delta_ranking_punktmethode.png/pdf
%   04_cliffs_delta_ranking_buffermethode.png/pdf
%   05_cliffs_delta_trennschaerfe_methodenvergleich.png/pdf

clear; clc; close all;

%% 0) Pfade

dataDir = 'C:\Users\simon\BA Ahrtal 2026';

if ~isfolder(dataDir)
    dataDir = uigetdir(pwd, 'Ordner mit den drei Klassenstatistik-Exceldateien auswählen');
    if isequal(dataDir, 0)
        error('Kein Datenordner ausgewählt.');
    end
end

outDir = fullfile(dataDir, 'plots_cliffs_delta_3klassenstatistiken');
if ~exist(outDir, 'dir')
    mkdir(outDir);
end

%% 1) Drei Klassenstatistik-Dateien finden
% Gesucht werden nur Excel-Dateien (*.xlsx). QMD-Dateien werden ignoriert.

files.kfvPoints = resolveExcelFile(dataDir, {'Klassenstatistik','KFV','Pixelwerte','SAGA','25 K'});
files.randomBufferPoints = resolveExcelFile(dataDir, {'Klassenstatistik','Random','Buffer','Pixelwerte','SAGA','25 K'});
files.randomPoints = resolveExcelFile(dataDir, {'Klassenstatistik','Random','Points','Pixelwerte','SAGA','25 K'});

fprintf('\nVerwendete Dateien:\n');
fprintf('KFV:           %s\n', files.kfvPoints);
fprintf('Random-Buffer: %s\n', files.randomBufferPoints);
fprintf('Random-Points: %s\n\n', files.randomPoints);

%% 2) Tabellen einlesen

T_kfv = readAnyTable(files.kfvPoints);
T_randomBuffer = readAnyTable(files.randomBufferPoints);
T_randomPoints = readAnyTable(files.randomPoints);

%% 3) Parameter aus den drei Tabellen holen
% Reihenfolge entsprechend deiner Attributtabellen:
% Slope, VRM, Plan Curvature, Profile Curvature, MID, Valley Depth,
% Convergence Index, TWI, Flow Accumulation.

paramSpecs = {
    'Slope',              'SLOPE_1';
    'VRM',                'VRM_1';
    'Plan Curvature',     'PLAN_1';
    'Profile Curvature',  'PROF_1';
    'Mid-Slope Position', 'MID_1';
    'Valley Depth',       'VALLEY_1';
    'Convergence Index',  'CONV_1';
    'TWI',                'TWI_1';
    'Flow Accumulation',  'FLOW_1'
};

paramNames = paramSpecs(:,1);
colNames = paramSpecs(:,2);

KFV = table();
RBUF = table();
RPOINT = table();

for i = 1:size(paramSpecs, 1)
    safeName = matlab.lang.makeValidName(paramNames{i});

    KFV.(safeName) = getRequiredColumn(T_kfv, colNames{i});
    RBUF.(safeName) = getRequiredColumn(T_randomBuffer, colNames{i});
    RPOINT.(safeName) = getRequiredColumn(T_randomPoints, colNames{i});
end

%% 4) Cliff's Delta berechnen
% Buffermethode: KFV vs. Random-Buffer
% Punktmethode: KFV vs. Random-Points

deltaBuffer = cliffsDeltaTable(KFV, RBUF);
deltaPoint  = cliffsDeltaTable(KFV, RPOINT);

absBuffer = abs(deltaBuffer);
absPoint  = abs(deltaPoint);

shareBuffer = 100 * absBuffer ./ sum(absBuffer, 'omitnan');
sharePoint  = 100 * absPoint  ./ sum(absPoint,  'omitnan');

results = table(paramNames, deltaPoint(:), absPoint(:), sharePoint(:), ...
                      deltaBuffer(:), absBuffer(:), shareBuffer(:), ...
    'VariableNames', {'Parameter', ...
                      'Delta_Punktmethode_KFV_vs_RandomPoints', ...
                      'AbsDelta_Punktmethode', ...
                      'Anteil_Punktmethode_pct', ...
                      'Delta_Buffermethode_KFV_vs_RandomBuffer', ...
                      'AbsDelta_Buffermethode', ...
                      'Anteil_Buffermethode_pct'});

resultsPointSorted = sortrows(results(:, {'Parameter', ...
    'Delta_Punktmethode_KFV_vs_RandomPoints', 'AbsDelta_Punktmethode', 'Anteil_Punktmethode_pct'}), ...
    'AbsDelta_Punktmethode', 'descend');

resultsBufferSorted = sortrows(results(:, {'Parameter', ...
    'Delta_Buffermethode_KFV_vs_RandomBuffer', 'AbsDelta_Buffermethode', 'Anteil_Buffermethode_pct'}), ...
    'AbsDelta_Buffermethode', 'descend');

writetable(results, fullfile(outDir, 'cliffs_delta_gesamt_3klassenstatistiken.xlsx'));
writetable(resultsPointSorted, fullfile(outDir, 'cliffs_delta_punktmethode_kfv_vs_randompoints.xlsx'));
writetable(resultsBufferSorted, fullfile(outDir, 'cliffs_delta_buffermethode_kfv_vs_randombuffer.xlsx'));

%% 5) Einzelabbildungen wie bisher

makeDeltaBarFigure(resultsPointSorted.Parameter, ...
    resultsPointSorted.Delta_Punktmethode_KFV_vs_RandomPoints, ...
    'Cliff''s Delta: Punktmethode (KFV vs. Random-Points)', ...
    fullfile(outDir, '01_cliffs_delta_punktmethode'));

makeDeltaBarFigure(resultsBufferSorted.Parameter, ...
    resultsBufferSorted.Delta_Buffermethode_KFV_vs_RandomBuffer, ...
    'Cliff''s Delta: Buffermethode (KFV vs. Random-Buffer)', ...
    fullfile(outDir, '02_cliffs_delta_buffermethode'));

makeAbsRankingFigure(resultsPointSorted.Parameter, ...
    resultsPointSorted.Anteil_Punktmethode_pct, ...
    'Relative Trennstaerke nach |Cliff''s Delta|: Punktmethode', ...
    fullfile(outDir, '03_cliffs_delta_ranking_punktmethode'));

makeAbsRankingFigure(resultsBufferSorted.Parameter, ...
    resultsBufferSorted.Anteil_Buffermethode_pct, ...
    'Relative Trennstaerke nach |Cliff''s Delta|: Buffermethode', ...
    fullfile(outDir, '04_cliffs_delta_ranking_buffermethode'));

%% 6) Methodenvergleich der relativen Trennstaerke

makeMethodComparisonRankingFigure(results.Parameter, ...
    results.Anteil_Punktmethode_pct, results.Anteil_Buffermethode_pct, ...
    fullfile(outDir, '05_cliffs_delta_trennschaerfe_methodenvergleich'));

%% 7) Ausgabe im Command Window

fprintf('\nFertig. Ergebnisse liegen in:\n%s\n\n', outDir);

fprintf('Top 3 nach |Cliff''s Delta| - Punktmethode, KFV vs. Random-Points:\n');
disp(resultsPointSorted(1:min(3,height(resultsPointSorted)),:));

fprintf('Top 3 nach |Cliff''s Delta| - Buffermethode, KFV vs. Random-Buffer:\n');
disp(resultsBufferSorted(1:min(3,height(resultsBufferSorted)),:));

%% Lokale Hilfsfunktionen

function filepath = resolveExcelFile(folder, patterns)
    D = dir(fullfile(folder, '*.xlsx'));
    D = D(~startsWith({D.name}, '~$'));

    if isempty(D)
        error('Keine Excel-Dateien im Ordner gefunden: %s', folder);
    end

    names = {D.name};
    namesNorm = cellfun(@normalizeText, names, 'UniformOutput', false);

    hit = false(size(names));
    for i = 1:numel(names)
        ok = true;
        for p = 1:numel(patterns)
            if ~contains(namesNorm{i}, normalizeText(patterns{p}))
                ok = false;
                break
            end
        end
        hit(i) = ok;
    end

    idx = find(hit);

    if isempty(idx)
        fprintf('\nVorhandene Excel-Dateien im Ordner:\n');
        disp(names');
        error('Keine Excel-Datei gefunden fuer Muster: %s', strjoin(patterns, ', '));
    elseif numel(idx) > 1
        fprintf('\nMehrere Treffer fuer Muster %s:\n', strjoin(patterns, ', '));
        disp(names(idx)');
        error('Bitte Dateinamen eindeutiger machen oder Suchmuster im Code anpassen.');
    end

    filepath = fullfile(D(idx).folder, D(idx).name);
end

function s = normalizeText(s)
    s = lower(string(s));
    s = strrep(s, 'ä', 'a');
    s = strrep(s, 'ö', 'o');
    s = strrep(s, 'ü', 'u');
    s = strrep(s, 'ß', 'ss');
    s = regexprep(s, '[^a-z0-9]', '');
end

function T = readAnyTable(f)
    if ~isfile(f)
        error('Datei nicht gefunden: %s', f);
    end
    T = readtable(f, 'VariableNamingRule', 'preserve');
end

function x = getRequiredColumn(T, wantedName)
    names = string(T.Properties.VariableNames);
    namesNorm = normalizeVarNames(names);
    wantedNorm = normalizeVarNames(string(wantedName));

    idx = find(namesNorm == wantedNorm, 1);

    if isempty(idx)
        error('Spalte nicht gefunden: %s\nVorhandene Spalten sind:\n%s', ...
            wantedName, strjoin(cellstr(names), ', '));
    end

    x = makeNumeric(T.(T.Properties.VariableNames{idx}));
    x = x(isfinite(x));
end

function out = normalizeVarNames(in)
    out = lower(string(in));
    out = regexprep(out, '[^a-z0-9]', '');
end

function x = makeNumeric(x)
    if istable(x)
        x = table2array(x);
    end
    if iscell(x)
        x = string(x);
    end
    if isstring(x) || ischar(x)
        x = str2double(x);
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

    values = [x; y];
    groupX = [true(nx,1); false(ny,1)];

    [sortedVals, order] = sort(values);
    ranks = zeros(size(values));

    n = numel(values);
    k = 1;
    while k <= n
        j = k;
        while j < n && sortedVals(j+1) == sortedVals(k)
            j = j + 1;
        end

        avgRank = (k + j) / 2;
        ranks(order(k:j)) = avgRank;
        k = j + 1;
    end

    rankSumX = sum(ranks(groupX));
    U = rankSumX - nx*(nx+1)/2;

    % Positiv: Werte von x sind tendenziell groesser als Werte von y.
    delta = (2 * U / (nx * ny)) - 1;
end

function makeDeltaBarFigure(paramList, deltaVals, figTitle, outBase)
    fig = figure('Color','w','Position',[100 100 1100 650]);

    bar(deltaVals);
    yline(0, '-', 'HandleVisibility','off');

    xticks(1:numel(deltaVals));
    xticklabels(paramList);
    xtickangle(35);

    ylabel('Cliff''s Delta');
    title(figTitle, 'Interpreter','none', 'FontWeight','bold');

    grid on;
    ylim([-1.12 1.12]);

    for i = 1:numel(deltaVals)
        if deltaVals(i) >= 0
            yText = deltaVals(i) + 0.04;
            vAlign = 'bottom';
        else
            yText = deltaVals(i) - 0.04;
            vAlign = 'top';
        end

        text(i, yText, sprintf('%.2f', deltaVals(i)), ...
            'HorizontalAlignment','center', ...
            'VerticalAlignment', vAlign, ...
            'FontSize', 10);
    end

    exportgraphics(fig, [outBase '.png'], 'Resolution', 300);
    exportgraphics(fig, [outBase '.pdf'], 'ContentType','vector');
    close(fig);
end

function makeAbsRankingFigure(paramList, values, figTitle, outBase)
    fig = figure('Color','w','Position',[100 100 1100 650]);

    bar(values);

    xticks(1:numel(values));
    xticklabels(paramList);
    xtickangle(35);

    ylabel('Relativer Anteil an Summe |Delta| (%)');
    title(figTitle, 'Interpreter','none', 'FontWeight','bold');

    grid on;

    ymax = max(values, [], 'omitnan');
    ylim([0, ymax * 1.16]);

    for i = 1:numel(values)
        text(i, values(i) + 0.015*ymax, sprintf('%.1f', values(i)), ...
            'HorizontalAlignment','center', 'FontSize', 10);
    end

    exportgraphics(fig, [outBase '.png'], 'Resolution', 300);
    exportgraphics(fig, [outBase '.pdf'], 'ContentType','vector');
    close(fig);
end

function makeMethodComparisonRankingFigure(paramList, sharePoint, shareBuffer, outBase)
    % Gemeinsame Sortierung nach mittlerem Anteil beider Methoden.
    combinedShare = mean([sharePoint(:), shareBuffer(:)], 2, 'omitnan');
    [~, order] = sort(combinedShare, 'descend');

    pNames = paramList(order);
    vals = [sharePoint(order), shareBuffer(order)];

    fig = figure('Color','w','Position',[100 100 1200 680]);

    bar(vals, 'grouped');

    xticks(1:numel(pNames));
    xticklabels(pNames);
    xtickangle(35);

    ylabel('Relativer Anteil an Summe |Delta| (%)');
    title('Relative Trennstaerke nach |Cliff''s Delta|: Methodenvergleich', ...
        'Interpreter','none', 'FontWeight','bold');

    legend({'Punktmethode: KFV vs. Random-Points', ...
            'Buffermethode: KFV vs. Random-Buffer'}, ...
            'Location','northeast', 'Interpreter','none');

    grid on;

    ymax = max(vals, [], 'all', 'omitnan');
    ylim([0, ymax * 1.18]);

    % Werte oberhalb der Balken
    nbars = size(vals, 2);
    groupWidth = min(0.8, nbars/(nbars + 1.5));
    for j = 1:nbars
        x = (1:numel(pNames)) - groupWidth/2 + (2*j-1) * groupWidth / (2*nbars);
        for i = 1:numel(pNames)
            text(x(i), vals(i,j) + 0.015*ymax, sprintf('%.1f', vals(i,j)), ...
                'HorizontalAlignment','center', 'FontSize', 9);
        end
    end

    exportgraphics(fig, [outBase '.png'], 'Resolution', 300);
    exportgraphics(fig, [outBase '.pdf'], 'ContentType','vector');
    close(fig);
end
