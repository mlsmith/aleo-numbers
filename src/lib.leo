// A circuit representing a point along an elliptic curve.
circuit Point {
    x: field,
    y: field,

    // Point negation
    function ec_negate(mut self) -> Self {
        return Self { x: self.x, y: -self.y};
    }
    
    // Point addition
    function ec_add(mut self, q: Point) -> Self {
        let x_p = self.x;
        let x_q = q.x;
        let y_p = self.y;
        let y_q = q.y;
    
        let lam = (y_q - y_p) / (x_q - x_p);
        let x_r = lam * lam - x_p - x_q;
        let y_r = lam * (x_p - x_r) - y_p;

        return Self {x: x_r, y: y_r};
    }
}

// Circuit implementing the Pedersen hash function.
// Users must supply appropriate parameters to ensure that the resulting
// hash is a valid point on the desired curve.
circuit PedersenHash {
    digest: Point;
    x_parameters: [field; 256];
    y_parameters: [field; 256];

    // Instantiates a Pedersen hash circuit
    function new(digest: Point, const x_parameters: [field; 256], const y_parameters: [field; 256]) -> Self {
        return Self { digest: digest, x_parameters: x_parameters, y_parameters: y_parameters };
    }

    // Hashes a 256-bit array to a point on an elliptic curve.
    function hash(mut self, bits: [bool; 256]) -> Point {
        for i in 0..256 {
            if bits[i] {
                self.digest = self.digest.ec_add(Point { x: self.x_parameters[i], y: self.y_parameters[i] });
            }
        }
        return self.digest;
    }
}


circuit BullsAndCows {
    commitment: Point,
    guesses_left: u8,
    victory: bool,
    game_over: bool,
    num_exact_matches: u8,
    num_inexact_matches: u8,

    function valid_number(number: [u8; 4]) -> bool {
        let is_valid = true;

        // No numbers bigger than 9
        for i in 0..4 {
            if number[i] > 9 {
                is_valid = false; 
            }
        }

        // No duplicate numbers
        for i in 0..4 {
            for j in 0..4 {
                if i != j && number[i] == number[j] {
                    is_valid = false;
                }
            }
        }

        return is_valid;
    }


    function new_game(secret: [u8; 4], guesses_left: u8) -> Self {
        const digest: Point = Point { x: 0field, y: 258664426012969094010652733694893533536393512754914660539884262666720468348340822774968888139573360124440321458177field };

        const x: field = 781060772141658224290441550465044395149042435501746664987470571546413371306field;
        const y: field = 1867362672570137759132108893390349941423731440336755218616442213142473202417field;
        
        let hasher = PedersenHash::new(digest, [x; 256], [y; 256]);
        let hash: Point = hasher.hash([true; 256]);

        if BullsAndCows::valid_number(secret) == false {
            hash = Point { x: 0field, y: 0field };
        }

        return Self { 
            commitment: hash, 
            guesses_left: guesses_left, 
            victory: false,
            game_over: false,
            num_exact_matches: 0,
            num_inexact_matches: 0,
        };
    }


    function make_guess(self, secret: [u8; 4], guess: [u8; 4]) -> Self {
        let valid: bool = true;
        let game_over: bool = false;
        let num_exact_matches: u8 = 0;
        let num_inexact_matches: u8 = 0;
        let guesses_left = self.guesses_left;

        if BullsAndCows::valid_number(guess) == false {
            valid = false;
        }

        if guesses_left == 0 {
            valid = false;
        }      

        if valid == true {    
            for i in 0..4 {
                if secret[i] == guess[i] {
                    num_exact_matches += 1;
                }
            }

            for i in 0..4 {
                for j in 0..4 {
                    if secret[j] == guess[i] && i != j {
                        num_inexact_matches += 1;
                    }
                }
            }     
            guesses_left -= 1;
        }

        if guesses_left == 0 {
            game_over = true;
        }        

        let victory = num_exact_matches == 4;
        game_over = victory || game_over;
        let commitment = self.commitment;
        return Self { commitment, guesses_left, victory, game_over, num_exact_matches, num_inexact_matches };
    }
}