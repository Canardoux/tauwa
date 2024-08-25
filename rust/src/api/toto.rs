/*
 * Copyright 2024 Canardoux.
 *
 * This file is part of the τ project.
 *
 * τ is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 (GPL3), as published by
 * the Free Software Foundation.
 *
 * τ is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with τ.  If not, see <https://www.gnu.org/licenses/>.
 */


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
