dirsave = getDirectory("Choisir le dossier de sauvegarde des positions");
nbrposition=20;
setBatchMode(true);
	for(k=11;k<=nbrposition; k++) { /// pour toutes les positions
	//	E:\tiffs_lucie
				run("Bio-Formats", "open=E:\\E\\Films\\170720_LA_CPLA2i\\Raw\\170720_LA_CPLAi4_w10BF_s1_t1.TIF autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_"+k);
		//run("Bio-Formats", "open=E:\\E\\Films\\170516_LADeltaP\\Manip2\\170516_DP0_3_w10BF_s1_t1.TIF autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_"+k);
		saveAs("Tiff", dirsave + "pos"+k+".tif");
		run("Close");
}
setBatchMode(false);