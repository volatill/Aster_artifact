#!/bin/bash
## Instructions for running Aster experiments

## Environment Setup
numpy_install(){
  source "$(conda info --base)/etc/profile.d/conda.sh"
  conda activate py27

  conda install -y numpy
  python3 -m pip install numpy

  python3 -c "import sys, numpy; print(sys.executable); print('numpy', numpy.__version__)"
}

preparation(){
    git config --global url."https://github.com/".insteadOf git@github.com:
    git submodule sync --recursive
    git submodule update --init --recursive
    cd AsterDB
    git submodule update --init --recursive
    cd ..

    pip install numpy
    pip3 install numpy
    conda create -y -n py27 python=2.7
    source "$(conda info --base)/etc/profile.d/conda.sh"
    conda activate py27
    conda install -y -c conda-forge subprocess32
    python -c "import subprocess32, sys; print('ok', subprocess32.__version__, sys.version)"

    sudo apt-get install gnuplot
    sudo apt-get install gnuplot-x11
    sudo apt install r-base

    sudo apt-get install -y libjemalloc2
    export LD_PRELOAD="$(
    ( /sbin/ldconfig -p 2>/dev/null || /usr/sbin/ldconfig -p 2>/dev/null || ldconfig -p ) \
    | awk '/libjemalloc\.so(\.|$)/{print $4; exit}'
    )"

    cd graph-baseline-ext
    bash ./build_duckdb.sh
    bash ./build_umbra.sh
    cd ..

    cd AsterDB
    export USER_HOME_PATH=${PWD}
    sudo apt-get update
    sudo apt-get install g++-10 make libboost-all-dev -y
    sudo rm /usr/bin/g++
    sudo ln -s /usr/bin/g++-10 /usr/bin/g++
    sudo apt-get install openjdk-11-jdk
    export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
    sudo mkdir /usr/local/maven/
    mkdir $USER_HOME_PATH/.m2/ && mkdir $USER_HOME_PATH/.m2/repository
    wget https://repo.maven.apache.org/maven2/org/apache/maven/apache-maven/3.9.9/apache-maven-3.9.9-bin.tar.gz
    sudo tar -xvzf apache-maven-3.9.9-bin.tar.gz -C /usr/local/maven
    bash ./build_db.sh
    cd ..

    cd graph-baselines
    ./build_image.sh
    bash ./download_graphs.sh
    datasets=("dblp" "wikipedia" "orkut", "twitch" "cit-patents" "wiki-talk")
    for dataset in "${datasets[@]}"; do
      ./prepare_data.sh $dataset
    done
    cd ..
}



