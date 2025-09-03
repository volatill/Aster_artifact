algos="wikipedia orkut twitter"
algo=word(algos,2)
set terminal postscript eps color size 7,7
set output algo."_robustness.eps"
set multiplot layout 3,1 rowsfirst
set xrange [0.05:0.95]
set yrange [1:1550]


set style histogram clustered gap 2 
set style fill pattern 4 border -1 
set boxwidth 0.6 relative

unset key 
set ytics 0,500,1500 font "Helvetica,40" offset -0.5,0.5,0
set xtics font "Helvetica,48" offset 0,-1,0
unset xtics
set xlabel font "Helvetica,48" offset 0,-3,0
set ylabel font "Helvetica,48" offset -10,0,0
set lmargin 18
set rmargin 5
set tmargin 8.5
set border lw 2.5

set origin 0,0.657
set size 1,0.35
set label "Aster's degree threshold" at graph 0.27,1.12 center font "Helvetica-Italic,40"
plot algo."_threshold.dat"  using 1:2 with boxes lw 4 lc rgb '#00B324',\
 algo."_threshold.dat" using 1:($2+150):2 with labels font "Helvetica,36"

unset label
set yrange [0:1.07]
set xrange [0.05:0.95]
set ylabel "Normalized throughput"
#set y2label "Normalized throughput"
set xlabel "Lookup ratio"
unset tics
set ytics nomirror
set ytics ('0' 0, '0.2' 0.2, '0.4' 0.4, '0.6' 0.6, '0.8' 0.8, '1.0' 1.0)
set xtics ('0.2' 0.2, '0.4' 0.4, '0.6' 0.6, '0.8' 0.8)
set boxwidth 1
set key top outside horizontal center
set key height 0
#set key width -3.4
set key spacing 1
#set key top left
set key font "Helvetica,24"
unset key 
set ytics font "Helvetica,48" offset -1.5,0,0
set xtics font "Helvetica,48" offset 0,-1,0
set xlabel font "Helvetica,48" offset 0,-3,0
set ylabel font "Helvetica,48" offset -10,0,0
set lmargin 18
set bmargin 8
set rmargin 5
set tmargin 0
set style line 1 dt 1 pt 6 lc "#00B324" ps 6 lw 12
set style line 2 dt 1 pt 4 lc "#EEA916" ps 6 lw 12
set style line 3 dt 1 pt 10 lc "#2E54FF" ps 6 lw 12
set style line 4 dt 1 pt 12 lc "#FF264C" ps 6 lw 12


set origin 0,0
set size 1,0.674
plot algo.'.dat' using 1:2 smooth csplines ls 1 title "",\
algo.'.dat' using 1:2 with points ls 1 title "GraphDB",\
algo.'.dat' using 1:3 smooth csplines ls 2 title "",\
algo.'.dat' using 1:3 with points ls 2 title "Update-EB",\
algo.'.dat' using 1:4 smooth csplines ls 3 title "",\
algo.'.dat' using 1:4 with points ls 3 title "Full-EB",\
algo.'.dat' using 1:5 smooth csplines ls 4 title "",\
algo.'.dat' using 1:5 with points ls 4 title "Full-VB"



