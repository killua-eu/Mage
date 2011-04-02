#!/usr/bin/python

######################################################################
# -*- coding: utf-8 -*-                                              #
#                                                                    #
# FILE : kernel.py                                                   #
# CREATION DATE : 31-JUL-2010                                        #
# LAST MODIFICATION DATE : 31-JUL-2010                               #
#                                                                    #
#                                                                    #
# Kernel.py is mage's kernel configuration dictionary. Mage uses it  #
# to search kernels for misconfiguration. This dictionary is written #
# with recent x86 laptops, desktops and servers in mind. ATM,        #
# support for embedded devices and uncommon hardware is minmal.      #
#                                                                    #
#--------------------------------------------------------------------#
#                                                                    #
# CHANGELOG:                                                         #
# ==========                                                         #
# v0.1   31-JUL-2010   Pavel Stratil                                 #
# -Initial version                                                   #
#                                                                    #
# v0.2   06-AUG-2010   Jaromir Capik                                 #
# -hwdetect dump import                                              #
#								     #
# v0.3   31-DEC-2010   Pavel Stratil                                 #
# -600 lines of options added, TODO entries, var description         #
#                                                                    #
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
#	  CONFIG_SWAP=y, else CONFIG_SWAP=n.
#	  Also [ 'n', 'ym' ], [ 'n', 'my' ], [ 'mn', 'y' ], [ 'nm', 'y' ]
#	  are valid possibilities (ym means it must be either y or m).
# kname[] points to the location of a group of kernel config settings within the
#	  'make nconf' interface hiearchy
# kdscr[] (optional), contains description about the group of kernel config
#	  settings.
# kconf[] sets a kernel config option to a given value and provides optional
#	  description. i.e.: 
#	  kconf['iosched']['CFQ_GROUP_IOSCHED'] = [ 'y' ]  *)
#	  kconf['iosched']['CFQ_GROUP_IOSCHED'] = [ 'y', 'BLK_CGROUP is enabled. Without CFQ_GROUP_IOSCHED set, BLK_CGROUP=y is meaningless.' ]
#         *) same as kvote['iosched']['CFQ_GROUP_IOSCHED'] = [ 'y', 'y' ]
# krcmd[] recommended value for config group X if kernel['X'] is not defined.
# kdeps[] contains an array of userspace dependencies requiring the kernel opts.
# klist[] contains an array of a set of options, one of them must be set to yes.
# kgrep[] some simple pattern matching, i.e.:
#	  kgrep['net']['(BT_HCI*) &! (BT_HCIUART_*)']	= [ 'm' ]
# 	  kgrep['net']['BT_HCIUART_*']			= [ 'y' ]
#
# TODO starting with make nconfig, show all symbols = 0. now, since i hid some
#      symbols, i need to use the kgrep against a list of symbols where only
#      those displayed by the nconfig target are present, not against *all*
#      symbols. /usr/src/linux/scripts/kconfig/nconf.c - handle_f4()
# TODO a simple wildcard grep syntax?     
#
kvote = defaultdict(lambda: defaultdict(list))
kname = defaultdict(lambda: defaultdict)
kdscr = defaultdict(lambda: defaultdict)


#
# Test if variable is defined
# try:
#   x
# except NameError:
#   x = None
#    


################################################################################
# ### Config tests #############################################################
################################################################################

if (( box['virt-host'] > 0 ) and ( kernel['cgroups'] = 0 )):
  warn("Box is a virtualization host ( box['virt-host'] > 0 ) but kernel cgroups support is disabled ( kernel['cgroups'] = 0 ).")
if (( box['virt-host'] > 0 ) and ( kernel['namespaces'] = 0 )):
  warn("Box is a virtualization host ( box['virt-host'] > 0 ) but kernel namespaces support is disabled ( kernel['namespaces'] = 0 ).")
    


################################################################################
# ### General setup ############################################################
################################################################################


kname['swap'] = "[General setup] 'Support for paging of anonymous memory (swap)'"
kdscr['swap'] = "It is *very* common to have this on. Unless you know what you are doing, turning this off can destabilize your system."
krcmd['swap'] = 1
kvote['swap']['SWAP'] = [ 'n', 'y' ]


kname['cgroups'] = "[General setup] 'Control Group support'"
kdeps['cgroups'] = [ 'app-emulation/lxc', 'app-emulation/qemu-kvm', 'app-emulation/xen' ]
krcmd['cgroups'] = 1
kvote['cgroups']['CGROUPS']           	  = [ 'n', 'y' ]
kvote['cgroups']['CGROUP_NS']         	  = [ 'n', 'y' ]
kvote['cgroups']['CGROUP_FREEZER']    	  = [ 'n', 'y' ]
kvote['cgroups']['CGROUP_DEVICE']     	  = [ 'n', 'n' ]
kvote['cgroups']['CGROUP_CPUACCT']    	  = [ 'n', 'y' ]
kvote['cgroups']['RESOURCE_COUNTERS'] 	  = [ 'n', 'y' ]
kvote['cgroups']['CGROUP_SCHED']      	  = [ 'n', 'y' ]
kvote['cgroups']['BLK_CGROUP']      	  = [ 'n', 'y' ]
kconf['cgroups']['SCHED_AUTOGROUP'] 	  = [ 'n', 'y' ]
if ( hw['cpu']['cores'] > 1 ):
  kvote['cgroups']['CPUSETS']         	  = [ 'n', 'y' ]
