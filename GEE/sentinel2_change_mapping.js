// =====================================================
// REDUCED CHANGE DETECTION FOR KFV MAPPING
// Ahrtal, Sentinel-2
// Main layers: RGB, NDVI, BSI, dNDVI, dBSI, slope mask
// =====================================================

// -------------------------
// 0) Untersuchungsgebiet AOI2
// -------------------------
Map.centerObject(aoi2, 11);

// -------------------------
// 1) Zeiträume vor und nach dem Hochwasser
// -------------------------
var preStart = '2021-06-01';
var preEnd = '2021-07-10';

var postStart = '2021-07-16';
var postEnd = '2021-08-31';

// -------------------------
// 2) Einstellungen / Schwellenwerte
// -------------------------
var T_DNDVI = -0.20; // Vegetationsverlust: post - pre
var T_DBSI = 0.15; // Zunahme freigelegter Boden-/Schuttflächen: post - pre

var SLOPE_DEG = 8; // Hangneigungsmaske > 8°

// -------------------------
// 3) Sentinel-2 SR Harmonized
// -------------------------
var s2 = ee.ImageCollection('COPERNICUS/S2_SR_HARMONIZED');

// Wolken- und Schattenmaskierung über SCL + QA60
function maskS2SR(img) {
var scl = img.select('SCL');

var sclMask = scl.neq(1) // saturated / defective
.and(scl.neq(2)) // dark area pixels
.and(scl.neq(3)) // cloud shadows
.and(scl.neq(8)) // cloud medium probability
.and(scl.neq(9)) // cloud high probability
.and(scl.neq(10)); // cirrus

var qa = img.select('QA60');
var cloudBitMask = 1 << 10;
var cirrusBitMask = 1 << 11;

var qaMask = qa.bitwiseAnd(cloudBitMask).eq(0)
.and(qa.bitwiseAnd(cirrusBitMask).eq(0));

return img.updateMask(sclMask).updateMask(qaMask);
}

// Median-Komposit für den jeweiligen Zeitraum
function composite(start, end) {
return s2
.filterBounds(aoi2)
.filterDate(start, end)
.filter(ee.Filter.lte('CLOUDY_PIXEL_PERCENTAGE', 40))
.map(maskS2SR)
.median()
.clip(aoi2);
}

var pre = composite(preStart, preEnd);
var post = composite(postStart, postEnd);

// -------------------------
// 4) NDVI und BSI berechnen
// -------------------------
function addIndices(img) {
var nir = img.select('B8'); // NIR, 10 m
var red = img.select('B4'); // Rot, 10 m
var blue = img.select('B2'); // Blau, 10 m
var swir1 = img.select('B11'); // SWIR1, 20 m

// NDVI: Vegetationszustand
var ndvi = nir.subtract(red)
.divide(nir.add(red))
.rename('NDVI');

// BSI: freigelegte Boden-, Schutt- oder Sedimentflächen
var bsi = swir1.add(red).subtract(nir).subtract(blue)
.divide(swir1.add(red).add(nir).add(blue))
.rename('BSI');

return img.addBands([ndvi, bsi]);
}

pre = addIndices(pre);
post = addIndices(post);

// -------------------------
// 5) Veränderungslayer berechnen: post - pre
// -------------------------
var dNDVI = post.select('NDVI')
.subtract(pre.select('NDVI'))
.rename('dNDVI');

var dBSI = post.select('BSI')
.subtract(pre.select('BSI'))
.rename('dBSI');

// -------------------------
// 6) Masken für auffällige Veränderungsflächen
// -------------------------
var vegLoss = dNDVI.lt(T_DNDVI)
.selfMask()
.rename('vegLoss');

var newBareDebris = dBSI.gt(T_DBSI)
.selfMask()
.rename('newBareDebris');

// -------------------------
// 7) Hangneigung aus SRTM DEM
// -------------------------
var dem = ee.Image('USGS/SRTMGL1_003').clip(aoi2);

var slope = ee.Terrain.slope(dem)
.rename('slope');

var steep = slope.gt(SLOPE_DEG)
.selfMask()
.rename('steep');

// -------------------------
// 8) Visualisierung
// -------------------------
var visRGB = {
min: 0,
max: 3000,
bands: ['B4', 'B3', 'B2']
};

var visNDVI = {
min: -0.2,
max: 0.9,
palette: ['8c510a', 'f6e8c3', 'c7eae5', '5ab4ac', '01665e']
};

var visBSI = {
min: -0.5,
max: 0.5,
palette: ['2166ac', 'f7f7f7', 'b2182b']
};

var visDiff = {
min: -0.4,
max: 0.4,
palette: ['081d58', '225ea8', '41b6c4', 'f7f7f7', 'fdae61', 'f46d43', 'a50026']
};

var visSlope = {
min: 0,
max: 40
};

// -------------------------
// 9) Layer hinzufügen
// -------------------------

// RGB-Komposite
Map.addLayer(pre, visRGB, 'RGB pre', false);
Map.addLayer(post, visRGB, 'RGB post', true);

// NDVI
Map.addLayer(pre.select('NDVI'), visNDVI, 'NDVI pre', false);
Map.addLayer(post.select('NDVI'), visNDVI, 'NDVI post', false);
Map.addLayer(dNDVI, visDiff, 'dNDVI (post-pre)', true);

// BSI
Map.addLayer(pre.select('BSI'), visBSI, 'BSI pre', false);
Map.addLayer(post.select('BSI'), visBSI, 'BSI post', false);
Map.addLayer(dBSI, visDiff, 'dBSI (post-pre)', true);

// Masken
Map.addLayer(vegLoss, {palette: ['FF00FF']}, 'Mask: veg loss (dNDVI < -0.20)', false);
Map.addLayer(newBareDebris, {palette: ['FFA500']}, 'Mask: new bare/debris (dBSI > 0.15)', false);

// Hangneigung
Map.addLayer(slope, visSlope, 'slope (deg)', false);
Map.addLayer(steep, {palette: ['FFFFFF']}, 'Mask: steep (slope > 8°)', false);

// -------------------------
// 10) Ausgabe der verwendeten Schwellenwerte
// -------------------------
print('Threshold dNDVI:', T_DNDVI);
print('Threshold dBSI:', T_DBSI);
print('Slope threshold:', SLOPE_DEG);
