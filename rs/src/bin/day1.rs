use clap::Parser;
use regex::Regex;

#[derive(Parser)]
struct Cli {
    path: std::path::PathBuf,
}

fn find_digits(line: &str) -> Vec<i32> {
    let re = Regex::new(r"\d").unwrap();

    let digits: Vec<_> = re.find_iter(line)
        .map(|d| d.as_str().parse::<i32>().unwrap())
        .collect();

    return digits;
}

fn combine_first_and_last(digits: Vec<i32>) -> i32 {
    return 10 * digits.first().unwrap() + digits.last().unwrap();
}

fn solve_part1(content: String) -> i32 {
    return content
        .lines()
        .map(|line| {
        let digits = find_digits(line);
        let combined = combine_first_and_last(digits);
        return combined;
    }).sum()
}

fn solve_part2(content: String) -> i32 {
    return content
        .lines()
        .map(|line| {
        let updated_line = line
            .replace("one", "one1one")
            .replace("two", "two2two")
            .replace("three", "three3three")
            .replace("four", "four4four")
            .replace("five", "five5five")
            .replace("six", "six6six")
            .replace("seven", "seven7seven")
            .replace("eight", "eight8eight")
            .replace("nine", "nine9nine");
        let digits = find_digits(&updated_line);
        let combined = combine_first_and_last(digits);
        return combined;
    }).sum()
}

fn main() {
    let args = Cli::parse();
    println!("input: {:?}", args.path);

    let content = std::fs::read_to_string(&args.path).expect("could not read file");

    println!("part1: {}", solve_part1(content.clone()));
    println!("part2: {}", solve_part2(content.clone()));
}
