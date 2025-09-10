set terminal postscript eps enhanced color size 7,2.3
set output 'inmemory.eps'
#unset terminal
#unset output
set font 'Helvetica'
#set fontpath '/home/junfengliu/Desktop/Helvetica.ttc'
set multiplot layout 1,2 rowsfirst
set border lw 2.5 lc rgb "black"
set boxwidth 0.9 relative

set logscale y
set style data histogram
set style histogram clustered gap 1.8
set style fill solid border -1
set key font "Helvetica,24"
set key horizontal noinvert outside center top samplen 1 enhanced reverse Left height 0.5
unset key
set ylabel "Latency (us)" font "Helvetica,24" off -1.5,0
set xlabel font "Helvetica,24"
set xtics nomirror  font "Helvetica,24" offset 0,-1 scale 0.01
set ytics ('0.01' 0.01, '0.1' 0.1, '1' 1, '10' 10, '10^2' 100, '10^3' 1000, '10^4' 10000) font "Helvetica,24"
set yrange [0.5: 2000] 
set xrange [-0.6: 1.6]

set bmargin 6
set lmargin 5.5
set rmargin 0
set tmargin 0

levelc = 0xCC4C02
tierc = 0xFF8000
lazylevelc = 0xFFAE50
bushc = 0xFED92A
dosc = 0xFED98E
fanc = 0xA8DDB5
wafanc = 0x67A9CF

unset label
set label "(A) WikiTalk" at graph 0.48,-0.29 center font "Helvetica,24" textcolor rgb "black"

set origin 0.04,0
set size 0.45,0.95
plot 'wikitalk.dat' using 2:xticlabels(1) title columnheader(2) lw 4 lc rgb levelc,\
'' using 3:xticlabels(1) title columnheader(3) lw 4 lc rgb tierc,\
'' using 4:xticlabels(1) title columnheader(4) lw 4 lc rgb lazylevelc

set origin 0.04,0
set size 0.45,0.95
set style fill pattern border -1
plot 'wikitalk.dat' using 2:xticlabels(1) title columnheader(2) fillstyle pattern 1 transparent lc rgb levelc,\
'' using 3:xticlabels(1) title columnheader(3) fillstyle pattern 1 transparent lc rgb 'black',\
'' using 4:xticlabels(1) title columnheader(4) fillstyle pattern 2 transparent lc rgb 'white'

set logscale y
set style data histogram
set style fill solid border -1
set key font "Helvetica,24"
set key horizontal noinvert outside center top samplen 1 enhanced reverse Left height 0.5
unset key

unset label
set label "(B) DBLP" at graph 0.48,-0.29 center font "Helvetica,24" textcolor rgb "black"


set origin 0.53,0
set size 0.45,0.95
plot 'dblp.dat' using 2:xticlabels(1) title columnheader(2) lw 4 lc rgb levelc,\
'' using 3:xticlabels(1) title columnheader(3) lw 4 lc rgb tierc,\
'' using 4:xticlabels(1) title columnheader(4) lw 4 lc rgb lazylevelc

set origin 0.53,0
set size 0.45,0.95
set style fill pattern border -1
plot 'dblp.dat' using 2:xticlabels(1) title columnheader(2) fillstyle pattern 1 transparent lc rgb levelc,\
'' using 3:xticlabels(1) title columnheader(3) fillstyle pattern 1 transparent lc rgb 'black',\
'' using 4:xticlabels(1) title columnheader(4) fillstyle pattern 2 transparent lc rgb 'white'

unset multiplot