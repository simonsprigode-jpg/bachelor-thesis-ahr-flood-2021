# Bachelorarbeit – Ahrhochwasser 2021

Dieses Repository enthält die im Rahmen der Bachelorarbeit verwendeten Skripte zur Untersuchung hochwasserbedingter Landschaftsveränderungen im Ahrtal infolge des Hochwasserereignisses im Juli 2021.

Der Workflow kombiniert eine Sentinel-2-basierte Veränderungsanalyse in Google Earth Engine mit statistischen Auswertungen von Geländeparametern und binären logistischen Regressionsmodellen in MATLAB.

## Repository-Struktur

```text
bachelor-thesis-ahr-flood-2021/
├── README.md
├── AI_USAGE.md
├── MATLAB/
│   ├── 01_boxplots_terrain_parameters.m
│   ├── 02_spearman_correlation_analysis.m
│   ├── 03_cliffs_delta_analysis.m
│   ├── 04_logistic_regression_buffer.m
│   └── 05_logistic_regression_point.m
├── GEE/
│   └── sentinel2_change_mapping.js
├── Klassenstatistik KFV Pixelwerte SAGA 25 K.xlsx
├── Klassenstatistik Random Buffer Pixelwerte SAGA 25 K.xlsx
├── Klassenstatistik Random Points Pixelwerte SAGA 25 K.xlsx
├── KFV 1000 Klassenstatistik.xlsx
├── Random Buffer 1000 Klassenstatistik.xlsx
└── Random Points 1000 Klassenstatistik.xlsx
```

## Analytischer Workflow

Die Sentinel-2-Auswertung in Google Earth Engine dient der Unterstützung der visuellen KFV-Kartierung. Dafür werden Bilddaten vor und nach dem Hochwasser aufbereitet und Veränderungen von NDVI und BSI dargestellt.

Anschließend werden neun Geländeparameter für KFV sowie zwei unterschiedliche Referenzansätze untersucht. Als Referenz dienen Random-Buffer und Random-Points. Die statistische Auswertung umfasst Boxplotvergleiche, Spearman-Rangkorrelationen und Cliff's Delta.

Darauf aufbauend werden zwei Serien binärer logistischer Regressionsmodelle berechnet. Die Buffermethode unterscheidet zwischen KFV und Random-Buffer, während die Punktmethode KFV und Random-Points vergleicht. Die geschätzten Regressionsmodelle werden anschließend auf die vollständigen Geländeparameter-Raster übertragen, um räumliche Wahrscheinlichkeitskarten zu erzeugen.

## Geländeparameter

| Kürzel | Geländeparameter |
|---|---|
| `SLOPE` | Slope |
| `MID` | Mid-Slope Position |
| `TWI` | Topographic Wetness Index |
| `FLOW` | Flow Accumulation |
| `VALLEY` | Valley Depth |
| `VRM` | Vector Ruggedness Measure |
| `PLAN` | Plan Curvature |
| `PROF` | Profile Curvature |
| `CONV` | Convergence Index |

Bei den Boxplotvergleichen werden Valley Depth und Flow Accumulation als `log10(x + 1)` dargestellt. Für die logistischen Regressionsmodelle wird Flow Accumulation vor der Modellierung mit `log10(x + 1)` transformiert. Anschließend werden alle Prädiktoren der logistischen Regression z-standardisiert.

Die Spearman-Korrelationen und Cliff's-Delta-Berechnungen verwenden die eingelesenen Parameterwerte ohne diese logarithmischen Transformationen.

## Eingangsdaten

Die für die MATLAB-Auswertungen verwendeten vorbereiteten Stichprobendaten
sind im Repository im Ordner [`data/`](data/) enthalten. Die Herleitung,
Aufbereitung und methodische Verwendung der Datensätze und Geländeparameter
ist in der Bachelorarbeit beschrieben.

### 25-K-Stichproben

