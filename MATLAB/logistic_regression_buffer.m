%% buffer_logistic_regression_probability_maps_full.m
% Bufferbasierte logistische Regression mit 9 schrittweisen Modellen
% und Kartenerzeugung fuer jedes Modell.
%
% Behaltene Outputs:
% - AIC-Werte in der Konsole
% - ROC-Kurve mit AUC fuer bestes Modell
% - Konfusionsmatrix fuer bestes Modell
% - Pro Modell:
%   1) fein abgestufte Karte 0-1, blau = gering, rot = hoch
%   2) klassifizierte Karte 0-1 in 5 Klassen
%
% Keine geglaettete Karte.
% Keine Histogramme.
% Zusaetzlich: Koeffizientenplot des besten Modells.
%
% Wichtig:
% Die Rasterwerte werden wie die Punktdaten z-standardisiert.
% Die Karten sind echte logistische Regressionskarten.

clear; clc; close all;

%% 0) Ausgabeordner waehlen

outDir = uigetdir(pwd, 'Ausgabeordner fuer Ergebnisse auswaehlen');

if isequal(outDir, 0)
    error('Kein Ausgabeordner ausgewaehlt.');
end

fprintf('\nAusgabeordner:\n%s\n', outDir);

%% 1) Tabellen auswaehlen

fprintf('\nBitte KFV-1000-Tabelle auswaehlen.\n');
[hangName, hangPath] = uigetfile({'*.xlsx;*.xls','Excel-Dateien (*.xlsx, *.xls)'}, ...
    'KFV-1000-Tabelle auswaehlen');

if isequal(hangName, 0)
    error('Keine KFV-Tabelle ausgewaehlt.');
end

fprintf('\nBitte Random-Buffer-1000-Tabelle auswaehlen.\n');
[randomName, randomPath] = uigetfile({'*.xlsx;*.xls','Excel-Dateien (*.xlsx, *.xls)'}, ...
    'Random-Buffer-1000-Tabelle auswaehlen');

if isequal(randomName, 0)
    error('Keine Random-Buffer-Tabelle ausgewaehlt.');
end

hangFile = fullfile(hangPath, hangName);
randomFile = fullfile(randomPath, randomName);

H_raw = readtable(hangFile, 'VariableNamingRule', 'modify');
R_raw = readtable(randomFile, 'VariableNamingRule', 'modify');

fprintf('\nKFV-Tabelle: %d Zeilen\n', height(H_raw));
fprintf('Random-Buffer-Tabelle: %d Zeilen\n', height(R_raw));

disp('Spalten KFV:');
disp(H_raw.Properties.VariableNames');

disp('Spalten Random-Buffer:');
disp(R_raw.Properties.VariableNames');

%% 2) Modelltabellen bauen

H = makeModelTable(H_raw, 1, "KFV");
R = makeModelTable(R_raw, 0, "Random-Buffer");

D = [H; R];

% Flow Accumulation logarithmieren
D.FLOW_LOG = log10(1 + D.FLOW);

% Reihenfolge der schrittweisen Modelle:
% Model_1 = SLOPE
% Model_2 = SLOPE + MID
% Model_3 = SLOPE + MID + TWI
% ...
% Model_9 = alle Parameter
predictor_order = {'SLOPE','MID','TWI','FLOW_LOG', ...
                   'VALLEY','VRM','PLAN','PROF','CONV'};

D = D(:, [{'Y','GROUP'}, predictor_order]);

fprintf('\nBeobachtungen vor modellweiser Bereinigung: %d\n', height(D));
disp('Klassenverteilung vor modellweiser Bereinigung:');
tabulate(D.Y)

fprintf('\nBeobachtungen nach Entfernen fehlender Werte: %d\n', height(D));
disp('Klassenverteilung:');
tabulate(D.Y)

%% 3) Punktdaten der KFV- und Random-Buffer-Stichprobe standardisieren

D_std = D;

standardizationStats = table();
standardizationStats.Param = predictor_order';
standardizationStats.Mean = nan(numel(predictor_order), 1);
standardizationStats.Std  = nan(numel(predictor_order), 1);

for i = 1:numel(predictor_order)

    p = predictor_order{i};

    mu = mean(D.(p), 'omitnan');
    sd = std(D.(p), 'omitnan');

    if sd == 0 || isnan(sd)
        error('Parameter %s hat keine Streuung und kann nicht standardisiert werden.', p);
    end

    standardizationStats.Mean(i) = mu;
    standardizationStats.Std(i)  = sd;

    D_std.(p) = (D.(p) - mu) ./ sd;
