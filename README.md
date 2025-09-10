# Reproducibility Instructions

The following instructions are for reproducing the experiments we demonstrated in our paper:

> **Aster: Enhancing LSM-structures for Scalable Graph Database**  
> *Dingheng Mo, Junfeng Liu, Fan Wang, Siqiang Luo*  
> *Proceedings of the ACM on Management of Data (SIGMOD 2025)*

## Requirements

- [Anaconda](https://www.anaconda.com/)
- [Docker](https://www.docker.com/)
- 128GM memory space
- At least 500GB disk space

## Environment Setup

```bash
./reproduce_script.sh setup 
```

## Experimentation

Experiments in our paper can be runned and plotted by excuting the following command:

```bash
./reproduce_script.sh  
```

You can also run `reproduce_script.sh` with a specific figure you want to reproduce as parameter. For example, if you want to reproduce Figure 6 in our paper, you can run 
```bash
./reproduce_script.sh figure_6
```

Available parameters include `figure_6`, `figure_7`, `figure_8`, `figure_9`, and `table_6`. 

Note: To reproduce Figure 6(d) from our paper, please be aware that, depending on system performance, preloading data and executing experiments on the `Twitter` dataset may require few days or even longer for each method. For this reason, we have separated this case from the default workflow. To run experiments specifically on the `Twitter` dataset, please invoke the script with both parameters `figure_6` and `twitter`, as follows:

```bash
./reproduce_script.sh figure_6 twitter
```


## Result

You can find each generated figure and its corresponding results in the respective file under the **`results`** folder.
Please note that the figure legends are not included. For the legend corresponding to each method, kindly refer to our paper.
(https://dl.acm.org/doi/pdf/10.1145/3709662)