# unset output
set term postscript eps color size 6, 1
set output "property1.eps"
set font 'Helvetica'
set multiplot layout 1,2 rowsfirst

set style data histogram
set style histogram clustered gap 2
set style fill solid border -1
set key font "Helvetica,11"
set key horizontal noinvert outside center top samplen 1.2 enhanced reverse Left height 0.5
unset key
set ylabel "Latency (us)" font "Helvetica,13" off 2,0
# set xlabel "workload" font " Helvetica,15"
unset xlabel
set xtics nomirror font "Helvetica,9" offset 0,0.45 scale 0.01
set ytics 0.2 nomirror font "Helvetica,10" offset 0.6, 0
set yrange [0.009:5000]
set logscale y
set xrange [-0.5:3.5]
set ytics ('0.01' 0.01, '0.1' 0.1, '1' 1, '10' 10, '10^2' 100, '10^3' 1000, '10^4' 10000,'10^5' 100000)
set bmargin 0
set lmargin 5.5
set rmargin 0

Neo4j = 0xAD88C6
ArangoDB = 0xFF8000
OrientDB = 0xFFAE50
PostgreSQL = 0xEEAEAF
JanusGraph = 0xFED98E
Nebula = 0xA98175
OurMethod = 0x67A9CF

set label "(E) Property Queries on Freebase Large" at screen 0.28,0.05 center font "Helvetica,12"
set label "(F) Property Queries on LDBC Datagen" at screen 0.765,0.05 center font "Helvetica,12"

set origin 0.0,0.2
set size 0.53,0.8
plot 'freebase_add_delete.dat' using 2:xticlabels(1) title columnheader(2) lc rgb Neo4j, \
'' using 3:xticlabels(1) title columnheader(3) lc rgb ArangoDB,\
'' using 5:xticlabels(1) title columnheader(4) lc rgb OrientDB,\
'' using 4:xticlabels(1) title columnheader(5) lc rgb PostgreSQL,\
'' using 6:xticlabels(1) title columnheader(6) lc rgb JanusGraph,\
'' using 7:xticlabels(1) title columnheader(7) lc rgb OurMethod

set origin 0.0,0.2
set size 0.53,0.8
set style fill pattern border -1
plot 'freebase_add_delete.dat' using 2:xticlabels(1) title columnheader(2) fillstyle solid lc rgb Neo4j,\
'' using 3:xticlabels(1) title columnheader(3) fillstyle pattern 1 transparent lc rgb 'black',\
'' using 5:xticlabels(1) title columnheader(4) fillstyle pattern 2 transparent lc rgb 'white',\
'' using 4:xticlabels(1) title columnheader(5) fillstyle pattern 4 transparent lc rgb 'black',\
'' using 6:xticlabels(1) title columnheader(6) fillstyle pattern 15 transparent lc rgb 'black',\
'' using 7:xticlabels(1) title columnheader(7) fillstyle pattern 4 transparent lc rgb 'white'

unset key
unset ytics
unset ylabel

# set xlabel "workload composition(range read,update,point read)(%)" font "Helvetica,17" off 0,-1.5
set style fill solid border -1
set origin 0.4765,0.2
set size 0.52,0.8
plot 'ldbc_add_delete.dat' using 2:xticlabels(1) title columnheader(2) lc rgb Neo4j, \
'' using 3:xticlabels(1) title columnheader(3) lc rgb ArangoDB,\
'' using 5:xticlabels(1) title columnheader(4) lc rgb OrientDB,\
'' using 4:xticlabels(1) title columnheader(5) lc rgb PostgreSQL,\
'' using 6:xticlabels(1) title columnheader(6) lc rgb JanusGraph,\
'' using 7:xticlabels(1) title columnheader(7) lc rgb OurMethod

set origin 0.4765,0.2
set size 0.52,0.8
set style fill pattern border -1
plot 'ldbc_add_delete.dat' using 2:xticlabels(1) title columnheader(2) fillstyle solid lc rgb Neo4j,\
'' using 3:xticlabels(1) title columnheader(3) fillstyle pattern 1 transparent lc rgb 'black',\
'' using 5:xticlabels(1) title columnheader(4) fillstyle pattern 2 transparent lc rgb 'white',\
'' using 4:xticlabels(1) title columnheader(5) fillstyle pattern 4 transparent lc rgb 'black',\
'' using 6:xticlabels(1) title columnheader(6) fillstyle pattern 15 transparent lc rgb 'black',\
'' using 7:xticlabels(1) title columnheader(7) fillstyle pattern 4 transparent lc rgb 'white'

unset multiplot
unset label
reset session
