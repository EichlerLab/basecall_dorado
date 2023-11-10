"""
Basecall ONT runs from FAST5.

Adopted from https://github.com/paudano/ont_basecall
"""

### Libraries ###

import datetime
import numpy as np
import os, sys
import pandas as pd
import shutil
import time
import getpass

### Get install directory ###


INSTALL_DIR = os.path.dirname(workflow.snakefile)


configfile: os.path.join(INSTALL_DIR, "config/config.json")


### Setup cell table ###

CELL_DF_FILE_NAME = config.get("cell_table", "ont_basecall.tsv")

CELL_DF = pd.read_csv(
    CELL_DF_FILE_NAME, sep="\t", index_col=["SAMPLE", "SEQ_TYPE", "RUN_ID", "PROFILE"]
)

### Includes ###

shell.prefix("source ~/.bash_profile; ")


wildcard_constraints:
    sample="|".join(CELL_DF.index.get_level_values("SAMPLE")),
    seq_type="|".join(CELL_DF.index.get_level_values("SEQ_TYPE")),
    run_id="|".join(CELL_DF.index.get_level_values("RUN_ID")),
    profile="|".join(
        [
            f"{x}-{y}"
            for y in config["mod_base_profile"]
            for x in config["mod_base_profile"][y]
        ]
        + list(config["profile"].keys())
    ),


include: "rules/basecall.snake"


localrules:
    basecall_all,
