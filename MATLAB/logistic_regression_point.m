%% Punktbasierte logistische Regression
% Neun schrittweise erweiterte logistische Regressionsmodelle
% zur Unterscheidung von KFV und Random-Points.
%
% Flow Accumulation wird vor der Modellierung mit log10(x+1)
% transformiert. Alle Prädiktoren werden z-standardisiert.
%
% Für jedes Modell werden eine fein abgestufte und eine
% klassifizierte Anfälligkeitskarte erzeugt.
% Für Modell 4 und Modell 9 werden zusätzlich GeoTIFFs exportiert.

clear; clc; close all;


%% 1) Ausgabeordner wählen

outDir = uigetdir(pwd, 'Ausgabeordner für Ergebnisse auswählen');

if isequal(outDir, 0)
    error('Kein Ausgabeordner ausgewählt.');
end

fprintf('\nAusgabeordner:\n%s\n', outDir);


%% 2) Eingangstabellen auswählen

fprintf('\nBitte KFV-1000-Tabelle auswählen.\n');

[kfvName, kfvPath] = uigetfile( ...
    {'*.xlsx;*.xls', 'Excel-Dateien (*.xlsx, *.xls)'}, ...
    'KFV-1000-Tabelle auswählen');

if isequal(kfvName, 0)
    error('Keine KFV-Tabelle ausgewählt.');
end


fprintf('\nBitte Random-Points-1000-Tabelle auswählen.\n');

[randomName, randomPath] = uigetfile( ...
    {'*.xlsx;*.xls', 'Excel-Dateien (*.xlsx, *.xls)'}, ...
    'Random-Points-1000-Tabelle auswählen');

if isequal(randomName, 0)
    error('Keine Random-Points-Tabelle ausgewählt.');
end


kfvFile = fullfile(kfvPath, kfvName);
randomFile = fullfile(randomPath, randomName);

KFV_raw = readtable( ...
    kfvFile, ...
    'VariableNamingRule', 'preserve');

Random_raw = readtable( ...
    randomFile, ...
    'VariableNamingRule', 'preserve');

fprintf('\nKFV-Tabelle:           %d Zeilen\n', height(KFV_raw));
fprintf('Random-Points-Tabelle: %d Zeilen\n', height(Random_raw));


%% 3) Modelldatensatz erzeugen

KFV = makeModelTable(KFV_raw, 1, "KFV");
RandomPoints = makeModelTable(Random_raw, 0, "RandomPoints");

D = [KFV; RandomPoints];

% Flow Accumulation logarithmieren
D.FLOW_LOG = log10(1 + D.FLOW);

% Reihenfolge der schrittweise erweiterten Modelle:
% Modell 1 = SLOPE
% Modell 2 = SLOPE + MID
% Modell 3 = SLOPE + MID + TWI
% ...
% Modell 9 = alle neun Parameter

predictor_order = { ...
    'SLOPE', ...
    'MID', ...
    'TWI', ...
    'FLOW_LOG', ...
    'VALLEY', ...
    'VRM', ...
    'PLAN', ...
    'PROF', ...
    'CONV'};

D = D(:, [{'Y', 'GROUP'}, predictor_order]);

fprintf('\nBeobachtungen im Gesamtdatensatz: %d\n', height(D));
disp('Klassenverteilung:');
tabulate(D.Y);


%% 4) Prädiktoren z-standardisieren

D_std = D;

standardizationStats = table();
standardizationStats.Param = predictor_order';
standardizationStats.Mean = nan(numel(predictor_order), 1);
standardizationStats.Std = nan(numel(predictor_order), 1);

for i = 1:numel(predictor_order)

    p = predictor_order{i};

    mu = mean(D.(p), 'omitnan');
    sd = std(D.(p), 'omitnan');

    if sd == 0 || isnan(sd)
        error('Parameter %s hat keine Streuung und kann nicht standardisiert werden.', p);
    end

    standardizationStats.Mean(i) = mu;
    standardizationStats.Std(i) = sd;

    D_std.(p) = (D.(p) - mu) ./ sd;

