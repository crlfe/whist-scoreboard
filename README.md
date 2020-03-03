# Whist Scoreboard

This repository is my first serious attempt to build a webapp in
[Elm](https://elm-lang.org/). Large chunks of the code are likely to change as
I experiment with what works best given the language and my preferences.

The application is a live scoreboard for card nights run by the seniors clubs
around my old home town. They play a variant of Whist similar to Flag Whist:

- Each team of four is assigned a numbered table.
- The team organizes into the captain, blue, red, and white.
- For each hand the scorekeeper shows the trump suit (or no-trump) and two player colors.
- The two players on each team with the indicated colors visit another table,
  while the last color and captain remain at their home table.
- All tables play a hand, then the scorekeeper changes trump and colors,
  and new visiting pairs move to the next table.
  This is much like a round-robin tournament, but see the example below.
- A hand yields 13 tricks following common Whist rules.
  One point is awarded to the team taking the majority,
  or two points if they took all 13 (which is extremely rare).
- As both home and away pairs can score points,
  a team will earn between 0 and 4 points during each hand.

The scoreboard is used to record the points scored by each team during each game,
keep running totals, and show the final ranking at the end of the night.
The webapp automates totals and ranking, and can be used with a projector or
large TV for every player to see the running totals.

## Example

```
Three teams at three tables (e.g. "4C" is table 4's captain):
Table 1: 1C 1B 1R 1W
Table 2: 2C 2B 2R 2W
Table 3: 3C 3B 3R 3W

First hand: Spades trump; Blue and White
Table 1: 1C 1R vs 3B 3W
Table 2: 2C 2R vs 1B 1W
Table 3: 3C 3R vs 2B 2W

Second hand: Hearts trump; White and Red
Table 1: 1C 1B vs 2W 2R
Table 2: 2C 2B vs 3W 3R
Table 3: 3C 3B vs 1W 1R

(skip the position where teams would play themselves)

Third hand: No trump; Red and Blue
Table 1: 1C 1W vs 3R 3B
Table 2: 2C 2W vs 1R 1B
Table 3: 3C 3W vs 2R 2B

Fourth hand: Diamonds trump; Blue and White
Table 1: 1C 1R vs 2B 2W
Table 2: 2C 2R vs 3B 3W
Table 3: 3C 3R vs 1B 1W
```

More tables will result in more games before the teams cycle,
and enough tables make it worth playing only part of the round-robin.
A typical event might have 25 teams, but only play 18 games before wrapping up the night.

## Building

For the moment, please use the pre-compiled version at https://crlfe.github.io/whist-scoreboard/

```
# Brief instructions:
yarn install
yarn build    # build webapp in dist/web
yarn package  # build Windows executable
```

## License and Warranty Disclaimer

```
Copyright (c) 2019 Chris Wolfe (https://crlfe.ca)

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice,
   this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its
   contributors may be used to endorse or promote products derived from this
   software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.
```
