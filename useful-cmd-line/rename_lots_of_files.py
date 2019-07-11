#!/bin/python

# rename a lot of file prefixes in a directory
# e.g. with directory contents
#   eta_daily.0000000732.data
#   eta_daily.0000000732.meta
#   eta_daily.0000002172.data
#   ...
#
# rename prefix via
#
#   old_prefix = 'eta_daily' 
#   new_prefix = 'exf_monthly'
#
# renames that prefix...
#

old_prefix = 'eta_daily'
new_prefix = 'exf_monthly'

import os

for filename in os.listdir('./'):
    if filename.startswith(old_prefix):
        print(filename)
        newname = filename.replace(old_prefix,new_prefix)
        print(' --> %s',newname)
        os.rename(filename,newname)
