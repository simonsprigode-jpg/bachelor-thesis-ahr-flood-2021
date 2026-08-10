%% Spearman-Korrelationen der Geländeparameter
% Vergleich der Rangkorrelationen zwischen neun Geländeparametern
% für KFV, Random-Buffer und Random-Points.

clear; clc; close all;


%% 1) Daten- und Ausgabeordner

dataDir = uigetdir(pwd, 'Ordner mit den Eingangsdaten auswählen');

if isequal(dataDir, 0)
    error('Kein Datenordner ausgewählt.');
end

outDir = fullfile(dataDir, 'plots_korrelationen');

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

% Einheitliche Namen innerhalb des MATLAB-Skripts
varNames = {
    'Slope', ...
    'VRM', ...
    'PlanCurv', ...
    'ProfCurv', ...
    'MSP', ...
    'Valley', ...
    'ConvIdx', ...
    'TWI', ...
    'FlowAcc'
};

% Zugehörige Spaltennamen in den Eingangstabellen
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

% Kurze Beschriftungen für die Korrelationsmatrizen
plotLabels = {
    'Slope', ...
    'VRM', ...
    'Plan', ...
    'Prof', ...
    'MSP', ...
    'Valley', ...
    'Conv', ...
    'TWI', ...
    'Flow'
};


%% 5) Einheitliche Parametertabellen erzeugen

P_kfv = buildParameterTable( ...
    T_kfv, varNames, sourceColumns);

P_randomBuffer = buildParameterTable( ...
    T_randomBuffer, varNames, sourceColumns);

P_randomPoints = buildParameterTable( ...
    T_randomPoints, varNames, sourceColumns);


%% 6) Spearman-Korrelationen berechnen

[R_kfv, n_kfv] = computeSpearman( ...
    P_kfv, varNames);

[R_buffer, n_buffer] = computeSpearman( ...
    P_randomBuffer, varNames);

[R_points, n_points] = computeSpearman( ...
    P_randomPoints, varNames);


fprintf('\nGültige Zeilen für die Korrelationsmatrizen:\n');
fprintf('KFV:           %d\n', n_kfv);
fprintf('Random-Buffer: %d\n', n_buffer);
fprintf('Random-Points: %d\n\n', n_points);


%% 7) Gemeinsame Vergleichsabbildung

makeCombinedCorrFigure( ...
    R_kfv, ...
    R_buffer, ...
    R_points, ...
    plotLabels, ...
    sprintf('KFV (n = %d)', n_kfv), ...
    sprintf('Random-Buffer (n = %d)', n_buffer), ...
    sprintf('Random-Points (n = %d)', n_points), ...
    fullfile(outDir, '04_corr_3gruppen_vergleich'));

fprintf('Fertig. Abbildung gespeichert in:\n%s\n', outDir);


%% Lokale Hilfsfunktionen

function T = readAnyTable(filePath)

    if ~isfile(filePath)
        error('Datei nicht gefunden: %s', filePath);
    end

    T = readtable(filePath, ...
        'VariableNamingRule', 'preserve');

end


function P = buildParameterTable(T, varNames, sourceColumns)

    P = table();

    % Spaltennamen vereinheitlichen:
    % Unterstriche, Leerzeichen und Zeilenumbrüche werden für die Suche ignoriert.
    originalNames = string(T.Properties.VariableNames);
    cleanNames = upper(regexprep(originalNames, '[^A-Za-z0-9]', ''));

    for i = 1:numel(varNames)

        wanted = upper(regexprep( ...
            string(sourceColumns{i}), ...
            '[^A-Za-z0-9]', ''));

        idx = find(cleanNames == wanted, 1);

        if isempty(idx)
            error('Spalte "%s" nicht gefunden.', sourceColumns{i});
        end

        actualName = originalNames(idx);

        P.(varNames{i}) = makeNumeric( ...
            T.(char(actualName)));

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


function [R, nValid] = computeSpearman(T, vars)

    X = table2array(T(:, vars));

    % Nur Zeilen verwenden, in denen alle neun Parameter gültig sind
    validRows = all(isfinite(X), 2);
    X = X(validRows, :);

    nValid = size(X, 1);

    R = corr(X, 'Type', 'Spearman');

end


function makeCombinedCorrFigure( ...
    R_kfv, R_buffer, R_points, labels, ...
    titleKFV, titleBuffer, titlePoints, outBase)

    fig = figure( ...
        'Color', 'w', ...
        'Position', [100 100 1500 1150]);

    tl = tiledlayout( ...
        fig, 2, 2, ...
        'TileSpacing', 'compact', ...
        'Padding', 'compact');


    % KFV
    ax1 = nexttile(tl, 1, [1 2]);

    plotCorrOnAxes( ...
        ax1, R_kfv, labels, titleKFV, 9);


    % Random-Buffer
    ax2 = nexttile(tl, 3);

    plotCorrOnAxes( ...
        ax2, R_buffer, labels, titleBuffer, 8);


    % Random-Points
    ax3 = nexttile(tl, 4);

    plotCorrOnAxes( ...
        ax3, R_points, labels, titlePoints, 8);


    % Gemeinsame Farbskala
    colormap(fig, parula(256));

    cb = colorbar(ax3);
    cb.Layout.Tile = 'east';
    cb.Label.String = 'Spearman r';


    title( ...
        tl, ...
        'Vergleich der Spearman-Korrelationen auf Basis abgegriffener Rasterwerte', ...
        'FontWeight', 'bold', ...
        'Interpreter', 'none');


    % Export für Arbeit und Archivierung
    exportgraphics( ...
        fig, ...
        [outBase '.png'], ...
        'Resolution', 300);

    exportgraphics( ...
        fig, ...
        [outBase '.pdf'], ...
        'ContentType', 'vector');

    close(fig);

end


function plotCorrOnAxes(ax, R, labels, figTitle, fontSizeNumbers)

    imagesc(ax, R, [-1 1]);

    axis(ax, 'equal');
    axis(ax, 'tight');

    ax.XTick = 1:numel(labels);
    ax.YTick = 1:numel(labels);

    ax.XTickLabel = labels;
    ax.YTickLabel = labels;

    ax.XTickLabelRotation = 45;
    ax.FontSize = 10;

    title( ...
        ax, ...
        figTitle, ...
        'Interpreter', 'none', ...
        'FontWeight', 'bold');


    % Korrelationswerte in die Matrix eintragen
    for i = 1:size(R, 1)

        for j = 1:size(R, 2)

            value = R(i, j);

            if abs(value) > 0.60
                textColor = 'w';
            else
                textColor = 'k';
            end

            text( ...
                ax, j, i, sprintf('%.2f', value), ...
                'HorizontalAlignment', 'center', ...
                'FontSize', fontSizeNumbers, ...
                'Color', textColor);

        end

    end

end
