defmodule Devi.Core.DateableTest do
  use ExUnit.Case, async: true
  alias Devi.Core.Dateable

  setup do
    early = %{
      inserted_at: "2022-01-01T23:50:07Z" |> DateTime.from_iso8601() |> elem(1)
    }

    middle = %{
      inserted_at: "2022-02-01T23:50:07Z" |> DateTime.from_iso8601() |> elem(1)
    }

    late = %{
      inserted_at: "2022-03-01T23:50:07Z" |> DateTime.from_iso8601() |> elem(1)
    }

    %{items: [early, middle, late], early: early, middle: middle, late: late}
  end

  describe "entries_in_range/3" do
    test "limits a list to just results within the range", %{items: items, middle: middle} do
      result = Dateable.entries_in_range(items, "2022-02-01", "2022-02-28")
      assert Enum.count(result) == 1
      assert result == [middle]
    end
  end

  describe "entries_before/2" do
    test "returns only items before the end date", %{items: items, early: early} do
      result = Dateable.entries_before(items, "2022-01-31")
      assert Enum.count(result) == 1
      assert result == [early]
    end
  end

  describe "to_date/1" do
    test "accepts a date" do
      result = Dateable.to_date(Date.new!(2016, 03, 05))
      assert result == Date.new!(2016, 3, 5)
    end

    test "accepts a date time" do
      result = Dateable.to_date(DateTime.new!(~D[2016-03-05], ~T[13:26:08.003], "Etc/UTC"))
      assert result == Date.new!(2016, 3, 5)
    end

    test "accepts a naieve date time" do
      result = Dateable.to_date(NaiveDateTime.new!(2016, 3, 5, 0, 0, 0))
      assert result == Date.new!(2016, 03, 05)
    end

    test "accepts an iso8601 string" do
      result = Dateable.to_date("2016-03-05")
      assert result == Date.new!(2016, 03, 05)
    end
  end
end