| Datensatz | Datei | Verwendung |
|---|---|---|
| KFV | [Klassenstatistik KFV Pixelwerte SAGA 25 K.xlsx](./Klassenstatistik%20KFV%20Pixelwerte%20SAGA%2025%20K.xlsx) | Boxplots, Spearman-Korrelationen, Cliff's Delta |
| Random-Buffer | [Klassenstatistik Random Buffer Pixelwerte SAGA 25 K.xlsx](./Klassenstatistik%20Random%20Buffer%20Pixelwerte%20SAGA%2025%20K.xlsx) | Boxplots, Spearman-Korrelationen, Cliff's Delta |
| Random-Points | [Klassenstatistik Random Points Pixelwerte SAGA 25 K.xlsx](./Klassenstatistik%20Random%20Points%20Pixelwerte%20SAGA%2025%20K.xlsx) | Boxplots, Spearman-Korrelationen, Cliff's Delta |

### 1-K-Stichproben

| Datensatz | Datei | Verwendung |
|---|---|---|
| KFV | [KFV 1000 Klassenstatistik.xlsx](./KFV%201000%20Klassenstatistik.xlsx) | Buffer- und Punktmodell |
| Random-Buffer | [Random Buffer 1000 Klassenstatistik.xlsx](./Random%20Buffer%201000%20Klassenstatistik.xlsx) | Buffermodell |
| Random-Points | [Random Points 1000 Klassenstatistik.xlsx](./Random%20Points%201000%20Klassenstatistik.xlsx) | Punktmodell |

| Datensatz | Datei | Verwendung |
|---|---|---|
| KFV | [KFV 1000 Klassenstatistik.xlsx](data/samples_1k/KFV%201000%20Klassenstatistik.xlsx) | Buffer- und Punktmodell |
| Random-Buffer | [Random Buffer 1000 Klassenstatistik.xlsx](data/samples_1k/Random%20Buffer%201000%20Klassenstatistik.xlsx) | Buffermodell |
| Random-Points | [Random Points 1000 Klassenstatistik.xlsx](data/samples_1k/Random%20Points%201000%20Klassenstatistik.xlsx) | Punktmodell |

### Geländeparameter-Raster

Für die räumliche Anwendung der logistischen Regressionsmodelle werden
zusätzlich die vollständigen GeoTIFF-Raster der neun Geländeparameter
benötigt. Aufgrund ihrer Dateigröße sind diese nicht direkt in diesem
GitHub-Repository enthalten.

Die Raster sind separat archiviert:

**[Geländeparameter-Raster – externer Datensatz](LINK_ZUM_DATENSATZ)**

Der externe Datensatz enthält die Raster für Slope, Mid-Slope Position,
Topographic Wetness Index, Flow Accumulation, Valley Depth, Vector
Ruggedness Measure, Plan Curvature, Profile Curvature und Convergence Index.

## MATLAB-Skripte

### `01_boxplots_terrain_parameters.m`

Das Skript vergleicht die Verteilungen der neun Geländeparameter zwischen KFV, Random-Buffer und Random-Points.

Für jeden Geländeparameter wird ein Drei-Gruppen-Boxplot erzeugt. Valley Depth und Flow Accumulation werden für die Darstellung mit `log10(x + 1)` transformiert.

Slope, TWI, Mid-Slope Position und Flow Accumulation werden zusätzlich in einer gemeinsamen 2×2-Abbildung dargestellt. Für diese vier Parameter werden außerdem Stichprobengröße, Mittelwert, Median, erstes und drittes Quartil sowie Interquartilsabstand berechnet und als Excel- und CSV-Datei ausgegeben.

Die Abbildungen werden als PNG mit 300 dpi sowie als Vektor-PDF exportiert.

### `02_spearman_correlation_analysis.m`

Das Skript berechnet Spearman-Rangkorrelationen zwischen den neun Geländeparametern getrennt für KFV, Random-Buffer und Random-Points.

Vor der Berechnung werden nur Zeilen berücksichtigt, in denen für alle neun Geländeparameter gültige numerische Werte vorliegen. Die Spearman-Korrelationsmatrizen werden anschließend in einer gemeinsamen Vergleichsabbildung dargestellt.

Die Vergleichsabbildung wird als PNG mit 300 dpi und als Vektor-PDF exportiert.

Die eigentliche Berechnung erfolgt mit:

```matlab
R = corr(X, 'Type', 'Spearman');
```

### `03_cliffs_delta_analysis.m`

Das Skript berechnet Cliff's Delta für zwei Gruppenvergleiche:

```text
KFV vs. Random-Buffer
KFV vs. Random-Points
```

Positive Delta-Werte zeigen tendenziell höhere Werte in den KFV, negative Delta-Werte entsprechend höhere Werte im jeweiligen Referenzdatensatz.

