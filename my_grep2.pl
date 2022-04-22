#!/usr/bin/perl -w

my_grep("test.txt","test","4",2,"A","append");

sub my_grep{
 # This routine works like the system grep with options -A and -B.
 # Usage:
 # my_grep($file,$file_dest,$pattern,$lines,$direction,$position)
 # where $file - file to be searched
 #       $file_dest - destination file
 #       $pattern - the pattern to be searched
 #       $lines - number of lines to be printed before or after the matching (0 = default)
 #       $direction A - print $lines after matching (default)
 #                  B - print $lines before matching
 #       $position new - overwrite previous content (default)
 #                 append - append to previous content
 # Mario Barbatti, Jun 2007
 #
 local($file,$file_dest,$pattern,$lines,$direction,$position,$found,$i,$j,@history,$mdle);
 $mdle  = "my_grep subroutine: ";
 $lines = 0;
 $direction = "A";
 $position = "new";
 $found = "";
 $file = "none_in_mygrep";
 $file_dest = "none_in_mygrep";
 ($file,$file_dest,$pattern,$lines,$direction,$position)=@_;
  $direction = lc $direction;
  $position  = lc $position;
  open(FL,$file) or die "Cannot open $file!";
  while(<FL>){
    push(@history,$_);
    $j++;
    if (/$pattern/){
      $found = $_;
      if ($lines != 0){
        if ($direction eq "a"){
          while(<FL>){
            $i++;
            if ($i <= $lines){
              $found = $found.$_;
            }
          }
        }elsif($direction eq "b"){
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
  if ($position eq "new"){
    open(FL,">$file_dest") or die "$mdle Cannot open $file_dest to write!";
  }elsif($position eq "append"){
    open(FL,">>$file_dest") or die "$mdle Cannot open $file_dest to append!";
  }else{
    die "$mdle exiting without writing \n";
  }
  print FL $found;
  close(FL);
}
