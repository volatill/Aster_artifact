#!/usr/bin/env python3
import argparse
import csv
import math
from collections import defaultdict

def parse_args():
    ap = argparse.ArgumentParser(description="Convert dblp_raw.dat to dblp.dat")
    ap.add_argument("--input", "-i", default="dblp_raw.dat", help="raw input file")
    ap.add_argument("--output", "-o", default="dblp.dat", help="output dat file")
    ap.add_argument("--precision", type=int, default=8, help="decimal places for numbers")
    return ap.parse_args()


ENGINE_ORDER = [
    "aster",               
    "gremlin-neo4j-tp3",   # Neo4j
    "gremlin-orientdb",    # OrientDB
    "gremlin-arangodb",    # ArangoDB
    "gremlin-pg",          # SQLG
    "gremlin-janusgraph",  # JanusGraph
    "nebulagraph",  # NebulaGraph
]

RATIOS = [i / 10.0 for i in range(1, 10)]  # 0.1 .. 0.9

def safe_float(x: str):
    try:
        v = float(x)
        if not math.isfinite(v):
            return None
        return v
    except Exception:
        return None

def throughput_ops_per_sec(ratio: float, read_us: float, write_us: float) -> float:
    if read_us is None or write_us is None:
        return 0.0
    # nan / inf 
    if not (math.isfinite(read_us) and math.isfinite(write_us)):
        return 0.0
    L = ratio * read_us + (1.0 - ratio) * write_us  
    if L <= 0:
        return 0.0
    return 1_000_000.0 / L

def main():
    args = parse_args()

    values = {eng: [0.0] * len(RATIOS) for eng in ENGINE_ORDER}
    seen_idx = defaultdict(int)  
    with open(args.input, "r", newline="") as f:
        reader = csv.reader(f)
        for row in reader:
            if not row:
                continue
            row = [c.strip() for c in row]
            if len(row) < 3:
                continue
            eng, read_s, write_s = row[0], row[1], row[2]
            if eng not in ENGINE_ORDER:
                continue

            idx = seen_idx[eng]
            if idx >= len(RATIOS):
                continue
            r = RATIOS[idx]

            read_us = safe_float(read_s)
            write_us = safe_float(write_s)
            thr = throughput_ops_per_sec(r, read_us, write_us)

            values[eng][idx] = thr
            seen_idx[eng] += 1

    fmt = "{:." + str(args.precision) + "f}"

    with open(args.output, "w") as out:
        for i, r in enumerate(RATIOS):
            row_out = [f"{r:.1f}"]  
            for eng in ENGINE_ORDER:
                row_out.append(fmt.format(values[eng][i]))
            out.write("\t".join(row_out) + "\n")

if __name__ == "__main__":
    main()