//TODO: validate graphically at enter
use super::{traitement_wordle, ResultPartie, ResultPlacement, ResultWordle};
use super::{ChoixMenu, Ui};
pub struct Cli {}

fn get_guess(_guess: &str, taille: usize) -> String {
    let res = cliclack::input(format!(
        "What is your guess for the word of {} letters",
        taille
    ))
    .placeholder(&"*".repeat(taille))
    .validate_interactively(move |input: &String| {
        if input.is_empty() {
            Err("Please enter an answer.")
        } else if input.chars().count() < taille && input != "e" && input != "m" {
            Err("Too short")
        } else if input.chars().count() > taille && input != "e" && input != "m" {
            Err("Too long")
        } else {
            Ok(())
        }
    })
    .interact();

    match res {
        Ok(guess) => guess,
        Err(e) => {
            eprint!("the error {} happened, try again", e);
            String::from("error, restart")
        }
    }
}

impl Ui for Cli {
    fn new() -> Self {
        Self {}
    }

    fn quit(&mut self) {}

    fn welcoming(&self) {
        match cliclack::intro("Welcome in the menu of this wordle game !") {
            Ok(_) => {}
            Err(e) => eprintln!(
                "An error happened during the print of the intro message : {}",
                e
            ),
        }
    }

    fn menu(&mut self) -> ChoixMenu {
        let _choix: String = String::new();

        loop {
            let ans = cliclack::select("What do you want to do ?")
                .initial_value("Start a game")
                .item("start", "Start a game", "")
                .item("quit", "Quit the game", "")
                .interact();

            match ans {
                Ok(choice) => match choice {
                    "start" => return ChoixMenu::Start,
                    "quit" => {
                        match cliclack::outro("Exiting") {
                            Ok(_) => {}
                            Err(e) => eprintln!(
                                "An error happened during the print of the outro message : {}",
                                e
                            ),
                        }
                        return ChoixMenu::Quit;
                    }
                    _ => println!("There was an error, please try again"),
                },
                Err(_) => println!("There was an error, please try again"),
            }
        }
    }

    fn partie(&mut self, mot: String, guess: String) -> ResultPartie {
        let _ = cliclack::log::info(format!(
            "The wordle game begin ! The word has {} letters",
            mot.chars().count()
        ));

        match cliclack::log::info(
            "You can go to the menu by inputting : m and exit by inputting : e",
        ) {
            Ok(_) => {}
            Err(e) => eprintln!(
                "An error happened during the print of the info of menu and quit : {}",
                e
            ),
        }

        loop {
            let guess = get_guess(&guess, mot.chars().count());

            let guess = guess.trim();

            if guess == "e" {
                match cliclack::outro("Exiting") {
                    Ok(_) => {}
                    Err(e) => eprintln!(
                        "An error happened during the print of the outro message : {}",
                        e
                    ),
                }
                return ResultPartie::Quit;
            }

            if guess == "m" {
                match cliclack::log::info("\nGoing to menu") {
                    Ok(_) => {}
                    Err(e) => eprintln!(
                        "An error happened during the print of the going to menu message : {}",
                        e
                    ),
                }
                return ResultPartie::Stay;
            }

            let guess = String::from(guess);

            match traitement_wordle(&mot, guess) {
                Ok(ResultWordle::Win) => {
                    match cliclack::log::success("You win !") {
                        Ok(_) => {}
                        Err(e) => eprintln!(
                            "Error happenned during the print of the win message : {}",
                            e
                        ),
                    }
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
