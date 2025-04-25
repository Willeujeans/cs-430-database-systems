module purge &&
module load python/bundle-3.8 &&
module load java/20 &&
virtualenv . &&
source bin/activate &&
pip install pyodbc Flask;
python manager_app.py