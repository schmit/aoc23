use clap::Parser;
use std::collections::HashSet;

#[derive(Parser)]
struct Cli {
    path: std::path::PathBuf,
}


fn predict_next_value(seq: Vec<i32>) -> i32 {
    let n = seq.len();

    let deltas = seq[..n-1].iter().zip(seq[1..].iter())
        .map(|(a, b)| b - a).collect::<Vec<i32>>();

    let n_unique_deltas = deltas.iter().cloned().collect::<HashSet<i32>>().len();

    if n_unique_deltas == 1 {
        return seq.last().unwrap() + deltas.first().unwrap();
    } 
    return seq.last().unwrap() + predict_next_value(deltas);
}

fn predict_prev_value(seq: Vec<i32>) -> i32 {
    let n = seq.len();

    let deltas = seq[..n-1].iter().zip(seq[1..].iter())
        .map(|(a, b)| b - a).collect::<Vec<i32>>();

    let n_unique_deltas = deltas.iter().cloned().collect::<HashSet<i32>>().len();

    if n_unique_deltas == 1 {
        return seq.first().unwrap() - deltas.first().unwrap();
    } 
    return seq.first().unwrap() - predict_prev_value(deltas);
}

fn solve_part1(content: String) -> i32 {
    return content
        .lines()
        .map(|line| {
            let sequence = line.split_whitespace()
                .map(|s| s.parse::<i32>().unwrap())
                .collect::<Vec<i32>>();
            return predict_next_value(sequence);
    }).sum();
}

fn solve_part2(content: String) -> i32 {
    return content
        .lines()
        .map(|line| {
            let sequence = line.split_whitespace()
                .map(|s| s.parse::<i32>().unwrap())
                .collect::<Vec<i32>>();
            return predict_prev_value(sequence);
    }).sum();
}

fn main() {
    let args = Cli::parse();
    println!("input: {:?}", args.path);

    let content = std::fs::read_to_string(&args.path).expect("could not read file");

    println!("part1: {}", solve_part1(content.clone()));
    println!("part2: {}", solve_part2(content.clone()));
}