Die Berechnung erfolgt über die lokale Funktion `cliffsDeltaFast()`. Dafür werden beide Gruppen gemeinsam sortiert und Rangwerte vergeben. Bei gleichen Werten wird der mittlere Rang verwendet. Aus der Rangsumme der KFV-Gruppe wird der Mann-Whitney-U-Wert und daraus Cliff's Delta berechnet.

Zusätzlich wird für jeden Geländeparameter der Anteil seines absoluten Cliff's-Delta-Wertes an der Summe aller absoluten Delta-Werte der jeweiligen Referenzmethode berechnet. Dadurch wird die relative Trennstärke der neun Geländeparameter zwischen Punkt- und Buffermethode verglichen.

Das Skript erzeugt gerichtete Cliff's-Delta-Abbildungen für beide Referenzmethoden sowie eine gemeinsame Abbildung zum Vergleich der relativen Trennstärke.

### `04_logistic_regression_buffer.m`

Das Skript führt binäre logistische Regressionen zur Unterscheidung zwischen KFV (`Y = 1`) und Random-Buffer (`Y = 0`) durch.

Flow Accumulation wird zunächst mit `log10(x + 1)` transformiert. Anschließend werden alle Prädiktoren anhand von Mittelwert und Standardabweichung der verwendeten Stichprobendaten z-standardisiert.

Es werden neun schrittweise erweiterte Modelle berechnet:

| Modell | Prädiktoren |
|---|---|
| **Modell 1** | `SLOPE` |
| **Modell 2** | `SLOPE + MID` |
| **Modell 3** | `SLOPE + MID + TWI` |
| **Modell 4** | `SLOPE + MID + TWI + FLOW_LOG` |
| **Modell 5** | `SLOPE + MID + TWI + FLOW_LOG + VALLEY` |
| **Modell 6** | `SLOPE + MID + TWI + FLOW_LOG + VALLEY + VRM` |
| **Modell 7** | `SLOPE + MID + TWI + FLOW_LOG + VALLEY + VRM + PLAN` |
| **Modell 8** | `SLOPE + MID + TWI + FLOW_LOG + VALLEY + VRM + PLAN + PROF` |
| **Modell 9** | `SLOPE + MID + TWI + FLOW_LOG + VALLEY + VRM + PLAN + PROF + CONV` |

Die Modelle werden anhand von AIC, BIC und Deviance verglichen. Zusätzlich wird Delta AIC relativ zum Modell mit dem niedrigsten AIC berechnet. Das Modell mit dem niedrigsten AIC wird automatisch als bestes Modell ausgewählt.

Für dieses Modell werden die Regressionskoeffizienten ausgegeben. Außerdem werden vorhergesagte Wahrscheinlichkeiten für die Modellstichprobe berechnet und daraus ROC-Kurve und AUC bestimmt. Bei einem Klassifikationsschwellenwert von `p = 0.5` werden zusätzlich Accuracy und Konfusionsmatrix berechnet.

Für die räumliche Anwendung werden die neun vollständigen Geländeparameter-Raster eingelesen. Die Rasterwerte werden mit denselben Mittelwerten und Standardabweichungen standardisiert, die zuvor für die jeweilige Modellstichprobe bestimmt wurden.

Für jede Rasterzelle wird der lineare Prädiktor berechnet:

```text
eta = b0 + b1*z1 + b2*z2 + ... + bn*zn
```

Anschließend wird dieser über die inverse Logit-Funktion in eine Wahrscheinlichkeit zwischen 0 und 1 transformiert:

```matlab
P = 1 ./ (1 + exp(-eta));
```

Für alle neun Modelle werden kontinuierliche Wahrscheinlichkeitskarten und Karten mit fünf Wahrscheinlichkeitsklassen erzeugt:

```text
0.0–0.2
0.2–0.4
0.4–0.6
0.6–0.8
0.8–1.0
```

Für Modell 4 und Modell 9 werden zusätzlich GeoTIFFs der vollständigen Wahrscheinlichkeitswerte sowie GeoTIFFs mit ausschließlich Rasterzellen von `p >= 0.75` exportiert.

Für das nach AIC beste Modell wird außerdem eine Zusammenfassung der rasterbasierten linearen Prädiktorwerte und des Anteils der Rasterzellen mit `p >= 0.75` gespeichert.

