use crate::globals::TREE_DEPTH;

trait Stash {
    fn stash_deposit(&mut self, id: Field, siblings: [Field; TREE_DEPTH]);
    fn stash_withdraw(&mut self, id: Field);
}
