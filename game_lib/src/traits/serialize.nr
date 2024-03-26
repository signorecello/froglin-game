trait Commit<N> {
    fn commit(self, secret: Field) -> Field;
}

trait Serialize<N> {
    fn serialize(self) -> [Field; N];
}
