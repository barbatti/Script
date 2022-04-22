# For a multiple column file, adds a blank row everytime tha x changes.
# How to use:
# awk -f addblanks.awk input > output
#
/^[[:blank:]]*#/ {next} # ignore comments (lines starting with #)  
NF < 3 {next} # ignore lines which don’t have at least 3 columns  
$1 != prev {printf "\n"; prev=$1} # print blank line  
{print} # print the line 
