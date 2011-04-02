#!/usr/bin/python

######################################################################
# -*- coding: utf-8 -*-                                              #
#                                                                    #
# FILE : kernel.py                                                   #
# CREATION DATE : 05-AUG-2010                                        #
# LAST MODIFICATION DATE : 05-AUG-2010                               #
#                                                                    #
#--------------------------------------------------------------------#
#                                                                    #
# CHANGELOG:                                                         #
# ==========                                                         #
# v0.1   05-AUG-2010   Pavel Stratil                                 #
# -Initial version                                                   #
#                                                                    #
######################################################################

from tools import *;
from collections import defaultdict;

# list of compatible profiles
whitelist = [ 'default/linux/amd64/10.0',
    'default/linux/amd64/10.0/desktop',
    'default/linux/amd64/10.0/desktop/gnome',
    'default/linux/amd64/10.0/desktop/kde',
    'default/linux/amd64/10.0/developer',
    'default/linux/amd64/10.0/server',
    'hardened/linux/amd64/10.0']

# test os['profile'] against whitelist.
# porovnej os['profile'] s hwdetect > potrebujeme nejaky indentifikator 64bitovosti
# porovnej os['profile'] s box['head'].
# hodnoty box['head'] jsou headless desktop dektop/gnome desktop/kde
# headless jde s default/linux/amd64/10.0, default/linux/amd64/10.0/developer,
#		 default/linux/amd64/10.0/server a hardened/linux/amd64/10.0
# desktopy jdou dobre s dekstop a nebo s hardenend a nebo s developer.
# pokud vybran developer profil, musi byt zaply box['developer']

