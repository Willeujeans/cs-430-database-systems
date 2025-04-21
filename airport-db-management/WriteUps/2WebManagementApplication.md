# Web Management Application
`manager_app.py`
You will complete the missing ODBC/PostgreSQL integration in a Python Flask application.

Tasks:
Implement the PostgreSQL connection using ODBC.
Update the necessary tables to have a manager that can access the Flask application.
Passwords should be stored as SHA-256 hashes (check out the example in password.py).
Write SQL queries for:
 - Adding, updating, and deleting employees.
 - Updating salaries and technicians' expertise.
 - Managing airplane models and airplanes.
 - Managing FAA test details.
 - Viewing airworthiness tests recorded by technicians.
 - Ensure updates only modify non-empty fields.
 - Ensure deletions check for foreign key dependencies before removal.

Deliverable: Submit a Python script (manager_app.py) with complete database integration.