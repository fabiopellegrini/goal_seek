defmodule GoalSeek do
  @moduledoc """
  Basic implementation of Microsoft Excel's GoalSeek macro, inspired by https://github.com/adam-hanna/goal-seek
  """

  # Mood: https://open.spotify.com/track/5JWPUEov2wlX7c0jhYZpeB

  # credo:disable-for-this-file
  # (cyclomatic complexity = 13, max allowed is 9)

  alias Noether.Either

  @default_options [
    tolerance_fn: nil,
    tolerance_percentage: nil,
    max_iterations: 1000,
    max_step: nil,
    float_precision: 2
  ]

  @doc """
  Find the specified numeric result by adjusting and returning a correct input value

      iex> GoalSeek.seek(5, &Kernel.+/2, [3, 0], 1)
      {:ok, 2}

      iex> GoalSeek.seek(-10, &:math.pow(&1, 3), [0], 0)
      {:ok, -2.15}

      iex> GoalSeek.seek(-10, &:math.pow(&1, 3), [0], 0, float_precision: 5)
      {:ok, -2.15443}
  """
  @spec seek(number(), (... -> number()), list(), integer(), keyword()) ::
          {:error, any()} | {:ok, number()}
  def seek(goal, function, parameters, independent_variable_idx, options \\ [])
      when is_function(function, length(parameters)) do
    options = Keyword.merge(@default_options, options)
    first_guess = Enum.at(parameters, independent_variable_idx)

    function
    |> iterate(
      parameters,
      goal,
      independent_variable_idx,
      options[:float_precision],
      tolerance_function(goal, options),
      options[:max_step],
      options[:max_iterations],
      0
    )
    |> Either.map(&optionally_cast_to_integer(&1, first_guess))
  end

  defp tolerance_function(goal, options) do
    case {options[:tolerance_fn], options[:tolerance_percentage]} do
      {nil, nil} ->
        goal_reached?(goal, options[:max_iterations], options[:float_precision])

      {nil, tolerance_percentage} ->
        fn result, _current_iteration ->
          tolerance = abs(goal) * tolerance_percentage / 100
          result <= goal + tolerance and result >= goal - tolerance
        end

      {tolerance_fn, _} ->
        fn result, _current_iteration -> tolerance_fn.(result) end
    end
  end

  defp iterate(_, _, _, _, _, _, _, max_iterations, max_iterations) do
    {:error, :cannot_converge}
  end

  defp iterate(
         function,
         parameters,
         goal,
         independent_variable_idx,
         float_precision,
         tolerance_fn,
         max_step,
         max_iterations,
         current_iteration
       ) do
    apply(function, parameters)
    |> Either.wrap()
    |> Either.bind(fn result ->
      error = result - goal
      old_guess = Enum.at(parameters, independent_variable_idx)

      if tolerance_fn.(result, current_iteration) do
        {:ok, Float.round(old_guess / 1.0, float_precision)}
      else
        new_guess =
          find_new_guess(
            error,
            max_step,
            old_guess,
            function,
            parameters,
            independent_variable_idx,
            goal
          )

        new_parameters = replace_at(parameters, independent_variable_idx, new_guess)

        iterate(
          function,
          new_parameters,
          goal,
          independent_variable_idx,
          float_precision,
          tolerance_fn,
          max_step,
          max_iterations,
          current_iteration + 1
        )
      end
    end)
  rescue
    e -> {:error, {:function_raised, e}}
  end

  defp find_new_guess(
         error,
         max_step,
         old_guess,
         function,
         parameters,
         independent_variable_idx,
         goal
       ) do
    new_guess = simple_new_guess(error, max_step, old_guess)
    parameters = replace_at(parameters, independent_variable_idx, new_guess)

    function
    |> apply(parameters)
    |> Either.wrap()
    |> Either.bind(&adjusted_new_guess(error, max_step, old_guess, g(error, &1 - goal)))
  end

  defp simple_new_guess(error, max_step, old_guess)
       when max_step != nil and abs(error) > max_step and old_guess + error > old_guess,
       do: old_guess + max_step

  defp simple_new_guess(error, max_step, old_guess)
       when max_step != nil and abs(error) > max_step,
       do: old_guess - max_step

  defp simple_new_guess(error, _max_step, old_guess), do: old_guess + error

  defp adjusted_new_guess(error, max_step, old_guess, g)
       when max_step != nil and abs(error / g) > max_step and old_guess - error / g > old_guess,
       do: old_guess + max_step

  defp adjusted_new_guess(error, max_step, old_guess, g)
       when max_step != nil and abs(error / g) > max_step,
       do: old_guess - max_step

  defp adjusted_new_guess(error, _max_step, old_guess, g), do: old_guess - error / g

  defp g(error, error), do: 0.0001
  defp g(error, error_1), do: (error_1 - error) / error

  defp replace_at(list, index, new_value) do
    Enum.take(list, index) ++ [new_value] ++ Enum.drop(list, index + 1)
  end

  defp goal_reached?(goal, max_iterations, float_precision) do
    fn
      result, current_iteration when current_iteration < max_iterations / 2 ->
        Float.round(abs(result - goal) / 1, float_precision + 1) <=
          :math.pow(10, -1 * (float_precision + 1))

      result, _current_iteration ->
        Float.round(abs(result - goal) / 1, float_precision) <=
          :math.pow(10, -1 * float_precision)
    end
  end

  defp optionally_cast_to_integer(last_guess, first_guess)
       when is_integer(first_guess) and round(last_guess) == last_guess,
       do: round(last_guess)

  defp optionally_cast_to_integer(last_guess, _first_guess),
    do: last_guess
end
