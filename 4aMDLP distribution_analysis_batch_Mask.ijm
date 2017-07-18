/// macro pour mesurer vitesses et intensités localisées
//BaseName = "0bis";
dirselect = getDirectory("Choisir le dossier GENERAL de la manip");

//BaseNameTab=newArray("0","1","2","3","0bis");

//BaseNameTab=newArray("0bis");
BaseNameTab=newArray("0_B");
//BaseNameTab=newArray("Yen");
lengh=lengthOf(BaseNameTab);
iBaseName=newArray(1,lengh);

Dialog.create("Parametres des images");
Dialog.addChoice("Masque a choisir pour le centrage de la cellule", newArray("Cell","Nucl"));
Dialog.show();
canalCentrage = Dialog.getChoice();

for(iname=0;iname<lengthOf(BaseNameTab);iname++) {
	BaseName=BaseNameTab[iname];

dirFlip = dirselect + BaseName + "_Flip\\";
print(dirFlip);
dirMaskFlip = dirselect + BaseName + "_MaskFlip\\";

run("Set Measurements...", "area mean standard min centroid center integrated median display redirect=None decimal=3");  /// regle les parametres de Fiji pour que la macro puisse fonctionner correctement
run("Options...", "iterations=1 count=1 black edm=Overwrite");
run("Colors...", "foreground=white background=black selection=yellow");

setBatchMode(true);

centrage="center";

//centrage="front";
//centrage="back";
//centrage="back";
canalDistribution = 1;
canalDextran = 2;
lissage = 5;
   //  "1/3 de l'avant du masque de centrage", "Avant du masque de centrage"
//centre pour "centre geometrique du masque de centrage";
//avant pour "Avant du masque de centrage"
//back pour "arrière du masque de centrage"


dirDistrib = dirselect + BaseName + "_Distrib_" + canalCentrage + "_" + centrage +"\\";  /// choix des dossier pour la sauvegarde des resultats et des masques
File.makeDirectory(dirDistrib); 

imagenames=getFileList(dirFlip); /// tableau contenant le nom des fichier contenus dans le dossier dirFlip

nbimages=lengthOf(imagenames); /// longueur du tableau == nombre de fichier dans le dossier

MeanVelo=newArray(nbimages);
StdDevVelo=newArray(nbimages);
MeanRatio=newArray(nbimages);
StdDevRatio=newArray(nbimages);
TimeFractionFront=newArray(nbimages);
TimeFractionBack=newArray(nbimages);
nbChgtDirect=newArray(nbimages);
MeanCellFrontTotInt=newArray(nbimages);
MeanCellFrontMeanInt=newArray(nbimages);
Meanmacropinfractionvol=newArray(nbimages);
Meanfrontlength=newArray(nbimages);



resultat=newArray("cell name", "time (frame)","Cell position (px)", "Cell velocity (px/framerate)", "smooth velocity (px/framerate)", "back mean intensity", "front mean intensity", "background", "ratio front/back",  "cell front area (px)", "cell front length (px)", "cell back area (px)", "cell back length (px)", "front tot int", "back tot int", "macropinosomes volumic fraction");
Array.print(resultat);

//setBatchMode(true);

for(image=0; image<nbimages; image++) { /// boucle sur les images contenues dans dirdata
name=imagenames[image];   /// ici prends le nom des images dans le dossier dirdata dans l'ordre de la boucle
totnamelength=lengthOf(name); /// enleve l'extension a name
namelength=totnamelength-4;   /// exemple ici, on enleve les 4 derniers caracteres
name1=substring(name, 0, namelength);  /// name1==name sans le .tif

open(dirFlip+name);
selectWindow(name);
Stack.getDimensions(w, h, chan, numSlices, frames);   /// prends les proprietes du stack
if (frames>numSlices) {   /// ici la macro marche avec les differents temps = slices et non frames
Stack.setDimensions(chan, frames, numSlices);   /// inverse si les stacks sont en frames et non en slices
Stack.getDimensions(w, h, chan, numSlices, frames);   /// inverse si les stacks sont en frames et non en slices
}

/// ouverture du masque de la cellule  

open(dirMaskFlip + name1+"_masqueCell.tif");
Stack.getDimensions(w, h, chan, numSlices, frames);  /// prends les proprietes du stack
    if (frames>numSlices) {   /// ici la macro marche avec les differents temps = slices et non frames
        Stack.setDimensions(chan, frames, numSlices);   /// inverse si les stacks sont en frames et non en slices
        Stack.getDimensions(w, h, chan, numSlices, frames);   /// inverse si les stacks sont en frames et non en slices
    }
    run("Properties...", "channels="+chan+" slices="+numSlices+" frames="+frames+" unit=px pixel_width=1 pixel_height=1 voxel_depth=1 frame=1");
/// ouverture du masque de centrage


//open(dirMaskFlip + name1+"_masque"+canalCentrage+".tif");

///imageCalculator("Subtract create stack", name1+"_masqueCell.tif", name1+"_masqueCentrage.tif");
///selectWindow(name1+"_masqueCell.tif");
///run("Close");
///selectWindow("Result of "+name1+"_masqueCell.tif");
///rename(name1+"_masqueCell.tif");

/// mesure du background sur le canal pour la mesure de la distribution avant arriere
selectWindow(name);
Stack.setPosition(canalDistribution, 1, 1); /// ici mesure le background sur la premiere slice (au temps 0) du canal a mapper
run("Select All");
run("Measure");
bg=getResult("Median", 0);  /// ici l'intensite medianne est consideree comme etant le background
run("Clear Results");
///selectWindow("Results");
///run("Close");




xPosition=newArray(numSlices);  /// tableaux pour les mesures de la cellule
yPosition=newArray(numSlices);
Cellvelocity=newArray(numSlices);
Vitesselissee=newArray(numSlices);
BackMeanInt=newArray(numSlices);
BackTotInt=newArray(numSlices);
FrontMeanInt=newArray(numSlices);
FrontTotInt=newArray(numSlices);
RatioFrontBack=newArray(numSlices);
FrontArea=newArray(numSlices);
FrontLength=newArray(numSlices);
BackArea=newArray(numSlices);
BackLength=newArray(numSlices);
temps=newArray(numSlices);
macropinfractionvol=newArray(numSlices-1);

for(l=0; l<numSlices; l++) {  /// boucle sur tout les temps du stack pour le centrage et les mesures de la position de l'objet sur canalCentrage
temps[l]=l;
l1=l+1;  /// l1 sert a faire correspondre le temps 0 a la slice 1  (les tableaux vont de 0 a nombredetimepoint-1, alors que les slices vont de 1 a nombredetimepoint)
selectWindow(name1+"_masque"+canalCentrage+".tif");
setSlice(l1);   /// choisit le bon temps dans le stack
run("Duplicate...", "title=temp1.tif");
run("Analyze Particles...", "size=40-Infinity circularity=0.00-1.00 show=Nothing include clear add slice");

//run("Analyze Particles...", "size=20-Infinity circularity=0.00-1.00 show=Nothing include clear add slice");   /// detecte la ou les ROIs correspondant a la cellule au temps l
centrageCounts=nResults;  /// permet de savoir combien de parties comporte le masque
centrageindexes= newArray(centrageCounts);  /// tableau necessaire pour faire le combine dans ROI manager si masque en plusieurs parties
if(centrageCounts==0) {
selectWindow("temp1.tif");
run("Close"); /// a completer pour securite si rien n'est detecte, ne doit pas arriver si les cellules sont decoupees correctement
} else {
for(p=0; p<centrageCounts ; p++) {
centrageindexes[p] = p ;    /// tableau necessaire pour faire le combine dans ROI manager si masque en plusieurs parties
}
if(centrageCounts==1) {
selectWindow(name1+"_masqueCell.tif");
setSlice(l1);
roiManager("select", 0);
}
else {
selectWindow(name1+"_masqueCell.tif"); 
setSlice(l1);
roiManager("select", centrageindexes);
roiManager("Combine");
}
getSelectionBounds(xxx1, yyy1, widthCell1, heightCell1);
length=widthCell1;
run("Measure");
xPosition[l]= getResult("X",0);
yPosition[l]= getResult("Y",0);
ww=w/2;
hh=h/2;


if(centrage=="center") {
deltaX=ww-xPosition[l];   //// A CHANGER POUR MODIFIER LA SEP0ARATION AVANT ARRIERE (+l/6 = avant 1/3 arriere 2/3   +0 avant 1/2 arriere 1/2     +l/4  avant 1/4 arriere 3/4   et -... c'est l'invcerse
deltaY=hh-yPosition[l];
//print("centerok");
}
if(centrage=="1/3 de l'avant du masque de centrage") {
deltaX=ww-(xPosition[l]+length/6);   //// A CHANGER POUR MODIFIER LA SEP0ARATION AVANT ARRIERE (+l/6 = avant 1/3 arriere 2/3   +0 avant 1/2 arriere 1/2     +l/4  avant 1/4 arriere 3/4   et -... c'est l'invcerse
deltaY=hh-yPosition[l];
}
if(centrage=="front") {
deltaX=ww-(xxx1+widthCell1);   //// A CHANGER POUR MODIFIER LA SEP0ARATION AVANT ARRIERE (+l/6 = avant 1/3 arriere 2/3   +0 avant 1/2 arriere 1/2     +l/4  avant 1/4 arriere 3/4   et -... c'est l'invcerse
deltaY=hh-yPosition[l];
//print("frontok");
}
if(centrage=="back") {
deltaX=ww-(xxx1);   //// A CHANGER POUR MODIFIER LA SEP0ARATION AVANT ARRIERE (+l/6 = avant 1/3 arriere 2/3   +0 avant 1/2 arriere 1/2     +l/4  avant 1/4 arriere 3/4   et -... c'est l'invcerse
deltaY=hh-yPosition[l];
}
//print(deltaX);
//print("wwidhtcell=", widthCell1);
//print(centrage);

run("Clear Results");
///selectWindow("Results");
///run("Close");

selectWindow(name1+"_masqueCell.tif");
run("Select None");
setSlice(l1);
run("Translate...", "x="+deltaX+" y="+deltaY+" interpolation=None slice");

for(c=0; c<chan; c++) {
c1=c+1;
selectWindow(name);
run("Select None");
Stack.setChannel(c1);
Stack.setSlice(l1);
run("Translate...", "x="+deltaX+" y="+deltaY+" interpolation=None slice");
}
 
selectWindow("temp1.tif");
run("Close");
///selectWindow("ROI Manager");
///run("Close");
}
}   /// fin de la boucle sur tous les temps
 
selectWindow(name);
rename(name1+"_centreA.tif");
 
selectWindow(name1+"_masqueCell.tif");
rename(name1+"_masqueCell_centre.tif");


for(l=0; l<numSlices; l++) {  /// boucle sur tout les temps pour le calcul de la vitesse
l1=l+1;
l2=l-1;
if(l==numSlices-1) {
Cellvelocity[l]=xPosition[l]-xPosition[l2]; /// attention, ici les 2 derniers timepoints auront la m�me vitesse
} else {
Cellvelocity[l]=xPosition[l1]-xPosition[l];
}
}

/// lissage de la vitesse

lissage1 = (lissage/2)-0.5;
lissage2 = (lissage/2)+0.5;

for(l=0; l<numSlices; l++) {  /// boucle sur tout les temps pour le lissage de la vitesse
if(l<lissage2) {
velocity=Array.slice(Cellvelocity,0,l+lissage1);
} else {
if (l>numSlices-lissage2) {
velocity=Array.slice(Cellvelocity,l-lissage1,numSlices);
} else {
velocity=Array.slice(Cellvelocity,l-lissage1,l+lissage1);
}
}
taille=lengthOf(velocity);
time=newArray(taille);
for (i=0; i<taille; i++) {
time[i]=i;
}
Fit.doFit("Straight Line", time, velocity);
ordonnee=d2s(Fit.p(0),6);
pente=d2s(Fit.p(1),6);
Vitesselissee[l]=lissage1*pente+ordonnee;
}


/// calcul du nombre de changement direction

nbdirectionchanges=0;

signe=newArray(numSlices);

smoothvelo2=newArray(numSlices);
smoothvelo3=newArray(numSlices);


a = 10;
b = a+1;

for(k=0; k<numSlices; k++) { /// ici mean sur 20 timepoint
if(k<b) {
meanvelo1=Array.slice(Vitesselissee,0,k+a);
} else {
if (k>numSlices-b) {
meanvelo1=Array.slice(Vitesselissee,k-a,numSlices);
} else {
meanvelo1=Array.slice(Vitesselissee,k-a,k+a);
}
}
Array.getStatistics(meanvelo1, minmeanvelo, maxmeanvelo, meanmeanvelo, stdDevmeanvelo);
smoothvelo2[k]=meanmeanvelo;
}

for(k=0; k<numSlices; k++) {
smoothvelo3[k]=abs(smoothvelo2[k]);
}

for(k=0; k<numSlices; k++) {
if(smoothvelo2[k]==smoothvelo3[k]) {
signe[k]="positif";
} else {
signe[k]="negatif";
}
}

for(k=1; k<numSlices; k++) {
if(signe[k]!=signe[0]) {
nbdirectionchanges=nbdirectionchanges+1;
signe[0]=signe[k];
}
}


nbChgtDirect[image]=nbdirectionchanges;

/// realisation des masques de l'avant et de l'arriere

selectWindow(name1+"_masqueCell_centre.tif");
run("Duplicate...", "title=temp.tif duplicate range=1-numSlices");
selectWindow("temp.tif");
makeRectangle(0, 0, ww, h);
run("Clear Outside", "stack");
run("Select None");
rename(name1+"_masqueCell_centre_arriere.tif");

selectWindow(name1+"_masqueCell_centre.tif");
run("Duplicate...", "title=temp.tif duplicate range=1-numSlices");
selectWindow("temp.tif");
makeRectangle(ww, 0, ww, h);
run("Clear Outside", "stack");
run("Select None");
rename(name1+"_masqueCell_centre_avant.tif");


for(l=0; l<numSlices; l++) {  /// boucle sur tout les temps pour les mesures � l'avant et � l'arriere
l1=l+1;
selectWindow(name1+"_masqueCell_centre_avant.tif");  /// mesure sur l'avant
Stack.setSlice(l1);
run("Duplicate...", "title=temp1.tif");
run("Analyze Particles...", "size=100-Infinity pixel circularity=0.00-1.00 show=Nothing clear add");
actinCounts1=nResults;
actinindexes1= newArray(actinCounts1);
if(actinCounts1==0) {
selectWindow("temp1.tif");
run("Close");
} else {
for(p=0; p<actinCounts1 ; p++) {
actinindexes1[p] = p ;
}
if(actinCounts1==1) {
selectWindow(name1+"_centreA.tif");
Stack.setChannel(canalDistribution);
Stack.setSlice(l1);
roiManager("select", 0);
}
else {
selectWindow(name1+"_centreA.tif");
Stack.setChannel(canalDistribution);
Stack.setSlice(l1);
roiManager("select", actinindexes1);
roiManager("Combine");
}
getSelectionBounds(xxx1, yyy1, widthCell1, heightCell1);
FrontLength[l]=widthCell1;
run("Measure");
FrontMeanInt[l]= getResult("Mean",0)-bg;
FrontArea[l]= getResult("Area",0);
FrontTotInt[l]=FrontMeanInt[l]*FrontArea[l];
run("Clear Results");
///selectWindow("Results");
///run("Close");
selectWindow("temp1.tif");
run("Close");
///selectWindow("ROI Manager");
///run("Close");

if(l<(numSlices-1)) {
if(actinCounts1==1) {
selectWindow(name1+"_centreA.tif");
Stack.setChannel(canalDextran);
Stack.setSlice(l1);
roiManager("select", 0);
}
else {
selectWindow(name1+"_centreA.tif");
Stack.setChannel(canalDextran);
Stack.setSlice(l1);
roiManager("select", actinindexes1);
roiManager("Combine");
}
getSelectionBounds(xxx3, yyy3, widthCell3, heightCell3);
run("Measure");
meandext=getResult("Mean",0);
run("Clear Results");
selectWindow(name1+"_centreA.tif");
Stack.setChannel(canalDextran);
Stack.setSlice(l1);
makeRectangle(xxx3,yyy3+heightCell3,widthCell3,10);
run("Measure");
bgdext=getResult("Mean",0);
run("Clear Results");
selectWindow(name1+"_centreA.tif");
Stack.setChannel(canalDextran);
Stack.setSlice(l1);
makeRectangle(xxx3+widthCell3,yyy3+(heightCell3/4),10,(heightCell3/2));
run("Measure");
channeldext=getResult("Mean",0);
run("Clear Results");
macropinfractionvol[l]=(meandext-bgdext)/(channeldext-bgdext);
}

}

selectWindow(name1+"_masqueCell_centre_arriere.tif");
Stack.setSlice(l1);
run("Duplicate...", "title=temp1.tif");
run("Analyze Particles...", "size=100-Infinity pixel circularity=0.00-1.00 show=Nothing clear add");
actinCounts2=nResults;
actinindexes2= newArray(actinCounts2);
if(actinCounts2==0) {
selectWindow("temp1.tif");
run("Close");
} else {
for(p=0; p<actinCounts2 ; p++) {
actinindexes2[p] = p ;
}
if(actinCounts2==1) {
selectWindow(name1+"_centreA.tif");
Stack.setChannel(canalDistribution);
Stack.setSlice(l1);
roiManager("select", 0);
}
else {
selectWindow(name1+"_centreA.tif");
Stack.setChannel(canalDistribution);
Stack.setSlice(l1);
roiManager("select", actinindexes2);
roiManager("Combine");
}
getSelectionBounds(xxx2, yyy2, widthCell2, heightCell2);
BackLength[l]=widthCell2;
run("Measure");
BackMeanInt[l]= getResult("Mean",0)-bg;
BackArea[l]= getResult("Area",0);
BackTotInt[l]=BackMeanInt[l]*BackArea[l];
run("Clear Results");
///selectWindow("Results");
///run("Close");
selectWindow("temp1.tif");
run("Close");
///selectWindow("ROI Manager");
///run("Close");
}

RatioFrontBack[l]=(FrontMeanInt[l])/(BackMeanInt[l]);
}

/// fraction de temps � l'avant ou � l'arriere
timefront=0;
for(l=0; l<numSlices; l++) {  /// boucle sur tout les temps pour le calcul de la fraction de temps avant ou arriere
if(RatioFrontBack[l]>1) {
timefront=timefront+1;
}
}
timeback=numSlices-timefront;


/// fermeture des images
selectWindow(name1 +"_masqueCell_centre.tif");
saveAs("Tiff", dirDistrib + name1 +"_masqueCell_centree.tif");

selectWindow(name1+"_centreA.tif");
saveAs("Tiff", dirDistrib + name1+"_centreA.tif");


selectWindow(name1 +"_masqueCell_centre_avant.tif");
saveAs("Tiff", dirDistrib + name1 +"_masqueCell_centre_avant.tif");

selectWindow(name1 +"_masqueCell_centre_arriere.tif");
saveAs("Tiff", dirDistrib + name1 +"_masqueCell_centre_arriere.tif");


run("Close All");


for(l=0; l<numSlices; l++) {  /// boucle sur tout les temps pour l'affichage des resultats dans un fichier log
resultat1=newArray(16);
resultat1[0]=name1;
resultat1[1]=temps[l];
resultat1[2]=xPosition[l];
resultat1[3]=Cellvelocity[l];
resultat1[4]=Vitesselissee[l];
resultat1[5]=BackMeanInt[l];
resultat1[6]=FrontMeanInt[l];
resultat1[7]=bg;
resultat1[8]=RatioFrontBack[l];
resultat1[9]=FrontArea[l];
resultat1[10]=FrontLength[l];
resultat1[11]=BackArea[l];
resultat1[12]=BackLength[l];
resultat1[13]=FrontTotInt[l];
resultat1[14]=BackTotInt[l];
if(l<(numSlices-1)) {
resultat1[15]=macropinfractionvol[l];
} else {
resultat1[15]=NaN;	
}
Array.print(resultat1);
}



///calcul des moyennes et stdDev par cellules

Array.getStatistics(Vitesselissee, minvelo, maxvelo, meanvelo, stdDevvelo);
MeanVelo[image]=meanvelo;
StdDevVelo[image]=stdDevvelo;
Array.getStatistics(RatioFrontBack, minratio, maxratio, meanratio, stdDevratio);
MeanRatio[image]=meanratio;
StdDevRatio[image]=stdDevratio;

Array.getStatistics(FrontMeanInt, minFrontMeanInt, maxFrontMeanInt, meanFrontMeanInt, stdDevFrontMeanInt);
MeanCellFrontMeanInt[image]=meanFrontMeanInt;

Array.getStatistics(FrontTotInt, minFrontTotInt, maxFrontTotInt, meanFrontTotInt, stdDevFrontTotInt);
MeanCellFrontTotInt[image]=meanFrontTotInt;

Array.getStatistics(macropinfractionvol, minmacropinfractionvol, maxmacropinfractionvol, meanmacropinfractionvol, stdDevmacropinfractionvol);
Meanmacropinfractionvol[image]=meanmacropinfractionvol;

Array.getStatistics(FrontLength, minFrontLength, maxFrontLength, meanFrontLength, stdDevFrontLength);
Meanfrontlength[image]=meanFrontLength;

TimeFractionFront[image]=timefront/numSlices;
TimeFractionBack[image]=timeback/numSlices;



/// plot des vitesse et ratio en fonction du temps

NormVelo=newArray(numSlices);  /// normalisation pour le multiplot
for(l=0; l< numSlices; l++) {
NormVelo[l]=(Vitesselissee[l]/maxvelo)*2;
}

Plot.create("Normalized data graph"+name1+"", "time (sec)", "Fluorescent golgi area / Vesicles counts", temps, NormVelo);
Plot.setLimits(0, numSlices-1, 0, 2);
Plot.setColor("blue");
Plot.add("line", temps, RatioFrontBack);
Plot.setColor("red");
Plot.show();

//selectWindow("Normalized data graph"+name1+"");
//saveAs("Tiff", dirDistrib + "Normalized data graph"+name1+".tif");
run("Close All");

 
}  /// fin de la boucle sur toutes les images

selectWindow("Log");
run("Text...", "save=["+ dirDistrib + "Results_all_timepoint.txt]");
//run("Text...", "save=["+ dirDistrib + "Results_all_timepoint.xls]");

run("Close");

/// affichage des stats moyennes
Moyenne=newArray("Cell name", "mean velo", "StdDev velo", "mean ratio", "StdDev ratio", "% of time front", "% of time back", "nb chgt direction", "mean(time) mean front int", "mean(time) tot front int", "mean macropin vol fraction","Mean front length");
Array.print(Moyenne);
for(image=0; image<nbimages; image++) {
Moyenne1=newArray(12);
Moyenne1[0]=imagenames[image];
Moyenne1[1]=MeanVelo[image];
Moyenne1[2]=StdDevVelo[image];
Moyenne1[3]=MeanRatio[image];
Moyenne1[4]=StdDevRatio[image];
Moyenne1[5]=TimeFractionFront[image];²
Moyenne1[6]=TimeFractionBack[image];
Moyenne1[7]=nbChgtDirect[image];
Moyenne1[8]=MeanCellFrontMeanInt[image];
Moyenne1[9]=MeanCellFrontTotInt[image];
Moyenne1[10]=Meanmacropinfractionvol[image];
Moyenne1[11]=Meanfrontlength[image];
Array.print(Moyenne1);
}

selectWindow("Log");
run("Text...", "save=["+ dirDistrib + "Parametres_Moyens.txt]");
run("Close");

/// realisation du stack avec tout les graphs


for(image=0; image<nbimages; image++) {
name=imagenames[image];   /// ici prends le nom des images dans le dossier dirDistribdata dans l'ordre de la boucle
totnamelength=lengthOf(name); /// enleve l'extension a name
namelength=totnamelength-4;   /// exemple ici, on enleve les 4 derniers caracteres
name1=substring(name, 0, namelength);  /// name1==name sans le .tif
//open(dirDistrib+"Normalized data graph"+name1+".tif");
}
}
//run("Images to Stack", "method=[Scale (largest)] name=Stack title=[] bicubic use");
//selectWindow("Stack");
//saveAs("Tiff", dir + "Graphs.tif");
run("Close");

setBatchMode(false);

selectWindow("Results");
run("Close");
