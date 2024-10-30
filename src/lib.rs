use std::error::Error;

pub mod config;
mod gen_words;
mod ui;
use crate::ui::{cli::Cli, tui::Tui, ChoixMenu, ResultPartie, Ui};
use config::{Config, ConfigUi};
use ui::UiEnum;

pub enum Instance {
    Cli,
    Tui,
}

pub struct App {
    instance: UiEnum,
}

impl App {
    pub fn run(&mut self) -> Result<(), Box<dyn Error>> {
        self.instance.welcoming();
        loop {
            let partie_result = match self.instance.menu() {
                ChoixMenu::Quit => {
                    self.instance.quit();
                    return Ok(());
                }
                ChoixMenu::Start => self.instance.partie(gen_words::pick_the_word(), None),
            };

            match partie_result {
                ResultPartie::Quit => {
                    self.instance.quit();
                    return Ok(());
                }
                ResultPartie::Stay => self.instance.welcoming(),
            }
        }
    }
    pub fn build(config: Config) -> Result<App, Box<dyn Error>> {
        match config.ui {
            ConfigUi::Cli => {
                return Ok(App {
                    instance: UiEnum::ItemCli(Cli::new()),
                });
            }
            ConfigUi::Tui => {
                return Ok(App {
                    instance: UiEnum::ItemTui(Tui::new()),
                })
            }
            _ => return Err("tui and gui not implemented yet".into()),
        }
    }
}

pub fn launch(config: config::Config) -> Result<(), Box<dyn Error>> {
    let mut app = match App::build(config) {
        Err(e) => return Err(e),
        Ok(app) => app,
    };

    return app.run();
}