gen_figure_6(){
    mkdir results/figure_6
    rm -rf results/figure_6/*.dat
    echo "Figure 6:"
    datasets=("dblp" "wikipedia" "orkut")
    for dataset in "${datasets[@]}"; do
        cd graph-baselines
        ./fig6.sh $dataset
        cd ..
        cd AsterDB
        ./fig6.sh ${dataset} > fig6_raw.dat
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

gen_figure_6_twitter(){
    mkdir results/figure_6
    echo "Figure 6(d):"
    datasets=("twitter")
    cd graph-baselines
    ./prepare_data.sh twitter
    cd ..
    for dataset in "${datasets[@]}"; do
        cd graph-baselines
        ./fig6.sh $dataset
        cd ..
        cd AsterDB
        ./fig6.sh ${dataset} > fig6_raw.dat
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
    datasets=("dblp" "twitch" "wikipedia" "orkut")
    for dataset in "${datasets[@]}"; do
        cd graph-baselines
        ./fig7.sh $dataset
        cd ..
        cd AsterDB
        ./fig7.sh ${dataset} > fig7_raw.dat
        RAW="fig7_raw.dat"
        OUT="../graph-baselines/fig7.dat"
        awk -v out="$OUT" '
        BEGIN {
          # defaults (if a key is missing, we print 0.00)
          getv = addv = adde = dele = 0.0
        }
        {
          line = tolower($0)

          # Each time we see a match, we overwrite: the last block wins
          if (match(line, /^get[[:space:]]*avg:[[:space:]]*([0-9.]+)/, m))   { getv = m[1] + 0.0 }
          if (match(line, /^addv[[:space:]]*avg:[[:space:]]*([0-9.]+)/, m))  { addv = m[1] + 0.0 }
          if (match(line, /^adde[[:space:]]*avg:[[:space:]]*([0-9.]+)/, m))  { adde = m[1] + 0.0 }
          if (match(line, /^dele[[:space:]]*avg:[[:space:]]*([0-9.]+)/, m))  { dele = m[1] + 0.0 }
        }
        END {
          # Map: get -> get_neighbors, addv -> add_vertex, adde -> add_edge, dele -> del_edge
          # Two decimals to match your fig7.dat style
          printf("aster,%.2f,%.2f,%.2f,%.2f\n", getv, addv, adde, dele) >> out
        }
        ' "$RAW"
        cd ..

        cp graph-baselines/fig7.dat results/figure_7/${dataset}_raw.dat

        outdir="results/figure_7"
        case "$dataset" in
          dblp|DBLP)          ds_name="DBLP" ;;
          wikipedia|Wiki*)    ds_name="Wikipedia" ;;
          orkut|Orkut)        ds_name="Orkut" ;;
          twitch|Twitch)    ds_name="Twitch" ;;   # change to "Twitch" if that’s your dataset
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
    done
    cd results/figure_7
    gnuplot ../../plot/query/plot1.gnu
    gnuplot ../../plot/query/plot2.gnu
    cd ../..

    datasets=("ldbc" "freebase")
    for dataset in "${datasets[@]}"; do
      cd graph-baselines
      ./fig7_property.sh $dataset
      cd ..

      cd AsterDB
      ./fig7_property.sh ${dataset} > fig7_property_raw.dat
      RAW="fig7_property_raw.dat"
      OUT="../graph-baselines/fig7_property.dat"
      mkdir -p "$(dirname "$OUT")"
      awk -v out="$OUT" '
      BEGIN {
        OFS=",";
        # Map operation phrase -> script filename
        map["vertex property search"]      = "node-property-search.groovy";
        map["edge property search"]        = "edge-specific-property-search.groovy";
        map["update vertex property"]      = "update-node-property.groovy";
        map["update edge property"]        = "update-edge-property.groovy";
        map["insert vertex property"]      = "insert-node-property.groovy";
        map["insert edge property"]        = "insert-edge-property.groovy";
        map["remove vertex property"]      = "delete-node-property.groovy";
        map["remove edge property"]        = "delete-edge-property.groovy";
      }
      {
        # Lowercase the whole line to be case-insensitive
        line = tolower($0)

        # Extract: time of <phrase>: <number>ns
        # Capture the phrase and numeric value (allow decimals)
        if (match(line, /time of[[:space:]]+([^:]+):[[:space:]]*([0-9.]+)[[:space:]]*ns/, m)) {
          key = m[1]                               # e.g. "vertex property search"
          gsub(/^[[:space:]]+|[[:space:]]+$/, "", key)
          script = (key in map) ? map[key] : ""
          if (script == "") next

          # ns -> microseconds
          val_ns = m[2] + 0.0
          val_us = val_ns

          # Two decimals
          printf("aster,%s,%.2f\n", script, val_us) >> out
        }
      }
      ' "$RAW"

      cp graph-baselines/fig7.dat results/figure_7/${dataset}_raw.dat
      python3 plot/query/parse_property_data.py --dataset ${dataset}
    done
    cd results/figure_7
    gnuplot ../../plot/query/plot1.gnu
    gnuplot ../../plot/query/plot2.gnu
    cd ../..
}

gen_figure_8(){
    mkdir results/figure_8
    rm -rf results/figure_8/*.dat
    echo "Figure 8:"
    set -euo pipefail
    datasets=("wikipedia" "orkut")
    for dataset in "${datasets[@]}"; do
      cd AsterDB
      ./fig8.sh $dataset > fig8_raw.dat
      cd ..
      cp AsterDB/fig8_raw.dat results/figure_8/${dataset}_raw.dat
      RAW="results/figure_8/${dataset}_raw.dat"
      OUT="results/figure_8/${dataset}.dat"
      mkdir -p "$(dirname "$OUT")"
      : > "$OUT" 

      LC_ALL=C awk -v out="$OUT" '
      BEGIN{
        OFS="\t"
        # fixed ratios to emit
        for(i=1;i<=9;i++) R[i]=i/10.0
      }
      {
        line=$0

        # track current update policy
        if (match(line,/using update policy:[[:space:]]*([0-9]+)/,m)) {
          pol = m[1] + 0
          next
        }

        # track current ratio from rops/wops
        if (match(line,/rops:[[:space:]]*([0-9]+)[[:space:]]+wops:[[:space:]]*([0-9]+)/,m)) {
          rops = m[1] + 0
          wops = m[2] + 0
          total = rops + wops
          if (total > 0) {
            r = rops / total
            rkey = sprintf("%.1f", r)    # e.g. 0.1 .. 0.9
          } else { rkey="" }
          next
        }

        # compute throughput at current (policy, ratio)
        if (match(line,/get:[[:space:]]*([0-9.]+),[[:space:]]*add:[[:space:]]*([0-9.]+)/,m)) {
          if (rkey == "" || pol == "") next
          get_us = m[1] + 0.0
          add_us = m[2] + 0.0
          rr = rkey + 0.0
          L = rr*get_us + (1.0-rr)*add_us
          thr = (L > 0 ? 1000000.0 / L : 0.0)

          key = pol ":" rkey
          THR[key] = thr
          # track row-wise max per ratio
          if (!(rkey in RMAX) || thr > RMAX[rkey]) RMAX[rkey] = thr
        }
      }
      END{
        for (i=1;i<=9;i++){
          rkey = sprintf("%.1f", R[i])
          rowmax = (rkey in RMAX ? RMAX[rkey] : 0)

          # raw values per policy (default 0)
          v2 = (("2:" rkey) in THR ? THR["2:" rkey] : 0)
          v1 = (("1:" rkey) in THR ? THR["1:" rkey] : 0)
          v0 = (("0:" rkey) in THR ? THR["0:" rkey] : 0)

          # normalize by row max (if any)
          if (rowmax > 0) {
            n2 = v2 / rowmax
            n1 = v1 / rowmax
            n0 = v0 / rowmax
          } else {
            n2 = n1 = n0 = 0
          }

          printf("%.1f\t%.9f\t%.9f\t%.9f\t0\n", R[i], n2, n1, n0) >> out
        }
      }
      ' "$RAW"
      echo "[OK] Wrote $OUT"
      cd results/figure_8
      gnuplot ../../plot/robustness/plot_$dataset.gnu
      cd ../..
    done
}

gen_figure_9(){
    mkdir results/figure_9
    rm -rf results/figure_9/*.dat
    echo "Figure 9:"
    cd AsterDB
    ./fig9.sh > fig9_raw.dat
    cd ..

    cd graph-baseline-ext/duckdb
    ./fig9.sh > fig9_raw.dat
    cd ../..

    cd graph-baseline-ext/umbra
    docker run -v umbra-db:/var/db -p 5432:5432 --ulimit nofile=1048576:1048576 --ulimit memlock=8388608:8388608 umbradb/umbra:latest
    ./load_data.sh
    ./fig9.sh > fig9_raw.dat
    cd ../..

    cp AsterDB/fig9_raw.dat results/figure_9/aster.dat
    cp graph-baseline-ext/duckdb/fig9_raw.dat results/figure_9/duckdb.dat
    cp graph-baseline-ext/umbra/fig9_raw.dat results/figure_9/umbra.dat
}

gen_table_6() {
    mkdir results/table_6
    rm -rf results/table_6/*.dat
    datasets=("cit-patents" "wiki-talk")
    for dataset in "${datasets[@]}"; do
        cd graph-baselines
        ./tab6.sh $dataset
        cd ..
        cd AsterDB
        ./tab6.sh ${dataset} > tab6_raw.dat
        RAW="tab6_raw.dat"
        OUT="../graph-baselines/tab6.dat"
        awk '
        function norm(x,  lx){ lx=tolower(x); return (lx=="nan"||lx=="inf"||lx=="+inf"||lx=="-inf") ? 0 : x }
        {
        if (match($0, /get:[[:space:]]*([0-9.+-eE]+)/, mg)) { g = norm(mg[1]); have_g=1 }
        if (match($0, /add:[[:space:]]*([0-9.+-eE]+)/, ma)) { a = norm(ma[1]); have_a=1 }
        if (have_g && have_a) { printf("aster,%.2f,%.2f\n", g, a); have_g=have_a=0 }
        }
        ' "$RAW" >> "$OUT"
        cd ..

        cp graph-baselines/fig6.dat results/figure_6/${dataset}_results.dat
        # cd results/table_6
        # # python3 ../../plot/throughput/parse_data.py --input ${dataset}_raw.dat --output ${dataset}.dat
        # # gnuplot ../../plot/throughput/plot_$dataset.gnu
        # cd ../..
    done
}

usage() {
  cat <<EOF
Usage: $0 [setup] [figure_6] [figure_7] [figure_8] [figure_9] [table_6]
- No args: run figure_6, figure_7, figure_8, figure_9 in order.
- You can also pass one or multiple targets, e.g.: $0 setup figure_6
EOF
}

main() {
  mkdir -p results

  if [[ "$#" -eq 2 ]] && { { [[ "$1" == "figure_6" && "$2" == "twitter" ]]; } || { [[ "$1" == "twitter" && "$2" == "figure_6" ]]; }; }; then
    gen_figure_6_twitter
    exit 0
  fi

  if [[ $# -eq 0 ]]; then
    gen_figure_6
    gen_figure_7
    gen_figure_8
    gen_figure_9
    gen_table_6
    exit 0
  fi

  for arg in "$@"; do
    case "$arg" in
      setup)     preparation ;;
      figure_6)  gen_figure_6 ;;
      figure_7)  gen_figure_7 ;;
      figure_8)  gen_figure_8 ;;
      figure_9)  gen_figure_9 ;;
      table_6)  gen_table_6 ;;
      numpy) numpy_install ;;
      *)         echo "[ERROR] unknown target: $arg"; usage; exit 1 ;;
    esac
  done
}

main "$@"