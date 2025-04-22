#!/bin/bash

createdb -U postgres airport

psql -U postgres -d airport -f create_database.sql