else:
  kvote['cgroups']['CPUSETS']         	  = [ 'n', 'n' ]
if ( box['virt-host'] = 2 ):
  kvote['cgroups']['CGROUP_MEM_RES_CTLR'] = [ 'n', 'y' ]
else:
  kvote['cgroups']['CGROUP_MEM_RES_CTLR'] = [ 'n', 'n' ]


kname['namespaces'] = "[General setup] 'Namespaces support'"
kdeps['namespaces'] = [ 'app-emulation/lxc', 'app-emulation/qemu-kvm', 'app-emulation/xen' ]
krcmd['namespaces'] = 1
kvote['namespaces']['NAMESPACES']  = [ 'n', 'y' ]
kvote['namespaces']['USER_NS']     = [ 'n', 'y' ]
kvote['namespaces']['PID_NS']      = [ 'n', 'y' ]
kvote['namespaces']['NET_NS']      = [ 'n', 'y' ]
kvote['namespaces']['UTS_NS']      = [ 'n', 'y' ]
kvote['namespaces']['IPC_NS']      = [ 'n', 'y' ]


kname['initrd'] = "[General setup] 'Initial RAM filesystem and RAM disk (initramfs/initrd) support'"
krcmd['initrd'] = 1
kvote['initrd']['BLK_DEV_INITRD'] = [ 'n', 'y' ]


kname['deprecated'] = "Assortment of deprecated kernel settings."
krcmd['deprecated'] = 0
kvote['deprecated']['SYSFS_DEPRECATED'] = [ 'n', 'y' ]


kname['iosched'] = "[Enable the block layer] 'IO Schedulers'"
kdscr['iosched'] = "Choice of the IO scheduler can have noticable performance implications. The more complex CFQ (default) is most of the time the best choice, but in some cases the simpler Deadline may be better (i.e. in cases when IO plans of some 'intelligent' HW RAID controllers + NCQ disks collide with CFQ's). The best way to determine which scheduler to use is to start with CFQ and benchmark the disk performance of all schedulers (change the scheduler with: 'echo deadline > /sys/block/sda/queue/scheduler'). See also http://kerneltrap.org/node/7637."
kconf['iosched']['IOSCHED_DEADLINE'] = [ 'y' ]
kconf['iosched']['IOSCHED_CFQ']      = [ 'y' ]
kconf['iosched']['DEFAULT_IOSHED']   = [ kernel['iosched'] ]
if (( kvote['cgroups']['BLK_CGROUP'] = 'y' ) and ( kernel['iosched'] = 'cfq' )):	# TODO podminka na kvote['cgroups']['BLK_CGROUP'] nebude tak snadno splnena jak bych chtel. asi bude zapotrebi vedet nazave arraye s vyslednymi hodnotami konfigurace a nebo to brat z kontrolovaneho konfigu nejakou funkci.
  kconf['iosched']['CFQ_GROUP_IOSCHED'] = [ 'y' ]
else:
  kconf['iosched']['CFQ_GROUP_IOSCHED'] = [ 'n' ]
kconf['iosched']['SCHED_AUTOGROUP']  = [ 'y' ]

################################################################################
# ### Userspace dependencies ###################################################
################################################################################

kname['procacct'] = "[General setup] 'BSD process accounting'"
kdeps['procacct'] = [ 'sys-process/iotop' ]
krcmd['procacct'] = 1
kvote['procacct']['BSD_PROCESS_ACCT']    = [ 'n', 'y' ]
kvote['procacct']['BSD_PROCESS_ACCT_V3'] = [ 'n', 'y' ]
kvote['procacct']['TASKSTATS']           = [ 'n', 'y' ]
kvote['procacct']['TASK_DELAY_ACCT']     = [ 'n', 'y' ]
kvote['procacct']['TASK_XACCT']          = [ 'n', 'y' ]
kvote['procacct']['TASK_IO_ACCOUNTING']  = [ 'n', 'y' ]


kname['ikvoteig'] = "[General setup] 'Kernel .config"
kdeps['ikvoteig'] = [ 'app-admin/mage' ]
krcmd['ikvoteig'] = 1
kvote['ikvoteig']['IKCONFIG']      = [ 'm', 'y' ]
kvote['ikvoteig']['IKCONFIG_PROC'] = [ 'n', 'y' ]


kname['profile'] = "[General setup] 'Profiling support'"
kdeps['profile'] = [ 'dev-util/oprofile' ]
krcmd['profile'] = 0
kvote['profile']['PROFILING'] = [ 'n', 'y' ]
kvote['profile']['OPROFILE']  = [ 'n', 'm' ]


kname['loadmod'] = "[Enable loadable module support]"
krcmd['loadmod'] = 1
kvote['loadmod']['MODULES']             = [ 'y', 'y' ]
kvote['loadmod']['MODULE_UNLOAD']       = [ 'n', 'y' ]
kvote['loadmod']['MODULE_FORCE_UNLOAD'] = [ 'n', 'y' ]


################################################################################
# ### Hardware support #########################################################
################################################################################

kname['oddarch'] = "Enable some quite odd/old architectures."
krcmd['oddarch'] = 0
kvote['oddarch']['X86_MPPARSE'] 			= [ 'n', 'y' ]	# old (i.e. 32bit) smp systems
kvote['oddarch']['X86_VSMP'] 				= [ 'n', 'y' ]	#
kvote['oddarch']['CALGARY_IOMMU_ENABLED_BY_DEFAULT']	= [ 'n', 'y' ] 	# include iommu support but require it to be enabled with a boot parameter
kvote['oddarch']['X86_EXTENDED_PLATFORM'] 		= [ 'n', 'y' ] 	# non-x86


