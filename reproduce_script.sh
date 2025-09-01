#!/bin/bash
## Instructions for running Aster experiments

## Environment Setup
preparation(){
    git submodule update --init --recursive

    pip install numpy
    pip3 install numpy
    conda create -y -n py27 python=2.7
    source "$(conda info --base)/etc/profile.d/conda.sh"
    conda activate py27
    conda install -y -c conda-forge subprocess32
    python -c "import subprocess32, sys; print('ok', subprocess32.__version__, sys.version)"

    cd graph-baselines
    ./build_image.sh
    ./download_graphs.sh
    ./prepare_data.sh
    cd ..

    sudo apt-get install gnuplot
    sudo apt-get install gnuplot-x11
    sudo apt install r-base

    sudo apt-get install -y libjemalloc2
    export LD_PRELOAD="$(
    ( /sbin/ldconfig -p 2>/dev/null || /usr/sbin/ldconfig -p 2>/dev/null || ldconfig -p ) \
    | awk '/libjemalloc\.so(\.|$)/{print $4; exit}'
    )"
}

datasets=("dblp" "wikipedia" "orkut" "twitter")

gen_figure_6(){
    mkdir results/figure_6
    rm -rf results/figure_6/*.dat
    echo "Figure 6:"

    for dataset in "${datasets[@]}"; do
        cd graph-baselines
        ./fig6.sh $dataset
        cd ..
        cd AsterDB
        ./fig6.sh $dataset
        RAW="fig6_raw.dat"
        OUT="../graph-baselines/fig6.dat"
        awk '
        function norm(x,  lx){ lx=tolower(x); return (lx=="nan"||lx=="inf"||lx=="+inf"||lx=="-inf") ? 0 : x }
        {
        if (match($0, /get:[[:space:]]*([0-9.+-eE]+)/, mg)) { g = norm(mg[1]); have_g=1 }
        if (match($0, /add:[[:space:]]*([0-9.+-eE]+)/, ma)) { a = norm(ma[1]); have_a=1 }
        if (have_g && have_a) { printf("aster,%.2f,%.2f\n", g, a); have_g=have_a=0 }
        }
        ' "$RAW" >> "$OUT"
        cd ..

        cp graph-baselines/fig6.dat results/figure_6/${dataset}_raw.dat
        cd results/figure_6
        python3 ../../plot/throughput/parse_data.py --input ${dataset}_raw.dat --output ${dataset}.dat
        gnuplot ../../plot/throughput/plot_$dataset.gnu
        cd ../..
    done
}

gen_figure_7(){
    mkdir results/figure_7
    rm -rf results/figure_7/*.dat
    echo "Figure 7:"
    queries=(get_neighbors add_vertex add_edge del_edge)
    for query in "${queries[@]}"; do
     echo "Dataset	Neo4j	ArangoDB	PostgreSQL	OrientDB	JanusGraph	NebulaGraph	AsterDB" > results/figure_7/${query}.dat
    done
    for dataset in "${datasets[@]}"; do
        cd graph-baselines
        ./fig7.sh $dataset
        cd ..
        cp graph-baselines/fig7.dat results/figure_7/${dataset}_raw.dat

        outdir="results/figure_7"
        case "$dataset" in
          dblp|DBLP)          ds_name="DBLP" ;;
          wikipedia|Wiki*)    ds_name="Wikipedia" ;;
          orkut|Orkut)        ds_name="Orkut" ;;
          twitter|Twitter)    ds_name="Twitter" ;;   # change to "Twitch" if that’s your dataset
          *)                  ds_name="$dataset" ;;
        esac

        # ensure headers exist once per method file
        ensure_header() {
          local f="$1"
          if [[ ! -s "$f" ]]; then
            printf "Dataset\tNeo4j\tArangoDB\tPostgreSQL\tOrientDB\tJanusGraph\tNebulaGraph\tAsterDB\n" > "$f"
          fi
        }
        for m in get_neighbors add_vertex add_edge del_edge; do
          ensure_header "$outdir/$m.dat"
        done

        # parse CSV and append one row per method file
        awk -F',' -v ds="$ds_name" -v outdir="$outdir" '
        BEGIN {
          OFS = "\t"
          methods[1]="get_neighbors"; methods[2]="add_vertex"; methods[3]="add_edge"; methods[4]="del_edge";
          # desired output column order:
          slots[1]="Neo4j"; slots[2]="ArangoDB"; slots[3]="PostgreSQL"; slots[4]="OrientDB"; slots[5]="JanusGraph"; slots[6]="NebulaGraph"; slots[7]="AsterDB";
        }
        NR==1 {
          # map header names to indices
          for (i=1; i<=NF; i++) { gsub(/^[ \t]+|[ \t]+$/, "", $i); col[$i]=i }
          next
        }
        {
          # normalize db name -> slot
          db = $1; gsub(/^[ \t]+|[ \t]+$/, "", db)
          dbl = tolower(db)
          slot=""
          if      (dbl ~ /neo4j/)           slot="Neo4j"
          else if (dbl ~ /arangodb/)        slot="ArangoDB"
          else if (dbl ~ /(sqlg|-pg|postgres)/) slot="PostgreSQL"
          else if (dbl ~ /orientdb/)        slot="OrientDB"
          else if (dbl ~ /janus/)           slot="JanusGraph"
          else if (dbl ~ /nebula/)          slot="NebulaGraph"
          else if (dbl ~ /aster/)           slot="AsterDB"
          if (slot=="") next

          # capture values for each method; nan -> 0
          for (mi=1; mi<=4; mi++) {
            m = methods[mi]
            idx = col[m]
            if (!idx) continue
            v = $(idx)
            gsub(/^[ \t]+|[ \t]+$/, "", v)
            tl = tolower(v)
            if (tl=="nan" || tl=="inf" || tl=="+inf" || tl=="-inf" || v=="") v=0
            vals[m,slot] = v + 0
          }
        }
        END{
          for (mi=1; mi<=4; mi++) {
            m = methods[mi]
            line = ds
            for (si=1; si<=7; si++) {
              s = slots[si]
              v = ((m SUBSEP s) in vals) ? vals[m,s] : 0
              line = line OFS v
            }
            file = outdir "/" m ".dat"
            print line >> file
            close(file)
          }
        }
        ' results/figure_7/${dataset}_raw.dat

        cd results/figure_7
        cd ../..
    done


    cd results/figure_7
    gnuplot ../../plot/query/plot1.gnu
    gnuplot ../../plot/query/plot2.gnu
}

gen_figure_8(){
    mkdir results/figure_8
    rm -rf results/figure_8/*.dat
    echo "Figure 8:"

}

gen_figure_9(){
    mkdir results/figure_9
    rm -rf results/figure_9/*.dat
    echo "Figure 9:"


}

usage() {
  cat <<EOF
Usage: $0 [setup] [figure_6] [figure_7] [figure_8] [figure_9]
- No args: run figure_6, figure_7, figure_8, figure_9 in order.
- You can also pass one or multiple targets, e.g.: $0 setup figure_6
EOF
}

main() {
  mkdir -p results

  if [[ $# -eq 0 ]]; then
    gen_figure_6
    gen_figure_7
    gen_figure_8
    gen_figure_9
    exit 0
  fi

  for arg in "$@"; do
    case "$arg" in
      setup)     preparation ;;
      figure_6)  gen_figure_6 ;;
      figure_7)  gen_figure_7 ;;
      figure_8)  gen_figure_8 ;;
      figure_9)  gen_figure_9 ;;
      *)         echo "[ERROR] unknown target: $arg"; usage; exit 1 ;;
    esac
  done
}

main "$@"