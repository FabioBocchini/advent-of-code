import gleeunit
import gleeunit/should
import utils

pub fn main() {
  gleeunit.main
}

pub fn get_substring_index_test() {
  utils.get_substring_index("12345", "23")
  |> should.equal(Ok(1))
}

pub fn get_substring_index_error_test() {
  utils.get_substring_index("12345", "6")
  |> should.equal(Error(Nil))
}
