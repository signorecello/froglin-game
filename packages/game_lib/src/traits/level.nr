use crate::entities::{player::Player, froglin::Froglin};
use crate::globals::FROGLIN_MAX;

trait LevelUp {
    fn level_up(&mut self);
}
