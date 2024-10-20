use super::{ChoixMenu, Ui};
pub struct Cli {}

impl Ui for Cli {
    fn new() -> Self {
        Self {}
    }

    fn welcoming(&self) -> () {
        println!("Welcome in the menu of this worlde game !");
    }

    fn menu(&self) -> ChoixMenu {
        let mut choix: String = "".to_string();

        loop {
            match std::io::stdin().read_line(&mut choix) {
                Ok(_str) if choix.trim() == "s" || choix.trim() == "start" => {
                    return ChoixMenu::Start;
                }
                Ok(_str)
                    if choix.trim() == "quit"
                        || choix.trim() == "q"
                        || choix.trim() == "exit"
                        || choix.trim() == "e" =>
                {
                    println!("exitting");
                    return ChoixMenu::Quit;
                }
                Ok(_str) => {
                    println!("didn't understood that, can you repeat ?");
                    continue;
                }
                Err(_e) => continue,
            }
        }
    }

    fn partie(&self, mot: String) -> () {}
}
