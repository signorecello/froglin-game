use crate::entities::player::Player;
use crate::globals::PLAYER_SIZE;

trait Commit<N> {
    fn commit(self, secret: Field) -> Field;
}

trait Serialization<SIZE> {
    fn serialize(self) -> [Field; SIZE];
    fn deserialize(serialized: [Field; SIZE]) -> Self;

}
