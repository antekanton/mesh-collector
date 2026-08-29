#!/bin/bash
cron -f &
exec perl ./main.pl