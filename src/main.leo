import lib.(
    BullsAndCows,
    Point,
);

function main(
    create_game: bool,
    secret: [u8; 4],
    commitment_x: field, 
    commitment_y: field,
    guesses_left: u8,
    victory: bool,
    game_over: bool,
    num_exact_matches: u8,
    num_inexact_matches: u8,
    guess: [u8; 4],
) -> (field, field, u8, u8, u8, bool, bool) {
    let commitment = Point {x: commitment_x, y: commitment_y };

    console.log("Starting Bulls and Cows solver...");
    console.log("secret number: {}", secret);

    let game = BullsAndCows { commitment, guesses_left, victory, game_over, num_exact_matches, num_inexact_matches };

    if create_game {
        game = BullsAndCows::new_game( secret, guesses_left );
    } else if game_over == false {
        console.log("Checking guess...");
        console.log("guess: {}", guess);
        game = game.make_guess( secret, guess );
        console.log("Number of exact matches: {}", game.num_exact_matches);
        console.log("Number of inexact matches: {}", game.num_inexact_matches);
    }

    return (
        game.commitment.x,
        game.commitment.y,
        game.num_exact_matches,
        game.num_inexact_matches,
        game.guesses_left,
        game.victory,
        game.game_over,
    );
}


@test
function test_match() {
    let commitment_x: field = 0field;
    let commitment_y: field = 0field;
    let create_game: bool = true;
    let secret: [u8; 4] = [1, 9, 5, 2];
    let guess: [u8; 4] = [1, 9, 5, 2];

    let (c_x, c_y, default_xact, default_inxact, default_guesses_left, default_victory, default_game_over) = 
        main(create_game, secret, commitment_x, commitment_y, 10, false, false, 0, 0, guess);

    let (c_x1, c_y1, xact, inxact, guesses_left, victory, game_over) = 
        main(false, secret, c_x, c_y, default_guesses_left, default_victory, default_game_over, 0, 0, guess);

    console.assert(c_x == c_x1);
    console.assert(c_y == c_y1);
    console.assert(game_over == true);
    console.assert(victory == true);
    console.assert(xact == 4);
    console.assert(inxact == 0);
    console.assert(guesses_left == 9);
}

@test
function test_close_match() {
    let commitment_x: field = 0field;
    let commitment_y: field = 0field;
    let create_game: bool = true;
    let secret: [u8; 4] = [1, 9, 5, 2];
    let guess: [u8; 4] = [1, 9, 5, 3];

    let (c_x, c_y, default_xact, default_inxact, default_guesses_left, default_victory, default_game_over) = 
        main(create_game, secret, commitment_x, commitment_y, 10, false, false, 0, 0, guess);

    let (c_x1, c_y1, xact, inxact, guesses_left, victory, game_over) = 
        main(false, secret, c_x, c_y, default_guesses_left, default_victory, default_game_over, 0, 0, guess);

    console.assert(c_x == c_x1);
    console.assert(c_y == c_y1);    
    console.assert(game_over == false);
    console.assert(victory == false);
    console.assert(xact == 3);
    console.assert(inxact == 0);
    console.assert(guesses_left == 9);
}


@test
function test_secret_has_duplicate_digits() {
    let commitment_x: field = 0field;
    let commitment_y: field = 0field;
    let create_game: bool = true;
    let secret: [u8; 4] = [1, 9, 5, 1];
    let guess: [u8; 4] = [1, 9, 5, 3];

    let (c_x, c_y, xact, inxact, guesses_left, victory, game_over) = 
        main(create_game, secret, commitment_x, commitment_y, 10, false, false, 0, 0, guess);

    console.assert(c_x == 0field);
    console.assert(c_y == 0field);
    console.assert(xact == 0);
    console.assert(inxact == 0);
    console.assert(guesses_left == 10);
    console.assert(game_over == false);
    console.assert(victory == false);
}


@test
function test_secret_has_digit_greater_than_nine() {
    let commitment_x: field = 0field;
    let commitment_y: field = 0field;
    let create_game: bool = true;
    let secret: [u8; 4] = [1, 9, 5, 10];
    let guess: [u8; 4] = [1, 9, 5, 3];

    let (c_x, c_y, xact, inxact, guesses_left, victory, game_over) = 
        main(create_game, secret, commitment_x, commitment_y, 10, false, false, 0, 0, guess);

    console.assert(c_x == 0field);
    console.assert(c_y == 0field);
    console.assert(xact == 0);
    console.assert(inxact == 0);
    console.assert(guesses_left == 10);
    console.assert(game_over == false);
    console.assert(victory == false);
}


@test
function test_used_all_guesses() {
    let commitment_x: field = 0field;
    let commitment_y: field = 0field;
    let guesses_left: u8 = 2;    
    let create_game: bool = true;
    let secret: [u8; 4] = [1, 9, 5, 2];
    let guess: [u8; 4] = [1, 9, 5, 3];

    let (c_x, c_y, default_xact, default_inxact, default_guesses_left, default_victory, default_game_over) = 
        main(create_game, secret, commitment_x, commitment_y, guesses_left, false, false, 0, 0, guess);

    let (c_x1, c_y1, xact, inxact, guesses, victory, game_over) = 
        main(false, secret, c_x, c_y, default_guesses_left, default_victory, default_game_over, 0, 0, guess);
    
    guess = [1, 2, 3, 4];

    let (c_x2, c_y2, xact1, inxact1, guesses1, victory1, game_over1) = 
        main(false, secret, c_x1, c_y1, guesses, victory, game_over, xact, inxact, guess);

    console.log("guesses left: {}", default_guesses_left);
    
    console.assert(c_x == c_x2);
    console.assert(c_y == c_y2);    
    console.assert(xact1 == 1);
    console.assert(inxact1 == 1);
    console.assert(guesses1 == 0);
    console.assert(game_over1 == true);
    console.assert(victory1 == false);
}

