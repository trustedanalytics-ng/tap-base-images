#!/bin/bash
while [ 1 ] ; do /usr/local/bin/curator --config /curator.yml /delete_indices.yml ; sleep 86400 ; done 
