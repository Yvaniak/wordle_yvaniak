extern crate assert_cli;

mod integration {

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