end

fprintf('\nStandardisierungswerte:\n');
disp(standardizationStats);

% Standardisierungswerte speichern
writetable(standardizationStats, fullfile(outDir, 'standardization_values_buffer_logistic_regression.xlsx'));

%% 4) 9 logistische Modelle fitten und AIC vergleichen

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

    % Fuer jedes Modell nur die jeweils benoetigten Variablen verwenden
    D_model = D_std(:, [{'Y','GROUP'}, preds]);

    % Fehlende Werte nur fuer dieses konkrete Modell entfernen
    D_model = rmmissing(D_model);

    fprintf('\nFitte Model_%d:\n%s\n', k, formula);
    fprintf('Verwendete Beobachtungen: %d\n', height(D_model));
    disp('Klassenverteilung dieses Modells:');
    tabulate(D_model.Y)

    mdl = fitglm(D_model, formula, ...
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

results = table(ModelName, NumPredictors, Formula, AIC, BIC, Deviance);
results.DeltaAIC = results.AIC - min(results.AIC);
results = sortrows(results, 'AIC');

fprintf('\nAIC-MODELLVERGLEICH:\n');
disp(results);

% Modellvergleich speichern
writetable(results, fullfile(outDir, 'AIC_model_comparison_buffer_logistic_regression.xlsx'));
%% 4b) AIC-Plot fuer alle 9 Modelle

fig = figure('Color','w','Position',[100 100 950 600]);

bar(1:nModels, AIC);

set(gca, ...
    'XTick', 1:nModels, ...
    'XTickLabel', cellstr(ModelName));

xlabel('Modell');
ylabel('AIC');
title('AIC comparison - buffer-based logistic regression', ...
    'Interpreter','none');

grid on;

exportgraphics(fig, fullfile(outDir, ...
    'AIC_comparison_buffer_based_logistic_regression.png'), ...
    'Resolution', 300);

close(fig);
bestModelName = results.ModelName(1);
bestIdx = find(ModelName == bestModelName, 1);
bestModel = models{bestIdx};
D_best = modelData{bestIdx};
fprintf('\nBestes Modell nach AIC: %s\n', bestModelName);
fprintf('Formel: %s\n', results.Formula(1));
fprintf('AIC: %.4f\n', results.AIC(1));
fprintf('DeltaAIC: %.4f\n', results.DeltaAIC(1));
%% 4c) Koeffizientenplot des besten Modells

coefTable = bestModel.Coefficients;

coefTableOut = coefTable;
coefTableOut.Predictor = string(coefTableOut.Properties.RowNames);
coefTableOut = movevars(coefTableOut, 'Predictor', 'Before', 1);
writetable(coefTableOut, fullfile(outDir, 'coefficients_best_buffer_based_logistic_model.xlsx'));

coefNames = string(coefTable.Properties.RowNames);
coefNames(coefNames == "(Intercept)") = "Intercept";

coefValues = coefTable.Estimate;

% Alphabetische Sortierung wie in deiner bisherigen Abbildung
[coefNamesPlot, sortIdx] = sort(coefNames);
coefValuesPlot = coefValues(sortIdx);

fig = figure('Color','w','Position',[100 100 1050 650]);

bar(1:numel(coefValuesPlot), coefValuesPlot);
yline(0, 'k-', 'LineWidth', 1);

set(gca, ...
    'XTick', 1:numel(coefNamesPlot), ...
    'XTickLabel', cellstr(coefNamesPlot), ...
    'XTickLabelRotation', 35);

xlabel('Predictor');
ylabel('Standardized coefficient estimate');
title('Coefficients of best buffer-based logistic model', ...
    'Interpreter','none');

grid on;

exportgraphics(fig, fullfile(outDir, ...
    'coefficients_best_buffer_based_logistic_model.png'), ...
    'Resolution', 300);

close(fig);
%% 5) ROC-Kurve, AUC und Konfusionsmatrix fuer bestes Modell

p_hat = predict(bestModel, D_best);

[Xroc, Yroc, ~, AUC] = perfcurve(D_best.Y, p_hat, 1);

fprintf('\nAUC des besten Modells: %.4f\n', AUC);

