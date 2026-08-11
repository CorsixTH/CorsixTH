use chrono::{DateTime, FixedOffset, Local, Utc};
use serde::{Deserialize, Serialize};
use std::env;
use std::fs;
use std::path::PathBuf;
use std::process;

#[derive(Serialize, Deserialize)]
struct Session {
    start: String,
    end: String,
    hours: f64,
}

#[derive(Serialize, Deserialize)]
struct Tracker {
    current_start: Option<String>,
    sessions: Vec<Session>,
    total_sessions: usize,
    total_hours: f64,
}

impl Tracker {
    fn default_state() -> Self {
        Tracker {
            current_start: None,
            sessions: Vec::new(),
            total_sessions: 0,
            total_hours: 0.0,
        }
    }
}

fn tracker_path() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .join("..")
        .join("..")
        .join("time-tracker.json")
}

fn journal_path() -> PathBuf {
    PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .join("..")
        .join("..")
        .join("journal.md")
}

fn cmd_journal(data: &Tracker) {
    let path = journal_path();
    let content = match fs::read_to_string(&path) {
        Ok(c) => c,
        Err(_) => {
            println!("journal.md not found at {}, skipping", path.display());
            return;
        }
    };
    let total = hours_hm(data.total_hours);
    let header = format!(
        "<p align=\"right\"><b>Total time on the project: {}</b></p>",
        total
    );
    let marker = "Total time on the project:";
    let mut updated: Vec<&str> = content.lines().collect();
    if let Some(i) = updated.iter().position(|l| l.contains(marker)) {
        updated[i] = header.as_str();
    } else {
        let insert_at = match updated.iter().position(|l| l.trim() == "---") {
            Some(p) => p,
            None => updated.len(),
        };
        updated.insert(insert_at, header.as_str());
        updated.insert(insert_at + 1, "");
    }
    let mut out = updated.join("\n");
    out.push('\n');
    fs::write(&path, out).unwrap_or_else(|e| {
        eprintln!("Error writing {}: {}", path.display(), e);
        process::exit(1);
    });
    println!("journal.md: total time set to {}", total);
}

fn load() -> Tracker {
    let path = tracker_path();
    if !path.exists() {
        return Tracker::default_state();
    }
    let content = fs::read_to_string(&path).unwrap_or_else(|e| {
        eprintln!("Error reading {}: {}", path.display(), e);
        process::exit(1);
    });
    serde_json::from_str(&content).unwrap_or_else(|e| {
        eprintln!("Error parsing {}: {}", path.display(), e);
        process::exit(1);
    })
}

fn save(data: &Tracker) {
    let path = tracker_path();
    let mut content = serde_json::to_string_pretty(data).expect("serialize tracker");
    content.push('\n');
    fs::write(&path, content).unwrap_or_else(|e| {
        eprintln!("Error writing {}: {}", path.display(), e);
        process::exit(1);
    });
}

fn now_iso() -> String {
    Local::now().to_rfc3339_opts(chrono::SecondsFormat::Secs, true)
}

fn parse_dt(s: &str) -> DateTime<FixedOffset> {
    DateTime::parse_from_rfc3339(s).unwrap_or_else(|e| {
        eprintln!("Error parsing timestamp {}: {}", s, e);
        process::exit(1);
    })
}

fn round4(x: f64) -> f64 {
    (x * 10000.0).round() / 10000.0
}

fn hours_hm(hours: f64) -> String {
    let total_min = (hours * 60.0).round() as i64;
    let h = total_min / 60;
    let m = total_min % 60;
    format!("{}h {:02}m", h, m)
}

fn cmd_start(data: &mut Tracker, start_arg: Option<&str>) {
    if let Some(start) = &data.current_start {
        println!("Tracker already open since {}", start);
        process::exit(1);
    }
    data.current_start = Some(match start_arg {
        Some(s) => s.to_string(),
        None => now_iso(),
    });
    save(data);
    println!("Tracker started at {}", data.current_start.as_ref().unwrap());
}

fn cmd_close(data: &mut Tracker, end_arg: Option<&str>) {
    let start = match &data.current_start {
        Some(s) => s.clone(),
        None => {
            println!("No open session. Run 'start' first.");
            process::exit(1);
        }
    };
    let start_dt = parse_dt(&start);
    let end = match end_arg {
        Some(s) => s.to_string(),
        None => now_iso(),
    };
    let end_dt = parse_dt(&end);
    let elapsed_secs = (end_dt - start_dt).num_seconds();
    if elapsed_secs < 0 {
        println!("Negative elapsed time - clock went backwards? Aborting.");
        process::exit(1);
    }
    let elapsed = round4(elapsed_secs as f64 / 3600.0);
    data.sessions.push(Session {
        start,
        end,
        hours: elapsed,
    });
    data.total_sessions = data.sessions.len();
    data.total_hours = round4(data.total_hours + elapsed);
    data.current_start = None;
    save(data);
    let last = data.sessions.last().unwrap();
    println!(
        "Session closed: {} ({:.2}h)",
        hours_hm(last.hours),
        last.hours
    );
    println!("  started  {}", last.start);
    println!("  ended    {}", last.end);
    println!(
        "  totals   {} sessions | {} | {:.2}h",
        data.total_sessions,
        hours_hm(data.total_hours),
        data.total_hours
    );
    cmd_journal(data);
}

fn cmd_status(data: &Tracker) {
    if let Some(start) = &data.current_start {
        let start_dt = parse_dt(start);
        let now = Utc::now().with_timezone(start_dt.offset());
        let secs = (now - start_dt).num_seconds();
        let running = if secs > 0 { secs as f64 / 3600.0 } else { 0.0 };
        println!(
            "Session open since {} (running {})",
            start,
            hours_hm(running)
        );
    } else {
        println!("No open session.");
    }
    println!(
        "Totals: {} sessions | {} | {:.2}h",
        data.total_sessions,
        hours_hm(data.total_hours),
        data.total_hours
    );
}

fn cmd_summary(data: &Tracker) {
    println!("Sessions: {}", data.total_sessions);
    println!(
        "Total:    {} ({:.2}h)",
        hours_hm(data.total_hours),
        data.total_hours
    );
    for (i, s) in data.sessions.iter().enumerate() {
        println!(
            "  {:>2}. {} -> {}  ({})",
            i + 1,
            s.start,
            s.end,
            hours_hm(s.hours)
        );
    }
}

fn print_help() {
    println!("AI Lab project time tracker.");
    println!();
    println!("Usage:");
    println!("  time-tracker start [START]  # mark start (default now), open session");
    println!("  time-tracker close [END]  # mark end (default now), compute hours");
    println!("  time-tracker status   # show open session / totals");
    println!("  time-tracker summary  # show totals");
    println!("  time-tracker journal  # refresh the total time in journal.md");
    println!();
    println!("State is stored in time-tracker.json at the repo root.");
}

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() < 2 {
        print_help();
        process::exit(1);
    }
    let mut data = load();
    match args[1].as_str() {
        "start" => cmd_start(&mut data, args.get(2).map(String::as_str)),
        "close" => cmd_close(&mut data, args.get(2).map(String::as_str)),
        "status" => cmd_status(&data),
        "summary" => cmd_summary(&data),
        "journal" => cmd_journal(&data),
        _ => {
            print_help();
            process::exit(1);
        }
    }
}
