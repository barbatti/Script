#!/usr/bin/perl -w
#
system("\$NX/moldyn.pl > moldyn.log");
system("rm -rf TEMP DEBUG INFO_RESTART");
