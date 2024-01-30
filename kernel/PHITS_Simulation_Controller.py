#PHITS_Simulation_Controller
#PHITS Simulation Controller Main Function.
#See TriDFuison.doc (or pdf) for more information about options.
#
#Author: Lukas Carter, carterl1@mskcc.org
#
#Last modified:
# Daniel Lafontaine, lafontad@mskcc.org (1-16-2023)
#
#Note: option settings must fit on one line and can contain one physical model.
# -d phits_path_folder_name                    : PHITS path
# -o output_folder_name                        : Output directory
# -s series_nrr_file_name                      : Series nrrd file
# -l segmentation_label_nrrd_file_name         : Segmentation-label nrrd file
# -c segmentation_label_colotable_cbl_file_name: PHITS path: Segmentation label colorTable cbl file
# -r radionuclide_name: Radionuclide
# 
# -a source_particles source_particles batches: Alpha
# -b source_particles source_particles batches: Beta
# -g source_particles source_particles batches: Gamma
# -m source_particles source_particles batches: Monoenergetic Electron
# -p source_particles source_particles batches: Positron
# -x source_particles source_particles batches: Xray
#
# Example:
# cmd.exe /c start /wait python.exe C:\Temp\PHITS_Simulation_Controller.py -d C:\phits\ -o C:\Temp\PHITS -s C:\Temp\image.nrrd -l C:\Temp\Segmentation-label.nrrd -c C:\Temp\Segmentation-label_ColorTable.ctbl -r Y-90  -b 1000 1 -g 1000 1 -m 1000 1 -x 1000 1
#
# Copyright 2023, Lukas Carter, on behalf of the TriDFusion development team.
#
# This file is part of The Triple Dimention Fusion (TriDFusion).
#
# TriDFusion development has been led by:  Daniel Lafontaine
#
# TriDFusion is distributed under the terms of the Lesser GNU Public License.
#
#     This version of TriDFusion is free software: you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation, either version 3 of the License, or
#     (at your option) any later version.
#
# TriDFusion is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
# without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with TriDFusion. If not, see <http://www.gnu.org/licenses/>.

import sys
import os
import shutil
import subprocess
import argparse
from PHITS_DoseEngine import *

if __name__ == "__main__":

    parser = argparse.ArgumentParser(description="Run phits simulation with any data")

    # Arguments list

    parser.add_argument("-d", "--phits", type=str, help="PHITS path")
    parser.add_argument("-o", "--output", type=str, help="Output directory")
    parser.add_argument("-s", "--series", type=str, help="Series nrrd file")
    parser.add_argument("-l", "--label", type=str, help="Segmentation-label nrrd file")
    parser.add_argument("-c", "--color", type=str, help="Segmentation label colorTable cbl file")
    parser.add_argument("-r", "--radionuclide", type=str, help="Radionuclide")

    # Physical Model Arguments list
    # Accepts a list of strings

    parser.add_argument("-a", "--alpha", nargs='+', type=str, help="Alpha")
    parser.add_argument("-b", "--beta", nargs='+', type=str, help="Beta")  
    parser.add_argument("-g", "--gamma", nargs='+', type=str, help="Gamma")
    parser.add_argument("-m", "--monoenergeticElectron", nargs='+', type=str, help="Monoenergetic Electron")
    parser.add_argument("-p", "--positron", nargs='+', type=str, help="Positron")
    parser.add_argument("-x", "--xray",  nargs='+', type=str, help="Xray")

    args = parser.parse_args()

    phits_path = args.phits
    image_filename = args.series
    labelmap_filename = args.label
    llut_filename = args.color
    output_path = args.output
    radionuclide = args.radionuclide
    
    alpha_values = args.alpha
    beta_values = args.beta
    gamma_values = args.gamma
    monoenergetic_electron_values = args.monoenergeticElectron
    positron_values = args.positron
    xray_values = args.xray

    # Set simulations

    simulations = {}

    if alpha_values:
        alpha_value1, alpha_value2 = map(int, alpha_values)
        simulations['alpha'] = [alpha_value1, alpha_value2]
    
    if beta_values:
        beta_value1, beta_value2 = map(int, beta_values)
        simulations['beta'] = [beta_value1, beta_value2]
    
    if gamma_values:
        gamma_value1, gamma_value2 = map(int, gamma_values)
        simulations['gamma'] = [gamma_value1, gamma_value2]
    
    if monoenergetic_electron_values:
        monoenergetic_electron_value1, monoenergetic_electron_value2 = map(int, monoenergetic_electron_values)
        simulations['monoenergetic_electron'] = [monoenergetic_electron_value1, monoenergetic_electron_value2]
    
    if positron_values:
        positron_value1, positron_value2 = map(int, positron_values)
        simulations['positron'] = [positron_value1, positron_value2]
    
    if xray_values:
        xray_value1, xray_value2 =  map(int, xray_values)
        simulations['xray'] = [xray_value1, xray_value2]

    print("Simulations:")
    for emission, values in simulations.items():
        print(f"{emission}: {values}")

    # Loop all simulations items

    for emission, stats in simulations.items():
        sim_path = output_path + "\\" + emission
        create_phits_simulation(
            sim_path,
            image_filename,
            labelmap_filename,
            llut_filename,
            radionuclide,
            emission,
            str(stats[0]),
            str(stats[1]),
            phits_path
        )

        # Submit calculation to PHITS

        phits_input_filename = sim_path + "\\" + emission + ".inp"
        phits_bat_filename = fr"{phits_path}\bin\phits.bat"
        subprocess.run([phits_bat_filename, phits_input_filename])
        phits_vtk_output_filename = sim_path + "\\" + emission + "_VoxelDose.vtk"
        convert_phits_vtk_output_to_nrrd(phits_vtk_output_filename)

        print(f"PHITS simulation for {emission} complete!!!")