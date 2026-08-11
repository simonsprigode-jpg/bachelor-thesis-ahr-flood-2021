# Dokumentation der KI-Unterstützung

Bei der Entwicklung und Überarbeitung der in diesem Repository enthaltenen
Skripte wurde ChatGPT (OpenAI, 2026) unterstützend eingesetzt.

Die fachliche Konzeption der Analysen, die Auswahl und Aufbereitung der
Datensätze, die Festlegung der untersuchten Geländeparameter und
Referenzmethoden, die Auswahl der statistischen Verfahren sowie die
Interpretation der Ergebnisse erfolgten eigenständig.

Die KI-Unterstützung betraf insbesondere die programmiertechnische Umsetzung,
die Strukturierung längerer Skripte, die Automatisierung wiederkehrender
Arbeitsschritte sowie die Fehlersuche und technische Überarbeitung.

Alle verwendeten Skripte wurden anschließend geprüft und mit den für die
Bachelorarbeit verwendeten Eingangsdaten ausgeführt.

## Einordnung der Prozentangaben

Die im Folgenden genannten Prozentwerte sind grobe Schätzungen des Anteils der
programmiertechnischen Umsetzung, bei dem KI wesentlich unterstützend eingesetzt
wurde. Sie stellen ausdrücklich keinen prozentualen Anteil der wissenschaftlichen
Arbeit oder der fachlichen Eigenleistung dar.

## MATLAB
---
### `01_boxplots_terrain_parameters.m` Boxplotvergleiche 

**Eigene fachliche Leistung**

- Festlegung des Vergleichs zwischen KFV, Random-Buffer und Random-Points
- Auswahl der neun untersuchten Geländeparameter
- Entscheidung über die logarithmierte Darstellung von Valley Depth und
  Flow Accumulation
- Auswahl von Slope, TWI, Mid-Slope Position und Flow Accumulation für die
  zusammengefasste Hauptabbildung
- Festlegung der darzustellenden deskriptiven Kennwerte
- fachliche Auswertung und Interpretation der erzeugten Boxplots

**KI-Unterstützung**

- Strukturierung des MATLAB-Skripts
- Unterstützung bei Schleifen und lokalen Hilfsfunktionen
- korrektes Einlesen und Erkennen von Excel-Spalten
- Fehlerbehandlung bei abweichenden Spaltenbezeichnungen
- automatisierte Erstellung und Speicherung mehrerer Abbildungen
- technische Umsetzung der 2x2-Übersichtsabbildung
- Fehlersuche und Bereinigung des Codes

**Sinngemäß rekonstruierte wesentliche Prompts**

