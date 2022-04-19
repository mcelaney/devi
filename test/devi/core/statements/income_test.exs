defmodule Devi.Core.Statements.IncomeTest do
  use ExUnit.Case, async: true
  import Devi.CoreFixtures

  alias Devi.Core
  alias Devi.Core.PeriodLedger
  alias Devi.Core.Statements.Income

  setup do
    now = "2022-03-01T23:50:07Z" |> DateTime.from_iso8601() |> elem(1)
    ledger = general_ledger_fixture(%{now: now, preload_accounts: true, transactions: true})

    %{
      ledger: ledger,
      period_start: Date.from_iso8601!("2022-03-01"),
      period_end: Date.from_iso8601!("2022-03-31")
    }
  end

  describe "build/1" do
    setup(%{ledger: ledger} = state) do
      period_ledger =
        PeriodLedger.build(ledger, %{period_start: "2022-02-01", period_end: "2022-02-28"})

      Map.put(state, :period_ledger, period_ledger)
    end

    test "will generate an income statememnt with dates", %{
      ledger: ledger,
      period_start: period_start,
      period_end: period_end
    } do
      period_ledger =
        PeriodLedger.build(ledger, %{period_start: period_start, period_end: period_end})

      result = Core.generate_income_statement(period_ledger)

      assert result == %Income{
               period_end: period_end,
               expenses: %{rent: 2000, salary: 1200},
               expenses_subtotal: 3200,
               revenues: %{service: 8500},
               revenues_subtotal: 8500,
               period_start: period_start,
               total: 5300
             }
    end

    test "will generate an income statememnt with just end date", %{
      ledger: ledger,
      period_end: period_end
    } do
      period_ledger = PeriodLedger.build(ledger, %{period_before: period_end})
      result = Core.generate_income_statement(period_ledger)
      period_end = period_end |> Date.add(-1)

      assert result == %Income{
               period_end: period_end,
               expenses: %{rent: 2000, salary: 1200},
               expenses_subtotal: 3200,
               revenues: %{service: 8500},
               revenues_subtotal: 8500,
               period_start: nil,
               total: 5300
             }
    end

    test "will generate an income statememnt with jno dates", %{ledger: ledger} do
      period_ledger = PeriodLedger.build(ledger, %{})
      result = Core.generate_income_statement(period_ledger)

      assert result == %Income{
               period_end: nil,
               expenses: %{rent: 2000, salary: 1200},
               expenses_subtotal: 3200,
               revenues: %{service: 8500},
               revenues_subtotal: 8500,
               period_start: nil,
               total: 5300
             }
    end
  end
end
