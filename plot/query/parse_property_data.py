#!/usr/bin/env python3
import csv
import math
from pathlib import Path
import argparse

def parse_args():
    ap = argparse.ArgumentParser(description="Make per-dataset LDBC tables for figure 7")
    ap.add_argument("--dataset", "-d", default="ldbc", help="dataset name (e.g., ldbc, foo)")
    ap.add_argument("--dir", default="results/figure_7", help="directory containing raw/output files")
    return ap.parse_args()

# Display baseline columns (fixed order)
COLS_ADD_DEL = ["Neo4j", "ArangoDB", "PostgreSQL", "OrientDB", "JanusGraph", "AsterDB"]
COLS_GET_UPD = ["Neo4j", "ArangoDB", "PostgreSQL", "OrientDB", "JanusGraph", "NebulaGraph", "AsterDB"]

def norm_engine(raw: str) -> str | None:
    s = raw.strip().lower()
    if "/" in s:
        s = s.split("/")[-1]
    if "neo4j" in s:
        return "Neo4j"
    if "arangodb" in s:
        return "ArangoDB"
    if s.endswith("-pg") or "sqlg" in s or "postgres" in s:
        return "PostgreSQL"
    if "orientdb" in s:
        return "OrientDB"
    if "janus" in s:
        return "JanusGraph"
    if "nebula" in s:
        return "NebulaGraph"
    if "aster" in s:
        return "AsterDB"
    return None

# Script filename -> row label
SCRIPT_LABEL = {
    "insert-node-property.groovy":  "Add Vertex Property",
    "insert-edge-property.groovy":  "Add Edge Property",
    "delete-node-property.groovy":  "Delete Vertex Property",
    "delete-edge-property.groovy":  "Delete Edge Property",
    "update-node-property.groovy":  "Update Vertex Property",
    "update-edge-property.groovy":  "Update Edge Property",
    "node-property-search.groovy":  "Vertex Property Search",
    "edge-specific-property-search.groovy": "Edge Property Search",
}

# Row orders (fixed)
ROWS_ADD_DEL = [
    "Add Vertex Property",
    "Add Edge Property",
    "Delete Vertex Property",
    "Delete Edge Property",
]
ROWS_GET_UPD = [
    "Update Vertex Property",
    "Update Edge Property",
    "Vertex Property Search",
    "Edge Property Search",
]

def to_float_or_zero(s: str) -> float:
    try:
        v = float(s.strip())
        if not math.isfinite(v):
            return 0.0
        return v
    except Exception:
        return 0.0

def main():
    args = parse_args()
    root = Path(args.dir)
    root.mkdir(parents=True, exist_ok=True)

    raw_path = root / f"{args.dataset}_raw.dat"
    out_add_del = root / f"{args.dataset}_add_delete.dat"
    out_get_upd = root / f"{args.dataset}_get_update.dat"

    # table[row_label][baseline] = value
    table: dict[str, dict[str, float]] = {}

    with raw_path.open("r", newline="", encoding="utf-8") as f:
        reader = csv.reader(f)
        for rec in reader:
            if not rec or len(rec) < 3:
                continue
            eng_raw, script_raw, val_raw = rec[0].strip(), rec[1].strip(), rec[2].strip()
            baseline = norm_engine(eng_raw)
            if baseline is None:
                continue
            label = SCRIPT_LABEL.get(script_raw)
            if not label:
                continue
            val = round(to_float_or_zero(val_raw) / 1000.0, 2)
            table.setdefault(label, {})[baseline] = val

    # Write <dataset>_add_delete.dat
    with out_add_del.open("w", encoding="utf-8") as out:
        out.write("Query\t" + "\t".join(COLS_ADD_DEL) + "\n")
        for row_label in ROWS_ADD_DEL:
            cells = [f"\"{row_label}\""]
            for col in COLS_ADD_DEL:
                cells.append(str(table.get(row_label, {}).get(col, 0)))
            out.write("\t".join(cells) + "\n")

    # Write <dataset>_get_update.dat
    with out_get_upd.open("w", encoding="utf-8") as out:
        out.write("Dataset\t" + "\t".join(COLS_GET_UPD) + "\n")
        for row_label in ROWS_GET_UPD:
            cells = [f"\"{row_label}\""]
            for col in COLS_GET_UPD:
                cells.append(str(table.get(row_label, {}).get(col, 0)))
            out.write("\t".join(cells) + "\n")

    print(f"Wrote:\n  {out_add_del}\n  {out_get_upd}")

if __name__ == "__main__":
    main()
