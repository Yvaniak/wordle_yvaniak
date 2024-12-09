use clap::{crate_description, crate_name, crate_version, Command};

#[derive(Debug, PartialEq)]
pub enum ConfigUi {
    Cli,
    Tui,
    Gui,
}

#[derive(Debug, PartialEq)]
pub struct Config {
    pub ui: ConfigUi,
}

impl Config {
    pub fn build(mut args: impl Iterator<Item = String>) -> Result<Config, &'static str> {
        args.next();

        let lanceur = match args.next() {
            Some(arg) if arg == "cli" => ConfigUi::Cli,
            Some(arg) if arg == "tui" => ConfigUi::Tui,
            Some(arg) if arg == "gui" => ConfigUi::Gui,
            Some(_) => return Err("doesn't know this interface, the choices are gui, tui and cli"),
            None => ConfigUi::Cli,
        };

        Ok(Config { ui: lanceur })
    }

    pub fn cmd() -> Result<Config, &'static str> {
        let matches = Command::new(crate_name!())
            .about(crate_description!())
            .version(crate_version!())
            .subcommand(Command::new("cli").about("launch the wordle in the cli mode"))
            .subcommand(Command::new("tui").about("launch the wordle in the tui mode"))
            .subcommand(Command::new("gui").about("launch the wordle in the gui mode"))
            .get_matches();

        let lanceur = match matches.subcommand() {
            Some(("cli", _)) => ConfigUi::Cli,
            Some(("tui", _)) => ConfigUi::Tui,
            Some(("gui", _)) => ConfigUi::Gui,
            None => ConfigUi::Cli,
            Some((&_, _)) => {
                return Err("doesn't know this interface, the choices are gui, tui and cli")
            }
        };

        Ok(Config { ui: lanceur })
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn build_config_cli() {
        let args = ["", "cli"].iter().map(ToString::to_string);
        let config = Config::build(args);
        assert_eq!(config.unwrap(), Config { ui: ConfigUi::Cli });
    }

    #[test]
    fn build_config_tui() {
        let args = ["", "tui"].iter().map(|s| String::from(*s));
        let config = Config::build(args);
        assert_eq!(config.unwrap(), Config { ui: ConfigUi::Tui });
    }

    #[test]
    fn build_config_gui() {
        let args = ["", "gui"].iter().map(|s| String::from(*s));
        let config = Config::build(args);
        assert_eq!(config.unwrap(), Config { ui: ConfigUi::Gui });
    }

    #[test]
    fn build_config_vide() {
        let args = [""].iter().map(|s| String::from(*s));
        let config = Config::build(args);
        assert_eq!(config.unwrap(), Config { ui: ConfigUi::Cli });
    }

    #[test]
    fn build_config_unknown() {
        let args = ["", "unknown"].iter().map(|s| String::from(*s));
        let config = Config::build(args);
        assert!(config.is_err_and(|e| {
            e == "doesn't know this interface, the choices are gui, tui and cli"
        }),);
    }
}
