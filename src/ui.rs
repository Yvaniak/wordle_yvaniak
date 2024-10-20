pub mod cli;

pub enum ChoixMenu {
    Start,
    Quit,
}

pub trait Ui {
    fn new() -> Self;

    fn welcoming(&self) -> ();

    fn menu(&self) -> ChoixMenu;

    fn partie(&self, mot: String) -> ();
}