kname['blklayer'] = "[Enable the block layer] 'Block layer SG support v4'"
kdeps['blklayer'] = [ 'sys-fs/udev' ]
kconf['blklayer']['BLK_DEV_BSG'] 	  = [ 'y' ]
if ( hw['block']['t10/t13'] >= 1 ):
  kconf['blklayer']['BLK_DEV_INTEGRITY']  = [ 'y', 'Block layer data integrity support: supported by hardware' ]
else:
  kconf['blklayer']['BLK_DEV_INTEGRITY']  = [ 'n', 'Block layer data integrity support: unsupported by hardware' ]
if ( kvote['cgroups']['BLK_CGROUP'] = 'y' ):
  kconf['blklayer']['BLK_DEV_THROTTLING'] = [ 'y' ]
else:
  kconf['blklayer']['BLK_DEV_THROTTLING'] = [ 'n' ]


kname['cputimer'] = "[Processor type and features] 'Tickless System' and 'Preemtion model'"
kconf['cputimer']['NO_HZ'] 		= [ 'y' ]
kconf['cputimer']['HIGH_RES_TIMERS']    = [ 'y' ]
if ( box['performance'] != 'throughput' ):
  kconf['cputimer']['HZ_100']           = [ 'y' ]
  kconf['cputimer']['PREEMPT_NONE']      = [ 'y' ]
elif ( box['performance'] != 'balanced' ):
  kconf['cputimer']['HZ_300']           = [ 'y' ]
  kconf['cputimer']['PREEMPT_VOLUNTARY'] = [ 'y' ]
elif ( box['performance'] != 'lowlatency' ):
  kconf['cputimer']['HZ_1000']          = [ 'y' ]
  kconf['cputimer']['PREEMPT']           = [ 'y' ]
      

kname['multicore'] = "[Processor type and features] 'Symmetric multi-processing support'"
if ( hw['cpu']['cores'] > 1 ):
  kdscr['multicore'] = 'This machine has ' + hw['cpu']['cores'] + ' CPU cores. Following options enable the multicore support.'
  kconf['multicore']['SMP']      = [ 'y' ]
  kconf['multicore']['SCHED_MC'] = [ 'y' ]
  kconf['multicore']['X86_MSR']  = [ 'y' ]


kname['virt-guest'] = "[Processor type and features] 'Paravirtualized guest support'"
if ( box['virt-guest'] != '' ):
  if ( box['virt-guest'] = 'kvm' ):
    kconf['virt-guest']['PARAVIRT_GUEST'] = [ 'y' ]
    kconf['virt-guest']['PARAVIRT']       = [ 'y' ]
    kconf['virt-guest']['KVM_CLOCK']      = [ 'y' ]
    kconf['virt-guest']['KVM_GUEST']      = [ 'y' ]
    kconf['virt-guest']['XEN'] 	   	  = [ 'n' ]
  elif ( box['virt-guest'] = 'xen' ):
    kconf['virt-guest']['PARAVIRT_GUEST'] = [ 'y' ]
    kconf['virt-guest']['PARAVIRT']       = [ 'y' ]
    kconf['virt-guest']['KVM_CLOCK']      = [ 'n' ]
    kconf['virt-guest']['KVM_GUEST']      = [ 'n' ]
    kconf['virt-guest']['XEN'] 	    = [ 'y' ]
  elif ( box['virt-guest'] = 'all' ):
    kconf['virt-guest']['PARAVIRT_GUEST'] = [ 'y' ]
    kconf['virt-guest']['PARAVIRT']       = [ 'y' ]
    kconf['virt-guest']['KVM_CLOCK']      = [ 'y' ]
    kconf['virt-guest']['KVM_GUEST']      = [ 'y' ]
    kconf['virt-guest'] ['XEN'] 	  = [ 'y' ]
else:
  kconf['virt-guest']['PARAVIRT_GUEST']   = [ 'n' ]
  kconf['virt-guest']['PARAVIRT']         = [ 'n' ]
  kconf['virt-guest']['KVM_CLOCK']        = [ 'n' ]
  kconf['virt-guest']['KVM_GUEST']        = [ 'n' ]
  kconf['virt-guest']['XEN'] 	    	  = [ 'n' ]


kname['mce'] = "[Processor type and features] 'Machine Check'"
if ( "mce" in hw['cpu']['flags'] ):
  kconf['mce']['X86_MCE']         = [ 'y' ]
  if ( hw['cpu']['vendor'] == 'intel' ):
    kconf['mce']['X86_MCE_INTEL'] = [ 'y' ]
  elif ( hw['cpu']['vendor'] == 'amd' ):
    kconf['mce']['X86_MCE_AMD']   = [ 'y' ]
      

kname['cpuid'] = "[Processor type and features] '/dev/cpu/*/cpuid - CPU information support'"
kdscr['cpuid'] = "Gives processes access to the x86 CPUID instruction to be executed on a specific processor"
if ( kernel['cpuid'] = 1 ):
  kconf['cpuid']['X86_CPUID']   = [ 'y' ]
else
  kconf['cpuid']['X86_CPUID']   = [ 'n' ]


