"""diff forward_step_ad and taf_ad.log for adjoint experiments"""

import os
import difflib

experiments = [
    '1D_ocean_ice_column',
    'bottom_ctrl_5x5',
    'global_ocean.90x40x15',
    'global_ocean.cs32x15',
    'global_ocean_ebm',
    'global_oce_biogeo_bling',
    'global_with_exf',
    'halfpipe_streamice',
    'hs94.1x64x5',
    'isomip',
    'lab_sea',
    'obcs_ctrl',
    'offline_exf_seaice',
    'OpenAD',
    'tutorial_dic_adjoffline',
    'tutorial_global_oce_biogeo',
    'tutorial_global_oce_optim',
    'tutorial_tracer_adjsens']


files = ['forward_step_ad.f', 'taf_ad.log']

diff_dir = 'lots_of_diffs/'
if not os.path.isdir(diff_dir):
    os.makedirs(diff_dir)

for exp in experiments:

    print(f' --- {exp} --- ')
    branch_dir = f'/workspace/mitgcm_tests/shi_trans_coeff_ctrl/MITgcm/verification/{exp}/build/'
    master_dir = f'/workspace/mitgcm_tests/master.adjoint/MITgcm/verification/{exp}/build/'
    local_diff_dir = f'{diff_dir}/{exp}/'
    if not os.path.isdir(local_diff_dir):
        os.makedirs(local_diff_dir)

    for fname in files:
        print(f' --- {exp}, {fname} --- ')
        with open(branch_dir+fname, 'r') as branch, \
             open(master_dir+fname, 'r') as master, \
             open(local_diff_dir+fname,'w') as write_file:
                 mydiff = difflib.ndiff( branch.readlines(), master.readlines() )
                 delta = [line for line in mydiff if line.startswith('+ ') or line.startswith('- ')]
                 for d in delta:
                     print(d)
                     write_file.write(d)

    # compare size of binary
    branch = os.path.getsize(branch_dir+'mitgcmuv_ad') * 1e-6
    master = os.path.getsize(master_dir+'mitgcmuv_ad') * 1e-6

    print(f' -> {exp} mitgcmuv_ad size:\n\tmaster: {master}\n\tbranch: {branch}\n\tbranch-master: {branch-master}')
    print()
