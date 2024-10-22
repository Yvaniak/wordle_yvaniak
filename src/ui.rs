use std::error::Error;
use unicode_segmentation::UnicodeSegmentation;
pub mod cli;

pub enum ChoixMenu {
    Start,
    Quit,
}

pub trait Ui {
    fn new() -> Self;

    fn welcoming(&self) -> ();

    fn menu(&self) -> ChoixMenu;

    fn partie(&self, mot: String) -> ResultPartie;
}

#[derive(Debug, PartialEq)]
pub enum ResultPlacement {
    Good(char),
    Misplaced(char),
    Bad(char),
}

#[derive(Debug, PartialEq)]
pub enum ResultWordle {
    Win,
    UnmatchedLens(usize, usize),
    Placement(Placement),
}

pub enum ResultPartie {
    Quit,
    Stay,
}

pub fn traitement_wordle(ref_mot: &String, guess: String) -> Result<ResultWordle, Box<dyn Error>> {
    if guess == *ref_mot {
        return Ok(ResultWordle::Win);
    }

    let len_guess = guess.graphemes(true).count();
    let len_mot = (*ref_mot).graphemes(true).count();
    if len_guess != len_mot {
        //FIX: affichage marche pas bien
        //FIX: la condition marche pas avec les accents
        return Ok(ResultWordle::UnmatchedLens(len_mot, len_guess));
    }

    assert!(len_guess == len_mot);

    return Placement::build(ref_mot, guess);
}

#[derive(Debug, PartialEq)]
pub struct Placement {
    result: Vec<ResultPlacement>,
}

impl Placement {
    fn build(ref_mot: &String, guess: String) -> Result<ResultWordle, Box<dyn Error>> {
        let mut result: Vec<ResultPlacement> = Vec::new();
        let chars_mot = (*ref_mot).chars();

        for (i_l, l) in guess.chars().enumerate() {
            if !(*ref_mot).contains(l) {
                result.push(ResultPlacement::Bad(l));
            } else {
                if chars_mot.clone().nth(i_l).unwrap() == l {
                    result.push(ResultPlacement::Good(l));
                } else {
                    let match_mot: Vec<(usize, &str)> = (*ref_mot).match_indices(l).collect();
                    let match_guess: Vec<(usize, &str)> = guess.match_indices(l).collect();

                    let mut match_mot_i = Vec::new();
                    let mut match_guess_i = Vec::new();

                    for (i, _e) in match_mot {
                        match_mot_i.push(i);
                    }
                    for (i, _e) in match_guess {
                        match_guess_i.push(i);
                    }
                    for i in &match_mot_i {
                        println!("he1 : {}", i);
                    }
                    for i in &match_guess_i {
                        println!("he2 : {}", i);
                    }

                    match_mot_i.retain(|i| match_guess_i.contains(i));
                    match_guess_i.retain(|i| match_mot_i.contains(i));
                    for i in &match_mot_i {
                        println!("hey1 : {}", i);
                    }
                    for i in &match_guess_i {
                        println!("hey2 : {}", i);
                    }
                    if match_guess_i.len() == match_mot_i.len() {
                        println!("cas 1");
                        result.push(ResultPlacement::Bad(l))
                    } else {
                        println!("cas 2");
                        result.push(ResultPlacement::Misplaced(l));
                    }
                }
            }
        }

        Ok(ResultWordle::Placement(Placement { result }))
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn placement_brass_sands() {
        let res = Placement::build(&"brass".to_string(), "sands".to_string());
        match res.unwrap() {
            ResultWordle::Placement(p) => {
                assert_eq!(
                    p.result,
                    vec![
                        ResultPlacement::Misplaced('s'),
                        ResultPlacement::Misplaced('a'),
                        ResultPlacement::Bad('n'),
                        ResultPlacement::Bad('d'),
                        ResultPlacement::Good('s'),
                    ]
                )
            }
            _ => panic!("shouldn't have other than Placement"),
        }
    }

    #[test]
    fn placement_brass_turns() {
        let res = Placement::build(&"brass".to_string(), "turns".to_string());
        match res.unwrap() {
            ResultWordle::Placement(p) => {
                assert_eq!(
                    p.result,
                    vec![
                        ResultPlacement::Bad('t'),
                        ResultPlacement::Bad('u'),
                        ResultPlacement::Misplaced('r'),
                        ResultPlacement::Bad('n'),
                        ResultPlacement::Good('s'),
                    ]
                )
            }
            _ => panic!("shouldn't have other than Placement"),
        }
    }

    #[test]
    fn placement_brass_super() {
        let res = Placement::build(&"brass".to_string(), "super".to_string());
        match res.unwrap() {
            ResultWordle::Placement(p) => {
                assert_eq!(
                    p.result,
                    vec![
                        ResultPlacement::Misplaced('s'),
                        ResultPlacement::Bad('u'),
                        ResultPlacement::Bad('p'),
                        ResultPlacement::Bad('e'),
                        ResultPlacement::Misplaced('r'),
                    ]
                )
            }
            _ => panic!("shouldn't have other than Placement"),
        }
    }

    #[test]
    fn placement_brass_carbs() {
        let res = Placement::build(&"brass".to_string(), "carbs".to_string());
        match res.unwrap() {
            ResultWordle::Placement(p) => {
                assert_eq!(
                    p.result,
                    vec![
                        ResultPlacement::Bad('c'),
                        ResultPlacement::Misplaced('a'),
                        ResultPlacement::Misplaced('r'),
                        ResultPlacement::Misplaced('b'),
                        ResultPlacement::Good('s'),
                    ]
                )
            }
            _ => panic!("shouldn't have other than Placement"),
        }
    }

    #[test]
    fn placement_brass_barbs() {
        let res = Placement::build(&"brass".to_string(), "barbs".to_string());
        match res.unwrap() {
            ResultWordle::Placement(p) => {
                assert_eq!(
                    p.result,
                    vec![
                        ResultPlacement::Good('b'),
                        ResultPlacement::Misplaced('a'),
                        ResultPlacement::Misplaced('r'),
                        ResultPlacement::Bad('b'),
                        ResultPlacement::Good('s'),
                    ]
                )
            }
            _ => panic!("shouldn't have other than Placement"),
        }
    }

    #[test]
    fn placement_brass_canal() {
        let res = Placement::build(&"brass".to_string(), "canal".to_string());
        match res.unwrap() {
            ResultWordle::Placement(p) => {
                assert_eq!(
                    p.result,
                    vec![
                        ResultPlacement::Bad('c'),
                        ResultPlacement::Misplaced('a'),
                        ResultPlacement::Bad('n'),
                        ResultPlacement::Misplaced('a'),
                        ResultPlacement::Bad('l'),
                    ]
                )
            }
            _ => panic!("shouldn't have other than Placement"),
        }
    }

    #[test]
    fn placement_telephone_teephone() {
        let res = Placement::build(&"téléphone".to_string(), "téééphone".to_string());
        match res.unwrap() {
            ResultWordle::Placement(p) => {
                assert_eq!(
                    p.result,
                    vec![
                        ResultPlacement::Good('t'),
                        ResultPlacement::Good('é'),
                        ResultPlacement::Bad('é'),
                        ResultPlacement::Good('é'),
                        ResultPlacement::Good('p'),
                        ResultPlacement::Good('h'),
                        ResultPlacement::Good('o'),
                        ResultPlacement::Good('n'),
                        ResultPlacement::Good('e'),
                    ]
                )
            }
            _ => panic!("shouldn't have other than Placement"),
        }
    }
}
