defmodule GoalSeek do
  @moduledoc """
  Basic implementation of Microsoft Excel's GoalSeek macro, inspired by https://github.com/adam-hanna/goal-seek
  """

  # Mood: https://open.spotify.com/track/5JWPUEov2wlX7c0jhYZpeB

  # credo:disable-for-this-file
  # (cyclomatic complexity = 13, max allowed is 9)

  alias Noether.Either

  @result_precision 2
  @desired_precision 3
  @minimum_precision 2

  @default_options [
    tolerance_fn: nil,
    acceptance_fn: nil,
    max_iterations: 1000,
    max_step: nil
  ]

  @doc """
  Hello world.

  ## Examples

  iex> GoalSeek.seek(5, &Kernel.+/2, [3, 0], 1)
  {:ok, 2}

  iex> GoalSeek.seek(-10, &(&1 ** 3), [0], 0)
  {:ok, -2.15}

  # iex> GoalSeek.seek(10, &(&1 ** 3), [0], 0, tolerance_fn: fn result, _ -> result >= 8 and result <= 12 end)
  # {:ok, 2.15}

  # iex> GoalSeek.seek(-10, &(&1 ** 3), [0], 0, result_precision: 3)
  # {:ok, -2.154}

  iex> GoalSeek.seek(-9, &(&1 ** 3), [0], 0, acceptance_fn: &(&1 > 0))
  {:error, :cannot_converge}
  """
  @spec seek(number(), (... -> number()), list(), integer(), keyword()) ::
          {:error, any()} | {:ok, number()}
  def seek(goal, function, parameters, independent_variable_idx, options \\ [])
      when is_function(function, length(parameters)) do
    options = Keyword.merge(@default_options, options)
    first_guess = Enum.at(parameters, independent_variable_idx)
    default_tolerance_fn = goal_reached?(goal, options[:max_iterations])
    default_acceptance_fn = fn _guess -> true end

    function
    |> iterate(
      parameters,
      goal,
      independent_variable_idx,
      options[:tolerance_fn] || default_tolerance_fn,
      options[:acceptance_fn] || default_acceptance_fn,
      options[:max_step],
      options[:max_iterations],
      0
    )
    |> Either.map(&optionally_cast_to_integer(&1, first_guess))
  end

  defp iterate(_, _, _, _, _, _, _, max_iterations, max_iterations) do
    {:error, :cannot_converge}
  end

  defp iterate(
         function,
         parameters,
         goal,
         independent_variable_idx,
         tolerance_fn,
         acceptance_fn,
         max_step,
         max_iterations,
         current_iteration
       ) do
    apply(function, parameters)
    |> Either.wrap()
    |> Either.bind(fn result ->
      error = result - goal
      old_guess = Enum.at(parameters, independent_variable_idx)

      cond do
        tolerance_fn.(result, current_iteration) and acceptance_fn.(result) ->
          {:ok, Float.round(old_guess, @result_precision)}

        tolerance_fn.(result, current_iteration) and not acceptance_fn.(result) ->
          {:error, :cannot_converge}

        true ->
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

          if acceptance_fn.(new_guess) do
            new_parameters = replace_at(parameters, independent_variable_idx, new_guess)

            iterate(
              function,
              new_parameters,
              goal,
              independent_variable_idx,
              tolerance_fn,
              acceptance_fn,
              max_step,
              max_iterations,
              current_iteration + 1
            )
          else
            {:error, :cannot_converge}
          end
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

  defp goal_reached?(goal, max_iterations) do
    fn result, current_iteration ->
      if current_iteration < max_iterations / 2 do
        Float.round(abs(result - goal) / 1, @desired_precision) <= 10 ** (-1 * @desired_precision)
      else
        Float.round(abs(result - goal) / 1, @minimum_precision) <= 10 ** (-1 * @minimum_precision)
      end
    end
  end

  defp optionally_cast_to_integer(last_guess, first_guess) when is_integer(first_guess) do
    with {integer, _} <- Integer.parse("#{last_guess}"),
         {float, _} <- Float.parse("#{last_guess}"),
         true <- integer == float do
      integer
    else
      _ -> last_guess
    end
  end

  defp optionally_cast_to_integer(last_guess, _first_guess), do: last_guess
end