kname['cpufamily'] = "[Processor type and features] 'Processor family'"
if ( hw['cpu']['vendor'] == 'intel' )
  klist['cpufamily']['intel']           = [ 'GENERIC_CPU', 'MATOM', 'MCORE2', 'MPSC' ]
  kconf['microcode']['MICROCODE']       = [ 'm' ]
  kconf['microcode']['MICROCODE_INTEL'] = [ 'y' ]
elif ( hw['cpu']['vendor'] == 'amd' )
  klist['cpufamily']['amd']             = [ 'GENERIC_CPU', 'MK8' ]
  kconf['cpufamily']['AMD_IOMMU']       = [ 'y' ]
  kconf['microcode']['MICROCODE']       = [ 'm' ]
  kconf['microcode']['MICROCODE_AMD']   = [ 'y' ]
      

kname['numa'] = "[Processor type and features] 'Numa Memory Allocation and Scheduler Support'"
kdscr['numa'] = 'Used by some 64-bit CPUs (i.e. Intel Core i7 or later, AMD Opteron, or EM64T NUMA).'
kconf['numa']['MIGRATION'] 	    = [ 'y' ]
if ( "lm" in hw['cpu']['flags'] ): 
  kconf['numa']['NUMA']             = [ 'y' ]
  kconf['numa']['X86_64_ACPI_NUMA'] = [ 'y' ]
else:
  kconf['numa']['NUMA']             = [ 'n' ]
  kconf['numa']['X86_64_ACPI_NUMA'] = [ 'n' ]


kname['memory'] = "[Processor type and features]"
kdscr['memory'] = "A selection of memory-related options"
if ( box['virt-host'] = 2 ):
  kconf['memory']['KSM'] 	        = [ 'y' ]
else:
  kconf['memory']['KSM'] 	        = [ 'n' ]
  kconf['memory']['MTRR_SANITIZER']     = [ 'y' ]
kconf['memory']['CC_STACKPROTECTOR']    = [ 'n' ]  # change to 'y' when this option is no longer experimental
kconf['memory']['KEXEC']                = [ 'y' ]
kconf['memory']['RELOCATABLE']          = [ 'y' ]
kconf['memory']['KEXEC_JUMP']  	        = [ 'y' ]
kconf['memory']['TRANSPARENT_HUGEPAGE'] = [ 'y' ]
if ( box['embedded'] = 1 ):
  kconf['memory']['TRANSPARENT_HUGEPAGE_ALWAYS']  = [ 'n' ]
  kconf['memory']['TRANSPARENT_HUGEPAGE_MADVISE'] = [ 'y' ]
else:
  kconf['memory']['TRANSPARENT_HUGEPAGE_ALWAYS']  = [ 'y' ]
  kconf['memory']['TRANSPARENT_HUGEPAGE_MADVISE'] = [ 'n' ]
  

kname['pm'] = "[Power management and ACPI options] 'Power Management support'"
kdeps['pm'] = [ 'sys-power/powertop' ]
if ( kernel['powersave'] = 1 ):
  kvote['pm']['PM']                        = [ 'n', 'y' ]
  kvote['pm']['PM_DEBUG']                  = [ 'n', 'y' ] # required by sys-power/powertop
  kvote['pm']['PM_ADVANCED_DEBUG']         = [ 'n', 'y' ] # required by sys-power/powertop
  kvote['pm']['PM_RUNTIME']                = [ 'n', 'y' ]
  kvote['pm']['ACPI']                      = [ 'n', 'y' ]
  kvote['pm']['ACPI_POWER_METER']          = [ 'n', 'y' ]
  kvote['pm']['ACPI_AC']                   = [ 'n', 'y' ]
  kvote['pm']['ACPI_BATTERY']              = [ 'n', 'y' ]
  kvote['pm']['ACPI_BUTTON']               = [ 'n', 'y' ]
  kvote['pm']['ACPI_FAN']                  = [ 'n', 'y' ]
  kvote['pm']['ACPI_DOCK']                 = [ 'n', 'y' ]
  kvote['pm']['ACPI_IPMI']                 = [ 'n', 'y' ]
  kvote['pm']['ACPI_PROCESSOR']            = [ 'n', 'y' ]
  kvote['pm']['ACPI_PROCESSOR_AGGREGATOR'] = [ 'n', 'y' ]
  kvote['pm']['ACPI_THERMAL']              = [ 'n', 'y' ]
  kvote['pm']['ACPI_SBS']                  = [ 'n', 'y' ]
  kvote['pm']['ACPI_HED']	           = [ 'n', 'y' ]
  kvote['pm']['ACPI_APEI']	           = [ 'n', 'y' ]
  kvote['pm']['CPU_FREQ']                  = [ 'n', 'y' ]
  kvote['pm']['CPU_FREQ_STAT']             = [ 'n', 'm' ] # used by sys-power/powertop
  kvote['pm']['CPU_FREQ_STAT_DETAILS']     = [ 'n', 'y' ] # used by sys-power/powertop
  if ( box['portable'] = 1 ):
    kconf['pm']['CPU_FREQ_DEFAULT_GOV_CONSERVATIVE'] = [ 'y' ] # battery driven machines (portables)
  else:
    kconf['pm']['CPU_FREQ_DEFAULT_GOV_ONDEMAND']     = [ 'y' ]
  kvote['pm']['CPU_FREQ_GOV_POWERSAVE']         = [ 'n', 'ym' ]
  kvote['pm']['CPU_FREQ_GOV_PERFORMANCE']       = [ 'n', 'ym' ]
  kvote['pm']['CPU_FREQ_GOV_USERSPACE']         = [ 'n', 'ym' ]
  kvote['pm']['CPU_FREQ_GOV_ONDEMAND']          = [ 'n', 'y' ]
  kvote['pm']['CPU_FREQ_GOV_CONSERVATIVE']      = [ 'n', 'y' ]
  kvote['pm']['X86_ACPI_CPUFREQ']               = [ 'n', 'y' ]
  if ( hw['cpu']['vendor'] == 'amd' ):
    kvote['pm']['X86_POWERNOW_K8']              = [ 'n', 'y' ]
  else:
    kvote['pm']['X86_POWERNOW_K8']              = [ 'n', 'n' ]
  kconf['pm']['CPU_IDLE'] 			= [ 'y' ]
  if ( hw['cpu']['vendor'] == 'intel' ):
    kvote['pm']['INTEL_IDLE']                   = [ 'n', 'y' ]
  else:
    kvote['pm']['INTEL_IDLE']                   = [ 'n', 'n' ]
      

