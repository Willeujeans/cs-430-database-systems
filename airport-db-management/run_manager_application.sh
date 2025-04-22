#!/bin/bash
module purge && module load python/bundle-3.10 && python3 -m venv venv && source venv/bin/activate && pip install flask pyodbc && python3 manager_app.py