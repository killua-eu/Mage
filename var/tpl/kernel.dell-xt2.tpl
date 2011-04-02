#!/usr/bin/python

######################################################################
# -*- coding: utf-8 -*-                                              #
#                                                                    #
# FILE : kernel-dell-laptop.tpl                                      #
# CREATION DATE : 05-JAN-2011                                        #
# LAST MODIFICATION DATE : 05-JAN-2011                               #
#                                                                    #
#                                                                    #
#--------------------------------------------------------------------#
#                                                                    #
# CHANGELOG:                                                         #
# ==========                                                         #
# r1   05-JAN-2011   Pavel Stratil                                   #
# -Initial release                                                   #
#                                                                    ##                                                                    #
######################################################################

from tools import *;
from hwdetect_dump import *;
from collections import defaultdict;

#
# This template loads the machine's configuration file (see sample.conf)
# and the output of hwscan. Based upon the kernel[], box[] and hw[] values,
# kernel configuration options' values are suggested.
#
# kvote[] contains a [ 'no', 'yes' ] value tuple, used with the y/n/m choices.
# 	  example: assume kvote['swap'] = [ 'n', 'y' ], if kernel['swap'] = 1
#	  CONFIG_SWAP=y, else CONFIG_SWAP=n
# kname[] points to the location of a group of kernel config settings within the
#	  'make nconf' interface hiearchy
# kdscr[] (optional), contains description about the group of kernel config
#	  settings.
# kconf[] sets a kernel config option to a given value and provides optional
#	  description. i.e.: 
#	  kconf['iosched']['CFQ_GROUP_IOSCHED'] = [ 'y' ]
#	  kconf['iosched']['CFQ_GROUP_IOSCHED'] = [ 'y', 'BLK_CGROUP is enabled. Without CFQ_GROUP_IOSCHED set, BLK_CGROUP=y is meaningless.' ]
# krcmd[] recommended value for config group X if kernel['X'] is not defined.
# kdeps[] contains an array of userspace dependencies requiring the kernel opts.
# klist[] contains an array of a set of options, one of them must be set to yes.
#

kconf['dell-xt2']['I8K']         = [ 'y' ]
kconf['dell-xt2']['HID_NTRIG']   = [ 'y' ]
kconf['dell-xt2']['DELL_LAPTOP'] = [ 'y' ]
kconf['dell-xt2']['DELL_WMI']    = [ 'y' ]
kconf['dell-xt2']['DCDBAS']      = [ 'y' ]

