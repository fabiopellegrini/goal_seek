# GoalSeek

[![Hex version](https://img.shields.io/hexpm/v/goal_seek.svg)](https://hex.pm/packages/goal_seek)
[![License](https://img.shields.io/hexpm/l/goal_seek.svg)](https://github.com/fabiopellegrini/goal_seek/blob/master/LICENSE)
[![CI tests](https://github.com/fabiopellegrini/goal_seek/actions/workflows/ci.yml/badge.svg)](https://github.com/fabiopellegrini/goal_seek/actions/workflows/ci.yml)

Basic implementation of Microsoft Excel's GoalSeek macro, inspired by [Adam Hanna's Javascript library](https://github.com/adam-hanna/goal-seek).

This library can be used to find the value of an independent variable `x` given a function `f` and some defined goal `y`, so that `y = f(x)`.

Given a desired output and a known function, goal seek finds the correct input to yield such an output.

Based on [Steffensen's Method](http://en.wikipedia.org/wiki/Steffensen%27s_method) to find the root of the error.

## Installation

Install the package by adding `goal_seek` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:goal_seek, "~> 0.1.0"}
  ]
end
```

## Usage

The library contains only one module with a public function: `&GoalSeek.seek/5`.

The function arguments are the following:

| Name                         | Description                                                               |
| ---------------------------- | ------------------------------------------------------------------------- |
| `goal`                       | the desired output of the function                                        |
| `function`                   | the function that is being evaluated, it can have any arity               |
| `parameters`                 | the initial list of parameters that will be used as input of the function |
| `independent_variable_index` | the index position of the independent variable `x` in the `f_params` list |
| `options`                    | keyword list of options, see next table                                   |

Available options:

| Name               | Description                                                                                                                                                   | Default |
| ------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- |
| `:tolerance_fn`    | a custom function used to check the validity of the result, it takes two arguments (`current_result` and `current_iteration`) and returns a boolean           | `nil`   |
| `:acceptance_fn`   | a custom function used to ensure the seeked value respects some criteria (e.g. being positive), it takes one argument (`current_guess`) and returns a boolean | `nil`   |
| `:max_iterations`  | the maximum number of attempts to make                                                                                                                        | 1000    |
| `:max_step`        | the maximum step size to move the independent variable `x` for the next guess                                                                                 | `nil`   |
| `:float_precision` | the desired float precision for the independent variable                                                                                                      | 2       |

## Examples


```elixir
iex> GoalSeek.seek(7, &Kernel.+/2, [3, 0], 1)
{:ok, 4}

iex> GoalSeek.seek(4, &(&1 * &1), [0], 0)
{:ok, -2}

iex> GoalSeek.seek(4, &(&1 * &1), [0], 0, acceptance_fn: &(&1 > 0))
{:ok, 2}

iex> GoalSeek.seek(-10, &:math.pow(&1, 3), [0], 0)
{:ok, -2.15}

iex> GoalSeek.seek(-10, &:math.pow(&1, 3), [0], 0, float_precision: 5)
{:ok, -2.15443}

iex> GoalSeek.seek(-9, &:math.pow(&1, 3), [0], 0, acceptance_fn: &(&1 > 0))
{:error, :cannot_converge}
```

Look at `test/goal_seek_test.exs` for more examples

## Contributors

Fabio Pellegrini - Author/Maintainer