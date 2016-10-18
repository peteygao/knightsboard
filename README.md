# Knight's Board Parallel Solver

## Description

This is a parallel solver (breadth-first search) for the Knight's Board problem, with a total of 5 levels.

All solutions with the exception of Level 1 is non-deterministic. Which means that the path returned may be different every time the application is invoked, but the path will always satisfy the constraint (e.g. shortest, longest, or any valid path). The reason for this behaviour is because the solver runs in parallel, the first solution that satisfies the constraint will be returned, and there's no guarantee the same path will be found first every run.

## Compiling

Make sure Elixir & Erlang is installed.

Clone this repo:

`git clone https://github.com/peteygao/knightsboard.git`

Compile the executable:
```
cd knightsboard
mix escript.build
```

The build should succeed and drop a `knights_board` executable in the same directory.

Run it via `./knights_board` and pass in the desired parameters

Some example invocations:
```
./knights_board -l 1 -m 3,2:4,4:5,6
./knights_board -l 4 -m 3,2:5:3
```

## User guide

```
--level -l  Level of the Knight's Board to solve for:
             Level 1:
              Test if all the --moves parameter are a valid string of Knight moves
             Level 2:
              Returns any path from start to end coordinates (if possible). Highly likely be the shortest by virtue of the fact that shortest paths computes the fastest
             Level 3:
              Returns a shortest path from start to end (if possible)
             Level 4:
              Returns a shortest path from start to end on a special 32x32 (see --board)
             Level 5:
              Returns the longest path from start to end on the level 4 board

--moves -m  Move set of the knight (level 1 has special rules, see below)
            To specify start/end grids, use the format:
              3,2:4,4
            Where 3,2 is the coordinate representing the start grid and 4,4 is the grid representing the end grid

            Board dimensions for levels 1 - 3 are 8x8. Levels 4 and 5 are 32x32 (see --board)

            Special Rules for Level 1:
            A chain of moves can be given in the same format, with each move being colon delimited:
              3,2:4,4:5,6

--board -b  Shows the 32x32 board used for level 4 and 5

--help -h   This help message
```

### Special board for level 4 and 5
```
1) W[ater] squares count as two moves when a piece lands there
2) R[ock] squares cannot be used
3) B[arrier] squares cannot be used AND cannot lie in the path
4) T[eleport] squares instantly move you from one T to the other in the same move
5) L[ava] squares count as five moves when a piece lands there

. . . . . . . . B . . . L L L . . . . . . . . . . . . . . . . .
. . . . . . . . B . . . L L L . . . . . . . . . . . . . . . . .
. . . . . . . . B . . . L L L . . . L L L . . . . . . . . . . .
. . . . . . . . B . . . L L L . . L L L . . . R R . . . . . . .
. . . . . . . . B . . . L L L L L L L L . . . R R . . . . . . .
. . . . . . . . B . . . L L L L L L . . . . . . . . . . . . . .
. . . . . . . . B . . . . . . . . . . . . R R . . . . . . . . .
. . . . . . . . B B . . . . . . . . . . . R R . . . . . . . . .
. . . . . . . . W B B . . . . . . . . . . . . . . . . . . . . .
. . . R R . . . W W B B B B B B B B B B . . . . . . . . . . . .
. . . R R . . . W W . . . . . . . . . B . . . . . . . . . . . .
. . . . . . . . W W . . . . . . . . . B . . . . . . T . . . . .
. . . W W W W W W W . . . . . . . . . B . . . . . . . . . . . .
. . . W W W W W W W . . . . . . . . . B . . R R . . . . . . . .
. . . W W . . . . . . . . . . B B B B B . . R R . W W W W W W W
. . . W W . . . . . . . . . . B . . . . . . . . . W . . . . . .
W W W W . . . . . . . . . . . B . . . W W W W W W W . . . . . .
. . . W W W W W W W . . . . . B . . . . . . . . . . . . B B B B
. . . W W W W W W W . . . . . B B B . . . . . . . . . . B . . .
. . . W W W W W W W . . . . . . . B W W W W W W B B B B B . . .
. . . W W W W W W W . . . . . . . B W W W W W W B . . . . . . .
. . . . . . . . . . . B B B . . . . . . . . . . B B . . . . . .
. . . . . R R . . . . B . . . . . . . . . . . . . B . . . . . .
. . . . . R R . . . . B . . . . . . . . . . . . . B . T . . . .
. . . . . . . . . . . B . . . . . R R . . . . . . B . . . . . .
. . . . . . . . . . . B . . . . . R R . . . . . . . . . . . . .
. . . . . . . . . . . B . . . . . . . . . . R R . . . . . . . .
. . . . . . . . . . . B . . . . . . . . . . R R . . . . . . . .
```
