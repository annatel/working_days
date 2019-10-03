# Based on https://github.com/AntoineAugusti/api-jours-feries-france/blob/master/build.py

base_url = "https://www.data.gouv.fr/fr/datasets/r/"

%HTTPoison.Response{body: body} =
  (base_url <> "cc620384-4ccf-41ae-a7ba-9eceacb7b6db")
  |> HTTPoison.get!(%{}, hackney: [{:follow_redirect, true}])

body
|> String.split("\n", trim: true)
|> Enum.drop(1)
|> Enum.drop(-1)
|> Enum.group_by(&Integer.parse(String.slice(&1, 0..3)))
|> Enum.map(fn {{year, _}, values} ->
  values =
    values
    |> Enum.map(&String.split(&1, ",", trim: true))
    |> Enum.map(&%{date: Enum.at(&1, 0), name: Enum.at(&1, 2)})

  {year, values}
end)
|> Enum.each(fn {year, values} ->
  folder = :code.priv_dir(:working_days) |> Path.join("data") |> Path.join("france")
  File.mkdir_p(folder)

  filename = folder |> Path.join(to_string(year) <> ".json")
  {:ok, file} = File.open(filename, [:write])
  IO.binwrite(file, Jason.encode!(values))
end)
