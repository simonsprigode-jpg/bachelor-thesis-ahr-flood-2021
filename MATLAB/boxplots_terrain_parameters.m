%% Vergleich von KFV, Random-Buffer und Random-Points
% Vergleich der abgegriffenen Rasterwerte für die 9 Geländeparameter aus SAGA.
% Valley Depth und Flow Accumulation werden als log10(x+1) dargestellt.
% Zusätzlich werden eine Übersicht der vier Hauptparameter und
% deren deskriptive Kennwerte ausgegeben.

clear; clc; close all;

%% 1) Pfade
dataDir = 'C:\Users\simon\BA Ahrtal 2026';
outDir = fullfile(dataDir, 'plots_punktvergleich_3gruppen_ohne_fallback');

if ~exist(outDir, 'dir')
    mkdir(outDir);
end

%% 2) Dateinamen
% Diese drei Excel-Dateien müssen jeweils alle relevanten Spalten enthalten:
% SLOPE_1, VRM_1, PLAN_1, PROF_1, MID_1, VALLEY_1, CONV_1, TWI_1, FLOW_1.
%
% Falls deine Dateien anders heißen, ändere nur diese drei Zeilen.

files.kfvPoints          = 'Klassenstatistik KFV Pixelwerte SAGA 25 K.xlsx';
files.randomBufferPoints = 'Klassenstatistik Random Buffer Pixelwerte SAGA 25 K.xlsx';
files.randomPoints       = 'Klassenstatistik Random Points Pixelwerte SAGA 25 K.xlsx';
%% 3) Tabellen einlesen
% Es werden nur diese drei Tabellen gelesen. Keine Zonalstatistik, keine Fallback-Dateien.

T_kfv          = readAnyTable(dataDir, files.kfvPoints);
T_randomBuffer = readAnyTable(dataDir, files.randomBufferPoints);
T_randomPoints = readAnyTable(dataDir, files.randomPoints);

%% 4) Parameterliste
% Reihenfolge entsprechend der Attributtabelle:
% Slope, VRM, Plan Curvature, Profile Curvature, MID, Valley Depth,
% Convergence Index, TWI, Flow Accumulation.

plotSpecs = {
    'SLOPE',  'Slope (°)',                       'SLOPE_1',  false;
    'VRM',    'Vector Terrain Ruggedness (VRM)',  'VRM_1',    false;
    'PLAN',   'Plan Curvature',                   'PLAN_1',   false;
    'PROF',   'Profile Curvature',                'PROF_1',   false;
    'MID',    'Mid-Slope Position',               'MID_1',    false;
    'VALLEY', 'log10(Valley Depth + 1)',          'VALLEY_1', true;
    'CONV',   'Convergence Index',                'CONV_1',   false;
    'TWI',    'Topographic Wetness Index',         'TWI_1',    false;
    'FLOW',   'log10(Flow Accumulation + 1)',     'FLOW_1',   true
};

%% 5) Einzelne Boxplots erzeugen und Daten für Übersichtsplot speichern

plotData = struct();

for i = 1:size(plotSpecs, 1)

    code    = string(plotSpecs{i, 1});
    yLabel  = string(plotSpecs{i, 2});
    varName = string(plotSpecs{i, 3});
    useLog  = plotSpecs{i, 4};

    % Alle Werte kommen direkt aus den drei Klassenstatistik-Tabellen.
    kfvValues        = getNumericColExact(T_kfv, varName);
    randBufferValues = getNumericColExact(T_randomBuffer, varName);
    randPointValues  = getNumericColExact(T_randomPoints, varName);

    % Optional log10(x+1) für Valley Depth und Flow Accumulation
    if useLog
        kfvValues        = log10(kfvValues + 1);
        randBufferValues = log10(randBufferValues + 1);
        randPointValues  = log10(randPointValues + 1);
    end

    % Ungültige Werte entfernen
    kfvValues        = validNumeric(kfvValues);
    randBufferValues = validNumeric(randBufferValues);
    randPointValues  = validNumeric(randPointValues);

    titleTxt = ['Punktbasierter Vergleich: ', char(yLabel)];
    outBase = fullfile(outDir, ['box_3gruppen_', lower(char(code))]);

    plotThreeGroupBox(kfvValues, randBufferValues, randPointValues, ...
        titleTxt, char(yLabel), outBase, true);

    % Für spätere 2x2-Übersichtsabbildung speichern
    plotData.(char(code)).kfv        = kfvValues;
    plotData.(char(code)).buffer     = randBufferValues;
    plotData.(char(code)).points     = randPointValues;
    plotData.(char(code)).yLabel     = char(yLabel);
    plotData.(char(code)).titleLabel = char(yLabel);

