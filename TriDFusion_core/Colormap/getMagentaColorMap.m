function aColormap = getMagentaColorMap()    
%function aColormap = getMagentaColorMap()
%Get Magenta Color Map.
%See TriDFuison.doc (or pdf) for more information about options.
%
%Note: option settings must fit on one line and can contain one semicolon at most.
%Options can be strings, cell arrays of strings, or numerical arrays.
%
%Author: Daniel Lafontaine, lafontad@mskcc.org
%
%Last specifications modified:
%
% Copyright 2020, Daniel Lafontaine, on behalf of the TriDFusion development team.
% 
% This file is part of The Triple Dimention Fusion (TriDFusion).
% 
% TriDFusion development has been led by:  Daniel Lafontaine
% 
% TriDFusion is distributed under the terms of the Lesser GNU Public License. 
% 
%     This version of TriDFusion is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
% TriDFusion is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
% without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
% See the GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with TriDFusion.  If not, see <http://www.gnu.org/licenses/>.
aColormap = [
    0	0	0    
    1	0	1
    2	0	2
    3	0	3
    4	0	4
    5	0	5
    6	0	6
    7	0	7
    8	0	8
    9	0	9
    10	0	10
    11	0	11
    12	0	12
    13	0	13
    14	0	14
    15	0	15
    16	0	16
    17	0	17
    18	0	18
    19	0	19
    20	0	20
    21	0	21
    22	0	22
    23	0	23
    24	0	24
    25	0	25
    26	0	26
    27	0	27
    28	0	28
    29	0	29
    30	0	30
    31	0	31
    32	0	32
    33	0	33
    34	0	34
    35	0	35
    36	0	36
    37	0	37
    38	0	38
    39	0	39
    40	0	40
    41	0	41
    42	0	42
    43	0	43
    44	0	44
    45	0	45
    46	0	46
    47	0	47
    48	0	48
    49	0	49
    50	0	50
    51	0	51
    52	0	52
    53	0	53
    54	0	54
    55	0	55
    56	0	56
    57	0	57
    58	0	58
    59	0	59
    60	0	60
    61	0	61
    62	0	62
    63	0	63
    64	0	64
    65	0	65
    66	0	66
    67	0	67
    68	0	68
    69	0	69
    70	0	70
    71	0	71
    72	0	72
    73	0	73
    74	0	74
    75	0	75
    76	0	76
    77	0	77
    78	0	78
    79	0	79
    80	0	80
    81	0	81
    82	0	82
    83	0	83
    84	0	84
    85	0	85
    86	0	86
    87	0	87
    88	0	88
    89	0	89
    90	0	90
    91	0	91
    92	0	92
    93	0	93
    94	0	94
    95	0	95
    96	0	96
    97	0	97
    98	0	98
    99	0	99
    100	0	100
    101	0	101
    102	0	102
    103	0	103
    104	0	104
    105	0	105
    106	0	106
    107	0	107
    108	0	108
    109	0	109
    110	0	110
    111	0	111
    112	0	112
    113	0	113
    114	0	114
    115	0	115
    116	0	116
    117	0	117
    118	0	118
    119	0	119
    120	0	120
    121	0	121
    122	0	122
    123	0	123
    124	0	124
    125	0	125
    126	0	126
    127	0	127
    128	0	128
    129	0	129
    130	0	130
    131	0	131
    132	0	132
    133	0	133
    134	0	134
    135	0	135
    136	0	136
    137	0	137
    138	0	138
    139	0	139
    140	0	140
    141	0	141
    142	0	142
    143	0	143
    144	0	144
    145	0	145
    146	0	146
    147	0	147
    148	0	148
    149	0	149
    150	0	150
    151	0	151
    152	0	152
    153	0	153
    154	0	154
    155	0	155
    156	0	156
    157	0	157
    158	0	158
    159	0	159
    160	0	160
    161	0	161
    162	0	162
    163	0	163
    164	0	164
    165	0	165
    166	0	166
    167	0	167
    168	0	168
    169	0	169
    170	0	170
    171	0	171
    172	0	172
    173	0	173
    174	0	174
    175	0	175
    176	0	176
    177	0	177
    178	0	178
    179	0	179
    180	0	180
    181	0	181
    182	0	182
    183	0	183
    184	0	184
    185	0	185
    186	0	186
    187	0	187
    188	0	188
    189	0	189
    190	0	190
    191	0	191
    192	0	192
    193	0	193
    194	0	194
    195	0	195
    196	0	196
    197	0	197
    198	0	198
    199	0	199
    200	0	200
    201	0	201
    202	0	202
    203	0	203
    204	0	204
    205	0	205
    206	0	206
    207	0	207
    208	0	208
    209	0	209
    210	0	210
    211	0	211
    212	0	212
    213	0	213
    214	0	214
    215	0	215
    216	0	216
    217	0	217
    218	0	218
    219	0	219
    220	0	220
    221	0	221
    222	0	222
    223	0	223
    224	0	224
    225	0	225
    226	0	226
    227	0	227
    228	0	228
    229	0	229
    230	0	230
    231	0	231
    232	0	232
    233	0	233
    234	0	234
    235	0	235
    236	0	236
    237	0	237
    238	0	238
    239	0	239
    240	0	240
    241	0	241
    242	0	242
    243	0	243
    244	0	244
    245	0	245
    246	0	246
    247	0	247
    248	0	248
    249	0	249
    250	0	250
    251	0	251
    252	0	252
    253	0	253
    254	0	254
    255	0	255
    ] / 255;
end

