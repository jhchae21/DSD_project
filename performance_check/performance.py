#!/usr/bin/env python
# coding: utf-8 
# # DSD-2023 Project (CIFAR-10)
# ---
# ## Performance check!
# - This is a python script to help you check the performance of your RTL impelementation and correctness.
# 
# ## Usage
# python performance.py

from utils.setup_cifar10 import *
from utils.board import *
from utils.acc_check import accuracy_check

import time
# import numpy as np


# TEST SET
_, y_test = load_CIFAR10_test()

### Board connection
port_list = get_port_list()
SU = get_scale_uart(port_list)

### Import Student Code here! ###
from your_code import set_weight, inference

### Set Weight
set_weight(SU)

n_data = 64

## Run inference
start = time.time_ns()

preds = inference(SU, n_data)

duration = time.time_ns() - start

## Accuracy check
accuracy_check(preds, y_test, n_data)
print(preds)
print(y_test)

# ### Check accuracy
print("\nEnd-to-end time: {:.2f} ms".format( duration // 1000000 ))

