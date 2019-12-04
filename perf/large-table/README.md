# Table Performance Tests

The initial whist-scoreboard implementation used an HTML table with separate
buttons for each cell. At the design maximum of a 100x100 board, this resulted
in noticable delays for update or layout (e.g. 350ms from click to paint done).
This directory contains a set of standalone pages being used to compare the
performance of different structures.
