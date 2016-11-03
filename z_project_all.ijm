// z_project_all.ijm
// 
// version 2.0.0
//
// OVERVIEW:
//
// This script Z-projects all .dv image files (excluding _REF.dv image files) in a 
// directory called input. The Z-projected files are saved as tif images in 
// the directory called output. The script will process images that end with .dv
// but not REF.dv
//
// USER INPUTS REQUIRED:
//
// User must specify the input and output directories for image files. OPTIONAL: If 
// deconvolved_only parameter is set to true, then script will only process images
// whose file names end with R3D_D3D.dv
//
// TECHNICAL DETAILS:
//
// Loops through the list of files in input directory. If filename meets criteria set, then
// opens image using the Bio-Formats Windowless Importer tool as a composite virtual stack.
// Applies a maximum intensity z-projection to the image. For a time series, each frame is
// projected individually. Saves as uncompressed .tif file in output directory with same
// filename, except with the appended ending _zproj.tif and clears memory after saving file.

// User-specified parameters
input = "/Users/myname/Documents/inputfiles";
output = "/Users/myname/Documents/outputfiles";
deconvolved_only = true;

// Prevents execution of the script if input and output directories are the same
if (input == output) {
	exit("ERROR!\nInput and output directories must be different.");
}

// z_project function takes as inputs:
// input = the directory containing unprocessed images
// output = the directory where processed images should be saved
// filename = the name of the file to be z-projected
// for the output file, appends _zproj to file name
function z_project(input, output, filename) {
	run("Bio-Formats Windowless Importer", "open="+input+"/"+filename+" color_mode=Composite view=Hyperstack stack_order=XYCZT use_virtual_stack");
	run("Z Project...", "projection=[Max Intensity] all");
	filenamelength = lengthOf(filename);
	filenamenoextension = substring(filename, 0, filenamelength - 3); // removes the .dv from filename
	saveAs("Tiff", output + "/" + filenamenoextension + "_zproj");
	run("Close All"); // This command is critical because it also clears memory!
}

// loops through files in the directory
// applies the z_project function to each file

// RUNS THIS BLOCK IF deconvolved_only = true
if (deconvolved_only == true) {
	list = getFileList(input);
	for (i = 0; i < list.length; i++) {
		currentfilename = list[i];
		if (endsWith(currentfilename, "R3D_D3D.dv")) {
			print("Now Processing: " + currentfilename);
			z_project(input, output, currentfilename);
		}
	}
}

// RUNS THIS BLOCK IF deconvolved_only = false
else {
	list = getFileList(input);
	for (i = 0; i < list.length; i++) {
		currentfilename = list[i];
		if (endsWith(currentfilename, ".dv")) {
			if (! endsWith(currentfilename, "REF.dv")) {
				print("Now Processing: " + currentfilename);
				z_project(input, output, currentfilename);
			}
		}
	}
}