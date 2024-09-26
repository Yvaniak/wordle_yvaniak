use rand::Rng;
use std::io;
use unicode_segmentation::UnicodeSegmentation;

//TODO: make tests
//TODO: use a database pour gerer le add et l'import/export
//TODO: Prendre les mots d'un fichier pour init la database
//TODO: ajouter un add au menu pour ajouter des mots
//TODO: ajouter un import/export de mots
//TODO: ratatui
//TODO: GUI
//TODO: Test d'intégration en abstrayant le test de misplacement dans une fonction
fn main() {
    //menu loop
    println!("Welcome in the menu of this wordle game !");
    let mut boucler: bool = true;
    while boucler {
        println!("\nYou can start (start, s) or quit (quit, q)");

        let mut choix: String = String::new();

        //affectation avec verif que ça correspond
        match io::stdin().read_line(&mut choix) {
            Ok(str)
                if choix.trim() == "s"
                    || choix.trim() == "start"
                    || choix.trim() == "q"
                    || choix.trim() == "quit"
                    || choix.trim() == "exit"
                    || choix.trim() == "e" =>
            {
                str
            }
            Ok(_str) => {
                println!("didn't understood that, can you repeat ?");
                continue;
            }
            Err(_) => continue,
        };

        //trim prend un String et renvoie un &str
        let choix: &str = choix.trim();

        match choix {
            "s" | "start" => boucler = partie(pick_the_word()),
            "q" | "quit" | "exit" | "e" => boucler = false,
            _ => println!("didn't understood that, can you repeat ?"),
        }
    }
}

fn get_the_words() -> Vec<String> {
    return vec![
        "thé".to_string(),
        "café".to_string(),
        "faculté".to_string(),
        "lycée".to_string(),
        "ordinateur".to_string(),
        "téléphone".to_string(),
    ];
}

fn pick_the_word() -> String {
    let dico: Vec<String> = get_the_words();
    //Teste que le dico n'est pas plus grand que usize
    assert!(size_of::<usize>() > dico.len());

    let mot: usize = rand::thread_rng().gen_range(0..=dico.len() - 1);

    assert!(mot < dico.len());
    dico[mot].clone()
}

fn partie(mot: String) -> bool {
    println!("The word is {mot}"); //testing

    println!(
        "The wordle game begin ! The word has {} letters",
        mot.chars().count()
    );

    println!("You can go to the menu by inputting : menu and quit by inputting : quit");
    loop {
        println!("\nPlease input your guess.");
        let mut guess: String = String::new();

        match io::stdin().read_line(&mut guess) {
            Err(_) => {
                println!("\nerreur lors de la lecture");
                continue;
            }
            Ok(str) => str,
        };

        let guess = guess.trim();
        println!("mot:{}:", mot);
        println!("guess:{}:", guess);
        if guess == "quit" && guess == "exit" {
            println!("\nquitting");
            return false;
        }

        if guess == "menu" {
            println!("\ngoing to menu");
            return true;
        }

        let guess = guess.to_string();

        if guess == mot {
            println!("\nYou win !");
            return true;
        }

        let len_guess = guess.graphemes(true).count();
        let len_mot = mot.graphemes(true).count();
        if len_guess != len_mot {
            //FIX: affichage marche pas bien
            println!(
                "\nYou gave a word of {} letters but the word is {} letters",
                len_guess, len_mot
            );
            //FIX: la condition marche pas avec les accents
            continue;
        }

        let mut mot_copy: String = mot.clone();
        let mut guess_mut = guess.clone();
        assert!(len_guess == len_mot);
        println!("g {guess}");
        let mut cpt = 1;
        while mot_copy.len() > 0 {
            let c_mot = mot_copy.remove(0).to_string();
            let c_guess = guess_mut.remove(0).to_string();
            if c_mot != c_guess {
                println!("\nThe letter {} in position {} is not good", c_guess, cpt);
            }
            cpt += 1;
        }
        //TODO: faire la comparaison comme un vrai wordle
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn picked_word_is_in_dico() {
        let word: String = pick_the_word();
        let dico: Vec<String> = get_the_words();
        assert!(dico.contains(&word));
    }
}
