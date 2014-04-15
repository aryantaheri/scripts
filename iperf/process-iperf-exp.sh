#!/bin/bash

reports=$1

./process-iperf-tcp-exp.sh $reports
./process-iperf-udp-exp.sh $reports
./process-distribution.sh $reports
./process-percompute-iperf-tcp-exp.sh $reports
./process-percompute-iperf-udp-exp.sh $reports

