
/// macro pour mesurer vitesses avant arriere et centre de la cellule
/// plus mesure de la distrib actin
setBatchMode(false);
dirselect = getDirectory("Choisir le dossier GENERAL de la manip");


BaseName=newArray("20_0");

chanMeasure=1;

////////////////////////////////////////////
run("Set Measurements...", "area mean standard min centroid center bounding integrated median stack redirect=None decimal=3");
if(isOpen("Results")==true) {
	selectWindow("Results");
	run("Close");
}

////////////////////////////////////////////

for(condition=0;condition<lengthOf(BaseName);condition++) {

///creation des dossiers //////////////////

dirDistrib = dirselect + BaseName[condition] + "_Distrib_v2\\";
dirOriginalImage= dirselect + BaseName[condition];
dirFlip = dirselect + BaseName[condition] + "_Flip\\";
dirMaskFlip = dirselect + BaseName[condition] + "_MaskFlip\\";

File.makeDirectory(dirDistrib); 

setResult("Image Name",0,0);
setResult("BackPosition",0,0);
setResult("FrontPosition",0,0);
setResult("CenterPosition",0,0);
setResult("MeanActinBack",0,0);
setResult("BackArea",0,0);
setResult("MeanActinFront",0,0);
setResult("FrontArea",0,0);
updateResults();
IJ.renameResults("Results",BaseName[condition]+"_Results");
TableIndex=0;


imagenames=getFileList(dirOriginalImage); /// tableau contenant le nom des fichier contenus dans le dossier dirFlip

nbimages=lengthOf(imagenames); /// longueur du tableau == nombre de fichier dans le dossier

for(image=0; image<nbimages; image++) { /// boucle sur les images contenues dans dirdata
	name=imagenames[image];  /// ici prends le nom des images dans le dossier dirdata dans l'ordre de la boucle
	if(endsWith(name,".tif")==true) {
	totnamelength=lengthOf(name); /// enleve l'extension a name
	namelength=totnamelength-4;   /// exemple ici, on enleve les 4 derniers caracteres
	name1=substring(name, 0, namelength);  /// name1==name sans le .tif
	open(dirFlip+name);
	Stack.getDimensions(w, h, chan, slices, frames);  /// prends les proprietes du stack
	run("Duplicate...", "title=IntToMeasure duplicate channels="+chanMeasure);
	run("Subtract Background...", "rolling=50 stack");


	open(dirMaskFlip+name1+"_masqueCell.tif");
	run("Duplicate...", "title=Mask01 duplicate");
	run("Divide...", "value=255 stack");


	imageCalculator("Multiply create stack", "IntToMeasure","Mask01");
	selectWindow("IntToMeasure");
	run("Close");
	selectWindow("Result of IntToMeasure");
	rename("IntToMeasure");
	
	

	BackPosition=newArray(slices);
	FrontPosition=newArray(slices);
	CenterPosition=newArray(slices);
	MeanActinBack=newArray(slices);
	BackArea=newArray(slices);
	MeanActinFront=newArray(slices);
	FrontArea=newArray(slices);
	
	for(i=0;i<slices;i++) {
		selectWindow(name1+"_masqueCell.tif");
		run("Select None");
		Stack.setSlice(i+1);
		run("Analyze Particles...", "size=10-Infinity pixel clear exclude add slice");
		nbObject=roiManager("Count");
		if(nbObject>0) {
		if(nbObject==1) {
		roiManager("select",0);
		} 
		if(nbObject>1) {
			Objindexes1=newArray(nbObject);
			for(p=0; p<nbObject ; p++) {
				Objindexes1[p] = p ;
				}
			roiManager("select", Objindexes1);
			roiManager("Combine");
		}
		run("Clear Results");
		run("Measure");
		BackPosition[i]=getResult("BX",0);
		FrontPosition[i]=getResult("BX",0)+getResult("Width",0);
		CenterPosition[i]=getResult("X",0);
		width=getResult("Width",0);
		run("Clear Results");

		selectWindow("Mask01");
		Stack.setSlice(i+1);
		makeRectangle(0, 0, CenterPosition[i], h);
		run("Measure");
		BackArea[i]=getResult("RawIntDen",0);

		selectWindow("IntToMeasure");
		Stack.setSlice(i+1);
		makeRectangle(0, 0, CenterPosition[i], h);
		run("Measure");
		MeanActinBack[i]=getResult("RawIntDen",1)/getResult("RawIntDen",0);

		selectWindow("Mask01");
		Stack.setSlice(i+1);
		makeRectangle(CenterPosition[i], 0, w-CenterPosition[i], h);
		run("Measure");
		FrontArea[i]=getResult("RawIntDen",2);
        //waitForUser("oidfgvj");
		selectWindow("IntToMeasure");
		Stack.setSlice(i+1);
		makeRectangle(CenterPosition[i], 0, w-CenterPosition[i], h);
		run("Measure");
		MeanActinFront[i]=getResult("RawIntDen",3)/getResult("RawIntDen",2);

		run("Clear Results");
		}
		
		
		if(nbObject==0){
		BackPosition[i]=NaN;
		FrontPosition[i]=NaN;
		CenterPosition[i]=NaN;
		MeanActinBack[i]=NaN;
		BackArea[i]=NaN;
		MeanActinFront[i]=NaN;
		FrontArea[i]=NaN;
		}
		roiManager("Reset");
	}
	if(isOpen("Results")==true) {
	selectWindow("Results");
	run("Close");
	}

	IJ.renameResults(BaseName[condition]+"_Results","Results");
	for(i=0;i<slices;i++) {
	setResult("Image Name",TableIndex,imagenames[image]);
	setResult("BackPosition",TableIndex,BackPosition[i]);
	setResult("FrontPosition",TableIndex,FrontPosition[i]);
	setResult("CenterPosition",TableIndex,CenterPosition[i]);
	setResult("MeanActinBack",TableIndex,MeanActinBack[i]);
	setResult("BackArea",TableIndex,BackArea[i]);
	setResult("MeanActinFront",TableIndex,MeanActinFront[i]);
	setResult("FrontArea",TableIndex,FrontArea[i]);
	updateResults();
	TableIndex=TableIndex+1;
	}
	
	IJ.renameResults("Results",BaseName[condition]+"_Results_v2");
	
	
	run("Close All");

	}
}
selectWindow(BaseName[condition]+"_Results");
saveAs("Results", dirDistrib+BaseName[condition]+"_Results");
run("Close");
}