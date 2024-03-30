use dep::std::option::Option;
use crate::types::froglin::Froglin;

mod desert_froglin;
mod tree_froglin;

pub fn get_froglin_type_by_id(unique_id: Field, type_id: Field) -> Froglin {
    if type_id == 1 {
        desert_froglin::new(unique_id)
    } else if type_id == 2 {
        tree_froglin::new(unique_id)
    } else {
        assert(false, "Unknown froglin type");
        Froglin::default()
    }
}
