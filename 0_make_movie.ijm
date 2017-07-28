
nbrposition=10;


dir = getDirectory("Choose the experiment MAIN folder");
imageDir = dir + "Raw\\";
dircomposite=dir+"Composites\\";
File.makeDirectory(dircomposite); 
//channel=newArray("w1GFP", "w2DAPI");  //Video Curie
channel=newArray("w11GFP", "w21Dapi"); //Video IPGG
nbchan=lengthOf(channel);
//basename= "151217_cnx40_Y27";
basename= "170727_LA_test_activation";
fileList = getFileList(imageDir); 
numberSlice=fileList.length;
//filename = imageDir+basename+"_w1GFP_s1_t1.TIF";   //Video Curie
filename = imageDir+basename+"_w11GFP_s1_t1.TIF";   //Video IPGG

setBatchMode(true);
	for(k=1;k<=nbrposition; k++) { /// pour toutes les positions
		print(k);
	//	E:\tiffs_lucie
			//	run("Image Sequence...", "open=filename number=numberSlice starting=1 increment=1 scale=100 file=["+basename+"_"+channel[chan]+"_s"+s+"_t] sort");  
				run("Bio-Formats","open=filename number=numberSlice starting=1 increment=1 autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_"+k);

			//	run("Bio-Formats", "open=E:\\E\\Films\\170720_LA_CPLA2i\\Raw\\170720_LA_CPLAi4_w10BF_s1_t1.TIF autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_"+k);
		//run("Bio-Formats", "open=E:\\E\\Films\\170516_LADeltaP\\Manip2\\170516_DP0_3_w10BF_s1_t1.TIF autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_"+k);
		saveAs("Tiff", dircomposite + "pos"+k+".tif");
		run("Close");
}
setBatchMode(false);