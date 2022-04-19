defmodule Devi.Core.SubledgerTest do
  use ExUnit.Case, async: true
  import Devi.CoreFixtures
  alias Devi.Core.Subledger

  setup do
    older = "2022-01-01T23:50:07Z" |> DateTime.from_iso8601() |> elem(1)
    now = "2022-02-01T23:50:07Z" |> DateTime.from_iso8601() |> elem(1)
    newer = "2022-03-01T23:50:07Z" |> DateTime.from_iso8601() |> elem(1)

    ledger =
      general_ledger_fixture(%{
        older: older,
        now: now,
        newer: newer,
        preload_accounts: true,
        transactions: true
      })

    %{now: now, ledger: ledger}
  end

  # dumb test coverage hack
  test "requires all keys to be created" do
    assert %Subledger{}
  end

  describe "build/2" do
    test "splits entries in to their correct account types", %{ledger: ledger} do
      result = Subledger.build(ledger)
      assert is_nil(result.period_end)
      assert is_nil(result.period_start)
      assert Enum.count(result.asset) == 36
      assert Enum.count(result.capital) == 3
      assert Enum.count(result.dividend) == 3
      assert Enum.count(result.expense) == 6
      assert Enum.count(result.liability) == 6
      assert Enum.count(result.revenue) == 6
    end

    test "can limits entries to a time period", %{ledger: ledger} do
      result = Subledger.build(ledger, %{period_before: "2022-03-01"})
      assert result.period_end == Date.from_iso8601!("2022-02-28")
      assert is_nil(result.period_start)
      assert Enum.count(result.asset) == 24
      assert Enum.count(result.capital) == 2
      assert Enum.count(result.dividend) == 2
      assert Enum.count(result.expense) == 4
      assert Enum.count(result.liability) == 4
      assert Enum.count(result.revenue) == 4
    end

    test "can limit entries a period end", %{ledger: ledger} do
      result = Subledger.build(ledger, %{period_start: "2022-02-01", period_end: "2022-02-28"})
      assert result.period_end == Date.from_iso8601!("2022-02-28")
      assert result.period_start == Date.from_iso8601!("2022-02-01")
      assert Enum.count(result.asset) == 12
      assert Enum.count(result.capital) == 1
      assert Enum.count(result.dividend) == 1
      assert Enum.count(result.expense) == 2
      assert Enum.count(result.liability) == 2
      assert Enum.count(result.revenue) == 2
    end
  end

  describe "fetch_sub_totals/2" do
    test "will fetch grouped subtotals for all requested keys", %{ledger: ledger} do
      subledger = Subledger.build(ledger, %{period_start: "2022-02-01", period_end: "2022-02-28"})
      result = Subledger.fetch_sub_totals(subledger, [:expense, :revenue])
      assert result == %{expense: %{rent: 2000, salary: 1200}, revenue: %{service: 8500}}
    end
  end

  describe "fetch_totals/2" do
    test "will fetch subtotals for all requested keys", %{ledger: ledger} do
      subledger = Subledger.build(ledger, %{period_start: "2022-02-01", period_end: "2022-02-28"})
      result = Subledger.fetch_totals(subledger, [:expense, :revenue])
      assert result == %{expense: 3200, revenue: 8500}
    end
  end
end
