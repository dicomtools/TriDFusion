#PHITS_DoseEngine
#PHITS Dose Engine.
#See TriDFuison.doc (or pdf) for more information about options.
#
#Author: Lukas Carter, carterl1@mskcc.org
#
#Last modified:
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

import os
import sys
import math
import numpy as np
import nrrd


'''

@@@~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~@8-<

SET I/O PATHS

'''

# Set program folder
# program_folder = os.path.realpath("__file__")[:-8]
script_path = os.path.abspath(__file__)
program_folder = os.path.dirname(script_path)

# Radionuclide summary data
tridfusion_radionuclide_summary_data_file = program_folder + "\\" + "PHITS_Radionuclides.csv"

# Radionuclide emission data
# tridfusion_radionuclide_emission_data_file = program_folder + "RIsource.rad"

# Materials data
tridfusion_materials_data_file = program_folder + "\\" + "PHITS_Materials.csv"

# PHITS parameter defaults
# tridfusion_phits_configuration_file = program_folder + "TriDFusion_PHITS_Config.csv"


'''

@@@~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~@8-<

FUNCTIONS

'''


def convert_time(input_time, input_unit, output_unit='s'):
    """
    Converts time units.
    :param input_time:  Time value (float)
    :param input_unit:  Units of the input time (str)
    :param output_unit:  Desired unit of the time (str)
    :return:  Time value (float) in the desired unit
    EXAMPLE USAGE:  time_converter(60, 'm', 'h') --> 1.0
    """

    # Convert input to s
    units_to_seconds = {
        'y': 365.2425 * 24 * 60 * 60,
        'd': 24 * 60 * 60,
        'h': 60 * 60,
        'm': 60,
        's': 1,
        'ms': 1.0E-03,
        'us': 1.0E-06,
        'ns': 1.0E-09
    }
    seconds_to_unit = {
        'y': 1 / (365.2425 * 24 * 60 * 60),
        'd': 1 / (24 * 60 * 60),
        'h': 1 / (60 * 60),
        'm': 1 / 60,
        's': 1,
        'ms': 1 / 1.0E-03,
        'us': 1 / 1.0E-06,
        'ns': 1 / 1.0E-09
    }
    output_time = input_time * units_to_seconds[input_unit] * seconds_to_unit[output_unit]
    return float(output_time)


def read_radionuclide_summary_database(filepath=tridfusion_radionuclide_summary_data_file):
    """
    Read the TriDFusion radionuclide database into a dictionary.  Note:  the database was generated from ICRP 107 but
        has alternate names for each radiation type to suit the PHITS code.
    :param filepath:  Full file path
    :return:  Dictionary - keys: radionuclide symbol in 'dash' format (str); values: [half-life (str), [emissions]]
    EXAMPLE USAGE:  read_radionuclide_summary_database() -->
        { ..., 'Tc-99m': ['6.015h', ['beta', 'gamma', 'monoenergetic_electron', 'xray']], ...}
    """

    radionuclide_database = {}

    try:
        with open(filepath, 'r') as f:
            for line in f:
                if line != "\n" and not line.startswith("#"):
                    try:
                        line = line.strip().split(',')
                        radionuclide = line[0]
                        half_life_string = line[1]
                        emissions = line[2:]
                        radionuclide_database[radionuclide] = [half_life_string, emissions]
                    except IndexError:
                        pass
    except FileNotFoundError:
        print("WARNING:  Radionuclide database not found in <install dir>\\kernel...  Attempting to pull from 3DF...")
        pass

    return radionuclide_database


