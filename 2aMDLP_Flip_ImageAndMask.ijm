
/// macro pour retourner les cellules

//BaseNameTab=newArray("0_S","0_B");
BaseNameTab=newArray("KO_S");
BaseNameTab=newArray("Yen");
//BaseNameTab=newArray("0","5","10","20");
//BaseNameTab=newArray("cell3p10");
BaseNameTab=newArray("0","1","2","3","0bis");
BaseNameTab=newArray("0_B","0_S");
//BaseNameTab=newArray("1_B");
iBaseName=lengthOf(BaseNameTab);
//print(lengh);
//filterSize=40; // taille minimum detectee par le analyse particle
filterSize=40;
dirselect = getDirectory("Choisir le dossier GENERAL de la manip");



Dialog.create("Parametres des images");
Dialog.addChoice("Masque a choisir pour le flip", newArray("Cell","Nucl"));
Dialog.show();
maskName = Dialog.getChoice(); 	


setBatchMode(true);

//iBaseName=newArray(1,lengh);
//print(lengthOf(iBaseName));
for(iname=0;iname<lengthOf(BaseNameTab);iname++) {
	BaseName=BaseNameTab[iname];
	//print(BaseName);
dirdata = dirselect  + BaseName + "\\"; // dossier contenant les cellules pour l'analyse et le mapping
dirMask = dirselect + BaseName + "_Mask\\";
dirFlip = dirselect + BaseName + "_Flip\\";
dirMaskFlip = dirselect + BaseName + "_MaskFlip\\";
File.makeDirectory(dirFlip); 
File.makeDirectory(dirMaskFlip);

imagenames=getFileList(dirdata); /// tableau contenant le nom des fichier contenus dans le dossier dirdata
nbimages=lengthOf(imagenames); /// longueur du tableau == nombre de fichier dans le dossier


for(image=0; image<nbimages; image++) { /// boucle sur les images contenues dans dirdata

	name=imagenames[image];   /// ici prends le nom des images dans le dossier dirdata dans l'ordre de la boucle
	totnamelength=lengthOf(name); /// enleve l'extension a name
	namelength=totnamelength-4;   /// exemple ici, on enleve les 4 derniers caracteres
	name1=substring(name, 0, namelength);  /// name1==name sans le .tif

	open(dirdata+name);
	selectWindow(name);
	Stack.getDimensions(w, h, chan, numSlices, frames);   /// prends les proprietes du stack
	if (frames>numSlices) {   /// ici la macro marche avec les differents temps = slices et non frames
		Stack.setDimensions(chan, frames, numSlices);   /// inverse si les stacks sont en frames et non en slices
		Stack.getDimensions(w, h, chan, numSlices, frames);   /// inverse si les stacks sont en frames et non en slices
	}

	open(dirMask+name1+"_masqueCell.tif");
	open(dirMask+name1+"_masqueNucl.tif");


	/// mesure de la position au temps 0
	selectWindow(name1+"_masque"+maskName+".tif");
	setSlice(1);
	run("Duplicate...", "title=temp1.tif");		
	run("Analyze Particles...", "size="+filterSize+"-Infinity circularity=0.00-1.00 show=Nothing include clear add slice");
	cellCounts=nResults;
	cellindexes= newArray(cellCounts);
		if(cellCounts==0) {
				selectWindow("temp1.tif");
				run("Close");				/// a completer pour securite si rien n'est detecte, ne doit pas arriver si les cellules sont decoupees correctement
		} else {
		for(p=0; p<cellCounts ; p++) {
		cellindexes[p] = p ;    /// tableau necessaire pour faire le combine dans ROI manager si masque en plusieurs parties
		}
		if(cellCounts==1) {
			selectWindow("temp1.tif");
			roiManager("select", 0);
			}
		else {
			selectWindow("temp1.tif");
			roiManager("select", cellindexes);
			roiManager("Combine");
		}
		
		run("Measure");
		xCell0=getResult("X",0);
		run("Clear Results");
		selectWindow("temp1.tif");
		run("Close");
		}

	/// mesure de la position au dernier temps 		
	selectWindow(name1+"_masque"+maskName+".tif");
	setSlice(numSlices);
	run("Duplicate...", "title=temp1.tif");		
	run("Analyze Particles...", "size="+filterSize+"-Infinity circularity=0.00-1.00 show=Nothing include clear add slice");
	cellCounts=nResults;
	cellindexes= newArray(cellCounts);
		if(cellCounts==0) {
				selectWindow("temp1.tif");
				run("Close");				/// a completer pour securite si rien n'est detecte, ne doit pas arriver si les cellules sont decoupees correctement
		} else {
		for(p=0; p<cellCounts ; p++) {
		cellindexes[p] = p ;    /// tableau necessaire pour faire le combine dans ROI manager si masque en plusieurs parties
		}
		if(cellCounts==1) {
			selectWindow("temp1.tif");
			roiManager("select", 0);
			}
		else {
			selectWindow("temp1.tif");
			roiManager("select", cellindexes);
			roiManager("Combine");
		}
		
		run("Measure");
		xCellfin=getResult("X",0);
		run("Clear Results");
		selectWindow("temp1.tif");
		run("Close");
		}

deltaX=xCellfin-xCell0;
if(deltaX<0) {
	selectWindow(name);
	run("Flip Horizontally", "stack");
	selectWindow(name1+"_masqueCell.tif");
	run("Flip Horizontally", "stack");
	selectWindow(name1+"_masqueNucl.tif");
	run("Flip Horizontally", "stack");
}


selectWindow(name1+"_masqueCell.tif");
saveAs("Tiff", dirMaskFlip + name1+"_masqueCell.tif");
run("Close");
selectWindow(name1+"_masqueNucl.tif");
saveAs("Tiff", dirMaskFlip + name1+"_masqueNucl.tif");
run("Close");
selectWindow(name);
saveAs("Tiff", dirFlip + name);
run("Close");

	
}  /// fin de la boucle sur toutes les images
}
setBatchMode(false);

selectWindow("Results");
run("Close");


