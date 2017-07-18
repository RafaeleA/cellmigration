/// macro cellule moyenne, marche apres avoir extrait des cellules dans un dossier et avoir supprimer l'image Montage.tif du dossier
//BaseNameTab=newArray("WT9-5-9 B","WT9-5-9 S");
//BaseNameTab=newArray("Triangle","Triangle");
//BaseNameTab=newArray("0","1","2","3","0bis");
//BaseNameTab=newArray("0-5cells","5-0cells");


BaseNameTab=newArray("0_B","0_S");
//BaseNameTab=newArray("1_B");
//BaseNameTab=newArray("Triangle");
BaseNameTab=newArray("Yen");

lengh=lengthOf(BaseNameTab);
dirselect = getDirectory("Choisir le dossier GENERAL de la manip");
Dialog.create("Parametres des images");
Dialog.addNumber("canal pour le masque de la cellule", 1 , 0 , 8, "index du canal");
//Dialog.addString("Methode de seuillage de la cellule", "Yen", 20);
Dialog.addString("Methode de seuillage de la cellule", "Triangle", 20);
Dialog.addNumber("canal pour le masque du noyau", 2 , 0 , 8, "index du canal");
Dialog.addString("Methode de seuillage du noyau", "Yen", 20);
Dialog.show();
canalCell = Dialog.getNumber();
seuillageCell = Dialog.getString();
canalNucl = Dialog.getNumber();
seuillageNucl = Dialog.getString();

run("Set Measurements...", "area mean standard min centroid center integrated median display redirect=None decimal=3");  /// regle les parametres de Fiji pour que la macro puisse fonctionner correctement
run("Options...", "iterations=1 count=1 black edm=Overwrite");  /// regle les parametres de Fiji pour que la macro puisse fonctionner correctement
run("Colors...", "foreground=white background=black selection=yellow");   /// regle les parametres de Fiji pour que la macro puisse fonctionner correctement

iBaseName=newArray(1,lengh);
for(iname=0;iname<lengthOf(BaseNameTab);iname++) {
	BaseName=BaseNameTab[iname];
	print(BaseName);
	//	if(endsWith(BaseName,".tif")==true) {
	
	dirdata = dirselect  + BaseName + "\\"; // dossier contenant les cellules pour l'analyse et le mapping
	dirMask = dirselect + BaseName + "_Mask\\";
	File.makeDirectory(dirMask);



	imagenames=getFileList(dirdata); /// tableau contenant le nom des fichier contenus dans le dossier dirdata
	nbimages=lengthOf(imagenames); /// longueur du tableau == nombre de fichier dans le dossier
	
	setBatchMode(true);
	
	for(image=0; image<nbimages; image++) { /// boucle sur les images contenues dans dirdata
	
		name=imagenames[image];
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
		selectWindow(name);
		run("Duplicate...", "title=temp1.tif duplicate channels="+canalCell+" range=1-numSlices");
		run("Subtract Background...", "rolling=1000 stack");
		Stack.getStatistics(voxelCount, mean, min, max, stdDev);
	    	setMinAndMax(min, max);
		run("8-bit");
		run("Auto Threshold", "method="+seuillageCell+" white stack use_stack_histogram");
		selectWindow("temp1.tif");
		run("Dilate", "stack");
		run("Dilate", "stack");
		run("Erode", "stack");
		run("Erode", "stack");
		run("Fill Holes", "stack");
		saveAs("Tiff", dirMask + name1+"_masqueCell.tif");
		run("Close");
	
		selectWindow(name);
		run("Duplicate...", "title=temp1.tif duplicate channels="+canalNucl+" range=1-numSlices");
		Stack.getStatistics(voxelCount, mean, min, max, stdDev);
	    	setMinAndMax(min, max);
		run("8-bit");
		run("Auto Threshold", "method="+seuillageNucl+" white stack use_stack_histogram");
		selectWindow("temp1.tif");
		run("Fill Holes", "stack");
		saveAs("Tiff", dirMask + name1+"_masqueNucl.tif");
		run("Close");
		
		selectWindow(name);
		run("Close");
	}
}
//}
setBatchMode(false);