def phits_emissions_from_3df_types(emissions):
    """
    Converts emission types from 3DF/MIRD3D's format to PHITS's format.
    :param emissions:  A list of emissions types (str), or, a single emission type (str)
    :return:  Dict with key: PHITS type (i.e., 'electron', 'photon', or 'alpha'); value as list with PHITS source options (e.g., 'iannih' or 'iaugers' parameter)
    EXAMPLE USAGE:  phits_emissions_from_3df_types("monoenergetic_electron") --> {"electron": ["iaugers = 2"]}
    """

    # Set particles for PHITS with options (e.g. iaugers, iannih, icharctx)
    emission_conversion_dict = {"alpha": "alpha",
                            "beta": "electron",
                            "positron": "positron",
                            "gamma": "photon",
                            "xray": "photon",
                            "monoenergetic_electron": "electron"}

    # Check that input is compatible
    if isinstance(emissions, str):
        if emissions not in emission_conversion_dict:
            raise ValueError("Check emission type.")
        else:
            emissions = [emissions]
    elif isinstance(emissions, list):
        for emission in emissions:
            if emission not in emission_conversion_dict:
                raise ValueError("Check emission type.")

    emissions_phits = []
    for emission in emissions:
        if emission_conversion_dict[emission] not in emissions_phits:
            emissions_phits.append(emission_conversion_dict[emission])
    emissions_with_options = {}
    for emission in emissions_phits:
        emissions_with_options[emission] = []
    if "electron" in emissions_phits:
        if "beta" in emissions and "monoenergetic_electron" in emissions:
            emissions_with_options["electron"].append("iaugers=0")
        elif "beta" in emissions:
            emissions_with_options["electron"].append("iaugers=1")
        else:
            emissions_with_options["electron"].append("iaugers=2")
    if "photon" in emissions_phits:
        if "gamma" in emissions and "xray" in emissions:
            emissions_with_options["photon"].append("icharctx=0")
            emissions_with_options["photon"].append("iannih=1")
        elif "gamma" in emissions:
            emissions_with_options["photon"].append("icharctx=1")
            emissions_with_options["photon"].append("iannih=1")
        else:
            emissions_with_options["photon"].append("icharctx=2")
            emissions_with_options["photon"].append("iannih=1")

    return emissions_with_options


def read_material_database(filepath=tridfusion_materials_data_file):
    """
    Gets material density and composition for materials/tissues in the TriDFusion library.
    :param material:  Tissue/material name (string)
    :return:  Dict with the keys as material name, values as list of material density [g/cc] (float) and the elemental
        composition (string) in PHITS format
    EXAMPLE USAGE:  read_material_database() --> {"Water": [1.0, "H 2 O 1"], ...}
    """

    material_database = {}

    try:
        with open(filepath, 'r') as f:
            for line in f:
                if line != "\n" and not line.startswith("#"):
                    try:
                        line = line.strip().split(',')
                        material = line[0]
                        density = float(line[1])
                        composition = line[2]
                        material_database[material] = [density, composition]
                    except IndexError:
                        pass
    except FileNotFoundError:
        print("WARNING:  Material database not found.  Material info will be extracted from labelmap lookup table or assigned liquid water.")
        pass

    return material_database


def read_labelmap_lut(llut_file):
    """
    Read a labelmap lookup table exported fromm TriDFusion (or 3D Slicer) into a dictionary.  This will allow us to
        access the material information (ID, density, composition, colors) using a material name key.  The lookup table
        file may include density and composition data by default (e.g., as-exported from 3DF) or may not (e.g., Slicer).
        If density and composition data are not included, we will get it from the stored database if the material name
        matches.  Otherwise it will be assumed to be liquid water.  Material densities/composition provided in the
        llut_file will override densities/composition in the database.
    :param llut_file:  Path & filename for the llut file
    :return:  Dictionary with keys: material name (str); values: [ID (int), name (str), R (int), G (int), B (int), A (int), density (float), composition (str)]
    EXAMPLE USAGE:  read_labelmap_lut( _ ) --> {"Water": [1, "Water", 255, 255, 255, 255, 1.00, "H 2 O 1"], ...}
    """

    llut = {}

    with open(llut_file, 'r') as f:
        for line in f:
            if line != "\n" and not line.startswith("#"):
                try:
                    line = line.strip().split(maxsplit=7)
                    linelen = len(line)
                    mat_id = int(line[0])
                    mat_name = line[1]
                    mat_display_red = line[2]
                    mat_display_green = line[3]
                    mat_display_blue = line[4]
                    mat_display_alpha = line[5]
                    if linelen == 6:
                        llut[mat_name] = [mat_id, mat_name, mat_display_red, mat_display_green, mat_display_blue, mat_display_alpha]
                    elif linelen == 8:
                        mat_density = float(line[6])
                        mat_composition = line[7]
                        llut[mat_name] = [mat_id, mat_name, mat_display_red, mat_display_green, mat_display_blue, mat_display_alpha, mat_density, mat_composition]
                except IndexError:
                    pass

    return llut


def read_nrrd(nrrd_file):
    """
    Reads nrrd format image.
    :param nrrd_file:  Path & filename for the image
    :return:  data (np array), header (ordered dict)
    """
    data, header = nrrd.read(nrrd_file)
    return data, header


