#!/bin/bash

echo "importing tariffplan located in /tariffplan"
cgr-loader -verbose -path=/tariffplan -datadb_host=redis-cgr

echo "done importing tariffplan located in /tariffplan"