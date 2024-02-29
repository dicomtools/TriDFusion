#ICRP107_RadionuclideData
#ICRP107_RadionuclideData.
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

import os
import math
import pandas as pd
from math import log10, floor
import sys


'''

@@@~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~@8-<

SET DATA I/O...  Ensure ICRP-07 datasets installed in <program folder>\Lib

'''

#program_folder = os.path.realpath("__file__")[:-8]
script_path = os.path.abspath(__file__)
program_folder = os.path.dirname(script_path)
#program_folder = "C:/Users/carterl1/PycharmProjects/ImageProcessing/"  #TODO:  Blender only!

rad_datafile = program_folder + "/Lib/ICRP-07.RAD"  # Full path to 'ICRP-07.RAD' file from ICRP 107
ndx_datafile = program_folder + "/Lib/ICRP-07.NDX"  # Full path to 'ICRP-07.NDX' file from ICRP 107
# TODO: On MAC OS, must delete non-ascii 'copyright' character in line 1 of ICRP-07.NDX
bet_datafile = program_folder + "/Lib/ICRP-07.BET"  # Full path to 'ICRP-07.BET' file from ICRP 107
ack_datafile = program_folder + "/Lib/ICRP-07.ACK"  # Full path to 'ICRP-07.ACK' file from ICRP 107
dpk_path = program_folder + "/Lib/20190213_Graves_DosePointKernels_v1.0"  # Full path to Graves (Med. Phys. 2019) dose point kernels
print(ndx_datafile)

'''

@@@~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~@8-<

INITIALIZE...  Make the NDX data accessible so don't have to load repeatedly

'''

print('Reading ICRP107 ICRP-07.NDX ...')
with open(ndx_datafile, 'r') as f1:
    all_radionuclides = []
    ndx_data = f1.readlines()[1:]
    ndx_dict = {}
    for lin in ndx_data:
        ndx_radionuclide = lin[:7].strip()
        ndx_data = lin
        ndx_dict[ndx_radionuclide] = ndx_data
        all_radionuclides.append(ndx_radionuclide)


'''

@@@~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~@8-<

SET RADIATION NAMES...  

'''

jcode_to_detailed_type = {
    'G': 'Gamma',
    'PG': 'Prompt gamma',
    'DG': 'Delayed gamma',
    'X': 'X-ray',
    'AQ': 'Annihilation photon',
    'B+': 'Positron',
    'B-': 'Beta',
    'DB': 'Delayed beta',
    'IE': 'Conversion electron',
    'AE': 'Auger electron',
    'A': 'Alpha',
    'AR': 'Alpha recoil',
    'FF': 'Fission fragment',
    'N': 'Neutron'
}
detailed_types = list(set(jcode_to_detailed_type.values()))
detailed_colormap = {
    'Gamma': '#2f302e',
    'Prompt gamma': '#2f302e',
    'Delayed gamma': '#2f302e',
    'X-ray': '#4d4f4b',
    'Annihilation photon': '#2f302e',
    'Positron': '#1f254d',
    'Beta': '#1f4d44',
    'Delayed beta': '#1f4d44',
    'Conversion electron': '#4d1f49',
    'Auger electron': '#73216c',
    'Alpha': '#55647d',
    'Alpha recoil': '#adadad',
    'Fission fragment': '#adadad',
    'Neutron': '#adadad'
}

icode_to_simple_type = {
    1: 'Gamma',
    2: 'X-ray',
    3: 'Annihilation photon',
    4: 'Positron',
    5: 'Beta',
    6: 'Conversion electron',
    7: 'Auger electron',
    8: 'Alpha',
    9: 'Alpha recoil',
    10: 'Fission fragment',
    11: 'Neutron'
}
simple_types = list(set(icode_to_simple_type.values()))
simple_colormap = {
    'Gamma': 'Red',
    'X-ray': 'Orange',
    'Annihilation photon': 'Gray',
    'Positron': 'Yellow',
    'Beta': 'Green',
    'Conversion electron': 'Blue',
    'Auger electron': 'Gray',
    'Alpha': 'Purple',
    'Alpha recoil': 'Gray',
    'Fission fragment': 'Gray',
    'Neutron': 'Gray'
}

icode_to_mird3d_type = {
    1: 'Gamma',
    2: 'X-ray',
    4: 'Positron',
    5: 'Beta',
    6: 'Monoenergetic electron',
    7: 'Monoenergetic electron',
    8: 'Alpha'
}
mird3dtypes = list(set(icode_to_mird3d_type.values()))
mird3d_colormap = {
    'Gamma': 'Red',
    'X-ray': 'Orange',
    'Positron': 'Yellow',
    'Beta': 'Green',
    'Monoenergetic electron': 'Blue',
    'Alpha': 'Purple'
}

