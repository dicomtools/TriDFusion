
<div align="center">
  <h1>TriDFusion (3DF) Image Viewer</h1>
  <p><strong>The TriDFusion (3DF) Image Viewer</strong> is Multi-Fusion Image Viewer for research provided by <a href="https://daniellafontaine.com/">Daniel Lafontaine,</a></p><p>published by <a href="https://ejnmmiphys.springeropen.com/articles/10.1186/s40658-022-00501-y">EJNMMI Physics</a>, full-text access is available for download<a href="https://rdcu.be/cXP9i/"> here.</a></p> 
</div>
  
  
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](https://github.com/dicomtools/TriDFusion)
[![GPLv3 license](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://github.com/dicomtools/TriDFusion/blob/main/LICENSE)

![TriDFusion](images/TriDFusionMontage.png)

## File format compatibility

| Medical Imaging Modalities                 | Import / Export File Formats                         |
| ------------------------------------------ | ---------------------------------------------------- |
| Positron Emission Tomography PET-CT (PT)   | DICOM using custom/vendor dictionaries               |
| Gamma Camera, Nuclear Medicine (NM)        | Raw data from nuclear imaging devices                |
| Computed Tomography (CT)                   | DICOM-RT structure (contours)                        |
| Digital Radiography (CR, DX)               | CERR planC, dose volumes and constraints             |
| Digital Angiography (XA)                   | Comma Separated Values (.csv)                        |
| Magnetic Resonance (MR)                    | Standard Triangle Language (.stl)                    |
| Secondary Pictures and Scanned Images (SC) | Bitmap (.bmp)                                        |
| Mammography (MG)                           | Neuroimaging Informatics Technology Initiative (.nii)|
| Ultrasonography (US)                       | Nearly Raw Raster Data (.nrrd)                       |

## Main features
- Multi-modality Image Viewer
- Total Tumor Burden Determination
- 3D Visualization
- 3D Printing
- Image Multi-Fusion
- Image Convolution
- Image Registration
- Image Resampling
- Image Re-Orientation
- Image Arithmetic and Post Filtering
- Image Editing
- Image Mask
- Image Constraint
- Lung Segmentation
- Edge Detection
- Voxel Dosimetry
- Machine Learning Segmentation
- Machine Learning 3D Lung Shunt & Lung Dose
- Machine Learning 3D Lung Lobe Quantification
- Machine Learning Y90 Dosimetry
- Radiomics

## MATLAB tested version

* MATLAB 2022a

## Installation

https://github.com/dicomtools/TriDFusion/wiki/Source-code-version-of-TriDFusion-(3DF)

The source code of TriDFusion (3DF) is distributed on gitHub. Hence, the first step is to download the "main" branch of TriDFusion (3DF). This can be done using the git bash. After going to the directory where you want to download the files, use the following command to download the "main" branch of TriDFusion (3DF): 

git clone https://github.com/dicomtools/TriDFusion.git

After downloading the "main" branch to (say) /home/.../.../TriDFusion_from_gitHub/, follow the steps listed below to use TriDFusion (3DF).

Fire up Matlab. Go to Home --> Set Path. Set the path to "Default". Add /home/.../.../TriDFusion_from_gitHub/ with sub-directories to the Matlab path.

To use TriDFusion (3DF) Graphical User Interface, type TriDFusion() in Matlab command window.

## Usage

MATLAB command:

* TriDFusion(); Open the graphical user interface.

* TriDFusion('path_to_dicom_folder'); Open the graphical user interface with a dicom image.

* TriDFusion('path_to_dicom_folder','path_to_dicom_folder'); Open the graphical user interface with 2 dicom image.

* TriDFusion('path_to_dicom_folder','path_to_dicom_folder', '-fusion'); Open the graphical user interface with 2 dicom image and fused them.

* TriDFusion('path_to_dicom_folder', '-mip'); Open the graphical user interface with a dicom image and create a 3D mip.

* TriDFusion('path_to_dicom_folder', '-iso'); Open the graphical user interface with a dicom image and create a 3D iso surface model.

* TriDFusion('path_to_dicom_folder', '-vol'); Open the graphical user interface with a dicom image and create a 3D volume rendering.

* TriDFusion('path_to_dicom_folder', '-mip', '-iso', '-vol'); Open the graphical user interface with a dicom image and create a fusion of a 3D mip, iso surface and volume rendering. Any combinaison can be use. 

DICOM directory structure:


    |-- main folder                             <-- The main folder or all series  

    |      |-- parent folder (series folder 1)  <-- Individual series folder 1
    |      |-- parent folder (series folder N)  <-- Individual series folder N
	
## Optional

CERR 
https://github.com/cerr/CERR

### Machine Learning Segmentation
TotalSegmentator (Tested version: pip install totalsegmentator==1.5.6)
https://github.com/wasserth/TotalSegmentator

### Radiomics
PY-Radiomics 
https://pyradiomics.readthedocs.io/en/latest/installation.html

## References 

If you use TriDFusion (3DF) please cite it
https://ejnmmiphys.springeropen.com/articles/10.1186/s40658-022-00501-y
```
Lafontaine D, Schmidtlein CR, Kirov A, Reddy RP, Krebs S, Schöder H, Humm JL. TriDFusion (3DF) image viewer. EJNMMI Phys. 2022 Oct 18;9(1):72. doi: 10.1186/s40658-022-00501-y. PMID: 36258098; PMCID: PMC9579267.
```

Visit https://daniellafontaine.com/ for more information.