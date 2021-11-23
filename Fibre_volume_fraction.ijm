setBatchMode(true);
   dir = getDirectory("Choose a Directory");   
   Dialog.create("Measure network - input parameters");
   //Dialog.addString("Source folder:", "");
   Dialog.addString("Ext:", "oif");
   Dialog.addString("No. of brightest images:", "20");
   Dialog.show();
   //dir = Dialog.getString();
   ext = Dialog.getString();
   N = Dialog.getString();           
   
// calling function called “processFolder”
print("image"+"\t"+"volume_fraction");
processFolder(dir);

// definition of "processFolder" function
function processFolder(dir) {
  
   list = getFileList(dir);
   for (i=0; i<list.length; i++) {
      showProgress(i+1, list.length);
      if (endsWith(list[i], "/"))
         processFolder(""+dir+list[i]);
      else {
		 q = dir+list[i];
         processFile(q);
      }
   }
}

// definition of "processFile" function
function processFile(q) {
        if (endsWith(q, "."+ext)) {
        	run("Bio-Formats Windowless Importer", "open=[" + q + "]");
			title=getTitle();
		//preparatory operations, extraction of channel 2 for analysis
			run("Duplicate...", "duplicate channels=2");
			title_dup=getTitle();
			close(title);
			getDimensions( width, height, channels, slices, frames );
		//measure mean intensity of each slice and sort results by mean, in ascending order; extract N brightest images
			run("Clear Results");
			run("Set Measurements...", "mean redirect=None decimal=3");
			run("Measure Stack...");
			Table.sort("Mean");
			for (l = nResults-N; l < nResults; l++) {
				selectWindow(title_dup);
				j=getResult("Slice",l);
				Stack.setSlice( j );
				run("Duplicate...", "use");
			}
			close(title_dup);
		//cycle through extracted images and modify local contrast, subtract background, create mask
			y=nImages;
			for (k=1; k<=y; k++) {
				selectImage(k);
				run("Despeckle");
				run("Enhance Local Contrast (CLAHE)", "blocksize=32 histogram=256 maximum=3 mask=*None*");
				run("Subtract Background...", "rolling=12 disable");
				run("Clear Results");
				run("Set Measurements...", "min redirect=None decimal=3");
				run("Measure");
				MIN=getResult("Min",0);
				MAX=getResult("Max",0);
				setThreshold((MIN+MAX)/3, 65535);
				run("Convert to Mask");
				run("Despeckle");
			}
			run("Images to Stack", "name=Stack title=[] use");
			saveAs("TIFF",q+"-mask_stack");
			run("Set Measurements...", "area_fraction redirect=None decimal=3");
			run("Clear Results");
			run("Measure Stack...");
			run("Summarize");
			vol_fraction=getResult("%Area",N);
			print(title+"\t"+vol_fraction);
			run("Close All");
			selectWindow("Log");
		    saveAs("Text", dir+"Summary-volume_fraction"+".tsv");
        }
}

//saving analysis results in directory from which macro was run
selectWindow("Log");
saveAs("Text", dir+"Summary-volume_fraction"+".tsv");
close("Results");
close("Log");
setBatchMode(false);
waitForUser("Finito!");