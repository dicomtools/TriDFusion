#LED_DoseEngine
#LED_DoseEngine.
#See TriDFuison.doc (or pdf) for more information about options.
#
#Author: Lukas Carter, carterl1@mskcc.org
#
#Last modified:
#
# Copyright 2024, Lukas Carter, on behalf of the TriDFusion development team.
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

from ICRP107_RadionuclideData import *
from PHITS_DoseEngine import *

def led_calculation(desired_path_to_output,
                    input_image_filename,
                    input_labelmap_filename=None,
                    input_llut_filename=None,
                    radionuclide=None,
                    emission_types=None
                    ):
    """
    Local energy deposition calculation.
    :param desired_path_to_output:
    :param input_image_filename:
    :param input_labelmap_filename:
    :param input_llut_filename:
    :param radionuclide:
    :param emission_types:
    :return:
    """

    """Read the TriDFusion materials database.  If this database does not exist, material info will need to be defined
    in the llut file."""

    # Materials
    print("Reading TriDFusion material database...")
    material_database = read_material_database()

    # Get the 'activity' image
    print(f"Reading 'activity' image:  {input_image_filename}...")
    image_data, image_header = read_nrrd(input_image_filename)

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

    """CALCULATE DOSE"""
    # Create a 'density' image
    density_dict = {}
    for key, value in labelmap_lut.items():
        density_dict[value[0]] = value[6]
    # Using np.vectorize with the dictionary's get method directly
    vectorized_density_dict = np.vectorize(density_dict.get)

    density_data = vectorized_density_dict(labelmap_data)

    tridfusion_particle_type_to_mird3d_type = {
        'alpha': 'Alpha',
        'beta': 'Beta',
        'gamma': 'Gamma',
        'monoenergetic_electron': 'Monoenergetic electron',
        'positron': 'Positron',
        'xray': 'X-ray'
    }
    dose_total = np.zeros_like(image_data)  # buffer to hold sum of doses of components
    radionuclide = Radionuclide(radionuclide)
    for emission in emissions_used:
        delta = radionuclide.GetDelta(tridfusion_particle_type_to_mird3d_type[emission]) * 1.60218e-13  # kg*Gy/Bq*s

        # Convert activity image (i.e., Bq/mL for dose rate or Bq*s/mL for dose) by density and multiply by delta
        dose_image = 1000 * delta * np.divide(image_data, density_data, where=density_data!=0, out=np.zeros_like(image_data, dtype=float))
        dose_total += dose_image

    """WRITE THE OUTPUT IMAGE."""

    if not os.path.exists(desired_path_to_output):
        print("Creating output folder:  " + desired_path_to_output)
        os.makedirs(desired_path_to_output)

    desired_filename = desired_path_to_output + "\\" + os.path.basename(desired_path_to_output) + "_VoxelDose.nrrd"
    nrrd.write(desired_filename, dose_total, image_header)



if __name__ == "__main__":

    output_path = r"E:\Workspace\patient_4\Led"
    image_filename = r"E:\Workspace\patient_4\TIA cropped.nrrd"  # TODO: Set activity (Bq/mL -> Gy/s), TIA (Bq*s/mL -> Gy), or TIAC (Bq*s/Bq -> Gy/Bq) map file
    labelmap_filename = None  # TODO: Set labelmap file
    llut_filename = None  # TODO: Set lookup table file for label material information
    radionuclide = "Lu-177"  # TODO: Set radionuclide

    leds = [
        'beta',
        'monoenergetic_electron'
    ]

    for emission in leds:
        sim_path = output_path + "\\" + emission
        led_calculation(
            sim_path,
            image_filename,
            labelmap_filename,
            llut_filename,
            radionuclide,
            emission
        )

    # radionuclide = Radionuclide("Y-90")
    # emission = 'beta'
    # tridfusion_particle_type_to_mird3d_type = {
    #     'alpha': 'Alpha',
    #     'beta': 'Beta',
    #     'gamma': 'Gamma',
    #     'monoenergetic_electron': 'Monoenergetic electron',
    #     'positron': 'Positron',
    #     'xray': 'X-ray'
    # }
    # delta = radionuclide.GetDelta(tridfusion_particle_type_to_mird3d_type[emission]) * 1.60218e-13  # kg*Gy/Bq*s
    # print(delta)