fig = figure('Color','w','Position',[100 100 850 650]);
plot(Xroc, Yroc, 'LineWidth', 1.8);
hold on;
plot([0 1], [0 1], '--', 'LineWidth', 1);
xlabel('False positive rate');
ylabel('True positive rate');
title(sprintf('ROC curve - best buffer-based logistic model (AUC = %.4f)', AUC), ...
    'Interpreter','none');
grid on;
axis square;

exportgraphics(fig, fullfile(outDir, ...
    'ROC_best_buffer_based_model_AUC.png'), ...
    'Resolution', 300);
close(fig);

Y_true = double(D_best.Y);
Y_pred = double(p_hat >= 0.5);

confMat = confusionmat(Y_true, Y_pred, 'Order', [0 1]);
accuracy = mean(Y_pred == Y_true);

fprintf('\nKonfusionsmatrix fuer bestes Modell bei Schwellenwert 0.5:\n');

ConfusionTable = array2table(confMat, ...
    'VariableNames', {'Pred_0','Pred_1'}, ...
    'RowNames', {'True_0','True_1'});

disp(ConfusionTable);

writetable(ConfusionTable, fullfile(outDir, 'confusion_matrix_best_buffer_based_logistic_model.xlsx'), 'WriteRowNames', true);

fprintf('Accuracy bei Schwellenwert 0.5: %.4f\n', accuracy);

fig = figure('Color','w','Position',[100 100 850 650]);
cm = confusionchart(Y_true, Y_pred);
cm.Title = 'Confusion Matrix - threshold 0.5';
cm.RowSummary = 'row-normalized';
cm.ColumnSummary = 'column-normalized';

exportgraphics(fig, fullfile(outDir, ...
    'confusion_matrix_best_buffer_based_model.png'), ...
    'Resolution', 300);
close(fig);

%% 6) Raster auswaehlen

fprintf('\nBitte Slope-Raster auswaehlen.\n');
slopeFile = pickRaster('Slope-Raster auswaehlen');

fprintf('\nBitte Mid-Slope-Position-/MSP-Raster auswaehlen.\n');
mspFile = pickRaster('MSP-/Mid-Slope-Position-Raster auswaehlen');

fprintf('\nBitte TWI-Raster auswaehlen.\n');
twiFile = pickRaster('TWI-Raster auswaehlen');

fprintf('\nBitte Flow-Accumulation-Raster auswaehlen.\n');
flowFile = pickRaster('Flow-Accumulation-Raster auswaehlen');

fprintf('\nBitte Valley-Depth-Raster auswaehlen.\n');
valleyFile = pickRaster('Valley-Depth-Raster auswaehlen');

fprintf('\nBitte VRM-Raster auswaehlen.\n');
vrmFile = pickRaster('VRM-Raster auswaehlen');

fprintf('\nBitte Plan-Curvature-Raster auswaehlen.\n');
planFile = pickRaster('Plan-Curvature-Raster auswaehlen');

fprintf('\nBitte Profile-Curvature-Raster auswaehlen.\n');
profFile = pickRaster('Profile-Curvature-Raster auswaehlen');

fprintf('\nBitte Convergence-Index-Raster auswaehlen.\n');
convFile = pickRaster('Convergence-Index-Raster auswaehlen');

%% 7) Raster einlesen

[Slope, Rgeo] = readgeoraster(slopeFile);
MSP      = readgeoraster(mspFile);
TWI      = readgeoraster(twiFile);
Flow     = readgeoraster(flowFile);
Valley   = readgeoraster(valleyFile);
VRM      = readgeoraster(vrmFile);
PlanCurv = readgeoraster(planFile);
ProfCurv = readgeoraster(profFile);
ConvIdx  = readgeoraster(convFile);

Slope    = single(Slope);
MSP      = single(MSP);
TWI      = single(TWI);
Flow     = single(Flow);
Valley   = single(Valley);
VRM      = single(VRM);
PlanCurv = single(PlanCurv);
ProfCurv = single(ProfCurv);
ConvIdx  = single(ConvIdx);

allRasters = {Slope, MSP, TWI, Flow, Valley, VRM, PlanCurv, ProfCurv, ConvIdx};
rasterNames = {'SLOPE','MID','TWI','FLOW','VALLEY','VRM','PLAN','PROF','CONV'};

