function addTax(amount, rate) {
  return Math.round(amount * (1 + rate) * 100) / 100;
}
module.exports = { addTax };
// second release
// revert verified
