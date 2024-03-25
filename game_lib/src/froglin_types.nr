use dep::std::option::Option;
use crate::types::froglin::Froglin;

mod desert_froglin;
mod tree_froglin;

fn get_froglin_type_by_id(id: Field) -> Froglin {
    if id == 1 { desert_froglin::new(id) }
    else if id == 2 { tree_froglin::new(id) }
    else { assert(false, "Unknown froglin type"); Froglin::default() }
    
}
