use clap::Parser;
use regex::Regex;
use std::collections::HashMap;
use std::collections::HashSet;

#[derive(Parser)]
struct Cli {
    path: std::path::PathBuf,
}

#[derive(Debug)]
struct Scratch {
    winning: HashSet<u32>,
    numbers: HashSet<u32>,
}

impl Scratch {
    fn score(&self) -> usize {
        let overlap = self.winners();
        if overlap == 0 {
            return 0;
        }

        return usize::pow(2, (overlap-1).try_into().unwrap());
    }

    fn winners(&self) -> usize {
        return self.winning.intersection(&self.numbers).count();
    }
}

fn parse_number_string(number_string: &str) -> Vec<u32> {
    let re = Regex::new(r"(\d+)").unwrap();
    return re.captures_iter(number_string).map(|cap| cap[1].parse::<u32>().unwrap()).collect::<Vec<u32>>();
}

fn parse_line(line: &str) -> Scratch {
    let digits_str = line.split(":").collect::<Vec<&str>>()[1];
    let digits = digits_str.split("|").collect::<Vec<&str>>();

    return Scratch {
        winning: parse_number_string(digits[0]).into_iter().collect(),
        numbers: parse_number_string(digits[1]).into_iter().collect()
    }
}

fn solve_part1(content: String) -> usize {
    return content
        .lines()
        .map(|line| { return parse_line(line); })
        .map(|scratch| { return scratch.score(); })
        .sum();
}

fn solve_part2(content: String) -> usize {
    let winners: Vec<usize> = content
        .lines()
        .map(|line| { return parse_line(line); })
        .map(|scratch| { return scratch.winners(); })
        .collect();

    let mut copies: HashMap<usize, usize> = HashMap::new();

    let mut total_scratchcards: usize = 0;
    for (idx, winner) in winners.iter().enumerate() {
        let current_scratchcards = 1 + copies.get(&idx).unwrap_or(&0);
        total_scratchcards += current_scratchcards;

        for i in 0..*winner {
            copies
            .entry(idx+i+1 as usize)
            .and_modify(|e| *e += current_scratchcards)
            .or_insert(current_scratchcards);
        }
    }
    return total_scratchcards;
}

fn main() {
    let args = Cli::parse();
    println!("input: {:?}", args.path);

    let content = std::fs::read_to_string(&args.path).expect("could not read file");

    println!("part1: {}", solve_part1(content.clone()));
    println!("part2: {}", solve_part2(content.clone()));
}
