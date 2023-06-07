defmodule GoalSeekTest do
  @moduledoc false

  use ExUnit.Case, async: true

  doctest GoalSeek

  test "it solves a simple linear equation" do
    f = fn x -> x + 2 end

    assert {:ok, 98} === GoalSeek.seek(100, f, [2], 0)
  end

  test "it accepts a tolerance percentage with a positive goal" do
    f = fn x -> x + 2 end

    assert {:ok, 97} === GoalSeek.seek(100, f, [90], 0, tolerance_percentage: 1, max_step: 1)
  end

  test "it accepts a tolerance percentage with a negative goal" do
    f = fn x -> x * x * x end

    assert {:ok, -2.18} === GoalSeek.seek(-10, f, [2], 0, tolerance_percentage: 5)
  end

  test "custom tolerance function wins over tolerance percentage" do
    f = fn x -> x + 2 end

    assert {:ok, 89} ===
             GoalSeek.seek(100, f, [50], 0,
               tolerance_percentage: 1,
               tolerance_fn: &(&1 > 90 and &1 < 110),
               max_step: 1
             )
  end

  test "it returns error for function that never crosses the goal within the given bound" do
    f = fn x -> x * x end

    assert {:error, :cannot_converge} === GoalSeek.seek(-1, f, [0], 0)
  end

  test "it returns error for invalid function" do
    f = fn x -> x / 0 end

    assert {:error,
            {:function_raised, %ArithmeticError{message: "bad argument in arithmetic expression"}}} ===
             GoalSeek.seek(-1, f, [0], 0)
  end

  test "it finds exact goal for quadratic function" do
    f = fn x -> x * x end

    assert {:ok, -2} === GoalSeek.seek(4, f, [0], 0)
  end

  test "it returns same type of initial guess when possible" do
    f = fn x -> x * x end

    assert {:ok, -2.0} === GoalSeek.seek(4, f, [0.0], 0)
  end

  test "it finds exact goal for quadratic function with custom tolerance function" do
    f = fn x -> x * x end

    assert {:ok, -1} === GoalSeek.seek(4, f, [0], 0, tolerance_fn: &(&1 > 0 and &1 < 4))
  end

  test "it finds exact goal for cubic function" do
    f = fn x -> x * x * x end

    assert {:ok, 3} === GoalSeek.seek(27, f, [1], 0)
    assert {:ok, -1} === GoalSeek.seek(-1, f, [1], 0)
  end

  test "it finds approximate goal for cubic function" do
    f = fn x -> x * x * x end

    assert {:ok, 2.15} === GoalSeek.seek(10, f, [0], 0)
  end

  test "it approximates the result to a desired float precision" do
    f = fn x -> x * x * x end

    assert {:ok, 2.154} === GoalSeek.seek(10, f, [0], 0, float_precision: 3)
  end

  test "max step can be defined" do
    f = fn x -> x + 1 end

    assert {:error, :cannot_converge} === GoalSeek.seek(2001, f, [0], 0, max_step: 1)
    assert {:ok, 2000} === GoalSeek.seek(2001, f, [0], 0, max_step: 100)
  end

  test "even with a bad first guess the algorithm can converge to the goal" do
    f = fn x -> x * x end

    assert {:ok, 2} === GoalSeek.seek(4, f, [1000], 0, max_step: 1)
  end
end