def create_phits_simulation(desired_path_to_output,
                            input_image_filename,
                            input_labelmap_filename=None,
                            input_llut_filename=None,
                            radionuclide=None,
                            emission_types=None,
                            maxcas=None,
                            maxbch=None,
                            phits_path="c:\\phits\\",
                            padding_factor=0.01):
    """
    Create PHITS input files for the simulation.  Assumed space units of millimeters.  Assumed LPS orientation.
    :param desired_path_to_output:  Folder the simulation will be stored in; this will have subfolders for each
        particle type in the simulation
    :param input_image_filename:  This is the 'activity' image, required in units of Bq/mL (outputs dose rate in Gy/s),
        Bq*s/mL (outputs dose in Gy), [Bq*s]/[ml*Bq] (outputs dose coefficient in Gy/Bq), etc.
    :param input_labelmap_filename:  This is the labelmap, which defines integer IDs for the materials used
    :param input_llut_filename:  Lookup table maps the IDs in the labelmap to the material densities and compositions
    :param radionuclide:  Symbol of the radionuclide in 'dash' format (string)
    :param emission_types:  Emission type to be simulated.  Possible emissions include: 'alpha', 'beta', 'gamma', 'monoenergetic_electron', 'positron', 'xray'.  # TODO: This could be string for one emission or list of multiple.
    :param maxcas:  Source particles per batch
    :param maxbch:  Number of batches
    :param phits_path:  Path to phits executable
    :param padding_factor:  Fractional distance to overlap edge source voxels with phantom boundary surface
    :return:  Nothing
    """

    """Read the TriDFusion materials database.  If this database does not exist, material info will need to be defined
    in the llut file."""

    # Materials
    print("Reading TriDFusion material database...")
    material_database = read_material_database()

    """PROCESS THE IMAGE.  Here, we grab the image data that will be copied to the PHITS simultion folders, and we get
    the image metadata that go into the PHITS input file."""

    # Get the 'activity' image
    print(f"Reading 'activity' image:  {input_image_filename}...")
    image_data, image_header = read_nrrd(input_image_filename)

    # Put the image space into PHITS space
    dimensions_x = image_header['sizes'][0]
    dimensions_y = image_header['sizes'][1]
    dimensions_z = image_header['sizes'][2]
    space_directions = np.array(image_header['space directions'])
    # spacing_x = np.linalg.norm(space_directions[:, 0]) / 10  # centimeters
    # spacing_y = np.linalg.norm(space_directions[:, 1]) / 10  # centimeters
    # spacing_z = np.linalg.norm(space_directions[:, 2]) / 10  # centimeters
    spacing_x = np.linalg.norm(space_directions[0]) / 10  # centimeters
    spacing_y = np.linalg.norm(space_directions[1]) / 10  # centimeters
    spacing_z = np.linalg.norm(space_directions[2]) / 10  # centimeters
    padding_x = spacing_x * padding_factor
    padding_y = spacing_y * padding_factor
    padding_z = spacing_z * padding_factor
    origin_x = image_header['space origin'][0] / 10  # centimeters
    origin_y = image_header['space origin'][1] / 10  # centimeters
    origin_z = image_header['space origin'][2] / 10  # centimeters
    minimum_x = origin_x - 0.5 * spacing_x  # centimeters
    maximum_x = origin_x + (dimensions_x - 0.5) * spacing_x  # centimeters
    minimum_y = origin_y - 0.5 * spacing_y  # centimeters
    maximum_y = origin_y + (dimensions_y - 0.5) * spacing_y  # centimeters
    minimum_z = origin_z - 0.5 * spacing_z  # centimeters
    maximum_z = origin_z + (dimensions_z - 0.5) * spacing_z  # centimeters

    # Calculate voxel volume [cc]
    voxel_volume = spacing_x * spacing_y * spacing_z

    # Get total image activity
    activity_per_voxel = image_data * voxel_volume
    image_activity = np.sum(activity_per_voxel)


    """PROCESS THE LABELMAP.  Here, we grab the labelmap data that will also be copied to the PHITS simulation folders,
    and we get the labelmap metadata to compare with the activity image data to make sure the simulation geometry and
    source distribution coincide.  If there is no labelmap provided, we will assume the entire simulation medium is 
    water."""

    # TODO:  Handle if ID=0 is present in the llut; this is the 'background' ID in 3D Slicer

    # Get the labelmap if it exists
    if input_labelmap_filename is not None:
        print(f"Reading labelmap:  {input_labelmap_filename}...")
        labelmap_data, labelmap_header = read_nrrd(input_labelmap_filename)

        if input_llut_filename is None:
            raise FileNotFoundError('File not found:  labelmap lookup table...')

        # Check that the activity image and the labelmap represent the same space
        if (image_header['dimension'] == labelmap_header['dimension'] and
            image_header['space'] == labelmap_header['space'] and
            np.allclose(image_header['sizes'], labelmap_header['sizes']) and
            np.allclose(image_header['space directions'], labelmap_header['space directions']) and
            image_header['kinds'] == labelmap_header['kinds'] and
            np.allclose(image_header['space origin'], labelmap_header['space origin'])):
            pass
        else:
            raise ValueError('Activity distribution and labelmap do not correspond.')

        # Find out what materials are in the labelmap
        labelmap_data_ids = np.unique(labelmap_data).tolist()  # TODO:  This does nothing - was just here to check consistency between labelmap values and llut

        # Read labelmap lookup table into a dictionary
        print(f"Reading labelmap lookup table:  {input_llut_filename}...")
        labelmap_lut = read_labelmap_lut(input_llut_filename)

        # Check labelmap lookup table for missing materials; pull missing materials from library or assign H20
        for key, value in labelmap_lut.items():
            if len(value) == 6:
                try:
                    value.extend(material_database[key])
                    print(f"Material density and composition missing from llut for material: {key}...  Pulling from 3DF database.")
                except KeyError:
                    value.extend([1.00, "H 2 O 1"])
                    print(f"Material density and composition missing from llut and 3DF database for material: {key}...  Assigning liquid water.")

    # If no labelmap exists, we will create one with unitary values and water composition (i.e., the whole simulation geometry is water)
    else:
        # Create a copy of the image volume but fill it with "1"s
        labelmap_data = np.ones_like(image_data, dtype=np.int)
        labelmap_lut = {"Water": [1, "Water", 255, 255, 255, 255, 1.00, "H 2 O 1"]}


    """GET RADIONUCLIDE AND EMISSION INFO."""

    # Radionuclides
    print("Reading TriDFusion radionuclide summary database...")
    radionuclide_database = read_radionuclide_summary_database()

    # Check that specified emissions are OK
    if radionuclide_database:  # This routine if we have access to the database file in \Lib
        emissions_available = radionuclide_database[radionuclide][1]  # List of emissions available for the given radionuclide
        if isinstance(emission_types, str):
            emission_types = [emission_types]
        if not set(emission_types).issubset(emissions_available):
            raise ValueError("Emission(s) specified does not exist in database.")
    else:
        emissions_available = ['alpha', 'beta', 'gamma', 'monoenergetic_electron', 'positron', 'xray']  # We only do this since 3DF only enables direct selection of emission types

    emissions_used = list(set(emissions_available) & set(emission_types))

    phits_emission_types_and_options = phits_emissions_from_3df_types(emissions_used)

    totfact = str(len(phits_emission_types_and_options.keys()))


    """BUILD THE PHITS INPUT FILE."""

    if not os.path.exists(desired_path_to_output):
        print("Creating output folder:  " + desired_path_to_output)
        os.makedirs(desired_path_to_output)
    desired_filename = desired_path_to_output + "\\" + os.path.basename(desired_path_to_output) + ".inp"
    with open(desired_filename, 'w') as f:
        output_content = []
        title_block = []
        parameters_block = []
        materials_block = []
        surface_block = []
        cell_block = []
        source_block = []
        tally_block_region = []
        tally_block_voxel = []

        # File naming
        desired_filename_basename = os.path.basename(desired_filename)
        desired_filename_basename_woext = os.path.splitext(desired_filename_basename)[0]
        # input_labelmap_basename_woext = os.path.splitext(labelmap_metadata['data_file'])[0]
        # input_image_basename_woext = os.path.splitext(image_metadata['data_file'])[0]

        title_block.extend([
            "[ T i t l e ]",
            "    Generated by TriDFusion",
            "\n"
        ])

        parameters_block.extend([
            "[ P a r a m e t e r s ]",
            "    icntl      = 0           # (D=0) 3:ECH 5:NOR 6:SRC 7,8:GSH 11:DSH 12:DUMP",
            "    maxcas     = {0}         # Number of particles in one batch".format(maxcas),
            "    maxbch     = {0}         # Number of batches".format(maxbch),
            "    file(1)    = {0}         # PHITS install folder".format(phits_path),
            "    file(6)    = phits.out   # General PHITS output filename",
            "    emin(11) = 1.0",
            "    emin(12) = 0.001",
            "    dmax(12) = 100",
            "    emin(13) = 0.001",
            "    dmax(13) = 100",
            "    emin(14) = 0.001",
            "    dmax(14) = 100",
            "    negs     = 1",
            "    nlost    = {0}".format(int(int(maxcas) * int(maxbch) / 1000)),
            "    igerr    = {0}".format(int(int(maxcas) * int(maxbch) / 1000)),  # Added 2/17/2024
            "\n"
        ])

        materials_block.extend([
            "[ M a t e r i a l ]  $ Default materials backwards from 7999"
        ])

        # Read llut file for material and universe (cell) information.  Dict values: region, region name, r, g, b, a, density, composition

        for region_name, data in labelmap_lut.items():
            if data[6] != 0:
                materials_block.extend(
                    ["    m{0}    # {1}  {2} g/cc".format(data[0], data[1], "{:.3E}".format(data[6]))])
                materials_block.extend(["        " + data[7]])
        materials_block.extend(["\n"])

        # Create the [Surface] section
        surface_block.extend([
            "[ S u r f a c e ]  $ Default surfaces backwards from 9999",
            "    $ Fundamental voxel boundary surface",
            "    9997  rpp  {0}  {1}  {2}  {3}  {4}  {5}".format("{:.6E}".format(minimum_x),
                                                                "{:.6E}".format(minimum_x + spacing_x),
                                                                "{:.6E}".format(minimum_y),
                                                                "{:.6E}".format(minimum_y + spacing_y),
                                                                "{:.6E}".format(minimum_z),
                                                                "{:.6E}".format(minimum_z + spacing_z)),
            "    $ Voxel phantom boundary surface",
            "    9998  rpp  {0}  {1}  {2}  {3}  {4}  {5}".format("{:.6E}".format(minimum_x + padding_x),
                                                                "{:.6E}".format(maximum_x - padding_x),
                                                                "{:.6E}".format(minimum_y + padding_y),
                                                                "{:.6E}".format(maximum_y - padding_y),
                                                                "{:.6E}".format(minimum_z + padding_z),
                                                                "{:.6E}".format(maximum_z - padding_z)),
            "    $ Playing field sidelines",
            "    9999  s  {0}  {1}  {2}  {3}".format("{:.3E}".format((minimum_x + maximum_x) / 2),
                                                   "{:.3E}".format((minimum_y + maximum_y) / 2),
                                                   "{:.3E}".format((minimum_z + maximum_z) / 2),
                                                   "{:.3E}".format(10 * max(abs(minimum_x - maximum_x),
                                                                            abs(minimum_y - maximum_y),
                                                                            abs(minimum_z - maximum_z)))),
            "\n"
        ])

        # Create the [Cell] section
        cell_block.extend([
            "[ C e l l ]  $ Default cells backwards from 8999, universes backwards from 6999",
            "    $ Material universes"
        ])

        for region_name, data in labelmap_lut.items():
            if data[6] != 0:
                cell_block.extend(["    {0}  {1}  {2}  {3}  {4}".format(data[0], data[0], "-" + "{:.3E}".format(data[6]), "-9999", "u=" + str(data[0]))])
            else:
                cell_block.extend(["    {0}  {1}  {2}  {3}  {4}".format(data[0], 0, "", "-9999", "u=" + str(data[0]))])
        cell_block.extend([
            "    $ Voxel universe",
            "    8996  0      -9997",
            "        lat=1 u=6999",
            "        fill=0:{0} 0:{1} 0:{2}".format(dimensions_x - 1, dimensions_y - 1, dimensions_z - 1),
            "        infl:{" + desired_filename_basename_woext + "_geometry.txt}",
            "    $ Phantom space",
            "    8997   0      -9998  fill=6999  $ Region filled with voxels",
            "    $ Playing field",
            "    8998   0      -9999  9998        $ Void outside voxel phantom",
            "    8999  -1       9999             $ Out of bounds"
        ])

        cell_block.extend(["\n"])

        # Create the [Source] section
        source_block.extend([
            "[ S o u r c e ]",
            "    totfact = {0}".format(totfact)
        ])
        for emission in phits_emission_types_and_options.keys():
            source_block.extend([
                "    <source> = 1.0",
                "    s-type=22",
                "    proj={0}".format(emission)
            ])
            for option in phits_emission_types_and_options[emission]:
                source_block.extend(["    {0}".format(option)])
            source_block.extend([
                "    dir=all",
                "    e-type=28",
                "        ni=1",
                "            {0}  {1}".format(radionuclide, "{:.6E}".format(image_activity)),
                "    dtime=0",
                "    norm=0",
                "    mesh=xyz",
                "    x-type=2",
                "        nx={0}".format(dimensions_x),
                "        xmin={0}".format("{:.6E}".format(minimum_x)),
                "        xmax={0}".format("{:.6E}".format(maximum_x)),
                "    y-type=2",
                "        ny={0}".format(dimensions_y),
                "        ymin={0}".format("{:.6E}".format(minimum_y)),
                "        ymax={0}".format("{:.6E}".format(maximum_y)),
                "    z-type=2",
                "        nz={0}".format(dimensions_z),
                "        zmin={0}".format("{:.6E}".format(minimum_z)),
                "        zmax={0}".format("{:.6E}".format(maximum_z)),
                "    infl:{" + desired_filename_basename_woext + "_source.txt}",
            ])

        source_block.extend(["\n"])

        # Create [T-deposit] tally
        tally_block_voxel.extend([
            "[ T - d e p o s i t ]",
            "    file=" + desired_filename_basename_woext + "_VoxelDose.out",
            "    mesh=xyz",
            "    x-type=2",
            "        nx={0}".format(dimensions_x),
            "        xmin={0}".format("{:.6E}".format(minimum_x)),
            "        xmax={0}".format("{:.6E}".format(maximum_x)),
            "    y-type=2",
            "        ny={0}".format(dimensions_y),
            "        ymin={0}".format("{:.6E}".format(minimum_y)),
            "        ymax={0}".format("{:.6E}".format(maximum_y)),
            "    z-type=2",
            "        nz={0}".format(dimensions_z),
            "        zmin={0}".format("{:.6E}".format(minimum_z)),
            "        zmax={0}".format("{:.6E}".format(maximum_z)),
            "    output=dose",
            "    unit=0  # Normally Gy/source, but overridden by norm=0 source option",
            "    factor=1.0  # Gy/s for input activity map (Bq/mL), Gy for input TIA map (Bq*s/mL), Gy/Bq for TIAC map (Bq*s/Bq/mL)",
            "    axis=xz",
            "    epsout=0",
            "    vtkout=1"
        ])

        # Tie all blocks together and write the input file
        for each in [title_block, parameters_block, materials_block, surface_block, cell_block, source_block, tally_block_voxel]:
            output_content.extend(each)

        for each in output_content:
            f.write(str(each))
            f.write("\n")
        f.write("\n[end]\n")

    # Copy the image (source) and labelmap (geometry) files to the output directory
    print("Writing PHITS geometry...")
    geometry_output_filename = desired_path_to_output + "\\" + os.path.basename(desired_path_to_output) + "_geometry.txt"
    with open(geometry_output_filename, 'w') as f:
        write_list = labelmap_data.flatten('F').tolist()  # Need Fortran order
        for each in write_list:
            f.write(f"\t{int(each)}\n")  # For some stupid reason, there needs to be a tab preceding the value.  Wtf.  

    print("Writing PHITS source distribution...")
    source_output_filename = desired_path_to_output + "\\" + os.path.basename(desired_path_to_output) + "_source.txt"
    with open(source_output_filename, 'w') as f:
        write_list = image_data.flatten('F').tolist()  # Need Fortran order
        for each in write_list:
            f.write(f"{each:.6e}\n")

    print("Writing nrrd header information...")
    nhdr_output_filename = desired_path_to_output + "\\" + os.path.basename(desired_path_to_output) + ".nhdr"
    with open(nhdr_output_filename, 'w') as f:
        f.write(f"NRRD0004\n")
        f.write(f"type: float\n")
        f.write(f"dimension: {image_header['dimension']}\n")
        f.write(f"space: {image_header['space']}\n")
        f.write(f"sizes: {dimensions_x} {dimensions_y} {dimensions_z}\n")
        f.write(f"space directions: ({image_header['space directions'][0][0]},{image_header['space directions'][0][1]},{image_header['space directions'][0][2]}) ")
        f.write(f"({image_header['space directions'][1][0]},{image_header['space directions'][1][1]},{image_header['space directions'][1][2]}) ")
        f.write(f"({image_header['space directions'][2][0]},{image_header['space directions'][2][1]},{image_header['space directions'][2][2]})\n")
        f.write(f"kinds: domain domain domain\n")
        f.write(f"encoding: raw\n")
        f.write(f"endian: little\n")
        # f.write(f"space origin: ({origin_x},{origin_y},{origin_z})\n")
        f.write(f"space origin: ({image_header['space origin'][0]},{image_header['space origin'][1]},{image_header['space origin'][2]})\n")

    print("Simulation files written.")


