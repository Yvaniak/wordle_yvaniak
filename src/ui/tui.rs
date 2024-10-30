use super::{traitement_wordle, ResultPartie, ResultPlacement, ResultWordle};
use super::{ChoixMenu, Ui};

use ratatui::crossterm::{
    event::{self, DisableMouseCapture, EnableMouseCapture, Event},
    execute,
    terminal::{disable_raw_mode, enable_raw_mode, EnterAlternateScreen, LeaveAlternateScreen},
};
use ratatui::text::{Text, ToText};
use ratatui::{
    backend::CrosstermBackend,
    layout::{Constraint, Direction, Flex, Layout, Position, Rect},
    style::{Style, Stylize},
    widgets::{Block, Paragraph},
    Terminal,
};

use std::rc::Rc;

use tui_big_text::{BigText, PixelSize};

use std::io::{self, Stderr};
pub struct Tui {
    terminal: Terminal<CrosstermBackend<Stderr>>,
    start_area: Rect,
    quit_area: Rect,
}

impl Ui for Tui {
    //TODO: Verify
    fn new() -> Self {
        // setup terminal
        enable_raw_mode().expect("ratatui stuff, should change the api if appears");
        let mut stderr = io::stderr(); // This is a special case. Normally using stdout is fine
        execute!(stderr, EnterAlternateScreen, EnableMouseCapture)
            .expect("ratatui stuff, should change the api if appears");
        let backend = CrosstermBackend::new(stderr);
        let terminal =
            Terminal::new(backend).expect("ratatui stuff, should change the api if appears");
        Self {
            terminal,
            start_area: Rect::new(0, 0, 0, 0),
            quit_area: Rect::new(0, 0, 0, 0),
        }
    }

    fn quit(&mut self) -> () {
        // restore terminal
        disable_raw_mode().expect("ratatui stuff, should change if appears");
        execute!(
            self.terminal.backend_mut(),
            LeaveAlternateScreen,
            DisableMouseCapture
        )
        .expect("ratatui stuff, should change if appears");
        self.terminal
            .show_cursor()
            .expect("ratatui stuff, should change if appears");
    }

    //TODO :
    fn welcoming(&self) -> () {
        // if let Event::Key(key) =
        //     event::read().expect("ratatui stuff, should change the api if appears")
        // {
        //     let _ = dbg!(key.code);
        // }
    }

    //TODO:
    fn partie(&mut self, mot: String, guess_test: Option<String>) -> ResultPartie {
        let mut guess: String = String::new();
        loop {
            let _ = self.terminal.draw(|f| {
                let layout_game = my_layout(Direction::Vertical, f.area(), 80, 20);
                let layout_buttons = my_layout(Direction::Horizontal, layout_game[1], 50, 50);
                let game_area = my_flex(3, layout_game[0]);
                let menu_area = my_flex(5, layout_buttons[0]);
                let quit_area = my_flex(5, layout_buttons[1]);

                let block = Block::bordered().style(Style::new().fg(ratatui::style::Color::Red));
                let game = Paragraph::new("T E S T").block(block).centered().bold();
                let button_menu =
                    my_paragraph(ratatui::style::Color::Blue, "\nMenu (Shift + m)".to_text());
                let button_quit =
                    my_paragraph(ratatui::style::Color::Red, "\nQuit (Shift + q)".to_text());

                f.render_widget(game, game_area);
                f.render_widget(button_menu, menu_area);
                f.render_widget(button_quit, quit_area);
                self.start_area = menu_area;
                self.quit_area = quit_area;
            });
            // todo!("see interactivity");
            if let Event::Key(key) = event::read().expect("ratatui stuff, should change if appears")
            {
                if key.kind == event::KeyEventKind::Release {
                    continue;
                }
                if key.modifiers != event::KeyModifiers::SHIFT {
                    continue;
                }
                match key.code {
                    event::KeyCode::Char('M') => {
                        return ResultPartie::Stay;
                    }
                    event::KeyCode::Char('Q') => {
                        return ResultPartie::Quit;
                    }
                    _ => {}
                }
            }
            if let Event::Mouse(click) =
                event::read().expect("ratatui stuff, should change if appears")
            {
                match click.kind {
                    event::MouseEventKind::Up(_) => {
                        let pos_mouse = Position::new(click.column, click.row);
                        if self.start_area.contains(pos_mouse) {
                            return ResultPartie::Stay;
                        } else if self.quit_area.contains(pos_mouse) {
                            return ResultPartie::Quit;
                        } else {
                            println!("Pas de choix encore");
                        }
                    }
                    _ => {}
                }
            }
        }
    }

    //TODO:
    fn menu(&mut self) -> ChoixMenu {
        loop {
            let _ = self.terminal.draw(|f| {
                let layout_menu = my_layout(Direction::Vertical, f.area(), 50, 50);
                let layout_buttons = my_layout(Direction::Horizontal, layout_menu[1], 50, 50);

                let title_area = my_flex(10, layout_menu[0]);
                let start_area = my_flex(5, layout_buttons[0]);
                let quit_area = my_flex(5, layout_buttons[1]);

                let title = BigText::builder()
                    .pixel_size(PixelSize::Full)
                    .style(Style::new().blue().bold())
                    .lines(vec!["Wordle".into()])
                    .centered()
                    .build();

                let button_start =
                    my_paragraph(ratatui::style::Color::Green, "\nStart (s)".to_text());
                let button_quit = my_paragraph(ratatui::style::Color::Red, "\nQuit (q)".to_text());

                f.render_widget(title, title_area);
                f.render_widget(button_start, start_area);
                f.render_widget(button_quit, quit_area);
                self.start_area = start_area;
                self.quit_area = quit_area;
            });
            if let Event::Key(key) = event::read().expect("ratatui stuff, should change if appears")
            {
                if key.kind == event::KeyEventKind::Release {
                    continue;
                }
                match key.code {
                    event::KeyCode::Char('q') => {
                        return ChoixMenu::Quit;
                    }
                    event::KeyCode::Char('s') => {
                        return ChoixMenu::Start;
                    }
                    _ => {}
                }
            }
            if let Event::Mouse(click) =
                event::read().expect("ratatui stuff, should change if appears")
            {
                match click.kind {
                    event::MouseEventKind::Up(_) => {
                        let pos_mouse = Position::new(click.column, click.row);
                        if self.start_area.contains(pos_mouse) {
                            return ChoixMenu::Start;
                        } else if self.quit_area.contains(pos_mouse) {
                            return ChoixMenu::Quit;
                        } else {
                            println!("Pas de choix encore");
                        }
                    }
                    _ => {}
                }
            }
        }
    }
}

fn my_layout(direction: Direction, area: Rect, first_part: u16, second_part: u16) -> Rc<[Rect]> {
    Layout::default()
        .direction(direction)
        .constraints(vec![
            Constraint::Percentage(first_part),
            Constraint::Percentage(second_part),
        ])
        .split(area)
}

fn my_flex(len: u16, area: Rect) -> Rect {
    let lay = Layout::vertical([Constraint::Length(len)])
        .flex(Flex::Center)
        .split(area);
    // .areas(area)
    lay[0]
}

fn my_paragraph<'a>(color: ratatui::style::Color, content: Text<'a>) -> Paragraph<'a> {
    let block = Block::bordered().style(Style::new().fg(color));
    Paragraph::new(content).block(block).centered().bold()
}
