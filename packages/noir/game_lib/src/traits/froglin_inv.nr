use crate::types::froglin::Froglin;

trait FroglinInventory {
    fn get_froglin(self, id: Field) -> Froglin;
    fn add_froglin(&mut self, froglin: Froglin);
    fn remove_froglin(&mut self, id: Field) -> bool;
    fn update_froglin(&mut self, froglin: Froglin) -> Self;
}