def convert_phits_vtk_output_to_nrrd(vtk_file):
    """
    Converts PHITS VTK output file to nrrd format.
    :param vtk_file:  Path and filename of vtk file
    :return:  Nothing
    """
    # Find associated NRRD header generated when simulation was created
    simulation_nhdr_filename = vtk_file[:-14] + ".nhdr"  # File[:-14] is the filename without the _VoxelDose.vtk extension
    if not os.path.exists(simulation_nhdr_filename):
        raise FileNotFoundError('NRRD header for this simulation does not exist.')  # TODO:  Generate NRRD header information from the vtk file metadata

    dose_section = []
    region_section = []

    # Flag to determine the current section
    current_section = None

    # Read vtk file
    with open(vtk_file, 'r') as f:
        for line in f:
            # Check for the header to determine the current section
            if line.startswith('all'):
                current_section = 'all'
                continue
            elif line.startswith('region'):
                current_section = 'region'
                continue
            elif line.startswith('material'):
                current_section = None
                continue

            # Store numeric data based on the current section
            if current_section == 'all':
                numbers = [float(num) for num in line.strip().split()]
                dose_section.extend(numbers)
            elif current_section == 'region':
                numbers = [int(num) for num in line.strip().split()]
                region_section.extend(numbers)

    # Print the results or further process the lists as needed
    # print("Dose Section:", dose_section)
    # print("Region Section:", region_section)

    # Read the nhdr
    dose_header = nrrd.read_header(simulation_nhdr_filename)

    # Convert dose array to numpy with the correct dimensions
    dose_image = np.array(dose_section).reshape((dose_header['sizes'][0], dose_header['sizes'][1], dose_header['sizes'][2]), order='F')

    # Write nrrd output
    nrrd_dose_file = vtk_file[:-14] + "_VoxelDose.nrrd"
    nrrd.write(nrrd_dose_file, dose_image, dose_header)


