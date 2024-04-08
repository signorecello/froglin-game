use crate::traits::serialization::Serialization;
use crate::globals::{ITEM_SIZE};
use dep::std::println;

struct Item {
    id: Field,
    quantity: Field
}

impl Serialization<ITEM_SIZE> for Item {
    fn serialize(self) -> [Field; ITEM_SIZE] {
        [self.id, self.quantity]
	}

    fn deserialize(serialized: [Field; ITEM_SIZE]) -> Self {
        Item {
            id: serialized[0],
            quantity: serialized[1]
        }
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

impl Eq for Item {
    fn eq(self, other: Item) -> bool {
        (self.id == other.id) & (self.quantity == other.quantity)
    }
}

impl Item {
    pub fn assert_unchanged(self, other: Item) {
        assert(self.id == other.id);
        assert(self.quantity == other.quantity);
    }
}
