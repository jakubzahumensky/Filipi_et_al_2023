# FIJI macro for automated assessment of fibre volume in a 3D image

## Motivation
I was approached by [Jana Turečková](https://www.iem.cas.cz/en/contacts/jana-tureckova-en/) from the [Dept. of Cellular Neurophysiology, IEM, CAS](https://www.iem.cas.cz/en/department/department-of-cellular-neurophysiology/) if I could develop a tool for the analysis of the ratio of volume in a 3D sample image taken up by neural fibres for [their study](https://doi.org/10.1038/s41598-023-33608-y).

## Macro steps
The macro takes the path for folder with data, creates segmentation masks and quantifies the volume of fibres relative to the total volume (of 3D image). The masks and quantification results are written out into “analysis” folder that is created on the same level as the data folder.

1. The specified number of brightest slices are extracted from the image
2. They are segmented and converted to masks, and saved
3. The area fraction taken up by fibres is quantified in each slice
4. These numbers are then averaged across the stack
    - This is equivalent to summing all areas from individual  slices and dividing them with the total area of all slices in the stack.
5. Results are saved in a csv table

## Macro usage
1. Open Fiji
2. Load macro in Fiji (drag-and-drop/ file → open) and run it
3. When prompted, input:
    - path to data folder, image file extension, channel to be analyzed, and how many brightest slices are to be extracted from each image stack for analysis
4. Press “OK”

*Note: the macro is time-consuming  due to the amount of slices and processing involved*

## Citation
**Filipi et al. 2023 - Cortical glia in SOD1(G93A) mice are subtly affected by ALS-like pathology**\
*Scientific Reports* 13(1):6538, doi: [10.1038/s41598-023-33608-y](https://doi.org/10.1038/s41598-023-33608-y)
