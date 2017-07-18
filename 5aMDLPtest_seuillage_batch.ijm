
/// macro test seuillage
BaseName = "Triangle";
dirselect = getDirectory("Choisir le dossier GENERAL de la manip");
dirdata = dirselect  + BaseName ;
   /// choix des dossier contenant les images a analyser 
//dir = getDirectory("Choisir le dossier pour la sauvegarde des masques et des resultats");
   /// choix des dossier pour la sauvegarde des resultats et des masques

dir = dirselect + BaseName + " TestSeuillage\\";
File.makeDirectory(dir); 

run("Set Measurements...", "area mean standard min centroid center integrated median display redirect=None decimal=3");  /// regle les parametres de Fiji pour que la macro puisse fonctionner correctement
run("Options...", "iterations=1 count=1 black edm=Overwrite");
   /// regle les parametres de Fiji pour que la macro puisse fonctionner correctement
run("Colors...", "foreground=white background=black selection=yellow");
   /// regle les parametres de Fiji pour que la macro puisse fonctionner correctement




///boite de dialogue pour le choix des cannaux et des seuillages

Dialog.create("Parametres du mapping");
Dialog.addNumber("canal pour le masque de la cellule", 1 , 0 , 8, "index du canal");
Dialog.addNumber("canal pour le centrage", 2 , 0 , 8, "index du canal");
Dialog.addNumber("Nombre de cellules pour les test",10, 0 , 8, "cellules");
Dialog.show();
canalCell = Dialog.getNumber();
canalCentrage = Dialog.getNumber();
nbCell = Dialog.getNumber();


setBatchMode(true);

imagenames=getFileList(dirdata); /// tableau contenant le nom des fichier contenus dans le dossier dirdata
nbimages=lengthOf(imagenames); /// longueur du tableau == nombre de fichier dans le dossier


imagenames1=newArray(nbCell);
for(i=0; i<nbCell; i++) {
	imagenames1[i]=imagenames[round(random()*(lengthOf(imagenames)-1))];
}

height=newArray(nbCell);
width=newArray(nbCell);

for(i=0; i<nbCell; i++) { /// boucle sur les images contenues dans dirdata

	name=imagenames1[i];
  /// ici prends le nom des images dans le dossier dirdata dans l'ordre de la boucle
	totnamelength=lengthOf(name); /// enleve l'extension a name
	namelength=totnamelength-4;
  /// exemple ici, on enleve les 4 derniers caracteres
	name1=substring(name, 0, namelength);
  /// name1==name sans le .tif

	open(dirdata+name);
	selectWindow(name);
	Stack.getDimensions(w, h, chan, numSlices, frames);
   /// prends les proprietes du stack
	if (frames>numSlices) {   /// ici la macro marche avec les differents temps = slices et non frames
		Stack.setDimensions(chan, frames, numSlices);   /// inverse si les stacks sont en frames et non en slices
		Stack.getDimensions(w, h, chan, numSlices, frames);   /// inverse si les stacks sont en frames et non en slices
	}

	/// realisation du masque de la cellule   
	selectWindow(name);
	run("Duplicate...", "title=temp1.tif duplicate channels="+canalCell+" range=1-numSlices");
	run("8-bit");
	run("Auto Threshold", "method=[Try all] white stack use_stack_histogram");
	selectWindow("temp1.tif");
	run("Close");
	selectWindow("Stack");
	Stack.getDimensions(w1, h1, chan1, numSlices1, frames1);
	rename(i+"_masqueCell.tif");
	selectWindow(name);
	run("Close");
	height[i]=h1;
	width[i]=w1;
}

Array.getStatistics(height, minheight, maxheight, meanheight, stdDevheight);
Array.getStatistics(width, minwidth, maxwidth, meanwidth, stdDevwidth);

for(i=0; i<nbCell; i++) { /// boucle sur les images contenues dans dirdata
  	selectWindow(i+"_masqueCell.tif");
  	run("Size...", "width="+meanwidth+" height="+meanheight+" average interpolation=Bilinear");
}

run("Concatenate...", "all_open title=[Concatenated Stacks]");
run("Stack to Hyperstack...", "order=xyczt(default) channels=1 slices=16 frames="+nbCell+" display=Color");
selectWindow("Concatenated Stacks");
saveAs("Tiff", dir + "masqueCell.tif");
run("Close");

for(i=0; i<nbCell; i++) { /// boucle sur les images contenues dans dirdata

	name=imagenames1[i];
  /// ici prends le nom des images dans le dossier dirdata dans l'ordre de la boucle
	totnamelength=lengthOf(name); /// enleve l'extension a name
	namelength=totnamelength-4;
  /// exemple ici, on enleve les 4 derniers caracteres
	name1=substring(name, 0, namelength);
  /// name1==name sans le .tif

	open(dirdata+name);
	selectWindow(name);
	Stack.getDimensions(w, h, chan, numSlices, frames);
   /// prends les proprietes du stack
	if (frames>numSlices) {   /// ici la macro marche avec les differents temps = slices et non frames
		Stack.setDimensions(chan, frames, numSlices);   /// inverse si les stacks sont en frames et non en slices
		Stack.getDimensions(w, h, chan, numSlices, frames);   /// inverse si les stacks sont en frames et non en slices
	}

	/// realisation du masque de la cellule   
	selectWindow(name);
	run("Duplicate...", "title=temp1.tif duplicate channels="+canalCentrage+" range=1-numSlices");
	run("8-bit");
	run("Auto Threshold", "method=[Try all] white stack use_stack_histogram");
	selectWindow("temp1.tif");
	run("Close");
	selectWindow("Stack");
	rename(i+"_masqueCentrage.tif");
	selectWindow(name);
	run("Close");

}


for(i=0; i<nbCell; i++) { /// boucle sur les images contenues dans dirdata
  	selectWindow(i+"_masqueCentrage.tif");
  	run("Size...", "width="+meanwidth+" height="+meanheight+" average interpolation=Bilinear");
}

run("Concatenate...", "all_open title=[Concatenated Stacks]");
run("Stack to Hyperstack...", "order=xyczt(default) channels=1 slices=16 frames="+nbCell+" display=Color");
selectWindow("Concatenated Stacks");
saveAs("Tiff", dir + "masqueCentrage.tif");	
run("Close");

setBatchMode(false);