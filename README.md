# WorkingDays

Elixir library for calculating working days according to holidays and days the business works

## Installation

```elixir
def deps do
  [
    {:working_days, git: "git@github.com:annatel/working_days.git", tag: "0.1.0"},
  ]
end
```

## Build json files
```
mix run priv/build_france_working_days.exs 
```

## Usage
```
iex> WorkingDays.add_working_days(%Date{year: 2019, month: 1, day: 1}, 3)
    %Date{year: 2019, month: 1, day: 4}

iex> WorkingDays.add_working_days(%Date{year: 2018, month: 12, day: 30}, 2)
%Date{year: 2019, month: 1, day: 2}

iex> WorkingDays.add_working_days(%Date{year: 2019, month: 10, day: 30}, 2, [1, 2, 3, 4, 5])
%Date{year: 2019, month: 11, day: 4}

iex> WorkingDays.add_working_days(%Date{year: 2019, month: 10, day: 25}, 3, [5])
%Date{year: 2019, month: 11, day: 22}
```

## Run test
```
mix test
```