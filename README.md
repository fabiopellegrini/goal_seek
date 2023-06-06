# GoalSeek

[![Hex version](https://img.shields.io/hexpm/v/goal_seek.svg)](https://hex.pm/packages/goal_seek)
[![License](https://img.shields.io/hexpm/l/goal_seek.svg)](https://github.com/fabiopellegrini/goal_seek/blob/master/LICENSE)
[![Build Status](https://img.shields.io/circleci/project/github/fabiopellegrini/goal_seek/master.svg)](https://circleci.com/gh/fabiopellegrini/goal_seek/tree/master)
[![Code coverage badge](https://img.shields.io/codecov/c/github/fabiopellegrini/goal_seek/master.svg)](https://codecov.io/gh/fabiopellegrini/goal_seek/branch/master)
[![Coverage Status](https://coveralls.io/repos/fabiopellegrini/goal_seek/badge.svg?branch=master)](https://coveralls.io/r/fabiopellegrini/goal_seek?branch=master)

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

| Name              | Description                                                                                                                                                   | Default |
| ----------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- |
| `:tolerance_fn`   | a custom function used to check the validity of the result, it takes two arguments (`current_result` and `current_iteration`) and returns a boolean           | `nil`   |
| `:acceptance_fn`  | a custom function used to ensure the seeked value respects some criteria (e.g. being positive), it takes one argument (`current_guess`) and returns a boolean | `nil`   |
| `:max_iterations` | the maximum number of attempts to make                                                                                                                        | 1000    |
| `:max_step`       | the maximum step size to move the independent variable `x` for the next guess                                                                                 | `nil`   |

## Examples


```elixir
```

Look at `test/goal_seek_test.exs` for more examples

## Contributors

Fabio Pellegrini - Author/Maintainer