end

fprintf('\nStandardisierungswerte:\n');
disp(standardizationStats);

writetable( ...
    standardizationStats, ...
    fullfile(outDir, ...
    'standardization_values_point_logistic_regression.xlsx'));


%% 5) Neun logistische Modelle fitten

nModels = numel(predictor_order);

ModelName = strings(nModels, 1);
Formula = strings(nModels, 1);
AIC = nan(nModels, 1);
BIC = nan(nModels, 1);
Deviance = nan(nModels, 1);
NumPredictors = nan(nModels, 1);

models = cell(nModels, 1);
modelData = cell(nModels, 1);


for k = 1:nModels

    preds = predictor_order(1:k);

    formula = "Y ~ " + strjoin(string(preds), " + ");

    % Nur die für das jeweilige Modell benötigten Variablen verwenden
    D_model = D_std(:, [{'Y', 'GROUP'}, preds]);

    % Fehlende Werte modellweise entfernen
    D_model = rmmissing(D_model);

    fprintf('\nModell %d:\n%s\n', k, formula);
    fprintf('Verwendete Beobachtungen: %d\n', height(D_model));

    mdl = fitglm( ...
        D_model, ...
        formula, ...
        'Distribution', 'binomial', ...
        'Link', 'logit');

    models{k} = mdl;
    modelData{k} = D_model;

    ModelName(k) = "Model_" + k;
    Formula(k) = formula;
    AIC(k) = mdl.ModelCriterion.AIC;
    BIC(k) = mdl.ModelCriterion.BIC;
    Deviance(k) = mdl.Deviance;
    NumPredictors(k) = k;

end


%% 6) Modellvergleich

results = table( ...
    ModelName, ...
    NumPredictors, ...
    Formula, ...
    AIC, ...
    BIC, ...
    Deviance);

results.DeltaAIC = results.AIC - min(results.AIC);

results = sortrows(results, 'AIC');

writetable( ...
    results, ...
    fullfile(outDir, ...
    'AIC_model_comparison_point_logistic_regression.xlsx'));

fprintf('\nMODELLVERGLEICH:\n');
disp(results);


%% 7) Bestes Modell auswählen

bestModelName = results.ModelName(1);

bestIdx = find(ModelName == bestModelName, 1);

bestModel = models{bestIdx};
D_best = modelData{bestIdx};

fprintf('\nBestes Modell nach AIC: %s\n', bestModelName);
fprintf('Formel: %s\n', results.Formula(1));
fprintf('AIC: %.4f\n', results.AIC(1));
fprintf('BIC: %.4f\n', results.BIC(1));
fprintf('DeltaAIC: %.4f\n', results.DeltaAIC(1));


%% 8) Koeffizienten des besten Modells

coefTable = bestModel.Coefficients;

coefTableOut = coefTable;
coefTableOut.Predictor = string(coefTableOut.Properties.RowNames);

coefTableOut = movevars( ...
    coefTableOut, ...
    'Predictor', ...
    'Before', 1);

writetable( ...
    coefTableOut, ...
    fullfile(outDir, ...
    'coefficients_best_point_based_logistic_model.xlsx'));

fprintf('\nKoeffizienten des besten Modells:\n');
disp(coefTableOut);


%% 9) ROC, AUC und Konfusionsmatrix

p_hat = predict(bestModel, D_best);

[Xroc, Yroc, ~, AUC] = perfcurve( ...
    D_best.Y, ...
    p_hat, ...
    1);

fprintf('\nAUC des besten Modells: %.4f\n', AUC);


% Klassifikation bei p = 0.5
Y_true = double(D_best.Y);
Y_pred = double(p_hat >= 0.5);

confMat = confusionmat( ...
    Y_true, ...
    Y_pred, ...
    'Order', [0 1]);

accuracy = mean(Y_pred == Y_true);

