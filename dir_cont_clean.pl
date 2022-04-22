 sub rm_files {
# Delete files
# usage: rm_files(path,type,size)
# path - directory path
# type - B for binary (case insensitive)
#        T for text
#        A for all
# size - remove only files above this size in MB
# Example:
# rm_files("TEMP/WORK","B",1)
# will remove all binary files from TEMP/WORK whose size is 
# larger or equal to 1 MB.
# Mario Barbatti, Mar 2007
#
   local (@files);
   local ($element,$dir_path,$fname,$max_size,$MB2byte,$type,$value);
   ($dir_path,$type,$value)=@_;

   if (!-e $dir_path){
     return;
   }
   $MB2byte = 1048576;
   $max_size = $value*$MB2byte; 

   opendir (DIR,$dir_path) or die "Can't open current dir: $dir_path\n";
   @files = grep (!/^\.\.?$/, readdir (DIR));
   closedir (DIR);

   for $element (@files) {
       $fname = "$dir_path/$element";
       if (-B $fname){
          if (-s $fname >= $max_size){
             if (($type eq "B"||"b") or ($type eq "A"||"a")){
               system("rm -rf $fname");   # Delete binary files
             }
          }
       }elsif (-T $fname){
          if (-s $fname >= $max_size){
             if (($type eq "T"||"t") or ($type eq "A"||"a")){
               system("rm -rf $fname");   # Delete text files 
             }
          }
       } 
   }
 }