# Periodic table information; element name and atomic number by symbol
element_info_dict = {
    'H': ['Hydrogen', 1],
    'He': ['Helium', 2],
    'Li': ['Lithium', 3],
    'Be': ['Beryllium', 4],
    'B': ['Boron', 5],
    'C': ['Carbon', 6],
    'N': ['Nitrogen', 7],
    'O': ['Oxygen', 8],
    'F': ['Fluorine', 9],
    'Ne': ['Neon', 10],
    'Na': ['Sodium', 11],
    'Mg': ['Magnesium', 12],
    'Al': ['Aluminum', 13],
    'Si': ['Silicon', 14],
    'P': ['Phosphorus', 15],
    'S': ['Sulfur', 16],
    'Cl': ['Chlorine', 17],
    'Ar': ['Argon', 18],
    'K': ['Potassium', 19],
    'Ca': ['Calcium', 20],
    'Sc': ['Scandium', 21],
    'Ti': ['Titanium', 22],
    'V': ['Vanadium', 23],
    'Cr': ['Chromium', 24],
    'Mn': ['Manganese', 25],
    'Fe': ['Iron', 26],
    'Co': ['Cobalt', 27],
    'Ni': ['Nickel', 28],
    'Cu': ['Copper', 29],
    'Zn': ['Zinc', 30],
    'Ga': ['Gallium', 31],
    'Ge': ['Germanium', 32],
    'As': ['Arsenic', 33],
    'Se': ['Selenium', 34],
    'Br': ['Bromine', 35],
    'Kr': ['Krypton', 36],
    'Rb': ['Rubidium', 37],
    'Sr': ['Strontium', 38],
    'Y': ['Yttrium', 39],
    'Zr': ['Zirconium', 40],
    'Nb': ['Niobium', 41],
    'Mo': ['Molybdenum', 42],
    'Tc': ['Technetium', 43],
    'Ru': ['Ruthenium', 44],
    'Rh': ['Rhodium', 45],
    'Pd': ['Palladium', 46],
    'Ag': ['Silver', 47],
    'Cd': ['Cadmium', 48],
    'In': ['Indium', 49],
    'Sn': ['Tin', 50],
    'Sb': ['Antimony', 51],
    'Te': ['Tellurium', 52],
    'I': ['Iodine', 53],
    'Xe': ['Xenon', 54],
    'Cs': ['Cesium', 55],
    'Ba': ['Barium', 56],
    'La': ['Lanthanum', 57],
    'Ce': ['Cerium', 58],
    'Pr': ['Praseodymium', 59],
    'Nd': ['Neodymium', 60],
    'Pm': ['Promethium', 61],
    'Sm': ['Samarium', 62],
    'Eu': ['Europium', 63],
    'Gd': ['Gadolinium', 64],
    'Tb': ['Terbium', 65],
    'Dy': ['Dysprosium', 66],
    'Ho': ['Holmium', 67],
    'Er': ['Erbium', 68],
    'Tm': ['Thulium', 69],
    'Yb': ['Ytterbium', 70],
    'Lu': ['Lutetium', 71],
    'Hf': ['Hafnium', 72],
    'Ta': ['Tantalum', 73],
    'W': ['Tungsten', 74],
    'Re': ['Rhenium', 75],
    'Os': ['Osmium', 76],
    'Ir': ['Iridium', 77],
    'Pt': ['Platinum', 78],
    'Au': ['Gold', 79],
    'Hg': ['Mercury', 80],
    'Tl': ['Thallium', 81],
    'Pb': ['Lead', 82],
    'Bi': ['Bismuth', 83],
    'Po': ['Polonium', 84],
    'At': ['Astatine', 85],
    'Rn': ['Radon', 86],
    'Fr': ['Francium', 87],
    'Ra': ['Radium', 88],
    'Ac': ['Actinium', 89],
    'Th': ['Thorium', 90],
    'Pa': ['Protactinium', 91],
    'U': ['Uranium', 92],
    'Np': ['Neptunium', 93],
    'Pu': ['Plutonium', 94],
    'Am': ['Americium', 95],
    'Cm': ['Curium', 96],
    'Bk': ['Berkelium', 97],
    'Cf': ['Californium', 98],
    'Es': ['Einsteinium', 99],
    'Fm': ['Fermium', 100],
    'Md': ['Mendelevium', 101],
    'No': ['Nobelium', 102],
    'Lr': ['Lawrencium', 103],
    'Rf': ['Rutherfordium', 104],
    'Db': ['Dubnium', 105],
    'Sg': ['Seaborgium', 106],
    'Bh': ['Bohrium', 107],
    'Hs': ['Hassium', 108],
    'Mt': ['Meitnerium', 109],
    'Ds': ['Darmstadtium', 110],
    'Rg': ['Roentgenium', 111],
    'Cn': ['Copernicium', 112],
    'Uut': ['Ununtrium', 113],
    'Fl': ['Flerovium', 114],
    'Uup': ['Ununpentium', 115],
    'Lv': ['Livermorium', 116],
    'Uus': ['Ununseptium', 117],
    'Uuo': ['Ununoctium', 118]
}


'''

@@@~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~*~._.~@8-<

MAIN FUNCTIONALITY...  

'''


