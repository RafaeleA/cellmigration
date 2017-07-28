/// macro cellule moyenne, marche apres avoir extrait des cellules dans un dossier et avoir supprimer l'image Montage.tif du dossier
//=newArray("30_WT","30_KO","40_WT","40_KO");
BaseNameTab=newArray("0_B","0_S");
//"0_B",
//BaseNameTab=newArray("Yen");
//BaseNameTab=newArray("1","2","3","0bis");BaseNameTab=newArray("1");
filterSize=40; // taille minimum detectee par le analyse particle

canalMapping=newArray(1,2);
canalNames=newArray("Actin","Nucl");
//canalNames=newArray("Actin", "Actin");
setBatchMode(true);
dirselect = getDirectory("Choisir le dossier GENERAL de la manip");
iBaseName=newArray(1,2);
for(iname=0;iname<lengthOf(BaseNameTab);iname++) {
	BaseName=BaseNameTab[iname];
	//print(BaseName);

	dirdata = dirselect  + BaseName + "\\"; // dossier contenant les cellules pour l'analyse et le mapping
	//print("dirdata = "+dirdata);
	dirMask = dirselect + BaseName + "_Mask\\";
	dirFlip = dirselect + BaseName + "_Flip\\";
	dirMaskFlip = dirselect + BaseName + "_MaskFlip\\";//print("dirFlip = "+dirFlip);
	dirMapping = dirselect + BaseName + "_Mapping\\";
	//print("dirFlip = "+dirMapping);
	File.makeDirectory(dirMapping); 
	
	
	imagename_desktop=getFileList(dirdata); /// tableau contenant le nom des fichier contenus dans le dossier dirdata
	imagenames=imagename_desktop;
	for (i = 0; i<lengthOf(imagename_desktop); i++) {
	
		if(imagename_desktop[i] == "desktop.ini") {
			imagenames=Array.trim(imagename_desktop, i);
		}
	}
	
	
	nbimages=lengthOf(imagenames); /// longueur du tableau == nombre de fichier dans le dossier
	
		for (canal = 0;canal<lengthOf(canalMapping);canal++) {  // boucle sur les canaux (GFP, Dapi etc)
		print("canal", canal);
			for (image = 0; image<nbimages; image++) { // boucle sur les images contenues dans dirdata
		
				name=imagenames[image];  // ici prend le nom des images dans le dossier dirdata dans l'ordre de la boucle
				totnamelength=lengthOf(name); // enleve l'extension a name
				namelength=totnamelength-4;  // exemple ici, on enleve les 4 derniers caracteres
				name1=substring(name, 0, namelength);  // name1==name sans le .tif
				
				if (endsWith(name,".tif")==true) {
					open(dirFlip+name);
					selectWindow(name);
					Stack.getDimensions(w, h, chan, numSlices, frames);  /// prends les proprietes du stack
					
					if (frames>numSlices) {   /// ici la macro marche avec les differents temps = slices et non frames
						Stack.setDimensions(chan, frames, numSlices);   /// inverse si les stacks sont en frames et non en slices
						Stack.getDimensions(w, h, chan, numSlices, frames);   /// inverse si les stacks sont en frames et non en slices
					}
					open(dirMaskFlip + name1+"_masqueCell.tif");
			
					selectWindow(name);
					Stack.setPosition(canalMapping[canal], 1, 1); /// ici mesure le background sur la premiere slice (au temps 0) du canal a mapper
					run("Select All");
					run("Measure");
					bg=getResult("Median", 0);  /// ici l'intensite medianne est consideree comme etant le background
					run("Clear Results");
		
					for (l=0; l<numSlices; l++) {    /// boucle sur tout les temps du stack
						l1=l+1; /// l1 sert a faire correspondre le temps 0 a la slice 1  (les tableaux vont de 0 a nombredetimepoint-1, alors que les slices vont de 1 a nombredetimepoint)
						selectWindow(name1+"_masqueCell.tif");
						setSlice(l1);    /// choisit le bon temps dans le stack
						run("Duplicate...", "title=temp1.tif");		
						run("Analyze Particles...", "size="+filterSize+"-Infinity circularity=0.00-1.00 show=Nothing include clear add slice");
		  			 /// detecte la ou les ROIs correspondant a la cellule au temps l
						cellCounts=nResults;
		 			 /// permet de savoir combien de parties comporte le masque
						cellindexes= newArray(cellCounts);   /// tableau necessaire pour faire le combine dans ROI manager si masque en plusieurs parties
				
						if (cellCounts==0) {
							selectWindow("temp1.tif");
							run("Close");				/// a completer pour securite si rien n'est detecte, ne doit pas arriver si les cellules sont decoupees correctement
						} else {
							for (p = 0; p<cellCounts ; p++) {
								cellindexes[p] = p ;
		 			   /// tableau necessaire pour faire le combine dans ROI manager si masque en plusieurs parties
							}
					   }
				   
					   if (cellCounts == 1) {
				 	  		selectWindow(name);
				 	  		Stack.setPosition(canalMapping[canal], l1, 1);  /// se positionne sur le canal a mapper pour pouvoir dupliquer la cellule au temps l
				  	 		roiManager("select", 0);
					   } else {  
					/// se positionne sur le canal a mapper pour pouvoir dupliquer la cellule au temps l
							selectWindow(name);
							Stack.setPosition(canalMapping[canal], l1, 1);
		 		 	   	roiManager("select", cellindexes);
							roiManager("Combine");
					  }
				
					if (chan>1) {  
					/// duplique la cellule
						run("Duplicate...", "title=sumCrop"+l+".tif duplicate channels="+canalMapping[canal]+" slices="+l1+"");   
					}
				
					if (chan==1) {
						run("Duplicate...", "title=sumCrop"+l+".tif");  /// duplique la cellule
					}
					selectWindow("temp1.tif");
					run("Close");
				///selectWindow("ROI Manager");
				///run("Close");
					}
				} /// fin de la boucle sur tous les temps
		  		 
		
				selectWindow(name1 +"_masqueCell.tif");
				run("Close");
				selectWindow(name);
				run("Close");
		
				run("Images to Stack", "method=[Scale (smallest)] name=Stack title=[] bicubic use");
				run("Z Project...", "start=1 stop="+numSlices+" projection=[Average Intensity]");
				selectWindow("AVG_Stack");
				run("Subtract...", "value="+bg+" stack");
				saveAs("Tiff", dirMapping + name1+"moyenne_"+canalNames[canal]+".tif");
				selectWindow("Stack");
				run("Subtract...", "value="+bg+" stack");
				saveAs("Tiff", dirMapping + name1+"resize_"+canalNames[canal]+".tif");
				run("Close");
				selectWindow(name1+"moyenne_"+canalNames[canal]+".tif");
				run("Close");
		
			}
		
		
			// normalisation des cellules moyennes par les intensitees et resize
		
			height1 = newArray(nbimages);
			width1 = newArray(nbimages);
			meanactinfluo = newArray(nbimages);
			
			for (ii = 0; ii<nbimages; ii++) {
			
				name=imagenames[ii];
				totnamelength=lengthOf(name); // enleve l'extension a name
				namelength=totnamelength-4;
				
				name1=substring(name, 0, namelength);
				
				if (name! = "desktop.ini") {
					open(dirMapping+name1+"moyenne_"+canalNames[canal]+".tif");
					height1[ii]=getHeight();
					width1[ii]=getWidth();
					run("Select All");
					run("Measure");
					meanactinfluo[ii] = getResult("Mean",0);
					run("Clear Results");
					//selectWindow(name1+"moyenne.tif");
					//run("Close");
			    }	
			}
			
			
			Array.getStatistics(height1, minheight1, maxheight1, meanheight1, stdDevheight1);
			Array.getStatistics(width1, minwidth1, maxwidth1, meanwidth1, stdDevwidth1);
			Array.getStatistics(meanactinfluo, minMean, maxMean, meanMean, stdDevMean);
			
			for(iii=0; iii<nbimages; iii++) {
				
				name=imagenames[iii];
				totnamelength=lengthOf(name); /// enleve l'extension a name
				namelength=totnamelength-4;
				name1=substring(name, 0, namelength);
			
				
				selectWindow(name1+"moyenne_"+canalNames[canal]+".tif");
				normFactor=meanMean / meanactinfluo[iii] ;
				run("Multiply...", "value="+normFactor);
				run("Size...", "width="+meanwidth1+" height="+meanheight1+" average interpolation=Bilinear");
					
			}
			
			
			run("Images to Stack", "method=[Scale (smallest)] name=Stack title=[] bicubic use");
			saveAs("Tiff", dirMapping + "cellulemoyenne_"+canalNames[canal]+".tif");
				
			selectWindow("cellulemoyenne_"+canalNames[canal]+".tif");
			run("Z Project...", "start=1 stop="+numSlices+" projection=[Average Intensity]");
				selectWindow("AVG_cellulemoyenne_"+canalNames[canal]+".tif");
			
			if (canal==0) {
				
				selectWindow("AVG_cellulemoyenne_"+canalNames[canal]+".tif");
				selectWindow("AVG_cellulemoyenne_"+canalNames[canal]+".tif");
				run("physics");
				saveAs("Tiff", dirselect + BaseName + canalNames[canal] + "moy.tif");
				
			run("Close");
			
			}
		}

}

setBatchMode(false);