%% 8) Rastergroessen pruefen

refSize = size(Slope);

for i = 1:numel(allRasters)
    if ~isequal(size(allRasters{i}), refSize)
        error('Raster %s hat eine andere Groesse (%d x %d) als Slope (%d x %d).', ...
            rasterNames{i}, size(allRasters{i},1), size(allRasters{i},2), refSize(1), refSize(2));
    end
end

fprintf('\nAlle Raster haben dieselbe Groesse.\n');

%% 9) NoData-Pruefung der Praediktorraster

invalid = false(refSize);

for i = 1:numel(allRasters)

    X = allRasters{i};

    invalid = invalid | isnan(X) | isinf(X);
    invalid = invalid | X <= -9990;
end

% Flow darf für log10(Flow + 1) nicht negativ sein
invalid = invalid | Flow < 0;

fprintf('\nUngueltige Pixel laut Maske: %.2f %%\n', ...
    100 * nnz(invalid) / numel(invalid));
invalid_base = invalid;
%% 10) Raster als z-Werte standardisieren

Z.SLOPE = zscoreRaster(Slope, standardizationStats, 'SLOPE');
clear Slope

Z.MID = zscoreRaster(MSP, standardizationStats, 'MID');
clear MSP

Z.TWI = zscoreRaster(TWI, standardizationStats, 'TWI');
clear TWI

Flow_log = single(log10(single(Flow) + 1));
Z.FLOW_LOG = zscoreRaster(Flow_log, standardizationStats, 'FLOW_LOG');
clear Flow Flow_log

Z.VALLEY = zscoreRaster(Valley, standardizationStats, 'VALLEY');
clear Valley

Z.VRM = zscoreRaster(VRM, standardizationStats, 'VRM');
clear VRM

Z.PLAN = zscoreRaster(PlanCurv, standardizationStats, 'PLAN');
clear PlanCurv

Z.PROF = zscoreRaster(ProfCurv, standardizationStats, 'PROF');
clear ProfCurv

Z.CONV = zscoreRaster(ConvIdx, standardizationStats, 'CONV');
clear ConvIdx

%% 11) Farbskala

cmapFine = blueYellowRed(256);
cmapClass = blueYellowRed(5);

%% 12) Für jedes der 9 Modelle eine Karte erzeugen
for k = 1:nModels

    mdl = models{k};
    preds = predictor_order(1:k);

    coefTable = mdl.Coefficients;
    coefNames = string(coefTable.Properties.RowNames);

    b0 = coefTable.Estimate(coefNames == "(Intercept)");

    eta = b0 * ones(refSize);

    for j = 1:numel(preds)

        p = preds{j};

        idx = coefNames == string(p);

        if ~any(idx)
            error('Koeffizient fuer %s in Model_%d nicht gefunden.', p, k);
        end

        b = coefTable.Estimate(idx);

        eta = eta + b .* Z.(p);
    end

    P = 1 ./ (1 + exp(-eta));

    invalid_model = invalid_base;

P(invalid_model) = NaN;
    P(P < 0) = 0;
    P(P > 1) = 1;

   fprintf('\nModel_%02d Kartenkontrolle:\n', k);
fprintf('NaN-Anteil P: %.2f %%\n', 100 * sum(isnan(P(:))) / numel(P));
fprintf('Minimum P: %.4f\n', min(P(:), [], 'omitnan'));
fprintf('Maximum P: %.4f\n', max(P(:), [], 'omitnan'));

    %% Klassifizierte Karte
    edges = [0 0.2 0.4 0.6 0.8 1.000001];
    Pclass = discretize(P, edges);
    Pclass(isnan(P)) = NaN;

    %% PNG fein abgestuft, 0 bis 1
    fig = figure('Color','w','Position',[100 100 1200 800]);
    h = imagesc(P, [0 1]);
    set(gca, 'Color', [1 1 1]);
    set(h, 'AlphaData', ~isnan(P));
    axis image off;
    colormap(cmapFine);

    cb = colorbar;
    cb.Ticks = [0 0.25 0.5 0.75 1];
    cb.TickLabels = {'0','0.25','0.50','0.75','1'};
    ylabel(cb, 'modellierte Wahrscheinlichkeit p');

    title({sprintf('Model_%d: logistische Regression der Buffermethode', k), ...
           'fein abgestufte modellierte Wahrscheinlichkeit'}, ...
           'Interpreter','none');

    exportgraphics(fig, fullfile(outDir, ...
        sprintf('buffer_model_%02d_probability_fine_blue_yellow_red.png', k)), ...
        'Resolution', 300);
    close(fig);

    %% PNG 5 Klassen
    fig = figure('Color','w','Position',[100 100 1200 800]);
    h = imagesc(Pclass);
    set(h, 'AlphaData', ~isnan(Pclass));
    axis image off;
    colormap(cmapClass);
    clim([1 5]);

    cb = colorbar;
    cb.Ticks = 1:5;
    cb.TickLabels = {'0.0-0.2','0.2-0.4','0.4-0.6','0.6-0.8','0.8-1.0'};
    ylabel(cb, 'p-Klasse');

    title({sprintf('Model_%d: logistische Regression der Buffermethode', k), ...
           'klassifizierte modellierte Wahrscheinlichkeit'}, ...
           'Interpreter','none');

    exportgraphics(fig, fullfile(outDir, ...
        sprintf('buffer_model_%02d_probability_classes_5_blue_yellow_red.png', k)), ...
        'Resolution', 300);
    close(fig);

