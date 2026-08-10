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

**Geschätzte KI-Unterstützung bei der programmiertechnischen Umsetzung:**  
ca. **25–30 %**



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

**Geschätzte KI-Unterstützung bei der programmiertechnischen Umsetzung:**  
ca. **30 %**



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
- Festlegung der verwendeten Schwellenwerte
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

**Geschätzte KI-Unterstützung bei der programmiertechnischen Umsetzung:**  
ca. **20–30 %**

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
