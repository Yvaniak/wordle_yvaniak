use std::env;
use std::process;

use wordle_yvaniak::Config;

fn main() {
    let config: Config = Config::build(env::args()).unwrap_or_else(|err| {
        eprintln!("Problem parsing arguments: {err}");
        process::exit(1);
    });
    if let Err(e) = wordle_yvaniak::run(config) {
        eprintln!("Application error: {e}");
        process::exit(1);
    }
}