end

fprintf('\nFertig. Ergebnisse liegen in:\n%s\n', outDir);

%% ===== Hilfsfunktionen =====

function f = pickRaster(titleText)

    [name, path] = uigetfile({'*.tif;*.tiff','GeoTIFF (*.tif, *.tiff)'}, titleText);

    if isequal(name, 0)
        error('Keine Datei ausgewaehlt: %s', titleText);
    end

    f = fullfile(path, name);
end

function T = makeModelTable(Traw, yValue, groupName)

    T = table();

    T.Y = yValue * ones(height(Traw), 1);
    T.GROUP = repmat(string(groupName), height(Traw), 1);

    T.SLOPE  = toNumeric(Traw.(findVar(Traw, {'SLOPE_1','SLOPE1','SLOPE'})));
    T.MID    = toNumeric(Traw.(findVar(Traw, {'MID_1','MID1','MSP_1','MSP1','MID','MSP'})));
    T.TWI    = toNumeric(Traw.(findVar(Traw, {'TWI_1','TWI1','TWI'})));
    T.FLOW   = toNumeric(Traw.(findVar(Traw, {'FLOW_1','FLOW1','FLOWACC','FLOWACCUMULATION','FLOW'})));
    T.VALLEY = toNumeric(Traw.(findVar(Traw, {'VALLEY_1','VALLEY1','VALLEY'})));
    T.VRM    = toNumeric(Traw.(findVar(Traw, {'VRM_1','VRM1','VRM'})));
    T.PLAN   = toNumeric(Traw.(findVar(Traw, {'PLAN_1','PLAN1','PLAN'})));
    T.PROF   = toNumeric(Traw.(findVar(Traw, {'PROF_1','PROF1','PROF'})));
    T.CONV   = toNumeric(Traw.(findVar(Traw, {'CONV_1','CONV1','CONV'})));
end

function varName = findVar(Traw, patterns)

    names = string(Traw.Properties.VariableNames);
    cleanNames = upper(regexprep(names, '[^A-Za-z0-9]', ''));

    for p = 1:numel(patterns)

        pat = upper(regexprep(string(patterns{p}), '[^A-Za-z0-9]', ''));

        exactIdx = find(cleanNames == pat, 1, 'first');

        if ~isempty(exactIdx)
            varName = names(exactIdx);
            return;
        end

        containsIdx = find(contains(cleanNames, pat), 1, 'first');

        if ~isempty(containsIdx)
            varName = names(containsIdx);
            return;
        end
    end

    error('Keine passende Spalte gefunden fuer Muster: %s', strjoin(string(patterns), ', '));
end

function x = toNumeric(x)

    if isnumeric(x)
        return;
    end

    if iscell(x)
        x = string(x);
    end

    if isstring(x) || ischar(x) || iscategorical(x)
        x = str2double(string(x));
    end
end

function Zout = zscoreRaster(X, S, paramName)

    idx = strcmp(string(S.Param), paramName);

    if ~any(idx)
        error('Parameter %s nicht in Standardisierungstabelle gefunden.', paramName);
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

    cmap = [interp1(x, r, xi)', ...
            interp1(x, g, xi)', ...
            interp1(x, b, xi)'];
end
