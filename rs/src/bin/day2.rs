use clap::Parser;
use regex::Regex;

#[derive(Parser)]
struct Cli {
    path: std::path::PathBuf,
}

#[derive(Debug)]
struct Draw {
    red: i32,
    blue: i32,
    green: i32
}


fn parse_line(line: &str) -> Vec<&Draw> {
    let re = Regex::new(r"(\d+) (red|blue|green)").unwrap();
    let mut draws = Vec::<&Draw>::new();
    let draws_line = line.split(";");

    for draw_str in draws_line {
        let captures = re.captures_iter(draw_str);
        let mut draw = Draw {red: 0, blue: 0, green: 0};
        for cap in captures {
            println!("cap: {:?}", cap);
        }

        draws.push(&draw);
    }
    println!("draws: {:?}", draws);
    return draws;
}

fn solve_part1(content: String) -> i32 {
    return content
        .lines()
        .map(|line| {
            let draw = parse_line(line);
            return 0;
        }).sum()
}

fn solve_part2(content: String) -> i32 {
    return 0;
}

fn main() {
    let args = Cli::parse();
    println!("input: {:?}", args.path);

    let content = std::fs::read_to_string(&args.path).expect("could not read file");

    println!("part1: {}", solve_part1(content.clone()));
    println!("part2: {}", solve_part2(content.clone()));
}
