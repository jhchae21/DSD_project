# 2025 DSD Performance Measure Codes

## Procedure to check your CNN accelerator performance 
You can check your performance via below command.
```
python3 performance.py
```

## Description about this project

Main modification for this project is `your_code.py` and `utils/scale_uart.py`.
We will check your performance with 64 images.

Performance measurement doesn't include `set_weight` in `your_code.py`.

Performance measurement includes `load_data` and `inference` in `your_code.py`.

Do not compute in host ( e.g. perform multiplication at host via '*' ) 

