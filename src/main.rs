use std::process;
use wordle_yvaniak::config::Config;

fn main() {
    let config: Config = Config::cmd().unwrap_or_else(|err| {
        eprintln!("Problem parsing arguments: {err}");
        process::exit(1);
    });
    if let Err(e) = wordle_yvaniak::launch(config) {
        eprintln!("Application error: {e}");
        process::exit(1);
    }
}
#[cfg(test)]
mod test {

    //    #[test]
    //    fn cmd_config_cli() {
    //        let cmd = Command::cargo_bin(env!("CARGO_PKG_NAME"))
    //            .unwrap()
    //            .arg("cli")
    //            .write_stdin("q")
    //            .assert();
    //        cmd.success()
    //            .stdout("Welcome in the menu of this worlde game !\nexitting\n");
    //    }

    //    //TODO: tester avec tui

    //    #[test]
    //    fn cmd_config_gui() {
    //        let cmd = Command::cargo_bin(env!("CARGO_PKG_NAME"))
    //            .unwrap()
    //            .arg("gui")
    //            .assert();
    //        cmd.failure().code(1);
    //    }

    //    #[test]
    //    fn cmd_config_unknown() {
    //        let cmd = Command::cargo_bin(env!("CARGO_PKG_NAME"))
    //            .unwrap()
    //            .arg("unknown")
    //            .assert();
    //        // assert_eq!("", cmd.failure().code(2).get_output());
    //        cmd.failure().code(2);
    //    }
}
