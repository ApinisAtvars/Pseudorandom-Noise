public readonly struct SmallXXHash {

	const uint primeA = 0b10011110001101110111100110110001;
	const uint primeB = 0b10000101111010111100101001110111;
	const uint primeC = 0b11000010101100101010111000111101;
	const uint primeD = 0b00100111110101001110101100101111;
	const uint primeE = 0b00010110010101100110011110110001;

    readonly uint accumulator;

    public SmallXXHash (uint accumulator) {
        this.accumulator = accumulator;
    }

    // Type casting must be either implicit or explicit
    // We create a cast-to-uint operator
    public static implicit operator uint (SmallXXHash hash) {
        // Avalanche effect means spreading the influence of all input bits around
		uint avalanche = hash.accumulator;
		avalanche ^= avalanche >> 15;
		avalanche *= primeB;
		avalanche ^= avalanche >> 13;
		avalanche *= primeC;
		avalanche ^= avalanche >> 16;
		return avalanche;
	}

    public static implicit operator SmallXXHash (uint accumulator) =>
		new SmallXXHash(accumulator);
    
    // The XXHash32 algorithm works by consuming its input in portions of 32 bits
    // but because our version is so small, we eat only a single portion in isolation
    public SmallXXHash Eat (int data) =>
		RotateLeft(accumulator + (uint)data * primeC, 17) * primeD;

	public SmallXXHash Eat (byte data) =>
		RotateLeft(accumulator + data * primeE, 11) * primeA;

    // Unlike bit shifting, rotation adds the bits that would have been lost to the other side
    static uint RotateLeft (uint data, int steps) =>
		(data << steps) | (data >> 32 - steps);

    public static SmallXXHash Seed (int seed) => (uint)seed + primeE;
}

