// TrackPresetsAssociations (associé à un fichier de TrackPresets)

~presetTracksVariations = IdentityDictionary.new; // Need to be created before storing
~presetTracksVariations.keys;
~presetTracksVariations.values;
~presetsTracksVariations.asCompileString;
~presetTracksVariations.removeAt('R1');





( // Lecture du TracksPreset Variations
~presetTracksVariationsFileName = ~presetsTracksFileName.split($.)[0]+"_Vars1.txt";

~presetTracksVariationsPath = (PathName.new(thisProcess.nowExecutingPath/*~currentPath*/).pathOnly ++ ~presetTracksVariationsFileName);
~presetTracksVariationsFileW = ZArchive.read(~presetTracksVariationsPath);
~presetTracksVariations = ~presetTracksVariationsFileW.readItem;
~presetTracksVariationsFileW.close;

~presetAssociationNames = 0 ! 10;
// ~presetAssociationNames[0] = ~presetTracksVariations.keys.asArray.sort; // Ci-dessous, préférable pour éviter un classement tel que 1, 10, 11, 2....
~presetAssociationNames[0] = ~presetTracksVariations.keys.asArray.reject({ arg item, i; item.asString.beginsWith("R") }).sort{|x, y| x.asString.naturalCompare(y.asString) < 0}; // 1ère page
if (~presetTracksVariations.keys.size > 60, { ~presetAssociationNames[1] = ~presetAssociationNames[0].copyRange(60,120) }); // 2eme page
~presetAssociationNames[5] = ~presetTracksVariations.keys.asArray.select({ arg item, i; item.asString.beginsWith("R") }).sort{|x, y| x.asString.naturalCompare(y.asString) < 0}; // 6ème page avec les keys rhytmiques commencant par Ry
(~presetAssociationNames[0] ++ ~presetAssociationNames[5]).do { |i| i.postln }; "TracksPreset Variations"; // Listing des keys de la 1ère page & 6ème page
)



~savePresetTracksRanges.('A 1 - Test', [0,2,4]);
~savePresetTracksRanges.('A 2 - Test', [0,2,4]);

~savePresetTracksRanges.('R 1 - Test', [8,10,12]);
~savePresetTracksRanges.('R 2 - Test', [8,10,12]);
~savePresetTracksRanges.('R 3 - Test', [8,10,12]);
~savePresetTracksRanges.('R 4 - Test', [8,10,12]);
~savePresetTracksRanges.('R 5 - Test', [8,10,12]);




( // Ecriture du TracksPreset Variations
~presetTracksVariationsPath = (PathName.new(~currentPath).pathOnly ++ ~presetTracksVariationsFileName);
~presetTracksVariationsFile = ZArchive.write(~presetTracksVariationsPath);
~presetTracksVariationsFile.writeItem(~presetTracksVariations);
~presetTracksVariationsFile.writeClose;
)