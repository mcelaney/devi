defmodule Devi.Core.DateableTest do
  use ExUnit.Case, async: true
  alias Devi.CoreFixtures
  alias Devi.Core.Dateable

  setup do
    early = CoreFixtures.account_entry_fixture(%{inserted_at: DateTime.from_iso8601("2022-01-01T23:50:07Z") |> elem(1)})
    middle = CoreFixtures.account_entry_fixture(%{inserted_at: DateTime.from_iso8601("2022-02-01T23:50:07Z") |> elem(1)})
    late = CoreFixtures.account_entry_fixture(%{inserted_at: DateTime.from_iso8601("2022-03-01T23:50:07Z") |> elem(1)})

    %{entries: [early, middle, late], early: early, middle: middle, late: late}
  end

  describe "limit_by_date_range/3" do
    test "limits a list to just results within the range", %{entries: entries, middle: middle} do
      result = Dateable.limit_by_date_range(entries, "2022-02-01", "2022-02-28")
      assert Enum.count(result) == 1
      assert result == [middle]
    end
  end

  describe "limit_by_start_date/2" do
    test "returns only items after the start date", %{entries: entries, late: late} do
      result = Dateable.limit_by_start_date(entries, "2022-03-01")
      assert Enum.count(result) == 1
      assert result == [late]
    end
  end

  describe "limit_by_end_date/2" do
    test "returns only items before the end date", %{entries: entries, early: early} do
      result = Dateable.limit_by_end_date(entries, "2022-01-31")
      assert Enum.count(result) == 1
      assert result == [early]
    end
  end

  describe "split_by_date/3" do
    test "returns only items in the date range", %{entries: entries, early: early, middle: middle, late: late} do
      result = Dateable.split_by_date(entries, "2022-02-01", "2022-02-28")
      assert result == %{
        before_range: [early],
        in_range: [middle],
        after_range: [late]
      }
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
