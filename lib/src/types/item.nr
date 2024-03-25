use crate::traits::serialize::Serialize;
use crate::globals::{ITEM_SIZE};
use dep::std::println;

struct Item {
    id: Field,
    quantity: Field
}

impl Serialize<ITEM_SIZE> for Item {
    fn serialize(self) -> [Field; ITEM_SIZE] {
        [self.id, self.quantity]
	}
}

impl Default for Item {
    fn default() -> Self {
        Item {
            id: 0,
            quantity: 0
        }
    }
}

impl Item {
    pub fn assert_unchanged(self, other: Item) {
        println(f"Asserting Item unchanged: {self}");
        assert(self.id == other.id);
        assert(self.quantity == other.quantity);
    }
}