fprintf('\nKonfusionsmatrix bei Schwellenwert 0.5:\n');

ConfusionTable = array2table( ...
    confMat, ...
    'VariableNames', {'Pred_0', 'Pred_1'}, ...
    'RowNames', {'True_0', 'True_1'});

disp(ConfusionTable);

fprintf('Accuracy bei Schwellenwert 0.5: %.4f\n', accuracy);


% Konfusionsmatrix als Abbildung
fig = figure( ...
    'Color', 'w', ...
    'Position', [100 100 850 650]);

cm = confusionchart(Y_true, Y_pred);

cm.Title = 'Confusion Matrix - threshold 0.5';
cm.RowSummary = 'row-normalized';
cm.ColumnSummary = 'column-normalized';

exportgraphics( ...
    fig, ...
    fullfile(outDir, ...
    'confusion_matrix_best_model.png'), ...
    'Resolution', 300);

close(fig);


%% 10) Prädiktorraster auswählen

fprintf('\nBitte Slope-Raster auswählen.\n');
slopeFile = pickRaster('Slope-Raster auswählen');

fprintf('\nBitte Mid-Slope-Position-Raster auswählen.\n');
mspFile = pickRaster('Mid-Slope-Position-Raster auswählen');

fprintf('\nBitte TWI-Raster auswählen.\n');
twiFile = pickRaster('TWI-Raster auswählen');

fprintf('\nBitte Flow-Accumulation-Raster auswählen.\n');
flowFile = pickRaster('Flow-Accumulation-Raster auswählen');

fprintf('\nBitte Valley-Depth-Raster auswählen.\n');
valleyFile = pickRaster('Valley-Depth-Raster auswählen');

fprintf('\nBitte VRM-Raster auswählen.\n');
vrmFile = pickRaster('VRM-Raster auswählen');

fprintf('\nBitte Plan-Curvature-Raster auswählen.\n');
planFile = pickRaster('Plan-Curvature-Raster auswählen');

fprintf('\nBitte Profile-Curvature-Raster auswählen.\n');
profFile = pickRaster('Profile-Curvature-Raster auswählen');

fprintf('\nBitte Convergence-Index-Raster auswählen.\n');
convFile = pickRaster('Convergence-Index-Raster auswählen');


%% 11) Raster einlesen

[Slope, Rgeo] = readgeoraster(slopeFile);

MSP = readgeoraster(mspFile);
TWI = readgeoraster(twiFile);
Flow = readgeoraster(flowFile);
Valley = readgeoraster(valleyFile);
VRM = readgeoraster(vrmFile);
PlanCurv = readgeoraster(planFile);
ProfCurv = readgeoraster(profFile);
ConvIdx = readgeoraster(convFile);


Slope = single(Slope);
MSP = single(MSP);
TWI = single(TWI);
Flow = single(Flow);
Valley = single(Valley);
VRM = single(VRM);
PlanCurv = single(PlanCurv);
ProfCurv = single(ProfCurv);
ConvIdx = single(ConvIdx);


allRasters = { ...
    Slope, ...
    MSP, ...
    TWI, ...
    Flow, ...
    Valley, ...
    VRM, ...
    PlanCurv, ...
    ProfCurv, ...
    ConvIdx};

rasterNames = { ...
    'SLOPE', ...
    'MID', ...
    'TWI', ...
    'FLOW', ...
    'VALLEY', ...
    'VRM', ...
    'PLAN', ...
    'PROF', ...
    'CONV'};


%% 12) Rastergrößen prüfen

refSize = size(Slope);

for i = 1:numel(allRasters)

    if ~isequal(size(allRasters{i}), refSize)

        error( ...
            'Raster %s hat eine andere Größe (%d x %d) als Slope (%d x %d).', ...
            rasterNames{i}, ...
            size(allRasters{i}, 1), ...
            size(allRasters{i}, 2), ...
            refSize(1), ...
            refSize(2));

    end

end

fprintf('\nAlle Raster haben dieselbe Größe.\n');


