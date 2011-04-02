#!/usr/bin/python

######################################################################
# -*- coding: utf-8 -*-                                              #
#                                                                    #
# FILE : make.conf.tpl                                               #
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

# neco se musi (pri zapisu do make.conf) setnout (napr. licence, linguas,
# cflagy), neco appendnout (unikatne). vysvetleni co je co je v todo.
# i kdyz budou mit make.conf veci nejake default nastaveni ve var/core-makeconf/default
# melo by byt mozne je prepsat pouzitim nejakeho (uzivateli vlastniho)
# var/core-makeconf/mujskript skriptu ktery udela co chci ja.
# toto zde je jen nastrel v promennych protoze nevim jake metody nakonec budeme mit
make['ACCEPT_LICENSE'] 		= "PUEL skype-eula dlj-1.1 AdobeFlash-10.1" #a1
make['LINGUAS']        		= "en" #s
make['CFLAGS']         		= "-O2 -pipe -march=native" #s
make['CXXFLAGS']		= make['CFLAGS'] #s
make['LDFLAGS']			= "-Wl,--as-needed" #s

# potrebuje zkontrolovat proti 64bitovosti
make['CHOST']			= "x86_64-pc-linux-gnu" #s
make['USE']			= "" #a1

# potrebuje nastavit podle poctu cores
make['EMERGE_DEFAULT_OPTS'] 	= "--verbose --keep-going --jobs 3" #s
make['FEATURES']		= "parallel-fetch userfetch usersync usersandbox userpriv metadata-transfer collision-protect" #s

# potrebuje nastavit podle poctu cores
make['MAKEOPTS'] 		= "-j2" #s
make['PORTAGE_NICENESS']	= "0" #s

# potrebuje nastavit podle hwdetect
make['VIDEO_CARDS']		= "intel" #s
make['INPUT_DEVICES']		= "evdev" #s
make['GENTOO_MIRRORS']		= "http://ftp.fi.muni.cz/pub/linux/gentoo/ http://gentoo.mirror.dkm.cz/pub/gentoo/ ftp://ftp.wh2.tu-dresden.de/pub/mirrors/gentoo ftp://ftp.join.uni-muenster.de/pub/linux/distributions/gentoo http://ftp-stud.hs-esslingen.de/pub/Mirrors/gentoo/ http://ftp.snt.utwente.nl/pub/os/linux/gentoo" #a1
make['SYNC']			= "rsync://rsync.europe.gentoo.org/gentoo-portage" #s
make['PORTDIR_OVERLAY']		= "${PORTDIR_OVERLAY} /var/portage/".os['hostname'] #s

# patch make.conf aby obsahoval "source /var/portage/layman/make.conf" - hodila by se asi nejaka funkce insafter(file,value,string, [string], ...) kde string by byl string za ktery se to ma vlozit. takze insafter('/etc/make.conf',"source /var/portage/layman/make.conf",'CFLAGS','LDFLAGS') by vlozilo ten source na novy radek vlozeny pod radky na kterych je cflags a zaroven ldflags.

# TODO vyhod do /usr/lib/mage/mk-makeconf
with open('/etc/make.conf', 'wb') as configfile:
  make.write(configfile)
  


