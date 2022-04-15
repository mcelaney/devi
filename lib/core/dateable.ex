defmodule Devi.Core.Dateable do
  @moduledoc """
  Responsible for providing date filter capabilities for lists of items which
  contain an inserted_at column
  """

  @typedoc """
  If a string expects an iso8601 - year-mo-da
  """
  @type date_value :: Date.t | DateTime.t | String.t
  @type filterable :: %{inserted_at: date_value}

  @doc """
  Given a list of items containing an inserted_at value returns a list of items
  filtered by the given date range

  Filter is by whole day inclusive
  """
  @spec limit_by_date_range(list(filterable), date_value, date_value) :: list(filterable)
  def limit_by_date_range(items, start_date, end_date) do
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
  filtered by the given start_date

  Filter is by whole day inclusive
  """
  @spec limit_by_start_date(list(filterable), date_value) :: list(filterable)
  def limit_by_start_date(items, start_date) do
    Enum.filter(items, fn %{inserted_at: date} ->
      cond do
        Date.compare(to_date(date), to_date(start_date)) == :lt -> false
        true -> true
      end
    end)
  end

  @doc """
  Given a list of items containing an inserted_at value returns a list of items
  filtered by the given date range

  Filter is by whole day inclusive
  """
  @spec limit_by_end_date(list(filterable), date_value) :: list(filterable)
  def limit_by_end_date(items, end_date) do
    Enum.filter(items, fn %{inserted_at: date} ->
      cond do
        Date.compare(to_date(date), to_date(end_date)) == :gt -> false
        true -> true
      end
    end)
  end

  @doc """
  Given a list of items containing an inserted_at value returns a map of items
  separated in to before range, in range, and after range.

  "In range" is defined by whole day inclusive
  """
  @spec split_by_date(list(filterable), date_value, date_value) :: %{before_range: date_value, after_range: date_value, in_range: date_value}
  def split_by_date(items, start_date, end_date) do
    Enum.group_by(items, fn %{inserted_at: date} ->
      cond do
        Date.compare(to_date(date), to_date(start_date)) == :lt -> :before_range
        Date.compare(to_date(date), to_date(end_date)) == :gt -> :after_range
        true -> :in_range
      end
    end)
  end

  @doc """
  Transforms a given value in to a date.
  """
  @spec to_date(date_value) :: Date.t
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