### `05_logistic_regression_point.m`

Das Skript verwendet denselben Modellierungs- und Rasterworkflow wie die Buffermethode, vergleicht jedoch KFV (`Y = 1`) mit Random-Points (`Y = 0`).

Die Reihenfolge der neun Modelle, Transformation der Flow Accumulation, z-Standardisierung, Modellbewertung und räumliche Übertragung entsprechen der Buffermethode. Dadurch können die Ergebnisse beider Referenzansätze direkt miteinander verglichen werden.

Auch hier werden für das Modell mit dem niedrigsten AIC Regressionskoeffizienten, ROC-Kurve, AUC, Accuracy und Konfusionsmatrix bestimmt. Für alle neun Modelle werden kontinuierliche und klassifizierte Wahrscheinlichkeitskarten erzeugt. Für Modell 4 und Modell 9 werden zusätzlich GeoTIFFs der vollständigen Wahrscheinlichkeit sowie der Bereiche mit `p >= 0.75` ausgegeben.

## Google Earth Engine

### `sentinel2_change_mapping.js`

Das Skript verarbeitet Sentinel-2 Surface Reflectance Harmonized-Daten zur Unterstützung der visuellen KFV-Kartierung im Ahrtal.

Die verwendeten Zeiträume sind:

```text
Vor dem Hochwasser:  01.06.2021 bis 10.07.2021
Nach dem Hochwasser: 16.07.2021 bis 31.08.2021
```

Die Sentinel-2-Bildsammlung wird räumlich auf das Untersuchungsgebiet und zeitlich auf die beiden Zeiträume gefiltert. Szenen mit mehr als 40 % ausgewiesener Wolkenbedeckung werden ausgeschlossen.

Wolken, Wolkenschatten, Cirrus sowie weitere ungeeignete Pixel werden anhand des SCL-Bandes und der QA60-Bits maskiert. Für beide Zeiträume werden anschließend Median-Komposite erstellt.

Aus den Kompositen werden NDVI und BSI berechnet. Die Veränderung wird jeweils als

```text
post - pre
```

bestimmt.

Zur visuellen Unterstützung der Kartierung werden folgende Schwellenwerte verwendet:

```text
dNDVI < -0.20
dBSI  >  0.15
Slope >  8°
```

Die Hangneigung wird ergänzend aus dem SRTM-DGM berechnet.

Die erzeugten RGB-, NDVI-, BSI-, Differenz- und Maskenlayer werden im Google Earth Engine Code Editor dargestellt. Das Skript enthält keinen automatisierten Dateiexport dieser Layer.

## Zentrale MATLAB-Funktionen

Die folgende Übersicht enthält die für den analytischen Workflow wichtigsten MATLAB-Standardfunktionen. Allgemeine Hilfsbefehle für Schleifen, Arrays, Beschriftungen oder einfache mathematische Operationen sind bewusst nicht vollständig aufgeführt.