%% 13) Ungültige Rasterzellen bestimmen

invalid = false(refSize);

for i = 1:numel(allRasters)

    X = allRasters{i};

    invalid = invalid | isnan(X) | isinf(X);

    % Typische NoData-Werte
    invalid = invalid | X <= -9990;

end

% Flow Accumulation muss für log10(Flow + 1) >= 0 sein
invalid = invalid | Flow < 0;

fprintf('\nUngültige Pixel laut Maske: %.2f %%\n', ...
    100 * nnz(invalid) / numel(invalid));

invalid_base = invalid;


%% 14) Raster mit den Punktdaten-Parametern standardisieren

Z.SLOPE = zscoreRaster( ...
    Slope, ...
    standardizationStats, ...
    'SLOPE');

clear Slope


Z.MID = zscoreRaster( ...
    MSP, ...
    standardizationStats, ...
    'MID');

clear MSP


Z.TWI = zscoreRaster( ...
    TWI, ...
    standardizationStats, ...
    'TWI');

clear TWI


Flow_log = single(log10(single(Flow) + 1));

Z.FLOW_LOG = zscoreRaster( ...
    Flow_log, ...
    standardizationStats, ...
    'FLOW_LOG');

clear Flow Flow_log


Z.VALLEY = zscoreRaster( ...
    Valley, ...
    standardizationStats, ...
    'VALLEY');

clear Valley


Z.VRM = zscoreRaster( ...
    VRM, ...
    standardizationStats, ...
    'VRM');

clear VRM


Z.PLAN = zscoreRaster( ...
    PlanCurv, ...
    standardizationStats, ...
    'PLAN');

clear PlanCurv


Z.PROF = zscoreRaster( ...
    ProfCurv, ...
    standardizationStats, ...
    'PROF');

clear ProfCurv


Z.CONV = zscoreRaster( ...
    ConvIdx, ...
    standardizationStats, ...
    'CONV');

clear ConvIdx


%% 15) Farbskalen

cmapFine = blueYellowRed(256);
cmapClass = blueYellowRed(5);


%% 16) Modellkarten erzeugen

