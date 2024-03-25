use crate::types::froglin::Froglin;
use crate::globals::FROGLIN_MAX;

trait PlayerTrait {
    fn get_level(&mut self) -> Field;
    fn _get_level(self) -> Field;
    fn get_stash_root(self) -> Field;

    fn get_mana(self) -> u32;
    fn add_mana(&mut self, amount: u32);
    fn remove_mana(&mut self, amount: u32);

    fn get_froglins(self) -> [Froglin; FROGLIN_MAX];
    fn add_froglin(&mut self, froglin: Froglin) -> bool;
    fn update_froglin(&mut self, froglin: Froglin) -> Self;

    fn generate_identity(self, secret: Field) -> Field;
    fn assert_identity(self, secret: Field, other: Field);
}
