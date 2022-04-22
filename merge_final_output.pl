#!/usr/bin/perl -w

# This program merge the content of several final_output files.
# Each of the n final_output files should be put in a distinct 
# directory Ii (i=1..n). 

print "Number of final_output files to be merged: ";
$_=<STDIN>;
chomp;$_ =~ s/^\s*//;$_ =~ s/\s*$//;
$n=$_;

#Check directories
for ($i=1;$i<=$n;$i++){
  if (!-s "I$i"){
     warn "Directory I$i doea not exist!\n";
  }
}

#Make directory I_merged
$im="I_merged";
if (-s $im){
  die "Directory $im already exists. Delete it and run again.\n";
}else{
  system("mkdir $im");
}

# Loop, read, write
my (@files);
opendir (DIR, 'I1') or die "Can't open dir I1: $!\n";
@files = grep (/final_output/, readdir (DIR));
closedir (DIR);
foreach(@files){
  $fo=$_;
  open(FO,">$im/$fo") or die ":( $im/$fo";
  loop_over();
  close(FO);
}

# ----------------------------------------------------------------
sub loop_over{
 #Main loop
 $k=0;
 $first = 1;
 for ($i=1;$i<=$n;$i++){
   if (-s "I$i/$fo"){
     open(FOO,"I$i/$fo") or warn "I$i/$fo cannot be oppened\n";
     # read, skip or write the first card
     while(<FOO>){
       if ($first==1){
         print FO $_;   
       }
       if (/Accept initial/){
         $first = 0;
         last;
       }
     }
     #loop, read and write
     while(<FOO>){
       if (/Initial condition =/){
         $k++;
         print FO " Initial condition = $k\n";
       }else{
         print FO $_;
       }    
     }
     close(FOO);
   }
 }
}
