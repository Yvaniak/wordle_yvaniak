use inquire::{InquireError, Select, Text};

use super::{traitement_wordle, ResultPartie, ResultPlacement, ResultWordle};
use super::{ChoixMenu, Ui};
// use std::io;
pub struct Cli {}

fn get_guess(guess: &str, taille: usize) -> String {
    loop {
        if !guess.is_empty() {
            let guess_inquire = Text::new(
                format!("What is your guess for the word of {} letters ?", taille).as_str(),
            )
            .with_validator(move |g: &str| {
                if g.chars().count() != taille {
                    Ok(inquire::validator::Validation::Invalid(
                        format!(
                            "You entered a word that was of size {} but the word is of size {}",
                            g.chars().count(),
                            taille
                        )
                        .into(),
                    ))
                } else {
                    Ok(inquire::validator::Validation::Valid)
                }
            })
            .prompt();
            match guess_inquire {
                Ok(guess) => return guess,
                Err(_) => {
                    println!(
                        "An error happened during the processing of your guess, please try again"
                    );
                    continue;
                }
            }
        };
        return guess.to_owned();
    }
}

impl Ui for Cli {
    fn new() -> Self {
        Self {}
    }

    fn quit(&mut self) {}

    fn welcoming(&self) {
        println!("Welcome in the menu of this wordle game !");
    }

    fn menu(&mut self) -> ChoixMenu {
        let _choix: String = String::new();

        loop {
            let options: Vec<&str> = vec!["Start a game", "Quit the game"];
            let ans: Result<&str, InquireError> =
                Select::new("What do you want to do ?", options).prompt();
            match ans {
                Ok(choice) => match choice {
                    "Start a game" => return ChoixMenu::Start,
                    "Quit the game" => {
                        println!("Quitting");
                        return ChoixMenu::Quit;
                    }
                    _ => println!("There was an error, please try again"),
                },
                Err(_) => println!("There was an error, please try again"),
            }
        }
        // loop {
        //     match std::io::stdin().read_line(&mut choix) {
        //         Ok(_str) if choix.trim() == "s" || choix.trim() == "start" => {
        //             return ChoixMenu::Start;
        //         }
        //         Ok(_str)
        //             if choix.trim() == "quit"
        //                 || choix.trim() == "q"
        //                 || choix.trim() == "exit"
        //                 || choix.trim() == "e" =>
        //         {
        //             println!("exitting");
        //             return ChoixMenu::Quit;
        //         }
        //         Ok(_str) => {
        //             println!("didn't understood that, can you repeat ?");
        //             choix = String::new();
        //             continue;
        //         }
        //         Err(_e) => continue,
        //     }
        // }
    }

    fn partie(&mut self, mot: String, guess: String) -> ResultPartie {
        println!(
            "The wordle game begin ! The word has {} letters",
            mot.chars().count()
        );

        println!("You can go to the menu by inputting : menu and quit by inputting : quit");

        loop {
            println!("\nPlease input your guess.");

            let guess = get_guess(&guess, mot.chars().count());

            // let mut guess: String = String::new();

            //allow the test of partie
            // match &guess_test {
            //     Some(value_test) => guess = String::from(value_test),
            //     None => {
            //         match io::stdin().read_line(&mut guess) {
            //             Err(_) => {
            //                 println!("\nerreur lors de la lecture");
            //                 continue;
            //             }
            //             Ok(str) => str,
            //         };
            //     }
            // }

            let guess = guess.trim();

            if guess == "quit" || guess == "exit" {
                println!("\n{}ting", guess);
                return ResultPartie::Quit;
            }

            if guess == "menu" {
                println!("\ngoing to menu");
                return ResultPartie::Stay;
            }

            let guess = String::from(guess);

            match traitement_wordle(&mot, guess) {
                Ok(ResultWordle::Win) => {
                    println!("You win !");
                    return ResultPartie::Stay;
                }
                Ok(ResultWordle::UnmatchedLens(len_mot, len_guess)) => {
                    println!("You guessed a word of {len_guess} letters but the word to guess contains {len_mot} letters.");
                }
                Ok(ResultWordle::Placement(placement)) => {
                    for (cpt, i) in placement.result.into_iter().enumerate() {
                        match i {
                            ResultPlacement::Misplaced(l) => {
                                println!("\nThe letter {l} in position {cpt} is misplaced");
                            }
                            ResultPlacement::Bad(l) => {
                                println!("\nThe letter {l} in position {cpt} is not good");
                            }
                            ResultPlacement::Good(_l) => {}
                        }
                    }
                }
                Err(_e) => continue,
            }
        }
    }
}
