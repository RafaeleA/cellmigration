# cellmigration
## Installation
Make sure you have Fiji installed [https://imagej.net/Fiji/Downloads] (works better with the 2105 December 22 release)

git clone it

## Testing with sample image

### Routine
The main folder (named dossier PRINCIPAL in the macros) should contain several as many folders that there are conditions in the experiments, with the corresponding cells in those folders.
BaseNameTab if an array with the names of all the condition of the experiment. 
Everytime you use a new macro, rename BaseNameTab with the name of the condition of the experiment (name of the folder).
Example : Yen

In some macro that does not loop on all the conditions names, BaseName is a variable equivalent to BaseNameTab, for just 1 condition. 

### Make the masks of the cells.
Load macro 1aMDLP_MakeMask_Nucl_Cel with Fiji
If you have a good signal, **Triangle** for GFP (channel 1) and **Yen** for DAPI (channel 2) are well suited.

If the masks do not correspond to the shapes of the cell and/or nucleus, you can test  which threshold method is better suited with 5aMDLPtest_seuillage_batch. Just change BaseName whith the name of your condition)

It will create folders Yen_Masks
The masks of the cells will be saved in Yen_Masks


### Flip images and Masks
Load macro 2aMDLP_Flip_ImageAndMask.ijm 

(if the images have only 1 channel : 2aMDLP_Flip_ImageAndMask_1channel.ijm)


It will create folders Yen_Flip

The flipped cells will be saved in Yen_Flip

Similarly, the flipped masks will be saved in Yen_MasksFlip

### Generate the mean cell
Load macro 3MDLPmeancell.ijm

It will create folders Yen_Mapping
The mean cell will be saved int the main folder. A stack of the mean cells (normalized in size) called cellulemoyenne.tif will be saved in _Mapping







