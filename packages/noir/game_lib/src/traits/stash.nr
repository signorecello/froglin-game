use crate::globals::TREE_DEPTH;
use crate::types::froglin::Froglin;

trait Stash {
    fn stash_deposit(&mut self, id: Field, siblings: [Field; TREE_DEPTH], secret: Field);
    fn stash_withdraw(&mut self, froglin: Froglin, siblings: [Field; TREE_DEPTH], secret: Field);
}