kname['pm'] = "[Power management and ACPI options] 'Suspend'"
kdeps['suspend'] = [ 'sys-power/suspend' ]
if ( kernel['suspend'] = 1 ):
  kconf['suspend']['PM_TRACE_RTC'] = [ 'n', 'y' ]
  kconf['suspend']['SUSPEND']      = [ 'n', 'y' ]
  kconf['suspend']['HIBERNATION']  = [ 'n', 'y' ]


kname['pci'] = '[Bus options]'
kdscr['pci'] = 'To get information about devices attached to the PCI, use `lspci`, or `lspci -vv`'
kconf['pci']['PCI']              = [ 'y' ] # PCI
kconf['pci']['PCIEPORTBUS']      = [ 'y' ] # PCI Express
kconf['pci']['HOTPLUG_PCI']      = [ 'y' ] # Hotplug: PCI support
kconf['pci']['HOTPLUG_PCI_PCIE'] = [ 'y' ] # Hotplug: PCIE driver
kconf['pci']['HOTPLUG_PCI_ACPI'] = [ 'y' ] # Hotplug: ACPI driver
if ( box['portable'] = 1 ):
  kconf['pci']['PCCARD']         = [ 'y' ] # Notebook PCI cards (pcmcia, expresscard, ..)
else:
  kconf['pci']['PCCARD']         = [ 'n' ]
if ( box['virt-host'] = 2 ):
  kconf['pci']['PCI_STUB'] 	 = [ 'm' ]
  kconf['pci']['PCI_IOV'] 	 = [ 'y' ]
else:
  kconf['pci']['PCI_STUB'] 	 = [ 'n' ]
  kconf['pci']['PCI_STUB'] 	 = [ 'n' ]


kname['binfmt'] = "[Executable file formats / Emulations]"
kconf['binfmt']['BINFMT_ELF'] 			 = [ 'y' ]
kconf['binfmt']['BINFMT_MISC'] 			 = [ 'y' ]
kconf['binfmt']['IA32_EMULATION'] 		 = [ 'y' ]
kconf['binfmt']['CORE_DUMP_DEFAULT_ELF_HEADERS'] = [ 'y' ]


kvote['net']['NET']   				= [ 'y', 'y' ]
kvote['net']['PACKET']    			= [ 'm', 'y' ]
kvote['net']['UNIX']      			= [ 'y', 'y' ]
kvote['net']['XFRM_USER'] 			= [ 'm', 'y' ]
kvote['net']['NET_KEY']   			= [ 'm', 'y' ]
kvote['net']['INET']      			= [ 'y', 'y' ]
kvote['net']['IP_ADVANCED_ROUTER'] 		= [ 'm', 'y' ] # virt
kvote['net']['IP_MULTIPLE_TABLES'] 		= [ 'm', 'y' ] # virt
kvote['net']['NET_IPIP'] 			= [ 'm', 'm' ]
kvote['net']['NET_IPGRE_DEMUX'] 		= [ 'm', 'm' ]
kvote['net']['NET_IPGRE'] 			= [ 'm', 'm' ]
kvote['net']['IP_MROUTE'] 			= [ 'm', 'm' ] # virt
kvote['net']['IP_MROUTE_MULTIPLE_TABLES']	= [ 'm', 'm' ] # virt2
kvote['net']['ARPD'] 				= [ 'm', 'y' ]
kvote['net']['INET_AH'] 			= [ 'm', 'm' ]
kvote['net']['INET_ESP'] 			= [ 'm', 'm' ]
kvote['net']['INET_IPCOMP']			= [ 'm', 'm' ]
kvote['net']['INET_XFRM_MODE_TRANSPORT']	= [ 'm', 'm' ]
kvote['net']['INET_XFRM_MODE_TUNNEL']		= [ 'm', 'm' ]
kvote['net']['INET_XFRM_MODE_BEET']		= [ 'm', 'm' ]
kvote['net']['INET_DIAG'] 			= [ 'm', 'y' ] #iproute2
kvote['net']['IPV6']				= [ 'm', 'y' ]
kvote['net']['NETFILTER'] 			= [ 'm', 'y' ]
kvote['net']['NETFILTER_XT_MATCH_LENGTH'] 	= [ 'm', 'm' ]
kvote['net']['NETFILTER_XT_MATCH_OSF'] 		= [ 'm', 'm' ]
kvote['net']['IP_NF_TARGET_NETMAP'] 		= [ 'm', 'm' ]
kvote['net']['IP_NF_ARPTABLES'] 		= [ 'm', 'm' ]
kvote['net']['IP_NF_ARPFILTER'] 		= [ 'm', 'm' ]
kvote['net']['IP_NF_ARP_MANGLE'] 		= [ 'm', 'm' ]
kvote['net']['NETFILTER_ADVANCED'] 		= [ 'n', 'y' ]
kvote['net']['BRIDGE_NETFILTER'] 		= [ 'n', 'y' ]
kvote['net']['BRIDGE'] 				= [ 'n', 'y' ]
kvote['net']['VLAN_8021Q'] 			= [ 'm', 'y' ]
kvote['net']['AX25'] 				= [ 'n', 'm' ] # Amateur radio support
if ( box['portable'] = 1 ):
  kconf['net']['BT']        			= [ 'y', "[Networking support] 'Bluetooth subsystem support'" ]
  kconf['net']['BT_L2CAP']       		= [ 'y' ]
  kconf['net']['BT_SCO']       			= [ 'y' ]
  kconf['net']['BT_RFCOMM']      		= [ 'y' ]
  kconf['net']['BT_RFCOMM_TTY']  		= [ 'y' ]
  kconf['net']['BT_BNEP']        		= [ 'y' ]
  kconf['net']['BT_HIDP']        		= [ 'y' ]
  kconf['net']['BT_SCO']         		= [ 'y' ]
  kgrep['net']['(BT_HCI*) &! (BT_HCIUART_*)']	= [ 'm' ]
  kgrep['net']['BT_HCIUART_*']			= [ 'y' ]
  kconf['net']['WIRELESS']			= [ 'y', "[Networking support] 'Wireless'" ]
  kconf['net']['CFG80211']			= [ 'y' ]
  kconf['net']['RFKILL']			= [ 'y' ]
  kconf['net']['WIMAX']				= [ 'm' ]