for k = 1:nModels

    mdl = models{k};
    preds = predictor_order(1:k);

    coefTable = mdl.Coefficients;
    coefNames = string(coefTable.Properties.RowNames);

    % Intercept
    b0 = coefTable.Estimate( ...
        coefNames == "(Intercept)");

    eta = b0 * ones(refSize);


    % Linearen Prädiktor aus standardisierten Rastern berechnen
    for j = 1:numel(preds)

        p = preds{j};

        idx = coefNames == string(p);

        if ~any(idx)
            error( ...
                'Koeffizient für %s in Modell %d nicht gefunden.', ...
                p, k);
        end

        b = coefTable.Estimate(idx);

        eta = eta + b .* Z.(p);

    end


    % Logistische Transformation
    P = 1 ./ (1 + exp(-eta));

    P(invalid_base) = NaN;

    P(P < 0) = 0;
    P(P > 1) = 1;


    %% Rasterauswertung des besten Modells

    if k == bestIdx

        valid = ...
            ~isnan(P) & ...
            isfinite(P) & ...
            isfinite(eta);

        P_valid = double(P(valid));
        eta_valid = double(eta(valid));

        eta_threshold_075 = log(0.75 / (1 - 0.75));

        nValid = numel(P_valid);

        nHigh075 = sum(P_valid >= 0.75);

        shareHigh075 = ...
            100 * mean(P_valid >= 0.75);

        rasterEtaSummary = table( ...
            nValid, ...
            nHigh075, ...
            shareHigh075, ...
            eta_threshold_075, ...
            min(eta_valid), ...
            prctile(eta_valid, 25), ...
            median(eta_valid), ...
            mean(eta_valid), ...
            prctile(eta_valid, 75), ...
            prctile(eta_valid, 95), ...
            max(eta_valid), ...
            'VariableNames', { ...
                'NValidPixels', ...
                'N_P_GE_075', ...
                'Share_P_GE_075_Percent', ...
                'EtaThreshold_P075', ...
                'EtaMinimum', ...
                'EtaQ1', ...
                'EtaMedian', ...
                'EtaMean', ...
                'EtaQ3', ...
                'EtaP95', ...
                'EtaMaximum'});

        fprintf('\nRasterauswertung des besten Punktmodells:\n');
        disp(rasterEtaSummary);

        writetable( ...
            rasterEtaSummary, ...
            fullfile(outDir, ...
            'raster_eta_summary_best_point_based_model.xlsx'));

    end


    %% GeoTIFFs für Modell 4 und Modell 9

    if ismember(k, [4 9])

        P_out = single(P);

        % Vollständige Wahrscheinlichkeit 0 bis 1
        geotiffwrite( ...
            fullfile(outDir, ...
            sprintf('model_%02d_probability_full.tif', k)), ...
            P_out, ...
            Rgeo, ...
            'CoordRefSysCode', 25832);


        % Nur Bereich mit p >= 0.75
        P_high = P_out;

        P_high(P_high < 0.75) = NaN;

        geotiffwrite( ...
            fullfile(outDir, ...
            sprintf('model_%02d_probability_high_075_100.tif', k)), ...
            P_high, ...
            Rgeo, ...
            'CoordRefSysCode', 25832);

    end


    %% Kontrolle der modellierten Wahrscheinlichkeiten

    fprintf('\nModell %02d Kartenkontrolle:\n', k);

    fprintf( ...
        'NaN-Anteil P: %.2f %%\n', ...
        100 * sum(isnan(P(:))) / numel(P));

    fprintf( ...
        'Minimum P: %.4f\n', ...
        min(P(:), [], 'omitnan'));

    fprintf( ...
        'Maximum P: %.4f\n', ...
        max(P(:), [], 'omitnan'));


    %% Klassifizierte Wahrscheinlichkeit

    edges = [0 0.2 0.4 0.6 0.8 1.000001];

    Pclass = discretize(P, edges);

    Pclass(isnan(P)) = NaN;


    %% Fein abgestufte Modellkarte

    fig = figure( ...
        'Color', 'w', ...
        'Position', [100 100 1200 800]);

    h = imagesc(P, [0 1]);

    set(gca, 'Color', [1 1 1]);

    set(h, ...
        'AlphaData', ...
        ~isnan(P));

    axis image off;

    colormap(cmapFine);

    cb = colorbar;

    cb.Ticks = [0 0.25 0.5 0.75 1];

    cb.TickLabels = { ...
        '0', ...
        '0.25', ...
        '0.50', ...
        '0.75', ...
        '1'};

    ylabel(cb, 'modellierte Wahrscheinlichkeit p');

    title( ...
        {sprintf( ...
            'Model_%d: punktbasierte logistische Regression', k), ...
         'fein abgestufte modellierte Anfälligkeit'}, ...
        'Interpreter', 'none');

    exportgraphics( ...
        fig, ...
        fullfile(outDir, ...
        sprintf( ...
        'model_%02d_probability_fine_blue_yellow_red.png', k)), ...
        'Resolution', 300);

    close(fig);


    %% Klassifizierte Modellkarte

    fig = figure( ...
        'Color', 'w', ...
        'Position', [100 100 1200 800]);

    h = imagesc(Pclass);

    set(h, ...
        'AlphaData', ...
        ~isnan(Pclass));

    axis image off;

    colormap(cmapClass);

    clim([1 5]);

    cb = colorbar;

    cb.Ticks = 1:5;

    cb.TickLabels = { ...
        '0.0-0.2', ...
        '0.2-0.4', ...
        '0.4-0.6', ...
        '0.6-0.8', ...
        '0.8-1.0'};

    ylabel(cb, 'p-Klasse');

    title( ...
        {sprintf( ...
            'Model_%d: punktbasierte logistische Regression', k), ...
         'klassifizierte modellierte Anfälligkeit'}, ...
        'Interpreter', 'none');

    exportgraphics( ...
        fig, ...
        fullfile(outDir, ...
        sprintf( ...
        'model_%02d_probability_classes_5_blue_yellow_red.png', k)), ...
        'Resolution', 300);

    close(fig);