class Radionuclide:

    """
    Obtain all decay info given in ICRP107 for entered radionuclide.
    Must use 'dashed' notation (e.g. Zr-89, Tc-99m).
    """

    def __init__(self, entry):

        # Get basic data from NDX file

        self.element = entry.split('-')[0]
        print('Element:  ' + self.element)

        self.isotope = entry
        print('Isotope:  ' + self.isotope)

        self.element_fullname = element_info_dict[self.element][0]
        print('Element name:  ' + self.element_fullname)

        self.atomic_number = element_info_dict[self.element][1]
        print('Atomic number:  ' + str(self.atomic_number))

        self.mass_number = int(''.join(c for c in entry.split('-')[1] if c.isdigit()))
        print('Mass number:  ' + str(self.mass_number))

        self.neutron_number = self.mass_number - self.atomic_number
        print('Number of neutrons:  ' + str(self.neutron_number))

        self.half_life_string = ndx_dict[entry][7:17].strip()
        print('Half-life (string):  ' + self.half_life_string)
        self.half_life_numeric = float(ndx_dict[entry][7:15])
        # print('Half-life:  ' + str(self.half_life_numeric))
        self.half_life_unit = ndx_dict[entry][15:17].strip()
        # print('Half-life unit:  ' + self.half_life_unit)
        self.half_life_seconds = self.TimeConverter(self.half_life_numeric, self.half_life_unit, 's')
        print('Half-life [s]:  ' + str(self.half_life_seconds))

        self.decay_constant = math.log(2) / self.half_life_seconds
        print('Decay constant [1/s]:  ' + str(self.decay_constant))

        self.decay_modes_string = ndx_dict[entry][17:25].strip()
        print('Decay modes:  ' + self.decay_modes_string)

        self.decay_modes_list = []
        for decay_mode in ['A', 'B-', 'B+', 'EC', 'IT', 'SF']:
            if decay_mode in self.decay_modes_string:
                self.decay_modes_list.append(decay_mode)

        plain_to_elegant = {'A': '\u03b1', 'B-': '\u03b2-', 'B+': '\u03b2+', 'EC': 'Electron capture', 'IT': 'Internal transition', 'SF': 'Spontaneus fission'}
        self.decay_modes_list_elegant = [plain_to_elegant[x] for x in self.decay_modes_list]
        self.decay_modes_string_elegant = ', '.join(self.decay_modes_list_elegant)

        self.rad_pointer = int(ndx_dict[entry][25:32])
        print('ICRP-07.RAD file index:  ' + str(self.rad_pointer))

        self.bet_pointer = int(ndx_dict[entry][32:39])
        print('ICRP-07.BET file index:  ' + str(self.bet_pointer))

        self.ack_pointer = int(ndx_dict[entry][39:46])
        print('ICRP-07.ACK file index:  ' + str(self.ack_pointer))

        self.nsf_pointer = int(ndx_dict[entry][46:52])
        print('ICRP-07.NSF file index:  ' + str(self.nsf_pointer))

        self.daughter_1 = ndx_dict[entry][53:60].strip()
        print('Daughter #1:  ' + self.daughter_1)

        self.daughter_1_pointer = int(ndx_dict[entry][60:66])
        print('Daughter #1 pointer:  ' + str(self.daughter_1_pointer))

        self.daughter_1_branching = float(ndx_dict[entry][66:77])
        print('Daughter #1 branching fraction:  ' + str(self.daughter_1_branching))

        self.daughter_2 = ndx_dict[entry][78:85].strip()
        print('Daughter #2:  ' + self.daughter_2)

        self.daughter_2_pointer = int(ndx_dict[entry][85:91])
        print('Daughter #2 pointer:  ' + str(self.daughter_2_pointer))

        self.daughter_2_branching = float(ndx_dict[entry][91:102])
        print('Daughter #2 branching fraction:  ' + str(self.daughter_2_branching))

        self.daughter_3 = ndx_dict[entry][103:110].strip()
        print('Daughter #3:  ' + self.daughter_3)

        self.daughter_3_pointer = int(ndx_dict[entry][110:116])
        print('Daughter #3 pointer:  ' + str(self.daughter_3_pointer))

        self.daughter_3_branching = float(ndx_dict[entry][116:127])
        print('Daughter #3 branching fraction:  ' + str(self.daughter_3_branching))

        self.daughter_4 = ndx_dict[entry][128:135].strip()
        print('Daughter #4:  ' + self.daughter_4)

        self.daughter_4_pointer = int(ndx_dict[entry][135:141])
        print('Daughter #4 pointer:  ' + str(self.daughter_4_pointer))

        self.daughter_4_branching = float(ndx_dict[entry][141:152])
        print('Daughter #4 branching fraction:  ' + str(self.daughter_4_branching))

        daughters_list = []
        daughters_dict = {self.daughter_1: self.daughter_1_branching, self.daughter_2: self.daughter_2_branching, self.daughter_3: self.daughter_3_branching, self.daughter_4: self.daughter_4_branching}
        for daughter, branching_ratio in daughters_dict.items():
            if branching_ratio != 0.0:
                daughters_list.append(f"{daughter} ({self.RoundToNSignificantDigits(branching_ratio * 100, 3)}%)")
        self.daughters = ", ".join(each for each in daughters_list)
        print('Daughters:  ' + self.daughters)

        radioactive_daughters = []
        for daughter in daughters_dict.keys():
            if daughter in all_radionuclides:
                radioactive_daughters.append(daughter)
        self.radioactive_daughters = 'None'
        if len(radioactive_daughters) > 0:
            self.radioactive_daughters = ", ".join(each for each in radioactive_daughters)
        print('Radioactive daughters:  ' + self.radioactive_daughters)

        self.alpha_energy_mean = float(ndx_dict[entry][152:159])
        print('Mean alpha energy [MeV]:  ' + str(self.alpha_energy_mean))

        self.electron_energy_mean = float(ndx_dict[entry][159:167])
        print('Mean electron energy [MeV]:  ' + str(self.electron_energy_mean))

        self.photon_energy_mean = float(ndx_dict[entry][167:175])
        print('Mean photon energy [MeV]:  ' + str(self.photon_energy_mean))

        self.photon_lines_under10keV = int(ndx_dict[entry][175:179])
        print('Photon lines < 10 keV [#/nt]:  ' + str(self.photon_lines_under10keV))

        self.photon_lines_over10keV = int(ndx_dict[entry][179:183])
        print('Photon lines > 10 keV [#/nt]:  ' + str(self.photon_lines_over10keV))

        self.beta_lines = int(ndx_dict[entry][183:187])
        print('Beta lines [#/nt]:  ' + str(self.beta_lines))

        self.monoenergetic_electron_lines = int(ndx_dict[entry][187:192])
        print('Monoenergetic electron lines [#/nt]:  ' + str(self.monoenergetic_electron_lines))

        self.alpha_lines = int(ndx_dict[entry][192:196])
        print('Alpha lines [#/nt]:  ' + str(self.alpha_lines))

        self.isotopic_mass = float(ndx_dict[entry][196:207])
        print('Isotopic mass [amu]:  ' + str(self.isotopic_mass))

        self.mass_excess_amu = self.isotopic_mass - self.mass_number
        self.mass_excess_MeV = self.mass_excess_amu * 931.49
        print('Mass excess [MeV]:  ' + str(self.mass_excess_MeV))

        self.mass_defect = 938.28 * self.atomic_number + 939.57 * self.neutron_number - self.isotopic_mass * 931.49
        print('Mass defect [MeV/c^2]:  ' + str(self.mass_defect))

        self.binding_energy = self.mass_defect
        print('Binding energy [MeV]:  ' + str(self.binding_energy))

        self.binding_energy_per_nucleon = self.binding_energy / (self.atomic_number + self.neutron_number)
        print('Binding energy per nucleon [MeV/nucleon]:  ' + str(self.binding_energy_per_nucleon))

        self.air_kerma_rate_constant = float(ndx_dict[entry][207:217])
        print('Air kerma rate constant, Gamma_10 [(Gy*m^2)/(Bq*s)]:  ' + str(self.air_kerma_rate_constant))

        self.air_kerma_coefficient = float(ndx_dict[entry][217:226])
        print('Air kerma coefficient, K_air [(Gy*m^2)/(Bq*s)]:  ' + str(self.air_kerma_coefficient))

        self.equilibrium_dose_constant_np = (self.alpha_energy_mean + self.electron_energy_mean) * 1.60218e-13
        print('Equilibrium dose constant for weakly-penetrating radiations, Delta_np [(kg*Gy)/(Bq*s)]:  ' + str(self.equilibrium_dose_constant_np))

    def GetRadiations(self, data_format='Dataframe'):
        """
        Get list of radiations in ICRP-07.RAD
        :param data_format: 'MIRD3d', 'ICRP-07s', 'ICRP-07d', 'Dataframe'
        :return: dictionary with keys = radiation type, values = list of tuples of (energy in MeV, number per nuclear transformation)
        """
        # print('Reading ICRP107 ICRP-07.RAD ...')
        with open(rad_datafile, 'r') as f:
            rad_data = f.readlines()
            radiations_by_simple_type = {}
            radiations_by_detailed_type = {}
            radiations_by_mird3d_type = {}
            radiations = []

            rad_start_line = self.rad_pointer
            rad_end_line = rad_start_line + int(rad_data[rad_start_line - 1].split()[2])
            radionuclide_data = rad_data[rad_start_line:rad_end_line]
            i = 0
            for line in radionuclide_data:
                line = line.strip().split()
                icode = int(line[0])
                radiation_yield = float(line[1])
                energy = float(line[2])
                jcode = line[3]
                simple_name = icode_to_simple_type[icode]
                detailed_name = jcode_to_detailed_type[jcode]

                mird3d_name = 'Ignored'
                try:
                    mird3d_name = icode_to_mird3d_type[icode]
                except KeyError:
                    pass
                if simple_name not in radiations_by_simple_type.keys():
                    radiations_by_simple_type[simple_name] = [(energy, radiation_yield)]
                else:
                    radiations_by_simple_type[simple_name].append((energy, radiation_yield))
                if detailed_name not in radiations_by_detailed_type.keys():
                    radiations_by_detailed_type[detailed_name] = [(energy, radiation_yield)]
                else:
                    radiations_by_detailed_type[detailed_name].append((energy, radiation_yield))
                if mird3d_name != 'Ignored':
                    if mird3d_name not in radiations_by_mird3d_type.keys():
                        radiations_by_mird3d_type[mird3d_name] = [(energy, radiation_yield)]
                    else:
                        radiations_by_mird3d_type[mird3d_name].append((energy, radiation_yield))

                radiations.append((energy, radiation_yield, simple_name, detailed_name, mird3d_name))
                i += 1
            
            # print('ICRP-07 emissions, simplified (energy [MeV], yield [#/nt]):  ' + str(radiations_by_simple_type))
            # print('ICRP-07 emissions, detailed (energy [MeV], yield [#/nt]):  ' + str(radiations_by_detailed_type))
            # print('MIRD3d emissions (energy [MeV], yield [#/nt]):  ' + str(radiations_by_mird3d_type))

            df = pd.DataFrame(data=radiations, columns=['Energy [MeV]', 'Yield [#/nt]', 'Type (simple)', 'Type (detailed)', 'Type (MIRD3d)'])

            if data_format == 'MIRD3d':
                return radiations_by_mird3d_type
            if data_format == 'ICRP-07s':
                return radiations_by_simple_type
            if data_format == 'ICRP-07d':
                return radiations_by_detailed_type
            if data_format == 'Dataframe':
                return df

    def GetYield(self, particle, particle_type='MIRD3d'):
        """
        Get total yield per nt for specified emission.
        :param particle: Alpha, Alpha recoil, Beta, Positron, Gamma, Prompt gamma, Delayed gamma, X-ray, Auger electron, Conversion electron, Monoenergetic electron, Neutron, FF, Annihilation photon
        :param particle_type: simple, detailed, MIRD3d
        :return: yield (float)
        """
        emissions_df = self.GetRadiations(data_format='Dataframe')
        emission_yield = emissions_df.loc[emissions_df['Type (' + particle_type + ')'] == particle, 'Yield [#/nt]'].sum()
        return emission_yield

    def GetDelta(self, particle, particle_type="MIRD3d"):
        """
                Get total yield * energy, per nt for specified emission.
                :param particle: Alpha, Alpha recoil, Beta, Positron, Gamma, Prompt gamma, Delayed gamma, X-ray, Auger electron, Conversion electron, Monoenergetic electron, Neutron, FF, Annihilation photon
                :param particle_type: simple, detailed, MIRD3d
                :return: delta [MeV/nt] (float)
                """
        emissions_df = self.GetRadiations(data_format='Dataframe')
        emission_yields = emissions_df.loc[emissions_df['Type (' + particle_type + ')'] == particle, 'Yield [#/nt]']
        emission_energies = emissions_df.loc[emissions_df['Type (' + particle_type + ')'] == particle, 'Energy [MeV]']
        emission_deltas = emission_yields.mul(emission_energies)
        emission_delta = emission_deltas.sum()
        return emission_delta

    def GetSpectraSummaryByType(self, particle_type='MIRD3d'):
        emissions_df = self.GetRadiations(data_format='Dataframe')
        for each in ['Type (simple)', 'Type (detailed)', 'Type (MIRD3d)']:
            if each != f"Type ({particle_type})":
                emissions_df = emissions_df.drop(each, 1)
        return emissions_df

    def GetSpectraBeta(self, data_format='Dataframe'):
        """
        Get list of beta radiations in ICRP-07.BET
        :param data_format: List or Dataframe
        :return: list of tuples of (energy in MeV, number per nuclear transformation per MeV), or Pandas Dataframe
        """
        # print('Reading ICRP107 ICRP-07.BET ...')
        if self.bet_pointer != 0:
            with open(bet_datafile, 'r') as f:
                bet_data = f.readlines()
                beta_spectra = []
                bet_start_line = self.bet_pointer
                bet_end_line = bet_start_line + int(bet_data[bet_start_line - 1].split()[1])
                radionuclide_data = bet_data[bet_start_line:bet_end_line]
                for line in radionuclide_data:
                    line = line.strip().split()
                    energy = float(line[0])
                    probability_density = float(line[1])
                    beta_spectra.append((energy, probability_density))
                beta_spectra_df = pd.DataFrame(data=beta_spectra, columns=['Energy [MeV]', 'Probability density [#/MeV/nt]'])

            # print('Beta spectra (energy [MeV], probability [#/MeV/nt]):  ' + str(beta_spectra))

            if data_format == 'List':
                return beta_spectra
            else:
                return beta_spectra_df
        print('No beta spectra found.')

    def GetSpectraAuger(self, data_format='Dataframe'):
        """
        Get list of beta radiations in ICRP-07.ACK
        :param data_format: 'List' or 'Dataframe'
        :return: list of tuples of (energy in MeV, number per nuclear transformation) or Pandas Dataframe
        """
        # print('Reading ICRP107 ICRP-07.ACK ...')
        if self.ack_pointer != 0:
            with open(ack_datafile, 'r') as f:
                ack_data = f.readlines()
                ack_spectra = []
                ack_start_line = self.ack_pointer
                ack_end_line = ack_start_line + int(ack_data[ack_start_line - 1].split()[2])
                radionuclide_data = ack_data[ack_start_line:ack_end_line]
                for line in radionuclide_data:
                    line = line.strip().split()
                    energy = float(line[1])
                    radiation_yield = float(line[0])
                    core_hole = line[2]
                    relaxing_electron_initial_state = line[3]
                    emitted_electron_initial_state = line[4]
                    transition = " ".join([core_hole, relaxing_electron_initial_state, emitted_electron_initial_state])
                    ack_spectra.append((energy, radiation_yield, transition))
                ack_spectra_df = pd.DataFrame(data=ack_spectra, columns=['Energy [eV]', 'Yield [#/nt]', 'Transition'])

            # print('Auger/Coster-Kronig spectra (energy [eV], yield [#/nt]):  ' + str(ack_spectra))

            if data_format == 'List':
                return ack_spectra
            else:
                return ack_spectra_df
        print('No Auger/Coster-Kronig spectra found.')

    @staticmethod
    def TimeConverter(input_time, input_unit, output_unit='s'):
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

    @staticmethod
    def RoundToNSignificantDigits(x, n):
        return round(x, -int(floor(log10(x))) + (n - 1))

    def PlotSpectraSummary(self, particle_type='MIRD3d', save_path=None):
        """
        Plot the data.
        :param particle_type: simple, detailed, MIRD3d
        :return:
        """
        import seaborn as sns
        sns.set(rc={'figure.figsize':(7.5, 3.0)})

        import matplotlib.pyplot as plt
        plt.rcParams.update({'font.sans-serif': 'Century Gothic'})
        plt.rcParams.update({'font.family': 'sans-serif'})
        plt.rcParams.update({
            # "figure.facecolor": (1.0, 0.0, 0.0, 0.3),  # red   with alpha = 30%
            # "axes.facecolor": (0.0, 1.0, 0.0, 0.5),  # green with alpha = 50%
            "savefig.facecolor": (0.0, 0.0, 0.0, 0.0),  # black with alpha = 20%
        })

        from matplotlib.patches import Patch
        from matplotlib.lines import Line2D
        print(f"Plotting summary data for {self.isotope}...")

        # Get colormap
        particle_type_to_colormap = {'simple': simple_colormap, 'detailed': detailed_colormap, 'MIRD3d': mird3d_colormap}
        colormap = particle_type_to_colormap[particle_type]

        data = self.GetRadiations()

        # Get rid of unneeded columns and rows
        data = data.filter(['Energy [MeV]', 'Yield [#/nt]', 'Type (' + particle_type + ')'])
        data = data.loc[data['Type (' + particle_type + ')'] != 'Ignored']

        # Get set of listed radiations
        listed_radiations = list(set(data[('Type (' + particle_type + ')')]))
        print(listed_radiations)

        # Setup plot
        fig, ax = plt.subplots()

        # Generate each series in the plot
        for each in listed_radiations:
            df = data[data['Type (' + particle_type + ')'] == each]
            ax.scatter(df['Energy [MeV]'], df['Yield [#/nt]'], color=colormap[each], marker=' ')
            ax.vlines(df['Energy [MeV]'], ymin=0, ymax=df['Yield [#/nt]'], color=colormap[each])

        # Produce a legend with the unique colors from the scatter

        # EXAMPLES
        # legend_elements = [Line2D([0], [0], color='b', lw=4, label='Line'),
        #                    Line2D([0], [0], marker='o', color='w', label='Scatter', markerfacecolor='g', markersize=15),
        #                    Patch(facecolor='orange', edgecolor='r', label='Color Patch')]

        legend_elements = []
        for each in listed_radiations:
            legend_elements.append(Line2D([0], [0], color=colormap[each], lw=0, marker='o', markersize=5, label=each))
        ax.legend(handles=legend_elements, loc="upper right")
        ax.set_yscale('log')
        ax.set_ylabel('Yield [#/nt]')
        ax.set_xscale('log')
        ax.set_xlabel('Energy [MeV]')

        # Set gridlines
        ax.axes.get_xaxis().set_visible(True)
        ax.axes.get_yaxis().set_visible(True)
        ax.grid(b=True, which='major', color='w', linewidth=1.0)
        ax.grid(b=True, which='minor', color='w', linewidth=0.5)

        plt.tight_layout()
        if save_path is None:
            plt.show()
        else:
            plt.savefig(save_path + "\\" + nuclide.isotope + " Summary Spectrum.png")
            plt.close()

    def PlotSpectraBeta(self, save_path=None):
        """
        Plot the beta spectrum.
        :return:
        """
        import seaborn as sns
        sns.set(rc={'figure.figsize':(7.5, 3.0)})

        import matplotlib.pyplot as plt
        plt.rcParams.update({'font.sans-serif': 'Century Gothic'})
        plt.rcParams.update({'font.family': 'sans-serif'})
        plt.rcParams.update({
            # "figure.facecolor": (1.0, 0.0, 0.0, 0.3),  # red   with alpha = 30%
            # "axes.facecolor": (0.0, 1.0, 0.0, 0.5),  # green with alpha = 50%
            "savefig.facecolor": (0.0, 0.0, 0.0, 0.0),  # black with alpha = 20%
        })

        from matplotlib.patches import Patch
        from matplotlib.lines import Line2D
        print(f"Plotting beta spectrum for {self.isotope}...")

        data = self.GetSpectraBeta()

        # Setup plot
        fig, ax = plt.subplots()

        # Generate each series in the plot
        df = data
        # ax.plot(df['Energy [MeV]'], df['Probability density [#/MeV/nt]'], color='gray')
        # Shade the area between y1 and line y=0
        ax.fill_between(df['Energy [MeV]'], df['Probability density [#/MeV/nt]'], 0, color='gray', alpha=0.5)

        legend_elements = [Line2D([0], [0], color='gray', lw=0, marker='o', markersize=5, label='Beta')]
        ax.legend(handles=legend_elements, loc="upper right")
        # ax.set_yscale('log')
        ax.set_ylabel('Probability density [#/MeV/nt]')
        # ax.set_xscale('log')
        ax.set_xlabel('Energy [MeV]')

        # Set gridlines
        ax.axes.get_xaxis().set_visible(True)
        ax.axes.get_yaxis().set_visible(True)
        ax.grid(b=True, which='major', color='w', linewidth=1.0)
        ax.grid(b=True, which='minor', color='w', linewidth=0.5)

        plt.tight_layout()
        if save_path is None:
            plt.show()
        else:
            plt.savefig(save_path + "\\" + nuclide.isotope + " Beta Spectrum.png")
            plt.close()

    def PlotSpectraAuger(self, save_path=None):
        """
        Plot the fully detailed Auger spectra.
        :return:
        """
        import seaborn as sns
        sns.set(rc={'figure.figsize':(7.5, 3.0)})

        import matplotlib.pyplot as plt
        plt.rcParams.update({'font.sans-serif': 'Century Gothic'})
        plt.rcParams.update({'font.family': 'sans-serif'})
        plt.rcParams.update({
            # "figure.facecolor": (1.0, 0.0, 0.0, 0.3),  # red   with alpha = 30%
            # "axes.facecolor": (0.0, 1.0, 0.0, 0.5),  # green with alpha = 50%
            "savefig.facecolor": (0.0, 0.0, 0.0, 0.0),  # black with alpha = 20%
        })

        from matplotlib.patches import Patch
        from matplotlib.lines import Line2D
        print(f"Plotting Auger spectrum for {self.isotope}...")

        data = self.GetSpectraAuger()

        # Setup plot
        fig, ax = plt.subplots()

        # Generate each series in the plot
        df = data
        # Shade the area between y1 and line y=0
        ax.scatter(df['Energy [eV]'], df['Yield [#/nt]'], color='gray', marker=' ')
        ax.vlines(df['Energy [eV]'], ymin=0, ymax=df['Yield [#/nt]'], color='gray')

        legend_elements = [Line2D([0], [0], color='gray', lw=0, marker='o', markersize=5, label='Auger C-K')]
        ax.legend(handles=legend_elements, loc="upper right")
        ax.set_yscale('log')
        ax.set_ylabel('Yield [#/nt]')
        ax.set_xscale('log')
        ax.set_xlabel('Energy [eV]')

        # Set gridlines
        ax.axes.get_xaxis().set_visible(True)
        ax.axes.get_yaxis().set_visible(True)
        ax.grid(b=True, which='major', color='w', linewidth=1.0)
        ax.grid(b=True, which='minor', color='w', linewidth=0.5)

        plt.tight_layout()
        if save_path is None:
            plt.show()
        else:
            plt.savefig(save_path + "\\" + nuclide.isotope + " Auger Spectrum.png")
            plt.close()

    def GetDosePointKernels(self):
        """
            Get DataFrame of Graves et al. (Med. Phys. 2019) dose point kernels for each particle type {electron (CE & Auger), beta (positron & negatron), gamma (X-ray or gamma)}
            :return: DataFrame
        """
        dpk_df = None
        for file in os.listdir(dpk_path):
            dpk_isotope = file.split("_")[0]
            dpk_half_life_string = file.split("_")[1].lower()
            dpk_particle = file.split("_")[2].split('.')[0]  # beta, electron, or gamma

            unit_len = 0
            for each in dpk_half_life_string[::-1]:
                if each.isalpha():
                    unit_len += 1
                else:
                    break
            dpk_half_life_numeric = float(dpk_half_life_string[:-unit_len])
            dpk_half_life_unit = dpk_half_life_string[-unit_len:]
            dpk_half_life_seconds = self.TimeConverter(dpk_half_life_numeric, dpk_half_life_unit)


            dpk_particles = ['beta', 'electron', 'gamma']

            if f"{self.mass_number}{self.element.upper()}" == dpk_isotope and math.isclose(self.half_life_seconds, dpk_half_life_seconds, rel_tol=0.1):
                # Get dpk as list of lists for each particle type [['Outer radius (cm)', 'Absorbed dose per decay (Gy/Bq*s)'],...]
                dpk_lol = []
                dpk_doseonly_list = []
                with open(dpk_path + "\\" + file, 'r') as f:
                    lines = f.readlines()
                    for line in lines[2:]:
                        line = line.strip().split(',')
                        radius = float(line[0])
                        dose = float(line[4]) * 1.60218E-13 * 1000  # MeV/g/nt to Gy/nt
                        dpk_lol.append([radius, dose])
                        dpk_doseonly_list.append(dose)
                if dpk_df is None:
                    dpk_df = pd.DataFrame(data=dpk_lol, columns=['Outer radius [cm]', f"Absorbed dose, {dpk_particle} [Gy/nt]"])
                else:
                    dpk_df[f"Absorbed dose, {dpk_particle} [Gy/nt]"] = dpk_doseonly_list
            else:
                pass
        return dpk_df

    def PlotDosePointKernel(self, save_path=None):
        """
        Plot the dose point kernel for specified particle type
        :return:
        """
        import seaborn as sns
        sns.set(rc={'figure.figsize':(7.5, 3.0)})

        import matplotlib.pyplot as plt
        plt.rcParams.update({'font.sans-serif': 'Century Gothic'})
        plt.rcParams.update({'font.family': 'sans-serif'})
        plt.rcParams.update({
            # "figure.facecolor": (1.0, 0.0, 0.0, 0.3),  # red   with alpha = 30%
            # "axes.facecolor": (0.0, 1.0, 0.0, 0.5),  # green with alpha = 50%
            "savefig.facecolor": (0.0, 0.0, 0.0, 0.0),  # black with alpha = 20%
        })

        from matplotlib.patches import Patch
        from matplotlib.lines import Line2D
        print(f"Plotting dose-point kernel for {self.isotope}...")

        data = self.GetDosePointKernels()

        # Setup plot
        fig, ax = plt.subplots()

        # Generate each series in the plot
        df = data
        particles = ['beta', 'electron', 'gamma']
        color = {'beta': '#1f4d44', 'electron': '#73216c', 'gamma': '#2f302e'}
        name = {'beta': 'Positron/negatron', 'electron': 'Conversion/Auger electron', 'gamma': 'X-/gamma ray'}

        legend_elements = []
        for each in particles:
            try:
                ax.plot(df['Outer radius [cm]'], df[f"Absorbed dose, {each} [Gy/nt]"], color=f"{color[each]}", marker=' ')
                legend_elements.append(Line2D([0], [0], color=f"{color[each]}", lw=0, marker='o', markersize=5, label=f"{name[each]}"))
                ax.legend(handles=legend_elements, loc="upper right")
            except KeyError:
                pass

        ax.set_yscale('log')
        ax.set_ylabel('Absorbed dose [Gy/nt]')
        ax.set_xscale('log')
        ax.set_xlabel('Outer radius [cm]')

        # Set gridlines
        ax.axes.get_xaxis().set_visible(True)
        ax.axes.get_yaxis().set_visible(True)
        ax.grid(b=True, which='major', color='w', linewidth=1.0)
        ax.grid(b=True, which='minor', color='w', linewidth=0.5)

        plt.tight_layout()
        if save_path is None:
            plt.show()
        else:
            plt.savefig(save_path + "\\" + nuclide.isotope + f" DPK.png")
            plt.close()


