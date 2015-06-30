ARNColoc
========

### Tools for spots colocalisation and quantification

ARNColoc is a software suite written in matlab for RNA colocalisation, quantification and transcription site detection. ARNColoc also provide a tool (**shift**) for pixel shift detection.

The following tutorial describe step by step the use of ARNColoc to perform RNA quantification.

* * *

### Shift
 Fluorescence microscopy imaging is usually performed by sequentially acquiring image through different channels and merging them. However, deviation in the light beam of the emission filters can cause the pixels in each channel to be out of alignment, as seen in the following picture. This is called pixel shift.  
  
  ![pixel shift](https://cloud.githubusercontent.com/assets/5290110/8384565/de037280-1c0f-11e5-9476-195405faa015.jpg)
  
 **Shift** is a script that attempt to correct pixel shift based on reference image for each channel (cy5, cy3 and cy3.5). The algorithm behind is really simple and might be upgraded soon. 
  
   ![Shift interface](https://cloud.githubusercontent.com/assets/5290110/8384572/de0fc13e-1c0f-11e5-86a1-e584d03991ae.png)  

   * #### Input  
    The only input files are loc files. Loc files are the usual output of spot detection programs (Airlocalize for 3D, Localize for 2D) and contains each spot coordinates and its intensity. In order to use **Shift** you need to perform spot detection using high resolution reference image obtained for each channel.
          
   * #### Running
    Move to the directory containing the script and execute the **Shift.m** script (just type **Shift** in your matlab interpreter). The graphical interface should appear.

    1. Use the browse button to upload your file for each channel (in red)
    2. Use the channel marker to select the corresponding channel for each loc file (in blue)
    3. Select you input type. Use 2D for a 2D loc file from localize and 3D for 3D loc file from Airlocalize.  
    4. Choose the file you want to correct from your two input file. The other channel will be used as reference for the pixel shift detection (in green).
    <p> <img src="https://cloud.githubusercontent.com/assets/5290110/8384573/de124b98-1c0f-11e5-979c-4ea79d7a039d.png" /></p>
    5. Use the distance slider to set a limit on shfit between pixel. This is useful for pixel pairing when spots are found in one file and not the other. 
    <p> <img src="https://cloud.githubusercontent.com/assets/5290110/8384570/de08d46e-1c0f-11e5-979d-c368ada63cc7.png" /></p>  
  
    6. Click on the "OK" button !
        
    A **.shift** file containing informations about the pixel shift will be saved in your folder. This file can be used in ARNColoc to correct for pixel shifting in order to provide more accurate results.
        
* * *

### ARNColoc  

ARNColoc is the main script for RNA quantification.  
   * #### Input  
     * Segmentation file (nucleus mask)

        ![mask file](example/input/mask_for_display.png)
        
     * At least 2 loc files ([mrna](example/input/mRNA.loc), [erna_1](example/input/s_eRNA.loc) or [erna_2](example/input/as_eRNA.loc))

  
   * #### Run
    Execute the **ARNColoc** script in matlab by typing **ARNColoc** in you matlab interpreter. You might need to move to the directory containing the script ot set it as your matlab home directory.  
   
    1. Load your segmented image (nucleus mask). You can obtained a segmented image by manually circling the dapi signal in ImageJ or using an automatic segmentation tool like CellProfiler. You image will be displayed on  *the intensity_plot frame*.
    <p> <img src="https://cloud.githubusercontent.com/assets/5290110/8384563/ddfcfed2-1c0f-11e5-99f0-451ffdb14857.png" /></p>
    2. Load each of your loc files using the browse button and select the corresponding channel of acquisition. ARNColoc use cyanine dyes as label for color channels. For each loc file, the intensity distribution of the spot will be displayed on the *intensity_prot frame*.
    <p> <img src="https://cloud.githubusercontent.com/assets/5290110/8384564/ddfd6804-1c0f-11e5-94d4-5f86b83dc7b2.png" /></p> 
    3. **[Optional]** Set the transcription site coefficient (**_tc_**). This value will be use to define transcription sites. A spot will be considered as transcription site if :
    <div align="center">Intensity<sub>spot</sub> > Intensity<sub>single</sub> x <em><strong>tc</strong></em></div>
The default value is 1.5
    4. **[Optional]** Set the intensity threshold to discard any spot with intensity lower than your threshold. This is useful when you suspect that there are a lot of noise in your loc file. The intensity distribution shown when loading each loc file should be helpful in setting a threshold. Keep in mind that this threshold will be applied to all your input file.
    5. **[Optional]** Set the pixel size (in nm). You can obtain this value from your microscope specs. In case of rectangular pixel, enter the average value of of the length and width provided by the specs.
    6. **[Optional]** If you need to correct for pixel shifting, check  **"Pixel shift"**, upload you shift files (see [Shift](#shift)) and select the reference for the pixel shift correction (**"Shift Ref"**). Two analyses will be performed. One with your input files and another with the corrected version.
    <p> <img src="https://cloud.githubusercontent.com/assets/5290110/8384567/de050c94-1c0f-11e5-87a4-499b00dbb55a.png" /></p>
    7. If you have intronic signal (single mRNA are mostly expected to be found out of the nuclei), check **"Intron signal"**
    8. Check **"Label Nucleus"** to label each nucleus by a number.
    9. Press **OK**.
  
    You will be asked to provided a colocalization radius (in nm) between spot from each pair of RNA type. o perform colocalisation, a RNA type will be used as reference. Use the slider to select a radius you deem appropriate. Spots will only colocalize in this radius. Press OK when you're done.
    <p> <img src="https://cloud.githubusercontent.com/assets/5290110/8384566/de0497d2-1c0f-11e5-9674-f898d9469179.png" /></p>
  
    After that you will be asked to select a method to compute single spot intensity for each eRNA file (sense vs anti-sense). Three methods are proposed. **(1)** mean intensity of every spot, **(2)** A 2-means intensity clustering and a **(3)** 3-means intensity clustering. 2-means clustering use a k-means clustering with 2 centroids to assign your spot in two clusters based on their intensity. The mean intensity of the cluster with the lower intensities will be used as single eRNA intensity. 3-means clustering use the cluster with intermediate intensities to comptute single eRNA intensity. Depending on you data the 3-means clustering will sometimes give inapropriate high values. Please use the intensity distribution shown to decide which method suit you data best. You should verify where the single eRNA intensity computed by each method fit in the distribution and see if that make sense. 
  
    **Enter the chosen method number (1, 2 or 3) and press OK**.
    <p> <img src="https://cloud.githubusercontent.com/assets/5290110/8384569/de065c70-1c0f-11e5-9a44-e9f7153959ae.png" /></p>

    Some steps could be repeated for each RNA type. Please check each dialog box title to avoid being confused.
  
    **Output file can be found in the folder from which you execute ARNColoc**
    
    * ##### Output
    
     *  mrna.locx file : Custom loc file containing information about mRNA transcription site that colocalize either with s_erna or as_erna (last two columns add the number of nascent RNA per spot and which nucleus is the spot found in)
     * s\_erna.locx and as_erna.locx : Custom loc file about s\_eRNA or as_eRNA that colocalize with mRNA transcription site. 
     * trans.locx : Custom file with informations about each transcription site. I plan to use this file later to diplay transcription site on ImageJ / Imaris
     * Trans\_with\_s\_erna_.txt : A tsv file containing transcription file that colocalize with sense eRNA spots. 
     * Trans\_with\_as\_erna.txt :  A tsv file containing transcription file that colocalize with anti-sense eRNA spots. 
     * Trans\_without\_erna.txt :  A tsv file containing transcription file that do not colocalize with any eRNA spots. 
     * Trans\_coloc\_analysis.txt : A tsv file containing detailled information for each nucleus about transcription site colocalisation
     * spot\_coloc\_analysis.txt : A tsv file containing detailled information for each nucleus about spot colocalisation
     * Corr\* files :  outputs for after correcting for pixel shift.
     * An output image with each nucleus labeled for easy recognition (mRNA spot are marked as red spots, s\_eRNA as blue spots and as_eRNA as green spots)
     ![final label](https://cloud.githubusercontent.com/assets/5290110/8384638/662cea60-1c10-11e5-8311-f53dbb09a850.png)