end

%% 6) 2x2-Übersichtsabbildung der vier wichtigsten Parameter
% Die vier Parameter können bei Bedarf hier geändert werden.
% Aktuell: Slope, TWI, Mid-Slope Position und Flow Accumulation.

highlightCodes = {'SLOPE', 'TWI', 'MID', 'FLOW'};
plotFourPanelBoxplots(plotData, highlightCodes, ...
    fullfile(outDir, '00_uebersicht_4_wichtigste_parameter'));
%% 7) Kennwerte für die vier Hauptparameter ausgeben

summary4 = makeSummaryTable(plotData, highlightCodes);

disp('Kennwerte für die vier Hauptparameter:');
disp(summary4);

writetable(summary4, fullfile(outDir, 'summary_4_wichtigste_parameter.xlsx'));
writetable(summary4, fullfile(outDir, 'summary_4_wichtigste_parameter.csv'));
fprintf('\nFertig. Alle Plots wurden gespeichert in:\n%s\n', outDir);

%% Lokale Hilfsfunktionen
function S = makeSummaryTable(plotData, highlightCodes)

   groupNames = ["KFV", "Random-Buffer", "Random-Points"];

nRows = numel(highlightCodes) * numel(groupNames);

parameter   = strings(nRows,1);
group       = strings(nRows,1);
n           = zeros(nRows,1);
meanValue   = nan(nRows,1);
medianValue = nan(nRows,1);
q1Value     = nan(nRows,1);
q3Value     = nan(nRows,1);
iqrValue    = nan(nRows,1);

row = 0;

    for i = 1:numel(highlightCodes)

        code = highlightCodes{i};
        P = plotData.(code);

        
        values = {P.kfv, P.buffer, P.points};

        for g = 1:numel(groupNames)

            x = values{g};
            x = x(~isnan(x) & isfinite(x));

            q = quantile(x, [0.25 0.50 0.75]);

            row = row + 1;

parameter(row)   = string(P.yLabel);
group(row)       = groupNames(g);
n(row)           = numel(x);
meanValue(row)   = mean(x, 'omitnan');
medianValue(row) = q(2);
q1Value(row)     = q(1);
q3Value(row)     = q(3);
iqrValue(row)    = q(3) - q(1);

        end
    end

    S = table(parameter, group, n, ...
        round(meanValue, 3), ...
        round(medianValue, 3), ...
        round(q1Value, 3), ...
        round(q3Value, 3), ...
        round(iqrValue, 3), ...
        'VariableNames', {'Parameter', 'Group', 'n', 'Mean', 'Median', 'Q1', 'Q3', 'IQR'});

end
function T = readAnyTable(dataDir, fileName)
    f = fullfile(dataDir, fileName);

    if ~isfile(f)
        error('Datei nicht gefunden: %s', f);
    end

    T = readtable(f, 'VariableNamingRule', 'preserve');
    fprintf('Eingelesen: %s | Zeilen: %d | Spalten: %d\n', fileName, height(T), width(T));
end

function x = getNumericColExact(T, wanted)
    % Exakte Spaltensuche nach Normalisierung.
    % Das ist bewusst kein Fallback: VRM_11 wird nicht automatisch als VRM_1 akzeptiert.
    % Wenn QGIS Spalten wie VRM_11 erzeugt hat, müssen sie vorher in VRM_1 umbenannt werden.

    v = findExactVar(T, wanted);
    x = T.(v);

    if iscell(x) || isstring(x) || iscategorical(x)
        x = str2double(string(x));
    end

    x = double(x(:));
    x = validNumeric(x);

    fprintf('Gewählte Spalte für %s: %s | n = %d\n', wanted, v, numel(x));
end

