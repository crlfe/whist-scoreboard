# Whist Scoreboard

This repository is my first serious attempt to build a webapp in
[Elm](https://elm-lang.org/). Large chunks of the code are likely to change as
I experiment with what works best given the language and my preferences.

The application is a live scoreboard for card nights run by the seniors clubs
around my old home town. They play a variant of Whist similar to Flag Whist:

* Teams of four are assigned a table and divided into a home pair and an away pair.
* The home pair stay at their table, playing against away pairs from other tables.
* The away pair goes to other tables, playing against the respective home pairs.
* All tables play a hand, and then each visiting pair moves to the next table
  (much like a round-robin tournament).
* A hand yields 13 tricks, with one point awarded to the team taking the majority
  (or two points if they took all 13, which is extremely rare).
* As both home and away pairs can score points, a team can earn between 0 and 4 points during each hand.

The scoreboard is used to record the points scored by each team during each game,
keep running totals, and show the final ranking at the end of the night.
The webapp automates totals and ranking, and can be used with a projector or
large TV for every player to see the running totals.

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