| Funktion | Verwendung im Repository | Offizielle Dokumentation |
|---|---|---|
| `readtable` | Einlesen der Excel-Eingangstabellen | [MathWorks – readtable](https://www.mathworks.com/help/matlab/ref/readtable.html) |
| `writetable` | Export von Ergebnis- und Zusammenfassungstabellen | [MathWorks – writetable](https://www.mathworks.com/help/matlab/ref/writetable.html) |
| `boxchart` | Drei-Gruppen-Boxplots der Geländeparameter | [MathWorks – boxchart](https://www.mathworks.com/help/matlab/ref/boxchart.html) |
| `tiledlayout` / `nexttile` | Anordnung mehrerer Abbildungen in gemeinsamen Layouts | [MathWorks – tiledlayout](https://www.mathworks.com/help/matlab/ref/tiledlayout.html) / [nexttile](https://www.mathworks.com/help/matlab/ref/nexttile.html) |
| `corr(...,'Type','Spearman')` | Berechnung der Spearman-Rangkorrelationen | [MathWorks – corr](https://www.mathworks.com/help/stats/corr.html) |
| `fitglm` | Schätzung der binomialen logistischen Regressionsmodelle mit Logit-Link | [MathWorks – fitglm](https://www.mathworks.com/help/stats/fitglm.html) |
| `rmmissing` | Modellweises Entfernen von Beobachtungen mit fehlenden Werten | [MathWorks – rmmissing](https://www.mathworks.com/help/matlab/ref/rmmissing.html) |
| `predict` | Berechnung vorhergesagter Wahrscheinlichkeiten für die Modellstichprobe | [MathWorks – predict](https://www.mathworks.com/help/stats/generalizedlinearmodel.predict.html) |
| `perfcurve` | Berechnung der ROC-Koordinaten und des AUC-Werts | [MathWorks – perfcurve](https://www.mathworks.com/help/stats/perfcurve.html) |
| `confusionmat` | Berechnung der numerischen Konfusionsmatrix | [MathWorks – confusionmat](https://www.mathworks.com/help/stats/confusionmat.html) |
| `confusionchart` | Grafische Darstellung der Konfusionsmatrix | [MathWorks – confusionchart](https://www.mathworks.com/help/stats/confusionchart.html) |
| `readgeoraster` | Einlesen der vollständigen Geländeparameter-Raster | [MathWorks – readgeoraster](https://www.mathworks.com/help/map/ref/readgeoraster.html) |
| `geotiffwrite` | Export georeferenzierter Wahrscheinlichkeitsraster | [MathWorks – geotiffwrite](https://www.mathworks.com/help/map/ref/geotiffwrite.html) |
| `discretize` | Einteilung kontinuierlicher Wahrscheinlichkeiten in fünf Klassen | [MathWorks – discretize](https://www.mathworks.com/help/matlab/ref/double.discretize.html) |
| `exportgraphics` | Export der erzeugten Abbildungen als PNG bzw. PDF | [MathWorks – exportgraphics](https://www.mathworks.com/help/matlab/ref/exportgraphics.html) |

Mehrere Skripte enthalten zusätzlich lokale Hilfsfunktionen, beispielsweise `cliffsDeltaFast()`, `zscoreRaster()`, `readAnyTable()`, `buildParameterTable()` oder Funktionen zur robusten Erkennung von Spaltennamen. Diese Funktionen sind Bestandteil der jeweiligen Skripte und keine MATLAB-Standardfunktionen.

## Zentrale Google-Earth-Engine-Funktionen

| Funktion / Methode | Verwendung im Repository | Offizielle Dokumentation |
|---|---|---|
| `ee.ImageCollection()` | Laden der Sentinel-2-Bildsammlung | [Google Earth Engine – ee.ImageCollection](https://developers.google.com/earth-engine/apidocs/ee-imagecollection) |
| `filterBounds()` | Räumliche Filterung auf das Untersuchungsgebiet | [Google Earth Engine – filterBounds](https://developers.google.com/earth-engine/apidocs/ee-imagecollection-filterbounds) |
| `filterDate()` | Zeitliche Filterung der Bildsammlung | [Google Earth Engine – filterDate](https://developers.google.com/earth-engine/apidocs/ee-imagecollection-filterdate) |
| `filter()` / `ee.Filter.lte()` | Filterung nach der Metadatenangabe zur Wolkenbedeckung | [Google Earth Engine – filter](https://developers.google.com/earth-engine/apidocs/ee-imagecollection-filter) / [ee.Filter.lte](https://developers.google.com/earth-engine/apidocs/ee-filter-lte) |
| `map()` | Anwendung der Wolken- und Schattenmaskierung auf alle Szenen | [Google Earth Engine – map](https://developers.google.com/earth-engine/apidocs/ee-imagecollection-map) |
| `median()` | Erstellung der Median-Komposite | [Google Earth Engine – median](https://developers.google.com/earth-engine/apidocs/ee-imagecollection-median) |
| `select()` | Auswahl der Sentinel-2-Bänder und berechneten Indexbänder | [Google Earth Engine – select](https://developers.google.com/earth-engine/apidocs/ee-image-select) |
| `updateMask()` | Anwendung der SCL- und QA60-basierten Masken | [Google Earth Engine – updateMask](https://developers.google.com/earth-engine/apidocs/ee-image-updatemask) |
| `bitwiseAnd()` | Auswertung der Cloud- und Cirrus-Bits im QA60-Band | [Google Earth Engine – bitwiseAnd](https://developers.google.com/earth-engine/apidocs/ee-image-bitwiseand) |
| `clip()` | Begrenzung der Bilder auf das Untersuchungsgebiet | [Google Earth Engine – clip](https://developers.google.com/earth-engine/apidocs/ee-image-clip) |
| `addBands()` | Hinzufügen von NDVI und BSI zu den Kompositen | [Google Earth Engine – addBands](https://developers.google.com/earth-engine/apidocs/ee-image-addbands) |
| `selfMask()` | Maskierung von Pixeln außerhalb der definierten Veränderungsschwellen | [Google Earth Engine – selfMask](https://developers.google.com/earth-engine/apidocs/ee-image-selfmask) |
| `ee.Terrain.slope()` | Berechnung der Hangneigung aus dem SRTM-DGM | [Google Earth Engine – ee.Terrain.slope](https://developers.google.com/earth-engine/apidocs/ee-terrain-slope) |
| `Map.addLayer()` | Darstellung der Bild-, Index- und Maskenlayer im Code Editor | [Google Earth Engine – Map.addLayer](https://developers.google.com/earth-engine/apidocs/map-addlayer) |

Die arithmetischen Bildoperationen `add()`, `subtract()` und `divide()` sowie logische Vergleiche wie `lt()`, `gt()`, `neq()` und `eq()` werden ebenfalls im Earth-Engine-Skript verwendet. Sie sind grundlegende Bestandteile der Index- und Maskenberechnung und werden hier nicht einzeln aufgeführt.


## Ausführung

Die Skripte verwenden Dialogfenster zur Auswahl der jeweiligen Eingangs- und Ausgabeordner beziehungsweise Dateien.

Für die Boxplot-, Spearman- und Cliff's-Delta-Auswertungen wird zunächst der Ordner mit den benötigten Excel-Tabellen ausgewählt.

Bei den Regressionsskripten werden der Ausgabeordner, die beiden jeweiligen Stichprobentabellen sowie anschließend die neun GeoTIFF-Prädiktorraster ausgewählt.

Das Google-Earth-Engine-Skript wird im Google Earth Engine Code Editor ausgeführt.

## Softwareanforderungen

Für die Ausführung der Analysen werden benötigt:

- MATLAB
- Statistics and Machine Learning Toolbox
- Mapping Toolbox
- Google Earth Engine Code Editor

## Ausgaben

Je nach Skript werden unter anderem folgende Ergebnisse erzeugt:

- Boxplots der Geländeparameter als PNG und PDF
- deskriptive Kennwerte als Excel- und CSV-Datei
- gemeinsame Spearman-Korrelationsabbildung als PNG und PDF
- Cliff's-Delta-Abbildungen
- Tabellen zu Standardisierungswerten und Modellvergleichen
- Koeffiziententabellen der nach AIC ausgewählten Regressionsmodelle
- ROC-Kurven und AUC-Werte
- Accuracy und Konfusionsmatrizen
- kontinuierliche und klassifizierte Wahrscheinlichkeitskarten
- rasterbasierte Zusammenfassungen des jeweils besten Regressionsmodells
- GeoTIFF-Wahrscheinlichkeitsraster für Modell 4 und Modell 9
- GeoTIFF-Raster mit ausschließlich Wahrscheinlichkeiten von `p >= 0.75`

## Hinweis zur Modellbewertung

AUC, Accuracy und Konfusionsmatrix werden in den Regressionsskripten anhand derselben Beobachtungen berechnet, die auch zur Schätzung des jeweiligen Modells verwendet werden.

Diese Kennwerte beschreiben daher die Anpassung beziehungsweise Klassifikationsleistung des Modells innerhalb der analysierten Stichprobe und stellen keine unabhängige Testdatensatz- oder Kreuzvalidierung dar.

## KI-Unterstützung

Bei der technischen Entwicklung und Überarbeitung einzelner Skriptbereiche wurde generative KI unterstützend eingesetzt.

Die fachliche Konzeption der Analysen, die Auswahl und Aufbereitung der Datensätze, die Festlegung der untersuchten Geländeparameter und Referenzmethoden, die Auswahl der statistischen Verfahren sowie die Interpretation der Ergebnisse erfolgten eigenständig.

Eine detaillierte Dokumentation des Umfangs, der betroffenen Codebereiche und der Art der KI-Unterstützung befindet sich in:

[Dokumentation zur KI-Unterstützung](AI_USAGE.md)
