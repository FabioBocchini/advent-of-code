import gleam/dict
import gleeunit
import gleeunit/should
import utils

pub fn main() {
  gleeunit.main
}

/// get_substring_index
pub fn get_substring_index_test() {
  utils.get_substring_index("12345", "23")
  |> should.equal(Ok(1))
}

pub fn get_substring_index_error_test() {
  utils.get_substring_index("12345", "6")
  |> should.equal(Error(Nil))
}

/// return_if_error
pub fn return_if_error_ok_test() {
  {
    use x <- utils.return_if_error(Ok(1), 0)
    x + 1
  }
  |> should.equal(2)
}

pub fn return_if_error_error_test() {
  {
    use x <- utils.return_if_error(Error(Nil), 0)
    x + 1
  }
  |> should.equal(0)
}

/// get_digits_coordinates
pub fn get_digit_coordinates_ok_test() {
  utils.get_digit_coordinates("..12.3..4256")
  |> should.equal(dict.from_list([#(2, 2), #(5, 1), #(8, 4)]))
}

pub fn get_digit_coordinates_empty_test() {
  utils.get_digit_coordinates("")
  |> should.equal(dict.from_list([]))
}

pub fn get_digit_coordinates_full_test() {
  utils.get_digit_coordinates("123")
  |> should.equal(dict.from_list([#(0, 3)]))
}