function vname = findExactVar(T, wanted)
    names = string(T.Properties.VariableNames);

    normNames = normalizeVarNames(names);
    normWanted = normalizeVarNames(string(wanted));

    idx = find(normNames == normWanted, 1);

    if isempty(idx)
        error(['Spalte nicht exakt gefunden: %s.\n' ...
               'Bitte prüfe die Excel-Spaltennamen. Erwartet werden unter anderem: ', ...
               'SLOPE_1, VRM_1, PLAN_1, PROF_1, MID_1, VALLEY_1, CONV_1, TWI_1, FLOW_1.\n' ...
               'Vorhandene Spalten: %s'], wanted, strjoin(names, ', '));
    end

    vname = T.Properties.VariableNames{idx};
end

function out = normalizeVarNames(in)
    out = lower(string(in));
    out = regexprep(out, '[^a-z0-9]', '');
end

function x = validNumeric(x)
    x = double(x(:));
    x = x(~isnan(x) & isfinite(x));
end

function plotThreeGroupBox(kfvValues, randBufferValues, randPointValues, titleTxt, yLab, outBase, showSubtitle)

    fig = figure('Color', 'w', 'Position', [100 100 1000 620]);
    ax = axes(fig);

    drawThreeGroupBox(ax, kfvValues, randBufferValues, randPointValues, yLab, true);

    title(ax, titleTxt, 'Interpreter', 'none');

    if showSubtitle
        subtitle(ax, 'Box = Quartile; Medianlinie = blauer Strich; Whisker = 1,5 × IQR; Kreise = Ausreißerpunkte; roter Punkt = Mittelwert', ...
            'Interpreter', 'none');
    end

    xlabel(ax, 'Datengrundlage: abgegriffene Rasterwerte', 'Interpreter', 'none');

    exportgraphics(fig, string(outBase) + ".png", 'Resolution', 300);
    exportgraphics(fig, string(outBase) + ".pdf", 'ContentType', 'vector');

    close(fig);
end

function plotFourPanelBoxplots(plotData, highlightCodes, outBase)

    fig = figure('Color', 'w', 'Position', [80 80 1500 900]);
    t = tiledlayout(fig, 2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

    for i = 1:numel(highlightCodes)
        code = highlightCodes{i};
        ax = nexttile(t);

        S = plotData.(code);
        drawThreeGroupBox(ax, S.kfv, S.buffer, S.points, S.yLabel, i == 1);
        title(ax, S.titleLabel, 'Interpreter', 'none');
        xlabel(ax, '');
    end

    title(t, 'Punktbasierter Vergleich der wichtigsten Parameter', 'Interpreter', 'none');
    xlabel(t, 'KFV, Random-Buffer und Random-Points auf Grundlage abgegriffener Rasterwerte', 'Interpreter', 'none');

    exportgraphics(fig, string(outBase) + ".png", 'Resolution', 300);
    exportgraphics(fig, string(outBase) + ".pdf", 'ContentType', 'vector');

    close(fig);
end

function drawThreeGroupBox(ax, kfvValues, randBufferValues, randPointValues, yLab, showLegend)

    labels = ["KFV", "Random-Buffer", "Random-Points"];
    positions = [1, 2, 3];

    y = [
        kfvValues(:);
        randBufferValues(:);
        randPointValues(:)
    ];

    x = [
        repmat(positions(1), numel(kfvValues), 1);
        repmat(positions(2), numel(randBufferValues), 1);
        repmat(positions(3), numel(randPointValues), 1)
    ];

    b = boxchart(ax, x, y, ...
        'BoxWidth', 0.55, ...
        'MarkerStyle', 'o');

    hold(ax, 'on');

    means = [
        mean(kfvValues, 'omitnan'), ...
        mean(randBufferValues, 'omitnan'), ...
        mean(randPointValues, 'omitnan')
    ];

    m = scatter(ax, positions, means, 70, ...
        'o', ...
        'filled', ...
        'MarkerFaceColor', 'r', ...
        'MarkerEdgeColor', 'k', ...
        'LineWidth', 0.8);

    xticks(ax, positions);
    xticklabels(ax, labels);

    ylabel(ax, yLab, 'Interpreter', 'none');
    grid(ax, 'on');
    xlim(ax, [0.4 3.6]);

    if showLegend
        legend(ax, [b m], {'Boxplot', 'Mittelwert'}, 'Location', 'best');
    end
    
end
