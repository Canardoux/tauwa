use flutter_logger::logger::log;
use log::Level;
use log::{debug as d, info as i, trace as t};
use simple_log::*;
use std::cell::Cell;

thread_local! { static DEPTH: Cell<usize> = const { Cell::new(0) }; }

//use flutter_logger::logger::log;

//#[trace (prefix_enter="-> ", prefix_exit="<- ", logging)]
pub fn toto() -> String {
    t!("DANS TOTO");
    log(Level::Trace, "coucou", "hello I am a log from toto");
    i!(target: "yak", "yak shaving for toto:?");
    d!(target: "totoxxx", "Dou Gou Dou GOU!!!");

    "bobo".to_string()
}

//#[trace (prefix_enter="-> ", prefix_exit="<- ", logging)]
pub fn zozo() -> String {
    t!("DANS ZOZO");

    "bobo".to_string()
}
