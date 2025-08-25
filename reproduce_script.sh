#!/bin/bash
## Instructions for running Aster experiments

## Environment Setup
preparation(){
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
        cp graph-baselines/fig6.dat results/figure_6/{$dataset}_raw.dat
        python3 results/figure_6/parse_data.py $dataset
        cd results/figure_6
        gnuplot plot_$dataset.gnu
        cd ../..
    done
}

gen_figure_7(){
    mkdir results/figure_7
    rm -rf results/figure_7/*.dat
    echo "Figure 7:"

    for dataset in "${datasets[@]}"; do
        cd graph-baselines
        ./fig6.sh $dataset
        cd ..
        cp graph-baselines/fig7.dat results/figure_7/$dataset.dat
        cd results/figure_7
        cd ../..
    done

    python3 results/figure_7/parse_data.py 
    gnuplot plot1.gnu
    gnuplot plot2.gnu
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


mkdir results