end


fprintf('\nFertig. Ergebnisse liegen in:\n%s\n', outDir);


%% Lokale Hilfsfunktionen


function f = pickRaster(titleText)

    [name, path] = uigetfile( ...
        {'*.tif;*.tiff', 'GeoTIFF (*.tif, *.tiff)'}, ...
        titleText);

    if isequal(name, 0)
        error('Keine Datei ausgewählt: %s', titleText);
    end

    f = fullfile(path, name);

end


function T = makeModelTable(Traw, yValue, groupName)

    T = table();

    T.Y = yValue * ones(height(Traw), 1);

    T.GROUP = repmat( ...
        string(groupName), ...
        height(Traw), ...
        1);

    T.SLOPE = toNumeric( ...
        Traw.(findVar(Traw, 'SLOPE_1')));

    T.MID = toNumeric( ...
        Traw.(findVar(Traw, 'MID_1')));

    T.TWI = toNumeric( ...
        Traw.(findVar(Traw, 'TWI_1')));

    T.FLOW = toNumeric( ...
        Traw.(findVar(Traw, 'FLOW_1')));

    T.VALLEY = toNumeric( ...
        Traw.(findVar(Traw, 'VALLEY_1')));

    T.VRM = toNumeric( ...
        Traw.(findVar(Traw, 'VRM_1')));

    T.PLAN = toNumeric( ...
        Traw.(findVar(Traw, 'PLAN_1')));

    T.PROF = toNumeric( ...
        Traw.(findVar(Traw, 'PROF_1')));

    T.CONV = toNumeric( ...
        Traw.(findVar(Traw, 'CONV_1')));

end


function varName = findVar(Traw, wanted)

    names = string(Traw.Properties.VariableNames);

    cleanNames = upper( ...
        regexprep(names, '[^A-Za-z0-9]', ''));

    cleanWanted = upper( ...
        regexprep(string(wanted), '[^A-Za-z0-9]', ''));

    idx = find( ...
        cleanNames == cleanWanted, ...
        1, ...
        'first');

    if isempty(idx)

        error( ...
            'Spalte "%s" nicht gefunden. Vorhandene Spalten: %s', ...
            wanted, ...
            strjoin(names, ', '));

    end

    varName = names(idx);

end


function x = toNumeric(x)

    if iscell(x)
        x = string(x);
    end

    if isstring(x) || ischar(x) || iscategorical(x)
        x = str2double(string(x));
    end

    x = double(x(:));

end


function Zout = zscoreRaster(X, S, paramName)

    idx = strcmp( ...
        string(S.Param), ...
        paramName);

    if ~any(idx)

        error( ...
            'Parameter %s nicht in Standardisierungstabelle gefunden.', ...
            paramName);

    end

    mu = single(S.Mean(idx));
    sd = single(S.Std(idx));

    X = single(X);

    Zout = (X - mu) ./ sd;

    Zout = single(Zout);

end


function cmap = blueYellowRed(n)

    if nargin < 1
        n = 256;
    end

    blue   = [0.05 0.20 0.90];
    cyan   = [0.00 0.75 1.00];
    yellow = [1.00 0.95 0.15];
    red    = [0.90 0.00 0.00];

    x = [0 0.35 0.65 1];

    r = [blue(1) cyan(1) yellow(1) red(1)];
    g = [blue(2) cyan(2) yellow(2) red(2)];
    b = [blue(3) cyan(3) yellow(3) red(3)];

    xi = linspace(0, 1, n);

    cmap = [ ...
        interp1(x, r, xi)', ...
        interp1(x, g, xi)', ...
        interp1(x, b, xi)'];

end
