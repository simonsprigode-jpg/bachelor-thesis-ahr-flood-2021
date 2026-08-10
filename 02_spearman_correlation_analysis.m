%% Korrelationsmatrizen aus drei Klassenstatistiken
% Datengrundlage:
% 1) Klassenstatistik KFV Pixelwerte SAGA.xlsx
% 2) Klassenstatistik Random Buffer Pixelwerte SAGA.xlsx
% 3) Klassenstatistik Random Points Pixelwerte SAGA.xlsx
%
% Es werden keine Zonalstatistiken und keine separaten TWI-/Flow-Dateien gelesen.
% Alle Korrelationsmatrizen beruhen auf abgegriffenen Rasterwerten.

clear; clc; close all;

%% 0) Pfade
% Wichtig: In MATLAB besser C:\Users verwenden, nicht C:\Benutzer.
dataDir = 'C:\Users\simon\BA Ahrtal 2026';
outDir  = fullfile(dataDir, 'plots_korrelationsmatrix_3klassenstatistiken');

if ~exist(outDir, 'dir')
    mkdir(outDir);
end

%% 1) Drei Klassenstatistik-Dateien finden
% Es werden nur .xlsx-Dateien durchsucht. QMD-Dateien werden ignoriert.
% Die Suchmuster sind bewusst robust, aber es werden trotzdem nur drei
% Klassenstatistik-Dateien verwendet.

files.kfvPoints          = resolveFile(dataDir, {'Klassenstatistik','KFV','Pixelwerte','SAGA''25 K'});
files.randomBufferPoints = resolveFile(dataDir, {'Klassenstatistik','Random','Buffer','Pixelwerte','SAGA''25 K'});
files.randomPoints       = resolveFile(dataDir, {'Klassenstatistik','Random','Points','Pixelwerte','SAGA''25 K'});

fprintf('\nVerwendete Dateien:\n');
fprintf('KFV:           %s\n', files.kfvPoints);
fprintf('Random-Buffer: %s\n', files.randomBufferPoints);
fprintf('Random-Points: %s\n\n', files.randomPoints);

%% 2) Tabellen einlesen
T_kfv          = readAnyTable(files.kfvPoints);
T_randomBuffer = readAnyTable(files.randomBufferPoints);
T_randomPoints = readAnyTable(files.randomPoints);

%% 3) Parameterreihenfolge festlegen
% Reihenfolge analog zu den Klassenstatistiken:
% Slope, VRM, Plan Curvature, Profile Curvature, MID, Valley Depth,
% Convergence Index, TWI, Flow Accumulation.

varNames = {'Slope','VRM','PlanCurv','ProfCurv','MSP','Valley','ConvIdx','TWI','FlowAcc'};
plotLabels = {'Slope','VRM','Plan','Prof','MSP','Valley','Conv','TWI','Flow'};

columnCandidates = {
    {'SLOPE_1','SLOPE','SLP'};
    {'VRM_1','VRM'};
    {'PLAN_1','PLAN','PLC'};
    {'PROF_1','PROF','PRC','PROFILE'};
    {'MID_1','MID','MSP'};
    {'VALLEY_1','VALLEY','VD'};
    {'CONV_1','CONV','CI','CONVERGENCE'};
    {'TWI_1','TWI','WET'};
    {'FLOW_1','FLOW','ACC','ACCUMULATION'}
};

%% 4) Einheitliche Parametertabellen erzeugen
P_kfv          = buildParameterTable(T_kfv,          varNames, columnCandidates);
P_randomBuffer = buildParameterTable(T_randomBuffer, varNames, columnCandidates);
P_randomPoints = buildParameterTable(T_randomPoints, varNames, columnCandidates);

%% 5) Spearman-Korrelationsmatrizen berechnen
[R_kfv, n_kfv]       = computeSpearman(P_kfv, varNames);
[R_buffer, n_buffer] = computeSpearman(P_randomBuffer, varNames);
[R_points, n_points] = computeSpearman(P_randomPoints, varNames);

fprintf('Gültige Zeilen fuer Korrelationsmatrix:\n');
fprintf('KFV:           %d\n', n_kfv);
fprintf('Random-Buffer: %d\n', n_buffer);
fprintf('Random-Points: %d\n\n', n_points);

%% 6) Einzelne Korrelationsmatrizen exportieren
makeCorrFigure(R_kfv, plotLabels, ...
    sprintf('Spearman-Korrelation: KFV (n = %d)', n_kfv), ...
    fullfile(outDir, '01_corr_kfv_pixelwerte'));

makeCorrFigure(R_buffer, plotLabels, ...
    sprintf('Spearman-Korrelation: Random-Buffer (n = %d)', n_buffer), ...
    fullfile(outDir, '02_corr_randombuffer_pixelwerte'));

makeCorrFigure(R_points, plotLabels, ...
    sprintf('Spearman-Korrelation: Random-Points (n = %d)', n_points), ...
    fullfile(outDir, '03_corr_randompoints_pixelwerte'));

%% 7) Dreiteilige Vergleichsabbildung exportieren
makeCombinedCorrFigure(R_kfv, R_buffer, R_points, plotLabels, ...
    sprintf('KFV (n = %d)', n_kfv), ...
    sprintf('Random-Buffer (n = %d)', n_buffer), ...
    sprintf('Random-Points (n = %d)', n_points), ...
    fullfile(outDir, '04_corr_3gruppen_vergleich'));

%% 8) Korrelationswerte zusätzlich als Excel-Tabellen speichern
writeCorrTable(R_kfv, plotLabels, fullfile(outDir, 'corr_values_kfv.xlsx'));
writeCorrTable(R_buffer, plotLabels, fullfile(outDir, 'corr_values_randombuffer.xlsx'));
writeCorrTable(R_points, plotLabels, fullfile(outDir, 'corr_values_randompoints.xlsx'));

