use clap::Parser;
use std::collections::HashMap;
use std::collections::VecDeque;

#[derive(Parser)]
struct Cli {
    path: std::path::PathBuf,
}

#[derive(Debug, Clone, PartialEq, Eq)]
struct Signal {
    pulse: bool,
    sender: String,
    receiver: String,
}

#[derive(Debug, PartialEq)]
enum ModuleType {
    FlipFlop,
    Conjunction,
    Broadcast,
}

trait Module {
    fn receive(&mut self, signal: Signal) -> Vec<Signal>;

    fn add_sender(&mut self, sender: String);
}

#[derive(Debug)]
struct FlipFlopModule {
    name: String,
    receivers: Vec<String>,
    state: bool,
}

impl Module for FlipFlopModule {
    fn receive(&mut self, signal: Signal) -> Vec<Signal> {
        if !signal.pulse { 
            self.state = !self.state; 

            let signals = self.receivers.iter().map(|receiver| {
                return Signal { pulse: self.state, sender: self.name.clone(), receiver: receiver.clone() };
            }).collect();
            return signals;
        }

        return vec![];

    }

    fn add_sender(&mut self, _sender: String) {
        return;
    }
}

#[derive(Debug)]
struct ConjunctionModule {
    name: String,
    receivers: Vec<String>,
    state: HashMap<String, bool>,
}

impl Module for ConjunctionModule {
    fn receive(&mut self, signal: Signal) -> Vec<Signal> {
        self.state.insert(signal.sender, signal.pulse);

        for key in self.state.keys() {
            if !self.state[key] {
                return self.receivers.iter().map(|receiver| { return Signal { pulse: true, sender: self.name.clone(), receiver: receiver.clone() }; }).collect();
            }
        }

        return self.receivers.iter().map(|receiver| { return Signal { pulse: false, sender: self.name.clone(), receiver: receiver.clone() }; }).collect();
    }

    fn add_sender(&mut self, sender: String) {
        self.state.insert(sender, false);
        return;
    }
}

#[derive(Debug)]
struct BroadcastModule {
    name: String,
    receivers: Vec<String>
}

impl Module for BroadcastModule {
    fn receive(&mut self, _signal: Signal) -> Vec<Signal> {
        return self.receivers.iter().map(|receiver| { return Signal { pulse: false, sender: self.name.clone(), receiver: receiver.clone() }; }).collect();
        
    }

    fn add_sender(&mut self, _sender: String) {
        return;
    }
}


fn parse_module_type(line: &str) -> ModuleType {
    match line.chars().next().unwrap() {
        '&' => return ModuleType::Conjunction,
        '%' => return ModuleType::FlipFlop,
        _ => return ModuleType::Broadcast,
    }
}

fn parse_module_name(line: &str) -> String {
    match parse_module_type(line) {
        ModuleType::Broadcast => return "broadcast".to_string(),
        _ => return line.split_whitespace().next().unwrap()[1..].to_string(),
    }
}

fn parse_receivers(line: &str) -> Vec<String> {
    let parts = line.split(" -> ").collect::<Vec<&str>>();
    let receivers: Vec<String> = parts[1].split(", ").map(|s| s.to_string() ).collect();
    return receivers;
}

fn create_modules(content: String) -> HashMap<String, Box<dyn Module>> {
    let mut modules: HashMap<String, Box<dyn Module>> = HashMap::new();

    // create a hashmap with all modules
    for line in content.lines() {
        let module_type = parse_module_type(line);
        let module_name = parse_module_name(line);
        let receivers = parse_receivers(line);


        match module_type {
            ModuleType::Broadcast => {
                modules.insert(module_name.to_string(), Box::new(BroadcastModule { name: "broadcast".to_string(), receivers }));
            },

            ModuleType::Conjunction => {
                modules.insert(module_name.to_string(), Box::new(ConjunctionModule { name: module_name.to_string(), receivers, state: HashMap::new() }));
            },

            ModuleType::FlipFlop => {
                modules.insert(module_name.to_string(), Box::new(FlipFlopModule { name: module_name.to_string(), receivers, state: false }));
            },
        }
    }

    println!("modules: {:?}", modules.keys());

    // add senders now that we know all modules
    for line in content.lines() {
        let module_name = parse_module_name(line);
        let receivers = parse_receivers(line);

        println!("{} -> {:?}", module_name, receivers);
        for receiver in receivers {
            // receiver might not be connected to anything
            if let Some(module) = modules.get_mut(&receiver){
                module.add_sender(module_name.clone());
            }
        }
    }

    return modules;
}

fn solve_part1(content: String) -> usize {
    let mut modules = create_modules(content);

    let mut queue: VecDeque<Signal> = VecDeque::new();

    let mut low_signals = 0;
    let mut high_signals = 0;


    for _ in 0..1000 {
        queue.push_back(Signal { pulse: false, sender: "button".to_string(), receiver: "broadcast".to_string() });

        while !queue.is_empty() {
            let signal = queue.pop_front().unwrap();

            if signal.pulse {
                high_signals += 1;
            } else {
                low_signals += 1;
            }

            if let Some(module) = modules.get_mut(&signal.receiver) {
                let signals = module.receive(signal);

                for signal in signals {
                    queue.push_back(signal);
                }
            }
        }
    }

    println!("low: {}, high: {}", low_signals, high_signals);

    return low_signals * high_signals;
}