'''

@@@~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~@8-<

RUN PROGRAM:  Create input for PHITS

'''


if __name__ == "__main__":
    # create_phits_simulation(r"C:\Users\carterl1\Downloads\3DF_LukeTest\Simulation",  # TODO: Set folder to save case in
    #                         r"C:\Users\carterl1\Downloads\3DF_LukeTest\LukeTestBqmL.nrrd",  # TODO: Set activity (Bq/mL -> Gy/s), TIA (Bq*s/mL -> Gy), or TIAC (Bq*s/Bq -> Gy/Bq) map file
    #                         r"C:\Users\carterl1\Downloads\3DF_LukeTest\Segmentation-label.nrrd",  # TODO: Set labelmap file
    #                         r"C:\Users\carterl1\Downloads\3DF_LukeTest\Segmentation-label_ColorTable.ctbl",  # TODO: Set lookup table file for label material information
    #                         "Y-90",  # TODO: Set radionuclide
    #                         "beta",  # TODO: Set emissions to include in simulation (alpha, beta, positron, gamma, xray, monoenergetic_electron)
    #                         "1000",  # TODO: Set number of histories per batch
    #                         "1"  # TODO: Set number of batches
    #                         )

    convert_phits_vtk_output_to_nrrd(r"C:\Users\carterl1\Downloads\3DF_LukeTest\Simulation\Simulation_VoxelDose.vtk")




# Read input from command line (cmd: script name, then config file)  TODO: create a config file to read
# try:
#     input_file = sys.argv[1]
# except IndexError:
#     input_file = program_folder + "MIRD3d.config"