fprintf('Fertig. Ergebnisse gespeichert in:\n%s\n', outDir);

%% Hilfsfunktionen

function filepath = resolveFile(folder, patterns)
    D = dir(fullfile(folder, '*.xlsx'));
    D = D(~startsWith({D.name}, '~$'));

    if isempty(D)
        error('Keine xlsx-Dateien im Ordner gefunden: %s', folder);
    end

    names = {D.name};
    namesNorm = cellfun(@normalizeText, names, 'UniformOutput', false);

    hit = false(size(names));

    for i = 1:numel(names)
        ok = true;

        for p = 1:numel(patterns)
            if ~contains(namesNorm{i}, normalizeText(patterns{p}))
                ok = false;
                break;
            end
        end

        hit(i) = ok;
    end

    idx = find(hit);

    if isempty(idx)
        fprintf('\nVorhandene xlsx-Dateien in %s:\n', folder);
        disp(names');
        error('Keine Datei gefunden fuer Muster: %s', strjoin(patterns, ', '));
    elseif numel(idx) > 1
        fprintf('\nMehrere Treffer fuer %s:\n', strjoin(patterns, ', '));
        disp(names(idx)');
        error('Bitte Dateinamen eindeutiger machen.');
    end

    filepath = fullfile(folder, names{idx});
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

function P = buildParameterTable(T, varNames, columnCandidates)
    P = table();

    for i = 1:numel(varNames)
        P.(varNames{i}) = getPointColumn(T, columnCandidates{i});
    end
end

function x = getPointColumn(T, candidates)
    names = string(T.Properties.VariableNames);
    namesNorm = normalizeText(names);

    % Erst exakte normalisierte Namen suchen.
    for i = 1:numel(candidates)
        tok = normalizeText(candidates{i});
        idx = find(namesNorm == tok, 1);

        if ~isempty(idx)
            x = makeNumeric(T.(names(idx)));
            return;
        end
    end

    % Danach enthaltene Tokens suchen.
    for i = 1:numel(candidates)
        tok = normalizeText(candidates{i});
        idx = find(contains(namesNorm, tok), 1);

        if ~isempty(idx)
            x = makeNumeric(T.(names(idx)));
            return;
        end
    end

    error('Keine passende Spalte gefunden. Gesuchte Kandidaten: %s', strjoin(candidates, ', '));
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

function [R, nValid] = computeSpearman(T, vars)
    X = table2array(T(:, vars));
    ok = all(isfinite(X), 2);
    X = X(ok, :);
    nValid = size(X, 1);

    R = corr(X, 'Type', 'Spearman', 'Rows', 'complete');
end

function makeCorrFigure(R, labels, figTitle, outBase)
    fig = figure('Color','w','Position',[100 100 920 780]);
    ax = axes(fig);

    plotCorrOnAxes(ax, R, labels, figTitle, true, 10);

    exportgraphics(fig, [outBase '.png'], 'Resolution', 300);
    exportgraphics(fig, [outBase '.pdf'], 'ContentType', 'vector');
    close(fig);
end

function makeCombinedCorrFigure(R_kfv, R_buffer, R_points, labels, titleKFV, titleBuffer, titlePoints, outBase)
    fig = figure('Color','w','Position',[100 100 1500 1150]);
    tl = tiledlayout(fig, 2, 2, 'TileSpacing','compact', 'Padding','compact');

    ax1 = nexttile(tl, 1, [1 2]);
    plotCorrOnAxes(ax1, R_kfv, labels, titleKFV, false, 9);

    ax2 = nexttile(tl, 3);
    plotCorrOnAxes(ax2, R_buffer, labels, titleBuffer, false, 8);

    ax3 = nexttile(tl, 4);
    plotCorrOnAxes(ax3, R_points, labels, titlePoints, false, 8);

    colormap(fig, parula(256));

    cb = colorbar(ax3);
    cb.Layout.Tile = 'east';
    cb.Label.String = 'Spearman r';

    title(tl, 'Vergleich der Spearman-Korrelationen auf Basis abgegriffener Rasterwerte', ...
        'FontWeight','bold', 'Interpreter','none');

    exportgraphics(fig, [outBase '.png'], 'Resolution', 300);
    exportgraphics(fig, [outBase '.pdf'], 'ContentType', 'vector');
    %% 
    close(fig);
end

function plotCorrOnAxes(ax, R, labels, figTitle, showColorbar, fontSizeNumbers)
    imagesc(ax, R, [-1 1]);
    axis(ax, 'equal');
    axis(ax, 'tight');
    ax.XTick = 1:numel(labels);
    ax.YTick = 1:numel(labels);
    ax.XTickLabel = labels;
    ax.YTickLabel = labels;
    ax.XTickLabelRotation = 45;
    ax.FontSize = 10;
    title(ax, figTitle, 'Interpreter','none', 'FontWeight','bold');

    if showColorbar
        cb = colorbar(ax);
        cb.Label.String = 'Spearman r';
    end

    for i = 1:size(R,1)
        for j = 1:size(R,2)
            val = R(i,j);
            txtColor = 'k';

            if abs(val) > 0.60
                txtColor = 'w';
            end

            text(ax, j, i, sprintf('%.2f', val), ...
                'HorizontalAlignment','center', ...
                'FontSize', fontSizeNumbers, ...
                'Color', txtColor);
        end
    end
end

function writeCorrTable(R, labels, outFile)
    C = cell(size(R,1)+1, size(R,2)+1);
    C(1,2:end) = labels;
    C(2:end,1) = labels(:);
    C(2:end,2:end) = num2cell(R);
    writecell(C, outFile);
end
