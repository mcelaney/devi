defmodule Devi.Core.Dateable do
  @moduledoc """
  Responsible for providing date filter capabilities for lists of items which
  contain an inserted_at column
  """

  @typedoc """
  If a string expects an iso8601 - year-mo-da
  """
  @type date_value :: Date.t() | DateTime.t() | String.t()
  @type filterable :: %{inserted_at: date_value}

  @doc """
  Given a list of items containing an inserted_at value returns a list of items
  filtered by the given date range

  Filter is by whole day inclusive
  """
  @spec entries_in_range(list(filterable), date_value, date_value) :: list(filterable)
  def entries_in_range(items, start_date, end_date) do
    Enum.filter(items, fn %{inserted_at: date} ->
      cond do
        Date.compare(to_date(date), to_date(start_date)) == :lt -> false
        Date.compare(to_date(date), to_date(end_date)) == :gt -> false
        true -> true
      end
    end)
  end

  @doc """
  Given a list of items containing an inserted_at value returns a list of items
  filtered by the given date range

  Filter excludes the end_date
  """
  @spec entries_before(list(filterable), date_value) :: list(filterable)
  def entries_before(items, end_date) do
    Enum.filter(items, fn %{inserted_at: date} ->
      cond do
        Date.compare(to_date(date), to_date(end_date)) == :lt -> true
        true -> false
      end
    end)
  end

  @doc """
  Transforms a given value in to a date.
  """
  @spec to_date(date_value) :: Date.t()
  def to_date(%Date{} = limit), do: limit

  def to_date(%NaiveDateTime{year: year, month: month, day: day}) do
    Date.new!(year, month, day)
  end

  def to_date(%DateTime{year: year, month: month, day: day}) do
    Date.new!(year, month, day)
  end

  def to_date(date) do
    Date.from_iso8601!(date)
  end
end
