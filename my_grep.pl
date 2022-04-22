#!/usr/bin/perl -w

$string = my_grep("test.txt","4",8,"A");
print "$string \n";


sub my_grep{
 # This routine works like the system grep with options -A and -B.
 # Usage:
 # $value = my_grep($file,$pattern,$lines,$position)
 # where $file is the file to be searched
 #       $pattern is the pattern to be searched
 #       $lines is the number of lines to be returned before or after the matching
 #       $position A - return $lines after matching
 #                 B - return $lines before matching
 #       $value contains the matching line plus the other $lines lines separated by \n
 # Mario Barbatti, Jun 2007
 #
 local($file,$pattern,$lines,$position,$found,$i,$j,@history,$mdle);
 $mdle  = "my_grep subroutine: ";
 $lines = 0;
 $found = "$mdle Pattern not found \n";
 ($file,$pattern,$lines,$position)=@_;
  $position = lc $position;
  open(FL,$file) or die "Cannot open $file!";
  while(<FL>){
    push(@history,$_);
    $j++;
    if (/$pattern/){
      $found = $_;
      if ($lines != 0){
        if ($position eq "a"){
          while(<FL>){
            $i++;
            if ($i <= $lines){
              $found = $found.$_;
            }
          }
        }elsif($position eq "b"){
          for ($i = 1; $i<=$lines; $i++){
            $found = $history[$j-$i-1].$found;
            if ($j-$i-1 <= 0){
              last;
            }
          }
        }
      }
    }
  }
  close(FL);
  return $found;
}
