use std::error::Error;

mod gen_words;
mod ui;
use crate::ui::cli::Cli;
use crate::ui::ChoixMenu;
use crate::ui::Ui;

pub enum TypeUi {
    Cli,
    Tui,
    Gui,
}

pub struct Config {
    pub ui: TypeUi,
}

impl Config {
    pub fn build(mut args: impl Iterator<Item = String>) -> Result<Config, &'static str> {
        args.next();

        let lanceur = match args.next() {
            Some(arg) if arg == "cli" => TypeUi::Cli,
            Some(arg) if arg == "tui" => TypeUi::Tui,
            Some(arg) if arg == "gui" => TypeUi::Gui,
            Some(_) => return Err("doesn't know this interface, the choices are gui, tui and cli"),
            None => TypeUi::Cli,
        };

        Ok(Config { ui: lanceur })
    }
}

pub fn run(config: Config) -> Result<(), Box<dyn Error>> {
    let ui_instance = match config.ui {
        TypeUi::Cli => Cli::new(),
        _ => return Err("tui and gui not implemented yet".into()),
    };

    ui_instance.welcoming();
    loop {
        match ui_instance.menu() {
            ChoixMenu::Quit => return Ok(()),
            ChoixMenu::Start => ui_instance.partie(gen_words::pick_the_word()),
        }
    }
}