if __name__ == "__main__":
    # To use from Blender
    # nuclide = Radionuclide(sys.argv[0])  # TODO: Blender only!

    # to do all
    nuclide_list = []
    with open(r"C:\Users\carterl1\PycharmProjects\ImageProcessing\Lib\ICRP-07.NDX", 'r') as f:
        lines = f.readlines()
        for line in lines[1:]:
            line = line.split()[0]
            nuclide_list.append(line)
    print(nuclide_list)

    # To use normally
    # nuclide = Radionuclide("Y-90")
    start_nuclide = "N-16"
    start_nuclide_index = nuclide_list.index(start_nuclide)

    for each in nuclide_list[start_nuclide_index:]:
        nuclide = Radionuclide(each)
        save_path = r"C:\Users\carterl1\Desktop\Spectra Figures"
        dpk_save_path = r"C:\Users\carterl1\Desktop\Spectra Figures\DPK"
        summary_save_path = r"C:\Users\carterl1\Desktop\Spectra Figures\SummaryRadiations"
        beta_save_path = r"C:\Users\carterl1\Desktop\Spectra Figures\Beta"
        auger_save_path = r"C:\Users\carterl1\Desktop\Spectra Figures\Auger"

        print("Monoenergetic electron yield:  " + str(nuclide.GetYield('Monoenergetic electron')))
        print("Beta yield:  " + str(nuclide.GetYield('Beta')))

        print(nuclide.GetSpectraSummaryByType(particle_type='detailed'))
        nuclide.PlotSpectraSummary(particle_type='detailed', save_path=summary_save_path)
        if nuclide.GetSpectraBeta() is not None:
            print(nuclide.GetSpectraBeta())
            nuclide.PlotSpectraBeta(save_path=beta_save_path)
        if nuclide.GetSpectraAuger() is not None:
            print(nuclide.GetSpectraAuger())
            nuclide.PlotSpectraAuger(save_path=auger_save_path)

        print(nuclide.GetDosePointKernels())
        try:
            nuclide.PlotDosePointKernel(save_path=dpk_save_path)
        except TypeError:
            print("NO DOSE-POINT KERNEL AVAILABLE!!!")
