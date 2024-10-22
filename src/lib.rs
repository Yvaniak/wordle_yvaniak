use std::error::Error;

pub mod config;
mod gen_words;
mod ui;
use crate::ui::{cli::Cli, ChoixMenu, ResultPartie, Ui};
#[derive(Debug, PartialEq)]
pub enum TypeUi {
    Cli,
    Tui,
    Gui,
}

pub fn run(config: config::Config) -> Result<(), Box<dyn Error>> {
    let ui_instance = match config.ui {
        TypeUi::Cli => Cli::new(),
        _ => return Err("tui and gui not implemented yet".into()),
    };

    ui_instance.welcoming();
    loop {
        let partie_result = match ui_instance.menu() {
            ChoixMenu::Quit => return Ok(()),
            ChoixMenu::Start => ui_instance.partie(gen_words::pick_the_word()),
        };

        match partie_result {
            ResultPartie::Quit => return Ok(()),
            ResultPartie::Stay => ui_instance.welcoming(),
        }
    }
}
