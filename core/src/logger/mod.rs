use log::{Record, Level, Metadata};

pub struct Logger;

impl log::Log for Logger {
    fn enabled(&self, metadata: &Metadata) -> bool {
        return metadata.level() <= Level::Info
    }

    fn log(&self, record: &Record) {
        match record.level() {
            Level::Error => println!("🚨 ERROR - {}", record.args()),
            Level::Info => println!("🔵 INFO - {}", record.args()),
            Level::Warn => println!("⚠️ WARNING - {}", record.args()),
            Level::Debug => println!("🛠 DEBUG - {}", record.args()),
            Level::Trace => println!("🔮 TRACE - {}", record.args()),
        }
    }

    fn flush(&self) {}
}