1. „Die drei Datengruppen, neun Parameter und Transformationen stehen bereits
   fest. Hilf mir, die wiederkehrende Erstellung der Boxplots in MATLAB
   übersichtlich zu strukturieren und zu automatisieren. Ich möchte die Daten aller 3 Gruppen als vergleichende Boxplots je Parameter nebeneinander darstellen.“

   **Daraus entstandene Code-Idee:** Die bereits festgelegten Gruppen und
   Parameter werden über wiederverwendbare Plotfunktionen verarbeitet, anstatt
   für jeden Geländeparameter einen separaten Plotblock zu schreiben.

   **Betroffene Codebereiche:**  
   [Funktion `plotThreeGroupBox()`](https://github.com/simonsprigode-jpg/bachelor-thesis-ahr-flood-2021/blob/851f119018f040cbde1aa996eddb3cd39a565feb/MATLAB/boxplots_terrain_parameters.m#L225-L246)  
   [Funktion `drawThreeGroupBox()`](https://github.com/simonsprigode-jpg/bachelor-thesis-ahr-flood-2021/blob/7c13516984a0a99dd0b9f5006d190d17233bfdd1/MATLAB/boxplots_terrain_parameters.m#L271-L317)

2. „Für den Ergebnisteil möchte ich meine vier Hauptparameter, mit den größten Gruppenunterschieden: 
   Slope, TWI, Mid-Slope Position und Flow Accumulation zusätzlich gemeinsam
   als 2×2-Abbildung darstellen und die wichtigsten deskriptiven Kennwerte
   ausgeben.“

   **Daraus entstandene Code-Idee:** Ergänzung einer automatisierten
   2×2-Übersichtsabbildung sowie einer zusammenfassenden Tabelle mit
   Stichprobengröße, Mittelwert, Median, Quartilen und IQR (summary_4_wichtigste_parameter)

   **Betroffene Codebereiche:**  
   [Funktion `plotFourPanelBoxplots()`](https://github.com/simonsprigode-jpg/bachelor-thesis-ahr-flood-2021/blob/27353977cc9af75245d2b2f391d3fcd04e9595a6/MATLAB/boxplots_terrain_parameters.m#L247-L261)  
   [Funktion `makeSummaryTable()`](https://github.com/simonsprigode-jpg/bachelor-thesis-ahr-flood-2021/blob/681922f4e88e0a33497a40eb5422d5b52a0fdf43/MATLAB/boxplots_terrain_parameters.m#L116-L160)

3. „Erstelle die Spaltenerkennung beim Einlesen der Dateien robust gegenüber Sonderzeichen bzw. Zeilenumbrüchen in
   den Excel-Spaltennamen, ohne die Analyse selbst zu verändern.“

   **Daraus entstandene Code-Idee:** Die Excel-Spaltennamen werden für die
   Suche vereinheitlicht, sodass beispielsweise Zeilenumbrüche oder
   Unterstriche die Zuordnung beim Einlesen der Geländeparameter nicht verhindern.

   **Betroffene Codebereiche:**  
   [Funktion `getNumericColExact()`](https://github.com/simonsprigode-jpg/bachelor-thesis-ahr-flood-2021/blob/259cce5f5effc06f224e4e1b8216caab93b8acf3/MATLAB/boxplots_terrain_parameters.m#L182-L219)  
   [Funktion `findExactVar()`](HIER_PERMALINK_6)  
   [Funktion `normalizeVarNames()`](HIER_PERMALINK_7)


**Geschätzte KI-Unterstützung bei der programmiertechnischen Umsetzung:**  
ca. **25–30 %**

---

### `02_spearman_correlation_analysis.m` Korrelationsmatrizen

**Eigene fachliche Leistung**

- Auswahl der Spearman-Rangkorrelation als Korrelationsmaß
- Festlegung der drei getrennt zu untersuchenden Datensätze
- Auswahl und Reihenfolge der Geländeparameter
- Entscheidung für den Vergleich der drei Korrelationsmatrizen
- fachliche Interpretation der Korrelationsstrukturen und möglicher
  Redundanzen zwischen den Prädiktoren

**KI-Unterstützung**

- korrektes, automatisiertes Einlesen und Vereinheitlichen der drei Datensätze
- robuste Erkennung der benötigten Spalten
- technische Umsetzung der Korrelationsmatrizen
- automatisierte Erstellung der kombinierten Vergleichsabbildung
- Export der Korrelationswerte und Abbildungen
- Fehlersuche bei Excel-Spaltennamen und Zeilenumbrüchen

**Sinngemäß rekonstruierte wesentliche Prompts**

1. „Die Verwendung der Spearman-Korrelation, die drei Datensätze und die neun
   Parameter stehen fest. Kannst du mir helfen die Berechnung für alle drei Datensätze
   einheitlich in MATLAB umzusetzen?“

   **Daraus entstandene Code-Idee:** Die Spearman-Korrelationsmatrix wird über
   eine gemeinsame Funktion für jeden Datensatz berechnet, anstatt die
   Berechnung dreimal separat zu programmieren. Die eigentliche
   Spearman-Berechnung erfolgt mit der MATLAB-Standardfunktion `corr`.

   **Betroffener Codebereich:**  
   [Funktion `computeSpearman()`](HIER_PERMALINK_1)

2. „Die drei Korrelationsmatrizen sollen zusätzlich in einer gemeinsamen
   Abbildung direkt miteinander vergleichbar dargestellt werden.“

   **Daraus entstandene Code-Idee:** Automatisierte Darstellung der drei
   Korrelationsmatrizen mit einheitlicher Farbskala, eingetragenen
   Korrelationskoeffizienten und gemeinsamer Vergleichsabbildung.

   **Betroffene Codebereiche:**  
   [Funktion `makeCombinedCorrFigure()`](HIER_PERMALINK_2)  
   [Funktion `plotCorrOnAxes()`](HIER_PERMALINK_3)

3. „Einige Excel-Spalten werden wegen Sonderzeichen bzw. Zeilenumbrüchen in
   den Spaltennamen nicht erkannt. Mach die Zuordnung robust gegenüber Sonderzeichen etc., ohne die
   Datenwerte selbst zu verändern.“

   **Daraus entstandene Code-Idee:** Die Spaltennamen werden nur für die Suche
   vereinheitlicht, indem Sonderzeichen, Unterstriche und Zeilenumbrüche
   ignoriert werden. Anschließend wird weiterhin die tatsächliche
   Originalspalte aus der Tabelle verwendet.

   **Betroffener Codebereich:**  
   [Funktion `buildParameterTable()` und Spaltennormalisierung](HIER_PERMALINK_4)


**Geschätzte KI-Unterstützung bei der programmiertechnischen Umsetzung:**  
ca. **30 %**

---

### `03_cliffs_delta_analysis.m` Cliffs Delta Trennschärfe 

**Eigene fachliche Leistung**

- Auswahl von Cliff's Delta als nichtparametrisches Effektstärkemaß
- Festlegung der Vergleiche KFV vs. Random-Buffer und
  KFV vs. Random-Points
- Verwendung gerichteter Delta-Werte zur Interpretation der
  Gruppenunterschiede
- Konzept der relativen Trennstärke auf Grundlage der absoluten
  Cliff's-Delta-Werte
- fachliche Interpretation der Rangfolge der Geländeparameter

**KI-Unterstützung**

- technische Implementierung der Cliff's-Delta-Berechnung
- effiziente Berechnung über Rangordnungen bei großen Datensätzen
- Behandlung gleicher Werte (ties)
- automatisierte Sortierung und Zusammenstellung der Ergebnisse
- Erstellung der Einzel- und Vergleichsdiagramme
- korrekte Dateisuche und Spaltenerkennung
- Fehlersuche und Codebereinigung

  **Sinngemäß rekonstruierte wesentliche Prompts**

1. „Cliff's Delta als Methodik und die beiden Gruppenvergleiche stehen fest. Wie kann ich die
   Berechnung bei etwa 26.000 Werten effizient in MATLAB umsetzen?“

   **Daraus entstandene Code-Idee:** effiziente rangbasierte Implementierung,
   ohne sämtliche Wertepaarungen explizit zu erzeugen.

   **Betroffener Codebereich:**  
   [Funktion `cliffsDeltaFast()` – KI-unterstützte Implementierung](HIER_PERMALINK_EINFÜGEN)

   2. „Kannst du mir helfen die gerichteten Cliff's-Delta-Werte für beide Referenzmethoden
   vergleichbar darzustellen?“

   **Daraus entstandene Code-Idee:** Hilfe bei Erstellung und Ausgabe
   der beiden Effektstärkediagramme.

    **Betroffener Codebereich:**  
   [Funktion `makeDeltaBarFigure()`](HIER_PERMALINK)

   3. „Aus den absoluten Delta-Werten möchte ich zusätzlich die relative
   Trennstärke der Parameter für beide Methoden vergleichen.“

   **Daraus entstandene Code-Idee:** Berechnung der relativen Anteile und
   gemeinsame Vergleichsabbildung beider Referenzmethoden.

   **Betroffene Codebereiche:**  
   [Berechnung von `sharePoint` und `shareBuffer`](HIER_PERMALINK_1)  
   [Funktion `makeMethodComparisonRankingFigure()`](HIER_PERMALINK_2)


**Geschätzte KI-Unterstützung bei der programmiertechnischen Umsetzung:**  
ca. **40 %**

---

### `04_logistic_regression_buffer.m` Logistische Regression Buffermodell

**Eigene fachliche Leistung**

- Entwicklung des bufferbasierten Referenzansatzes
- Auswahl der KFV- und Random-Buffer-Stichproben
- Kodierung von KFV als Klasse 1 und Referenzdaten als Klasse 0
- Festlegung der neun schrittweise erweiterten Modelle
- Festlegung der Reihenfolge der Prädiktoren
- Entscheidung zur Transformation der Flow Accumulation mit log10(x+1)
- Entscheidung zur z-Standardisierung der Prädiktoren
- Auswahl von AIC und BIC für den Modellvergleich
- Verwendung von ROC/AUC und Konfusionsmatrix zur Modellbewertung
- Festlegung der Wahrscheinlichkeitsschwelle p >= 0.75
- fachliche Bewertung und Interpretation der Modellergebnisse und Karten

**KI-Unterstützung**

- programmiertechnische Umsetzung der neun Modelle in einer Schleifenstruktur
- automatisierter Aufbau der Modellformeln
- automatisierte Ausgabe und Speicherung von AIC, BIC und Modellkennwerten
- technische Umsetzung von ROC-Kurve, AUC und Konfusionsmatrix
- Übertragung der Regressionskoeffizienten auf die vollständigen Rasterdaten
- konsistente Anwendung der aus den Trainingsdaten bestimmten
  Standardisierungswerte auf die Raster
- Prüfung auf Rastergrößen und NoData-Werte
- pixelweise Berechnung des linearen Prädiktors und der logistischen
  Wahrscheinlichkeit
- Erstellung der fein abgestuften und klassifizierten Modellkarten
- GeoTIFF-Export für Modell 4 und Modell 9
- zusätzlicher GeoTIFF-Export für Bereiche mit p >= 0.75
- technische Fehlersuche und Speicheroptimierung

**Sinngemäß rekonstruierte wesentliche Prompts**

1. „Meine Klassen, Prädiktorreihenfolge und neun schrittweise erweiterten
   Logitmodelle stehen fest. Hilf mir, die Modelle in MATLAB automatisiert
   aufzubauen, statt neun einzelne Modellblöcke zu schreiben.“

   **Daraus entstandene Code-Idee:** Die jeweils benötigten Prädiktoren werden
   aus `predictor_order` ausgewählt und die Modellformel automatisch aufgebaut.
   Die Modelle werden anschließend mit der MATLAB-Funktion `fitglm` als
   binomiale Modelle mit Logit-Link geschätzt.

   **Betroffener Codebereich:**  
   [Schleife zum Aufbau und Fitten der neun Modelle](HIER_PERMALINK_1)

2. „Hilf mir bei dem automatisierten Modellvergleich und die Modellbewertung
   über AIC/BIC sowie ROC/AUC und Konfusionsmatrix.“

   **Daraus entstandene Code-Idee:** AIC und BIC werden für alle Modelle
   gesammelt und vergleichbar ausgegeben. Für das ausgewählte Modell werden
   vorhergesagte Wahrscheinlichkeiten erzeugt, aus denen ROC-Kurve, AUC und
   die Klassifikation bei einem festen Schwellenwert berechnet werden.

   **Betroffene Codebereiche:**  
   [Modellvergleich über AIC/BIC](HIER_PERMALINK_2)  
   [ROC/AUC mit `perfcurve()` und Konfusionsmatrix](HIER_PERMALINK_3)

3. „Die Modellkoeffizienten sollen auf die vollständigen Prädiktorraster
   übertragen werden. Verwende dafür dieselbe Standardisierung wie bei den
   Trainingsdaten und berechne für jede Rasterzelle die Modellwahrscheinlichkeit.“

   **Daraus entstandene Code-Idee:** Die Raster werden mit den gespeicherten
   Mittelwerten und Standardabweichungen der Punktdaten standardisiert.
   Anschließend werden für jedes Modell automatisch die passenden
   Regressionskoeffizienten ausgewählt und zum linearen Prädiktor `eta`
   zusammengesetzt. Daraus wird die logistische Wahrscheinlichkeit berechnet.

   **Betroffene Codebereiche:**  
   [Funktion `zscoreRaster()`](HIER_PERMALINK_4)  
   [Rasterbasierter Aufbau von `eta` und Berechnung von `P`](HIER_PERMALINK_5) -> eta = b0 + b1*Z1 + b2*Z2 + ... entspricht dem linearen Prädiktor Xβ eines GLM.      Die anschließende Berechnung P = 1 ./ (1 + exp(-eta)) ist die standardmäßige inverse Logit-Transformation, mit der der lineare Prädiktor in eine
   Wahrscheinlichkeit zwischen 0 und 1 überführt wird.

5. „Erstelle die Rasterauswertung. Achte auf ungültige Pixel und
   exportiere für Modell 4 und Modell 9 zusätzlich die vollständigen
   Wahrscheinlichkeitsraster sowie Raster nur für `p >= 0.75` als GeoTIFF.“

   **Daraus entstandene Code-Idee:** Gemeinsame NoData-Maske für alle
   Prädiktorraster, Prüfung der Rastergrößen und automatisierter
   GeoTIFF-Export der ausgewählten Modelle.

   **Betroffene Codebereiche:**  
   [Rastergrößen- und NoData-Prüfung](HIER_PERMALINK_6)  
   [GeoTIFF-Export mit `geotiffwrite()`](HIER_PERMALINK_7)
   

**Geschätzte KI-Unterstützung bei der programmiertechnischen Umsetzung:**  
ca. **50–55 %**

---

### `05_logistic_regression_point.m` Logistische Regression Punktmodell

**Eigene fachliche Leistung**

- Entwicklung des punktbasierten Referenzansatzes
- Auswahl der KFV- und Random-Point-Stichproben
- Festlegung der Klassenkodierung
- Festlegung der neun schrittweise erweiterten Modelle
- Auswahl und Reihenfolge der Prädiktoren
- Transformation und Standardisierung der Eingangsdaten
- Auswahl der Modellbewertung anhand von AIC, BIC, ROC/AUC und
  Konfusionsmatrix
- Festlegung des Schwellenwerts p >= 0.75
- Vergleich mit der Buffermethode
- fachliche Interpretation der Modellergebnisse und räumlichen Muster

**KI-Unterstützung**

- automatisierter Modellaufbau und Modellvergleich
- technische Umsetzung der Modellschleifen
- ROC-, AUC- und Konfusionsmatrix-Berechnung
- automatisiertes Einlesen und Prüfen der Prädiktorraster
- Übertragung der Modellkoeffizienten auf das Untersuchungsraster
- Behandlung ungültiger Rasterzellen und NoData-Werte
- Berechnung und Export der modellierten Wahrscheinlichkeiten
- Erstellung der Modellkarten 1–9
- GeoTIFF-Export für Modell 4 und Modell 9 sowie p >= 0.75
- Fehlersuche, Bereinigung und Verbesserung der Portabilität des Codes

**Sinngemäß rekonstruierte wesentliche Prompts**

1. „Übertrage meinen bereits festgelegten Modellaufbau der Buffermethode auf
   KFV vs. Random-Points, ohne die Modellstruktur oder Prädiktorreihenfolge
   zu verändern.“

   **Daraus entstandene Code-Idee:** Das automatisierte Gerüst der
   Buffermethode wird auf die Punktreferenz übertragen. Die jeweils benötigten
   Prädiktoren werden aus `predictor_order` ausgewählt und die neun Modelle
   automatisch mit `fitglm` berechnet.

   **Betroffener Codebereich:**  
   [Schleife zum Aufbau und Fitten der neun Punktmodelle](HIER_PERMALINK_1)

2. „Übertrage auch den Modellvergleich und die Diagnostik auf die
   Punktmethode, damit beide Referenzmethoden gleich ausgewertet werden.“

   **Daraus entstandene Code-Idee:** AIC und BIC werden für die neun Modelle
   gesammelt. Für das ausgewählte Modell werden ROC/AUC und die
   Konfusionsmatrix nach demselben Verfahren wie bei der Buffermethode
   berechnet.

   **Betroffene Codebereiche:**  
   [Modellvergleich über AIC/BIC](HIER_PERMALINK_2)  
   [ROC/AUC mit `perfcurve()` und Konfusionsmatrix](HIER_PERMALINK_3)

3. „Übertrage auch die Modelle der Punktmethode auf die vollständigen
   Prädiktorraster und erzeuge dieselben Karten und GeoTIFF-Ausgaben wie
   bei der Buffermethode.“

   **Daraus entstandene Code-Idee:** Die Raster werden mit den für die
   Punktmethode bestimmten Mittelwerten und Standardabweichungen
   standardisiert. Anschließend werden für jedes Modell die passenden
   Koeffizienten automatisch zum linearen Prädiktor `eta` zusammengesetzt
   und daraus die logistische Wahrscheinlichkeit berechnet. Zusätzlich
   werden ungültige Rasterzellen behandelt und für Modell 4 und Modell 9
   die vollständigen sowie auf `p >= 0.75` begrenzten GeoTIFFs exportiert.

   **Betroffene Codebereiche:**  
   [Funktion `zscoreRaster()`](HIER_PERMALINK_4)  
   [Rasterbasierter Aufbau von `eta` und Berechnung von `P`](HIER_PERMALINK_5) -> gleiches siehe Buffermethode 
   [Rasterprüfung und GeoTIFF-Export](HIER_PERMALINK_6)


**Geschätzte KI-Unterstützung bei der programmiertechnischen Umsetzung:**  
ca. **50–55 %**

---

## Google Earth Engine

### `sentinel2_change_mapping.js`

**Eigene fachliche Leistung**

- Festlegung des Untersuchungsgebiets
- Auswahl der Sentinel-2-Daten
- Festlegung der Vor- und Nach-Ereignis-Zeiträume
- Auswahl von NDVI und BSI zur Unterstützung der KFV-Kartierung
- Festlegung der Veränderungsrichtung post minus pre
- empirische Festlegung von dBSI > 0.15 als Screening-Schwellenwert auf Basis der visuellen Prüfung der resultierenden Veränderungsflächen
- Verwendung der Hangneigung als zusätzliche Orientierung
- visuelle Interpretation der erzeugten Layer bei der Kartierung der KFV

**KI-Unterstützung**

- Strukturierung des Earth-Engine-Skripts
- Unterstützung bei der technischen Umsetzung der Wolken- und
  Schattenmaskierung
- Erstellung wiederverwendbarer Funktionen für die Median-Komposite
- technische Umsetzung der Index- und Differenzberechnungen
- Aufbau der Schwellenwertmasken
- Organisation und Bereinigung der Visualisierungslayer
- Überarbeitung und Dokumentation des Codes

**Sinngemäß rekonstruierte wesentliche Prompts**

1. „Untersuchungsgebiet und Vor-/Nachzeiträume stehen fest. Hilf mir, die
   Sentinel-2-Daten in Earth Engine zu filtern, Wolken und Schatten zu
   maskieren und für beide Zeiträume Median-Komposite zu erstellen. Gib mir Codingunterstützung."

   **Daraus entstandene Code-Idee:** Aufbau einer wiederverwendbaren
   Wolken-/Schattenmaskierung auf Basis von SCL und QA60 sowie einer Funktion,
   die Sentinel-2-Szenen räumlich und zeitlich filtert und anschließend zu
   Median-Kompositen zusammenfasst.

   **Betroffene Codebereiche:**  
   [Funktion `maskS2SR()`](HIER_PERMALINK_1)  
   [Funktion `composite()`](HIER_PERMALINK_2)

2. „NDVI und BSI sollen für beide Zeiträume berechnet und anschließend als
   Veränderung `post - pre` verglichen werden. Hilf mir bei der Codeerstellung, um zur
   Kartierungsunterstützung benötigte Veränderungsmasken zu erstellen.“

   **Daraus entstandene Code-Idee:** Bündelung der Indexberechnung in
   `addIndices()`, anschließende Berechnung von `dNDVI` und `dBSI` sowie
   Erstellung der Schwellenwertmasken für auffällige Veränderungen.

   **Betroffene Codebereiche:**  
   [Funktion `addIndices()`](HIER_PERMALINK_3)  
   [Berechnung von `dNDVI`, `dBSI`, `vegLoss` und `newBareDebris`](HIER_PERMALINK_4)

**Geschätzte KI-Unterstützung bei der programmiertechnischen Umsetzung:**  
ca. **20 %**

---

## Gesamtbewertung der Coding-Unterstützung

Über die eigentlichen wissenschaftlichen Analyse-Skripte hinweg wird der Anteil
der KI-Unterstützung bei der programmiertechnischen Umsetzung insgesamt auf
etwa **40–45 %** geschätzt.

Diese Einschätzung bezieht sich ausschließlich auf die technische Erweiterung,
Überarbeitung und Fehlersuche des Codes.

Forschungsfrage, Untersuchungsdesign, Datengrundlage, Referenzmethoden,
Parameterauswahl, statistisches Analysekonzept, Schwellenwerte,
Ergebnisbewertung und wissenschaftliche Interpretation wurden nicht anhand
dieser Prozentangabe bewertet und stellen die fachliche Eigenleistung der
Bachelorarbeit dar.
