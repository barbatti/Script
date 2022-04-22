 set encoding iso_8859_1; 
 set terminal postscript eps enhanced color colortext font "Arial,18" size 5,5 linewidth 1
 set output 'f.eps'
 reset
 set xlabel "{/Symbol D}R_1 ({\305})" font "Arial, 22" offset 0,-1
 set ylabel "{/Symbol D}R_2 ({\305})" font "Arial, 22" offset -1.5,0 
 xmn =  -3.0
 xmx =   3.0
 ymn =  -3.0
 ymx =   3.0
 set xrange [xmn:xmx]
 set yrange [ymn:ymx]
 unset key
 unset colorbox
 set xtics 1
 set ytics 1
 set cbtics ("" 0)
 set cbrange[0:15]
 set palette rgbformulae 33,13,10
 set pm3d map interpolate 8,8
 set pointsize 1.5
 sp 'waf.dat' u 1:2:3 w pm3d notit, 'points.dat' u 1:2:3 w p 7
