use clap::Parser;
use std::fmt;
use std::hash::Hash;
use priority_queue::PriorityQueue;

#[derive(Parser)]
struct Cli {
    path: std::path::PathBuf,
}

#[derive(Debug, Copy, Clone, PartialEq, Eq, Hash)]
enum Direction {
    Up,
    Down,
    Left,
    Right,
}

impl Direction {
    fn turn_left(&self) -> Self {
        match self {
            Direction::Up => Direction::Left,
            Direction::Down => Direction::Right,
            Direction::Left => Direction::Down,
            Direction::Right => Direction::Up,
        }
    }

    fn turn_right(&self) -> Self {
        match self {
            Direction::Up => Direction::Right,
            Direction::Down => Direction::Left,
            Direction::Left => Direction::Up,
            Direction::Right => Direction::Down,
        }
    }

    fn opposite(&self) -> Self {
        match self {
            Direction::Up => Direction::Down,
            Direction::Down => Direction::Up,
            Direction::Left => Direction::Right,
            Direction::Right => Direction::Left,
        }
    }
}


#[derive(Debug, Clone, Copy, Hash, PartialEq, Eq)]
struct GridIndex {
    i: usize,
    j: usize,

    rows: usize,
    cols: usize,
}

impl GridIndex {
    fn step(self, direction: Direction) -> Option<Self> {
        let mut newIndex = self.clone();
        match direction {
            Direction::Up => if self.i > 0 {newIndex.i -= 1} else {return None},
            Direction::Down => if self.i < self.rows - 1 {newIndex.i += 1} else {return None}
            Direction::Left => if self.j > 0 {newIndex.j -= 1} else {return None},
            Direction::Right => if self.j < self.cols - 1 {newIndex.j += 1} else {return None},
        }
        return Some(newIndex);
    }

    fn manhattan_distance(&self, other: &GridIndex) -> usize {
        let dx = if self.i > other.i {self.i - other.i} else {other.i - self.i};
        let dy = if self.j > other.j {self.j - other.j} else {other.j - self.j};
        return dx + dy;
    }
}

#[derive(Debug)]
struct Grid<T> {
    rows: usize,
    cols: usize,
    data: Vec<T>,
}

impl<T: Clone + Default> Grid<T> {
    fn new(rows: usize, cols: usize) -> Self {
        let data = vec![T::default(); rows * cols];
        return Grid { rows, cols, data };
    }

    fn index(&self, index: GridIndex) -> usize {
        index.i * self.rows + index.j
    }   

    fn size(&self) -> usize {
        self.rows * self.cols
    }

    fn get(&self, index: GridIndex) -> Option<&T> {
        if index.i >= self.rows || index.j >= self.cols {
            return None;
        }
        self.data.get(self.index(index))
    }

    fn get_mut(&mut self, index: GridIndex) -> Option<&mut T> {
        let index1d = self.index(index);
        return self.data.get_mut(index1d);
    }

    fn set(&mut self, index: GridIndex, value: T) -> Option<()> {
        if let Some(index1d) = self.get_mut(index) {
            *index1d = value;
            return Some(());
        }
        None
    }
}

impl<T: Clone + Default + std::fmt::Display> std::fmt::Display for Grid<T> {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let mut s = String::new();
        for i in 0..self.rows {
            for j in 0..self.cols {
                s.push_str(&format!("{} ", self.get(GridIndex { i, j, rows: self.rows, cols: self.cols }).unwrap()));
            }
            s.push_str("\n");
        }
        write!(f, "{}", s)
    }
}

#[derive(Debug, Clone, Copy, Hash, Eq, PartialEq)]
struct State {
    position: GridIndex,
    direction: Direction,
    steps: usize,
}


impl State {
    fn step(self, direction: Direction) -> Option<Self> {
        let mut new_state = self.clone();
        new_state.direction = direction;

        if let Some(new_position) = self.position.step(direction) {
            new_state.position = new_position;
        } else {
            return None;
        }

        if self.direction == direction {
            new_state.steps = self.steps + 1;
        } else {
            new_state.steps = 1;
        }

        return Some(new_state);
    }

    fn next_states(self) -> Vec<Self> {
        let mut states = Vec::<Self>::new();
        if self.steps < 3 {
            if let Some(next) = self.step(self.direction) {
                states.push(next);
            }
        }
        if let Some(next) = self.step(self.direction.turn_left()) {
            states.push(next);
        }
        if let Some(next) = self.step(self.direction.turn_right()) {
            states.push(next);
        }
        return states;
    }
    // fn next_states(self) -> Vec<Self> {
    //     // part 2
    //     let mut states = Vec::<Self>::new();
    //     if self.steps < 10 {
    //         if let Some(next) = self.step(self.direction) {
    //             states.push(next);
    //         }
    //     }
    //     if self.steps >= 4 {
    //     if let Some(next) = self.step(self.direction.turn_left()) {
    //         states.push(next);
    //     }
    //     if let Some(next) = self.step(self.direction.turn_right()) {
    //         states.push(next);
    //     }
    //     }
    //     return states;
    // }
}

fn search(grid: &Grid<usize>, start: State, goal: &State) -> Option<usize> {
    let mut queue: PriorityQueue<(State, usize), i32> = PriorityQueue::new();

    let mut nodes_visited : usize = 0;
    queue.push((start, 0), 0);

    while let Some(((state, cost), priority)) = queue.pop() {
        nodes_visited += 1;
        // println!("{:?}, cost: {}, priority: {}", state, cost, priority);

        // check goal
        if state.position.i == goal.position.i && state.position.j == goal.position.j {
            println!("Visited {} nodes", nodes_visited);
            return Some(cost);
        }

        for next_state in state.next_states() {
            if let Some(value) = grid.get(next_state.position) {
                let next_cost = cost + *value;

                // A* using the manhattan distance as heuristic
                let priority = - ((next_cost + next_state.position.manhattan_distance(&goal.position)) as i32);
                queue.push_increase((next_state, next_cost), priority);
            }
        }
    }

    return None;
}

fn content_to_matrix(content: String) -> Grid<usize> {
    let lines = content.lines().collect::<Vec<&str>>();
    let rows = lines.len();
    let cols = lines[0].len();
    let mut matrix = Grid::new(rows, cols);

    for (i, line) in lines.iter().enumerate() {
        for (j, c) in line.chars().enumerate() {
            let index = GridIndex{ i, j, rows, cols};
            matrix.set(index, c.to_digit(10).unwrap() as usize);
        }
    }
    return matrix;
}

fn solve_part1(content: String) -> Option<usize> {
    let grid = content_to_matrix(content);
    println!("{}", grid);

    let start = State { position: GridIndex{ i: 0, j: 0, rows: grid.rows, cols: grid.cols }, direction: Direction::Right, steps: 0 };
    let goal = State { position: GridIndex{i: grid.cols - 1, j: grid.rows - 1, rows: grid.rows, cols: grid.cols} , direction: Direction::Right, steps: 0 };

    return search(&grid, start, &goal);
}

fn solve_part2(content: String) -> usize {
    0
}

fn main() {
    let args = Cli::parse();
    println!("input: {:?}", args.path);

    let content = std::fs::read_to_string(&args.path).expect("could not read file");

    if let Some(result) = solve_part1(content.clone()) {
        println!("part1: {}", result);

    }
    println!("part2: {}", solve_part2(content.clone()));
}
