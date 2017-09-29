# cellmigration

From cells cropped from a movie, make a mean cell that is the mean of all the cells at all timepoints, for all the conditions of an experiment. 

## Installation
Make sure you have [Fiji](https://imagej.net/Fiji/Downloads) installed (works better with the 2105 December 22 release)

git clone it

## Testing with sample image

### Routine
In the macros, "dossier PRINCIPAL" refers to the The main folder of the experiment
Put the cells of each condition in a subfolder named "Condition"


*Example:*
For an experiment whith 3 drug concentrations and a control, there should be 4 subfolders : control, conc1, conc2, con3. 

BaseNameTab is an array with the names of all the condition of the experiment. 
Everytime you use a new macro, rename BaseNameTab with the names of the conditions of the experiment (name of the folders).
Example : BaseNameTab=newArray("control","conc1","conc2");

Some macro that do not loop on the conditions, in that case BaseName is equivalent to BaseNameTab
Ex: Basename= "control";


### Make the masks of the cells.
Load macro 1aMDLP_MakeMask_Nucl_Cel with Fiji
If you have a good signal, **Triangle** for GFP (channel 1) and **Yen** for DAPI (channel 2) are well suited.

If the masks do not correspond to the shapes of the cell and/or nucleus, you can test  which threshold method is better suited with 5aMDLPtest_seuillage_batch. Just change BaseName whith the name of your condition.

It will create folders Condition_Masks
The masks of the cells will be saved in Condition_Masks


### Flip images and Masks
Load macro 2aMDLP_Flip_ImageAndMask.ijm 

(if the images have only 1 channel : 2aMDLP_Flip_ImageAndMask_1channel.ijm)


It will create folders Condition_Flip

The flipped cells will be saved in Condition_Flip

Similarly, the flipped masks will be saved in Condition_MasksFlip

### Generate the mean cell
Load macro 3MDLPmeancell.ijm

It will create folders Condition_Mapping
The mean cell will be saved int the main folder. A stack of the mean cells (normalized in size) called cellulemoyenne.tif will be saved in _Mapping