fn solve_part2(content: String) -> usize {
    let mut modules = create_modules(content);

    let mut queue: VecDeque<Signal> = VecDeque::new();

    let mut button_presses = 0;

    loop {
        button_presses += 1;
        queue.push_back(Signal { pulse: false, sender: "button".to_string(), receiver: "broadcast".to_string() });

        while !queue.is_empty() {
            let signal = queue.pop_front().unwrap();

            if signal.receiver == "rx" && !signal.pulse {
                return button_presses
            }

            if let Some(module) = modules.get_mut(&signal.receiver) {
                let signals = module.receive(signal);

                for signal in signals {
                    queue.push_back(signal);
                }
            }
        }
        if button_presses % 100000 == 0 {
            println!("button presses: {}", button_presses);
        }
    }
}

fn main() {
    let args = Cli::parse();
    println!("input: {:?}", args.path);

    let content = std::fs::read_to_string(&args.path).expect("could not read file");

    println!("part1: {}", solve_part1(content.clone()));
    println!("part2: {}", solve_part2(content.clone()));
}


#[cfg(test)]
mod module_tests {
    use crate::*;

    #[test]
    fn broadcast_module_sends_signals() {
        let mut broadcast_module = BroadcastModule { name: "broadcast".to_string(), receivers: vec!["a".to_string(), "b".to_string()] };
        let signals = broadcast_module.receive(Signal { sender: "button".to_string(), receiver: "broadcast".to_string(), pulse: true});

        assert_eq!(signals, vec![Signal { pulse: false, sender: "broadcast".to_string(), receiver: "a".to_string() }, Signal { pulse: false, sender: "broadcast".to_string(), receiver: "b".to_string() }]);
    }

    #[test]
    fn flip_flop_module_does_not_send_on_high_signal() {
        let mut flip_flop_module = FlipFlopModule { name: "self".to_string(), receivers: vec!["a".to_string(), "b".to_string()], state: false };
        let signals = flip_flop_module.receive(Signal {sender: "broadcast".to_string(), receiver: "self".to_string(), pulse: true});

        assert_eq!(signals, vec![]);
    }

    #[test]
    fn flip_flop_module_does_send_on_low_signal() {
        let mut flip_flop_module = FlipFlopModule { name: "ff".to_string(), receivers: vec!["a".to_string(), "b".to_string()], state: false };
        let signals = flip_flop_module.receive(Signal {sender: "sender".to_string(), receiver: "ff".to_string(), pulse: false});

        assert_eq!(signals, vec![Signal { pulse: true, sender: "ff".to_string(), receiver: "a".to_string() }, Signal { pulse: true, sender: "ff".to_string(), receiver: "b".to_string() }]);
    }

    #[test]
    fn conjunction_module_is_inverter_with_single_input() {
        let mut conjunction_module = ConjunctionModule { name: "cm".to_string(), receivers: vec!["a".to_string(), "b".to_string()], state: HashMap::new() };
        // initialize state
        conjunction_module.add_sender("sender".to_string());

        // receive a message and generate signals
        let signals = conjunction_module.receive(Signal{sender: "sender".to_string(), receiver: "cm".to_string(), pulse: true});

        assert_eq!(signals, vec![Signal { pulse: false, sender: "cm".to_string(), receiver: "a".to_string() }, Signal { pulse: false, sender: "cm".to_string(), receiver: "b".to_string() }]);
    }

    #[test]
    fn conjuction_module_handles_multiple_senders() {
        let mut conjunction_module = ConjunctionModule { name: "cm".to_string(), receivers: vec!["a".to_string(), "b".to_string()], state: HashMap::new() };
        // initialize state
        conjunction_module.add_sender("alice".to_string());
        conjunction_module.add_sender("bob".to_string());

        // receive a message and generate signals
        let signals = conjunction_module.receive(Signal {sender: "alice".to_string(), receiver: "cm".to_string(),  pulse: true});
        assert_eq!(signals, vec![Signal { pulse: true, sender: "cm".to_string(), receiver: "a".to_string() }, Signal { pulse: true, sender: "cm".to_string(), receiver: "b".to_string() }]);

        let signals = conjunction_module.receive(Signal {sender: "bob".to_string(), receiver: "cm".to_string(),  pulse: true});
        assert_eq!(signals, vec![Signal { pulse: false, sender: "cm".to_string(), receiver: "a".to_string() }, Signal { pulse: false, sender: "cm".to_string(), receiver: "b".to_string() }]);
    }

    #[test]
    fn parse_receivers_correctly() {
        let line = "broadcast -> ab, cd, ef";
        assert_eq!(parse_receivers(line), vec!["ab", "cd", "ef"]);
    }

    #[test]
    fn parse_module_name_correctly() {
        let line = "broadcast -> ab, cd, ef";
        assert_eq!(parse_module_name(line), "broadcast".to_string());

        let line = "&ab -> cd, ef";
        assert_eq!(parse_module_name(line), "ab".to_string());

        let line = "%ab -> cd, ef";
        assert_eq!(parse_module_name(line), "ab".to_string());

        let line = "%a -> cd, ef";
        assert_eq!(parse_module_name(line), "a".to_string());
    }

    #[test]
    fn parse_module_type_correctly() {
        let line = "broadcast -> ab, cd, ef";
        assert_eq!(parse_module_type(line), ModuleType::Broadcast);

        let line = "&ab -> cd, ef";
        assert_eq!(parse_module_type(line), ModuleType::Conjunction);

        let line = "%ab -> cd, ef";
        assert_eq!(parse_module_type(line), ModuleType::FlipFlop);
    }
}