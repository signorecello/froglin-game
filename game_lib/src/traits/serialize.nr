trait Serialize<N> {
    fn serialize(self) -> [Field; N];
}