kvote['net']['CEPH_LIB']			= [ 'm' ]

################################################################################
# ### Device drivers ###########################################################
################################################################################

#
# dscr: use  'lspci -nnk', lsusb, lshw (lshw -C Network)
#

############################
### Block devices ##########
############################
kconf['driver']['BLK_DEV']            = [ 'y' ]
kconf['driver']['BLK_DEV_FD']         = [ 'm' ] # floppy
kconf['driver']['BLK_DEV_LOOP']       = [ 'y' ] # loop
kconf['driver']['BLK_DEV_CRYPTOLOOP'] = [ 'm' ]
kconf['driver']['BLK_DEV_DRBD']       = [ 'm' ]
kconf['driver']['BLK_DEV_NBD']        = [ 'm' ]
kconf['driver']['BLK_DEV_RAM']        = [ 'y' ]
kconf['driver']['CDROM_PKTCDVD']      = [ 'y' ] # cdrom
kconf['driver']['ATA_OVER_ETH']       = [ 'm' ]
if (( box['virt-host'] > 0 )
  kconf['driver']['VIRTIO_BLK']       = [ 'm' ]
kconf['driver']['BLK_DEV_RBD']        = [ 'm' ] # ceph


############################
### Misc devices ###########
############################
kconf['driver']['MISC_DEVICES']       = [ 'y' ]
kconf['driver']['ENCLOSURE_SERVICES'] = [ 'm' ]
kgrep['driver']['EEPROM_*'] 	      = [ 'm' ]

############################
### SCSI device support ####
############################

kconf['driver']['RAID_ATTRS']       = [ 'y' ]
kconf['driver']['SCSI_ENCLOSURE']   = [ 'm' ]
kconf['driver']['SCSI_MULTI_LUN']   = [ 'y' ]
kconf['driver']['SCSI_LOGGING']     = [ 'y' ]
kconf['driver']['SCSI_SCAN_ASYNC']  = [ 'y' ]
kconf['driver']['SCSI_LOWLEVEL']    = [ 'y' ]
if kconf['driver']['SCSI_SCAN_ASYNC']:
  kconf['driver']['SCSI_WAIT_SCAN'] = [ 'm' ] # required for SCSI_SCAN_ASYNC work properly

############################
### Multiple devices drv. ##
############################
kconf['driver']['BLK_DEV_MD']    = [ 'y' ]
kconf['driver']['MD_AUTODETECT'] = [ 'y' ]
kconf['driver']['BLK_DEV_DM']    = [ 'm' ]
kconf['driver']['DM_CRYPT']      = [ 'm' ]
kconf['driver']['DM_SNAPSHOT']   = [ 'm' ]
kconf['driver']['DM_MIRROR']     = [ 'm' ]
kconf['driver']['FUSION']        = [ 'y' ]
kgrep['driver']['FUSION_*']      = [ 'm' ]
kgrep['driver']['FIREWIRE*']     = [ 'm' ]

############################
### Network device support #
############################
kconf['driver']['NETDEVICES']    = [ 'm' ]
kconf['driver']['IFB']     	 = [ 'm' ] # virt-host, routing
kconf['driver']['BONDING'] 	 = [ 'm' ] # virt-host, routing
kconf['driver']['MACVLAN'] 	 = [ 'm' ] # virt-host, routing
kconf['driver']['MACVTAP'] 	 = [ 'm' ] # virt-host, routing
kconf['driver']['TUN']   	 = [ 'm' ] # virt-host, routing
kconf['driver']['VETH']    	 = [ 'm' ] # virt-host, routing
if ( box['portable'] = 1 ):
  kconf['driver']['WLAN']  	 = [ 'y' ] # wifi support
kconf['driver']['FDDI']          = [ 'm' ]
kconf['driver']['PPP']                     = [ 'm' ]
kconf['driver']['PPP_FILTER']              = [ 'y' ]
kgrep['driver']['(PPP_*) &! (PPP_FILTER)'] = [ 'm' ]
if ( box['virt-host'] > 0 ):
  kconf['driver']['VIRTIO_NET']  = [ 'm' ]
if ( box['portable'] = 1 ):
  kconf['driver']['NET_PCMCIA']  = [ 'y' ]
kconf['driver']['USB_USBNET']    = [ 'm' ]
kconf['driver']['USB_HSO']       = [ 'm' ]

############################
### Character devices ######
############################

if ( box['virt-host'] > 0 ):
  kconf['driver']['VIRTIO_CONSOLE']      = [ 'm' ]
kconf['driver']['IMPI_HANDLER']          = [ 'y' ]
kconf['driver']['IMPI_POWEROFF']         = [ 'y' ]
kconf['driver']['IMPI_WATCHDOG']         = [ 'y' ]
kconf['driver']['IMPI_SI']               = [ 'y' ]
kconf['driver']['IMPI_DEVICE_INTERFACE'] = [ 'y' ]
kgrep['driver']['HW_RANDOM*'] 		 = [ 'y' ]
kconf['driver']['HANGCHECK_TIMER']       = [ 'm' ]


############################
### I2C support ############
############################
kconf['driver']['I2C_CHARDEV']     = [ 'y' ]
kconf['driver']['I2C_HELPER_AUTO'] = [ 'y' ]
kconf['driver']['I2C_COMPAT']      = [ 'n' ] # old userspace
kconf['driver']['CONFIG_I2C_STUB'] = [ 'n' ]
# TODO load all chip specific drivers as modules, which are then selected with
#      'sensors-detect' from sys-apps/lm_sensors

############################
### Spi support ############
############################
kconf['driver']['SPI'] 	      = [ 'y' ]
kconf['driver']['SPI_SPIDEV'] = [ 'm' ]


############################
### PPS & GPIO & Power sup.#
############################

if ( box['portable'] = 1 ):
  kconf['driver']['PPS']       = [ 'm' ] # ultraportables with GPS
  kconf['driver']['PDA_POWER'] = [ 'm' ] # ultraportables with one or two bateries
kconf['driver']['GPIOLIB']     = [ 'y' ]

############################
### Hardware monitoring ####
############################

kconf['driver']['HWMON'] = [ 'y' ]
kgrep['driver']['SENSORS_* &! SENSORS_W83795_FANCTRL &! HWMON_DEBUG_CHIP'] = ['m']
# loading all chip specific drivers as modules, which are then selected with
# 'sensors-detect' from sys-apps/lm_sensors


############################
### Generic Thermal sysfs ##
############################

kconf['driver']['THERMAL_HWMON'] = [ 'y' ] # lm_sensors

############################
### Watchdog & Multifunct. #
############################
kconf['driver']['WATCHDOG']      = [ 'y' ] # headless
kconf['driver']['SOFT_WATCHDOG'] = [ 'm' ]
kconf['driver']['MFD_SUPPORT']   = [ 'y' ]
kconf['driver']['REGULATOR']     = [ 'y' ]


############################
### Multimedia support #####
############################

kconf['driver']['MEDIA_SUPPORT']     = [ 'y' ]
kconf['driver']['VIDEO_DEV']         = [ 'y' ]
kconf['driver']['VIDEO_ALLOW_V4L1']  = [ 'n' ] # deprecated
kconf['driver']['VIDEO_V4L1_COMPAT'] = [ 'y' ]
kconf['driver']['DVB_CORE']          = [ 'y' ]
kconf['driver']['VIDEO_CAPTURE_DRIVERS']       = [ 'y' ]
kconf['driver']['VIDEO_HELPER_CHIPS_AUTO']     = [ 'y' ]
kconf['driver']['USB_VIDEO_CLASS']             = [ 'y' ]
kconf['driver']['USB_VIDEO_CLASS_INPUT_EVDEV'] = [ 'y' ]
kgrep['driver']['USB_GSPCA*']                  = [ 'm' ]
kconf['driver']['MEDIA_ATTACH']      	       = [ 'y' ] # requires >module-init-tools-3.2

############################
### Graphics support #######
############################

if ( box['portable'] = 1 ):
  kconf['driver']['VGA_SWITCHEROO']        = [ 'yn' ]
  kconf['driver']['BACKLIGHT_LCD_SUPPORT'] = [ 'y' ]
if ( box['head'] != "headless" ):
  kconf['driver']['DRM']                   = [ 'y' ]
kconf['driver']['FB']
kconf['driver']['FIRMWARE_EDID']           = [ 'y' ]
kconf['driver']['FB_MODE_HELPERS']         = [ 'y' ]
kconf['driver']['DISPLAY_SUPPORT']         = [ 'y' ]

############################
### Sound card support #####
############################

# TODO Enable your PCI device(s) as modules. This is really important since
# some drivers need to be loaded with custom options. See also
# http://www.gentoo.org/doc/en/alsa-guide.xml

kconf['driver']['SOUND']       = [ 'y' ]
kconf['driver']['SOUND_OSS_CORE_PRECLAIM'] = [ 'y' ]
kconf['driver']['SND']         = [ 'm' ]
kconf['driver']['SND_DRIVERS'] = [ 'n' ] # really, this SHOULD be disabled

############################
### HID support ############
############################

kconf['driver']['HID_SUPPORT']  = [ 'y' ]
kconf['driver']['HID']          = [ 'y' ]

############################
### USB support ############
############################


kconf['driver']['USB_SUPPORT']              = [ 'y' ]
kconf['driver']['USB']                      = [ 'y' ]
kconf['driver']['USB_ANNOUNCE_NEW_DEVICES'] = [ 'y' ]
kconf['driver']['USB_DEVICEFS']             = [ 'n' ] # deprecated
kconf['driver']['USB_SUSPEND']              = [ 'y' ]
kconf['driver']['USB_MON']                  = [ 'y' ]
kconf['driver']['USB_XHCI_HCD']             = [ 'm' ] # USB3 support
kconf['driver']['USB_PRINTER']              = [ 'y' ]
kconf['driver']['USB_STORAGE']              = [ 'y' ]
kconf['driver']['USB_UAS']                  = [ 'y' ]
kconf['driver']['USB_SERIAL']               = [ 'm' ]
kconf['driver']['EZUSB']                    = [ 'y' ]
kconf['driver']['USB_SERIAL_GENERIC']       = [ 'y' ]
kconf['driver']['USB_GADGET']               = [ 'm' ]

############################
### MMC/SD/SDIO, MEMORYST. #
############################

kconf['driver']['MMC']                = [ 'y' ]
kconf['driver']['MMC_SDHCI']          = [ 'y' ]
kconf['driver']['MMC_SDHCI_PCI']      = [ 'y' ]
kconf['driver']['MMC_SDHCI_PLTFM']    = [ 'y' ]
kconf['driver']['MEMSTICK']           = [ 'm' ]
kconf['driver']['MSPRO_BLOCK']        = [ 'm' ]

############################
### EDAC Reporting #########
############################

# EDAC (Error Detection And Correction) reporting
# TODO if you have ECC memory, enable.
kconf['driver']['EDAC'] = [ 'y' ]
kconf['driver']['EDAC_DECODE_MCE'] = [ 'y' ]
#kconf['driver']['EDAC_MM_EDAC']    = [ 'y' ] # ECC

############################
### X86 Platform Specific ##
############################

kconf['driver']['X86_PLATFORM_DEVICES']  = [ 'y' ]
kconf['driver']['INTEL_IPS']             = [ 'y' ]
kconf['driver']['ACPI_WMI']              = [ 'y' ] # wont load on unsupported


kgrep['fs']['EXT2_FS* &! EXT2_FS_XIP'] = [ 'y' ]
kgrep['fs']['EXT3_FS* &! EXT3_DEFAULTS_TO_ORDERED'] = [ 'y' ]
kconf['fs']['EXT4_FS*']     = [ 'y' ]
kconf['fs']['BTRFS_FS*']    = [ 'y' ]
kconf['fs']['INOTIFY_USER'] = [ 'y' ]   # incron
kconf['fs']['FANOTIFY']     = [ 'y' ]
kconf['fs']['QUOTA']        = [ 'y' ]
kconf['fs']['QUOTA_NETLINK_INTERFACE'] = [ 'y' ]
kconf['fs']['QFMT_V2']      = [ 'y' ]
kconf['fs']['AUTOFS4_FS']   = [ 'm' ]
kconf['fs']['FUSE_FS']      = [ 'y' ]
kconf['fs']['CUSE']         = [ 'y' ]
kconf['fs']['FSCACHE']      = [ 'm' ]
kconf['fs']['CACHEFILES']   = [ 'y' ]
kconf['fs']['UDF_FS']       = [ 'y' ]
kconf['fs']['NTFS_FS']      = [ 'y' ]
kconf['fs']['NTFS_RW']      = [ 'y' ]
kconf['fs']['ECRYPT_FS']    = [ 'm' ]
kconf['fs']['CEPH_FS']      = [ 'm' ]

kconf['hack']['MAGIC_SYSRQ'] = [ 'y' ] # enabled (Kernel Hacking -> Kernel Debugging -> Magic SysRq key).
kconf['hack']['LATENCYTOP']  = [ 'y' ] # (Latency measuring infrastructure)
kconf['hack']['TIMER_STATS'] = [ 'y' ] # Collect kernel timers statistics  (powertop)
kconf['hack']['SCHEDSTATS']  = [ 'y' ] # powertop
kconf['hack']['BKL']         = [ 'n' ]
kconf['hack']['SYSCTL_SYSCALL_CHECK'] = [ 'y' ]


kconf['crypto']['CRYPTO_AES_X86_64'] = [ 'y' ]
kconf['crypto']['CRYPTO_DEFLATE']    = [ 'y' ]
kconf['crypto']['CRYPTO_ZLIB']       = [ 'y' ]
kconf['crypto']['CRYPTO_LZO']        = [ 'y' ]


kconf['virt-host']['VIRTUALIZATION']  = [ 'y' ]
kconf['virt-host']['KVM']             = [ 'm' ]  # if this is built in, virtualbox will fail.
kconf['virt-host']['KVM_INTEL']       = [ 'm' ]
kconf['virt-host']['KVM_AMD']         = [ 'm' ]
kconf['virt-host']['VIRTIO_PCI']      = [ 'm' ]
kconf['virt-host']['VHOST_NET']       = [ 'm' ]
kconf['virt-host']['VIRTIO_BALLOON']  = [ 'm' ]





