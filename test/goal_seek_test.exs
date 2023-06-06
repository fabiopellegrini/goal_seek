defmodule GoalSeekTest do
  @moduledoc false

  use ExUnit.Case, async: true

  doctest GoalSeek

  # alias OfferEngine.Math.GoalSeek

  describe "goal seek" do
    test "a simple linear equation" do
      f = fn x -> x + 2 end

      assert {:ok, 98} === GoalSeek.seek(100, f, [2], 0)
    end

    test "returns error for function that never crosses the goal within the given bound" do
      f = fn x -> x * x end

      assert {:error, :cannot_converge} === GoalSeek.seek(-1, f, [0], 0)
    end

    test "returns error for invalid function" do
      f = fn x -> x / 0 end

      assert {:error,
              {:function_raised,
               %ArithmeticError{message: "bad argument in arithmetic expression"}}} ===
               GoalSeek.seek(-1, f, [0], 0)
    end

    test "finds exact goal for quadratic function" do
      f = fn x -> x * x end

      assert {:ok, -2} === GoalSeek.seek(4, f, [0], 0)
    end

    test "finds exact goal for quadratic function with custom tolerance function" do
      f = fn x -> x * x end
      goal = 4

      assert {:ok, -1} ===
               GoalSeek.seek(goal, f, [0], 0,
                 tolerance_fn: fn result, _ -> result > 0 and result < 4 end
               )
    end

    test "finds exact goal for cubic function" do
      f = fn x -> x * x * x end

      assert {:ok, 3} === GoalSeek.seek(27, f, [1], 0)
      assert {:ok, -1} === GoalSeek.seek(-1, f, [1], 0)
    end

    test "fails to find negative goal for cubic function with positive acceptance criteria" do
      f = fn x -> x * x * x end

      assert {:error, :cannot_converge} ===
               GoalSeek.seek(-9, f, [0], 0, acceptance_fn: fn x -> x > 0 end)
    end

    test "finds approximate goal for cubic function" do
      f = fn x -> x * x * x end

      assert {:ok, 2.15} === GoalSeek.seek(10, f, [0], 0)
    end
  end
end
