use crate::types::{player::Player, froglin::Froglin};
use crate::globals::FROGLIN_MAX;

trait Level {
    fn get_level(self) -> Field;
}

trait LevelUp {
    fn level_up(&mut self);
}
