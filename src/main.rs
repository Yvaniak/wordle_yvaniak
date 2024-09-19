use rand::Rng;
use std::io;
use std::mem;

//TODO: make tests
//TODO: use a database pour gerer le add et l'import/export
//TODO: Prendre les mots d'un fichier pour init la database
//TODO: ajouter un add au menu pour ajouter des mots
//TODO: ajouter un import/export de mots
//TODO: ratatui
//TODO: GUI
fn main() {
    //menu loop
    println!("Welcome in the menu of this wordle game !");
    loop {
        println!("You can start (start, s) or quit (quit, q)");

        let mut choix: String = String::new();

        //affectation avec verif que ça correspond
        match io::stdin().read_line(&mut choix) {
            Ok(str)
                if choix.trim() == "s"
                    || choix.trim() == "start"
                    || choix.trim() == "q"
                    || choix.trim() == "quit" =>
            {
                println!("test {}", choix);
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
            "s" | "start" => partie(),
            "q" | "quit" => return,
            _ => println!("didn't understood that, can you repeat ?"),
        }
    }
}

fn pick_the_word() -> String {
    let dico: [&str; 6] = ["thé", "café", "faculté", "lycée", "ordinateur", "téléphone"];

    //Teste que le dico n'est pas plus grand que usize
    assert!(mem::size_of::<usize>() > dico.len());

    let mot: usize = rand::thread_rng().gen_range(1..=dico.len() - 1);

    assert!(mot < dico.len());
    let mot: &str = dico[mot];

    //mise en String pour comparer
    return mot.to_owned();
}

fn partie() {
    let mot: String = pick_the_word();
    println!("The word is {mot}"); //testing

    println!("The wordle game begin ! The word has {} letters", mot.len());
    println!("You can stop by inputting : stop");
    loop {
        println!("Please input your guess.");
        let mut guess: String = String::new();

        match io::stdin().read_line(&mut guess) {
            Err(_) => continue,
            Ok(_str) if guess.trim() == "stop" => {
                println!("exiting");
                return;
            }
            Ok(_str) if guess.trim().to_owned() == mot => {
                println!("You win !");
                return;
            }
            Ok(str) if str - 1 != mot.len() => {
                println!(
                    "You gave a word of {} letters but the word is {} letters",
                    str - 1,
                    mot.len()
                );
                continue;
            }
            _ => continue,
        };
        //TODO: faire la comparaison comme un vrai wordle
    }
}
