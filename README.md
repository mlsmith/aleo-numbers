# numbers

This is an implementation of the Bulls and Cows game in Aleo.

The game is played by first establishing a secret number, in this case a four digit number.  Another player then tries to guess what that number is.  When an opponent makes a guess we will only supply them with two clues:

1. The number of exact matches that their guess has; The right number in the right place
2. The number of inexact matches that their guess has; The right number in the wrong place

There are also some constraints in the game:
1. There can be no duplicate numbers in the secret number, nor the guess.  Therefore the secret number can't be 1180 for instance.
2. There are a limited amount of guesses that the guessing player can make.  This is configurable via the input `guesses_left`.

Please see the wikipedia article for more details:
https://en.wikipedia.org/wiki/Bulls_and_Cows


## Inputs
This implementation has 10 inputs.

We need to define a unique point on the elliptic curve to associate with a particular game.  This is to ensure that we don't change the number in the middle of the match.  The commitment variables are `0` until they are initialized when creating a new game.  Then they are associated with all future game states.

1. `commitment_x`
2. `commitment_y`

We also need to define the inputs that keep track of the game state.  This state should be made available to the guessing player.

1. `guesses_left`
2. `victory`
3. `game_over`
4. `num_exact_matches`
5. `num_inexact_matches`

We need variables for initializing the game state:
1. `create_game`
2. `secret`

And finally we need the guessing player's input in the form of a `guess`.

The `game_over` flag is true when either the guessing player has used all of their `guesses_left` or they have achieved `victory` by guessing the `secret` correctly (by having `num_exact_matches == 4`).  Once the game is over the state cannot be altered for the game associate with that particular `commitment_x` and `commitment_y`.

## Build Guide

To compile this Leo program, run:
```bash
leo build
```

To test this Leo program, run:
```bash
leo test
```

## Development

To output the number of constraints, run:
```bash
leo build -d
```
