#!/usr/bin/python

######################################################################
# -*- coding: utf-8 -*-                                              #
#                                                                    #
# FILE : bash-parser.py                                              #
# CREATION DATE : 04-SEP-2011                                        #
# LAST MODIFICATION DATE : 04-SEP-2011                               #
#                                                                    #
#--------------------------------------------------------------------#
#                                                                    #
# CHANGELOG:                                                         #
# ==========                                                         #
# v0.1   04-SEP-2011   Jaromir Capik                                 #
# -Initial version                                                   #
#                                                                    #
######################################################################

import os
from tools import *

############ FUNCTIONS #############

def bash_read(filename, varname):
    return read_cmd_stdout("source " + filename + "; echo $" + varname)

def bash_read_notrim(filename, varname):
    return read_cmd_stdout("source " + filename + "; echo \"$" + varname + "\"")

def bash_update(filename, varname, value):
    f = open(os.path.expanduser(filename))	# read the whole file into list
    lines = f.readlines()
    f.close()
    linecnt = 0
    lastmatch = -1
    for line in lines:				# process all lines in the list
	line_stripped = line.lstrip()
	strip_len = len(line) - len(line_stripped)
	varname_len = len(varname)
        if (line_stripped[0:varname_len+1] == varname + "="):	# variable assignment found?
	    lastmatch = linecnt					# store the line number of this (last) match
	    lastmatch_padding = line[0:strip_len]  # remember whitespace padding (to preserve it when replacing)
	    lines[linecnt] = ""					# remove the assignment
	linecnt = linecnt + 1
    if (lastmatch == -1):	# variable doesn't exist yet? ... add it at the end
	if (lines[linecnt-1][-1] != "\n"):	# file not ending with newline? ... append newline first
	    lines.append("\n")
	lines.append(varname + "=\"" + value + "\"\n")
    else:			# variable exists? ... replace it and preserve padding with whitespaces
	lines[lastmatch] = lastmatch_padding + varname + "=\"" + value + "\"\n"
    f = open(os.path.expanduser(filename), 'w')	# write the whole list to the file
    f.writelines(lines)
    f.close()