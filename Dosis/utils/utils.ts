export function formatAddress(input: string): string {
  // Ensure it starts with 0x
  let hex = input.startsWith("0x") ? input.slice(2) : input;

  // Pad with leading zeros until length = 64
  hex = hex.padStart(64, "0");

  return "0x" + hex;
}