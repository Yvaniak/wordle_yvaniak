extern crate assert_cli;

mod integration {
    use assert_cli;

    #[test]
    fn cli() {
        assert_cli::Assert::main_binary()
            .with_args(&["cli"])
            .stdin("q")
            .succeeds()
            .and()
            .stdout()
            .contains(
                "Welcome in the menu of this wordle game !
exitting",
            )
            .unwrap();
    }

    #[test]
    fn tui() {
        assert_cli::Assert::main_binary()
            .with_args(&["tui", "quitting_test"])
            .fails()
            .and()
            .stderr()
            .contains("test")
            .unwrap();
    }

    #[test]
    fn gui() {
        assert_cli::Assert::main_binary()
            .with_args(&["gui"])
            .fails()
            .and()
            .stderr()
            .contains("Application error: tui and gui not implemented yet")
            .unwrap();
    }
}
