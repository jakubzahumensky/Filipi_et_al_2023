setBatchMode(true);
	
Dialog.create("Measure network - input parameters");
	Dialog.addDirectory("Directory:", "");
	Dialog.addString("Extension:", "oif");
	Dialog.addNumber("Channel:", 2);
	Dialog.addString("No. of brightest slices:", "20");
	Dialog.show();
	data_dir = Dialog.getString();
	ext = Dialog.getString();
	channel = Dialog.getNumber();
	number_of_slices = Dialog.getString();			  

var title = "";

analysis_dir = create_analysis_dir(data_dir);
print_header();
processFolder(data_dir);
wrap_up();


function print_header(){
	print("image" + "," + "volume_fraction");
}


function create_analysis_dir(dir){
	analysis_dir = File.getParent(dir) + "/analysis/";
	if (!File.exists(analysis_dir))
		File.makeDirectory(analysis_dir);
	return analysis_dir;
}


function processFolder(dir){
	list = getFileList(dir);
	for (i = 0; i < list.length; i++){
		showProgress(i + 1, list.length);
		if (endsWith(list[i], "/"))
			processFolder("" + dir + list[i]);
		else {
			file = dir + list[i];
			if (endsWith(file, "." + ext))
				processFile(file);
		}
	}
}


function processFile(file_path){
	title_dup = prepare_image(file_path);
	extract_brightest_slices(title_dup);
	create_masks(file_path);
	measure_volume_fraction();
	save_results();
	run("Close All");
}


function prepare_image(path){
	run("Bio-Formats Windowless Importer", "open=[" + path + "]");
	title = getTitle();
	run("Duplicate...", "duplicate channels=" + channel);
	title_dup = getTitle();
	close(title);
	return title_dup;
}


function extract_brightest_slices(img_title){
	getDimensions(width, height, channels, slices, frames);
//measure mean intensity of each slice and sort results by mean, in ascending order; extract N brightest images
	run("Clear Results");
	run("Set Measurements...", "mean redirect=None decimal=3");
	run("Measure Stack...");
	Table.sort("Mean");
	for (i = nResults - number_of_slices; i < nResults; i++){
		selectWindow(img_title);
		slice_id = getResult("Slice", i);
		Stack.setSlice(slice_id);
		run("Duplicate...", "use");
	}
	close(img_title);
}


function create_masks(path){
	n = nImages;
	for (i = 1; i <= n; i++){
		selectImage(i);
		run("Despeckle");
		run("Enhance Local Contrast (CLAHE)", "blocksize=32 histogram=256 maximum=3 mask=*None*");
		run("Subtract Background...", "rolling=12 disable");
		getStatistics(area, mean, min, max, std, histogram);
		setThreshold((min + max)/3, 65535);
		run("Convert to Mask");
		run("Despeckle");
	}
	run("Images to Stack", "name=Stack title=[] use");
	saveAs("TIFF", analysis_dir + title + "-mask_stack");
}


function measure_volume_fraction(){
	run("Set Measurements...", "area_fraction redirect=None decimal=3");
	run("Clear Results");
	run("Measure Stack...");
	run("Summarize");
	volume_fraction = getResult("%Area", number_of_slices);
	print(title + "," + volume_fraction);
}


function save_results(){
	selectWindow("Log");
	saveAs("Text", analysis_dir + "Summary-volume_fraction.csv");
}


function wrap_up(){
	close("Results");
	close("Log");
	waitForUser("Finito!");
}

setBatchMode(false);
