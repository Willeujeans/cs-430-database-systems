# Web Management Application
`manager_app.py`
You will complete the missing ODBC/PostgreSQL integration in a Python Flask application.

Tasks:
Implement the PostgreSQL connection using ODBC.
Update the necessary tables to have a manager that can access the Flask application.
Passwords should be stored as SHA-256 hashes (check out the example in password.py).
Write SQL queries for:

 - Ensure updates only modify non-empty fields.
 - Ensure deletions check for foreign key dependencies before removal.

 - Adding, updating, and deleting employees.
 - Updating salaries and technicians' expertise.
 - Managing airplane models and airplanes.
 - Managing FAA test details.
 
 - Viewing airworthiness tests recorded by technicians.

Deliverable: Submit a Python script (manager_app.py) with complete database integration.


To Run this application
``` BASH
module purge && module load python/bundle-3.10 && python3 -m venv venv && source venv/bin/activate && pip install flask pyodbc && python3 manager_app.py
```