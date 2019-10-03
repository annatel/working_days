defmodule WorkingDays do
  @moduledoc """
  Documentation for WorkingDays.
  """

  @doc """
  Add working days

  ## Examples

    iex> WorkingDays.add_working_days(%Date{year: 2019, month: 1, day: 1}, 3)
    %Date{year: 2019, month: 1, day: 4}

    iex> WorkingDays.add_working_days(%Date{year: 2018, month: 12, day: 30}, 2)
    %Date{year: 2019, month: 1, day: 2}

    iex> WorkingDays.add_working_days(%Date{year: 2019, month: 10, day: 30}, 2, [1, 2, 3, 4, 5])
    %Date{year: 2019, month: 11, day: 4}

    iex> WorkingDays.add_working_days(%Date{year: 2019, month: 10, day: 25}, 3, [5])
    %Date{year: 2019, month: 11, day: 22}

  """
  def add_working_days(
        %Date{} = from,
        num_of_working_days,
        working_days_of_week \\ [1, 2, 3, 4, 5, 6],
        region \\ :france
      )
      when is_integer(num_of_working_days) and num_of_working_days > 1 and
             length(working_days_of_week) > 0 and
             is_atom(region) do
    holidays =
      (get_holidays(from.year, region) ++ get_holidays(from.year + 1, region))
      |> Enum.map(& &1.date)

    adjust_working_day(Date.add(from, 1), holidays, working_days_of_week, num_of_working_days, 0)
  end

  defp adjust_working_day(%Date{} = date, _, _, num_of_working_days, acc)
       when num_of_working_days == acc,
       do: Date.add(date, -1)

  defp adjust_working_day(
         %Date{} = date,
         holidays,
         working_days_of_week,
         num_of_working_days,
         acc
       ) do
    if not_working_day?(date, holidays, working_days_of_week) do
      adjust_working_day(
        Date.add(date, 1),
        holidays,
        working_days_of_week,
        num_of_working_days,
        acc
      )
    else
      adjust_working_day(
        Date.add(date, 1),
        holidays,
        working_days_of_week,
        num_of_working_days,
        acc + 1
      )
    end
  end

  @doc """
  Is not a working days ?

  ## Examples

    iex> WorkingDays.not_working_day?(%Date{year: 2019, month: 1, day: 1}, [%Date{year: 2019, month: 1, day: 1}], [1, 2, 3, 4, 5, 6, 7])
    true

    iex> WorkingDays.not_working_day?(%Date{year: 2019, month: 1, day: 1}, [], [1, 3, 4, 5, 6, 7])
    true

    iex> WorkingDays.not_working_day?(%Date{year: 2019, month: 1, day: 1}, [], [1, 2, 3, 4, 5, 6, 7])
    false

  """
  def not_working_day?(%Date{} = date, holidays, working_days_of_week) do
    holiday?(date, holidays) or Date.day_of_week(date) not in working_days_of_week
  end

  @doc """
  Is a holiday ?

  ## Examples

    iex> WorkingDays.holiday?(%Date{year: 2019, month: 1, day: 1}, [%Date{year: 2019, month: 1, day: 1}])
    true

    iex> WorkingDays.holiday?(%Date{year: 2019, month: 1, day: 1}, [])
    false

  """
  def holiday?(%Date{} = date, holidays) do
    date in holidays
  end

  @doc """
  Get holidays by year from a region

  ## Examples

      iex> WorkingDays.get_holidays(1950, :france)
      [%{date: ~D[1950-01-01], name: "Jour de l'an"}, %{date: ~D[1950-04-10], name: "Lundi de Pâques"}, %{date: ~D[1950-05-01], name: "Fête du travail"}, %{date: ~D[1950-05-08], name: "Victoire des alliés"}, %{date: ~D[1950-05-18], name: "Ascension"}, %{date: ~D[1950-05-29], name: "Lundi de Pentecôte"}, %{date: ~D[1950-07-14], name: "Fête Nationale"}, %{date: ~D[1950-08-15], name: "Assomption"}, %{date: ~D[1950-11-01], name: "Toussaint"}, %{date: ~D[1950-11-11], name: "Armistice"}, %{date: ~D[1950-12-25], name: "Noël"}]

  """
  def get_holidays(year, region) when is_integer(year) and region in [:france] do
    :code.priv_dir(:working_days)
    |> Path.join("data")
    |> Path.join(to_string(region))
    |> Path.join(to_string(year) <> ".json")
    |> File.read!()
    |> Jason.decode!()
    |> Enum.map(&%{date: Date.from_iso8601!(&1["date"]), name: &1["name"]})
  end
end
