#!/usr/bin/perl -w
#
# Delete files in some directory
# rm_files(path,<type>,<size>)
# path - directory path
# type - B for binary
#        T for text
#        A for all
# size - remove only files above this size in MB
# Example:
# rm_files("TEMP/WORK",B,1)
# will remove all binary files from TEMP/WORK whose size is 
# larger or equal to 1 MB.
# 
# Mario Barbatti, Mar 2007
#
   print "Enter path:";
   chomp($path = <STDIN>);
   print "Enter type:";
   chomp($type = <STDIN>);
   print "Enter the maximum size (MB):";
   chomp($value = <STDIN>);
  
   rm_files($path,$type,$value);

   print "\nEnding test program \n";

 sub rm_files {
   local (@files);
   local ($element,$dir_path,$fname,$max_size,$MB2byte,$type,$value);
   ($dir_path,$type,$value)=@_;

   if (!-e $dir_path){
     print "$dir_path does not exist. Exiting.\n";
     return;
   }

   $MB2byte = 1048576;

   $max_size = $value*$MB2byte; 

   $dir_path = "WORK";
   opendir (DIR,$dir_path) or die "Can't open current dir: $dir_path\n";
   @files = grep (!/^\.\.?$/, readdir (DIR));
   closedir (DIR);

   for $element (@files) {
       $fname = "$dir_path/$element";
       if (-B $fname){
          if (-s $fname >= $max_size){
             if (($type eq "B"||"b") or ($type eq "A"||"a")){
               print "Binary file $element has ", -s $fname, " bytes. \n";
               print "*** This file has ",(-s $fname)/$MB2byte," MB and will be deleted ***\n";
               system("rm -rf $fname");
             }
          }
       }elsif (-T $fname){
          if (-s $fname >= $max_size){
             if (($type eq "T"||"t") or ($type eq "A"||"a")){
               print "Text file $element has ", -s $fname, " bytes. \n";
               print "*** This file has ",(-s $fname)/$MB2byte," MB and will be deleted ***\n";
               system("rm -rf $fname");
             }
          }
       } 
   }

   print "Max size in MB = $value\n";
   print "Max size in bytes = $max_size\n";
 }
