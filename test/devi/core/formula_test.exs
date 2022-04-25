defmodule Devi.Core.FormulaTest do
  use ExUnit.Case, async: true
  import Devi.CoreFixtures

  alias Devi.Core
  alias Devi.Core.PeriodLedger

  setup do
    now = "2022-03-03T23:50:07Z" |> DateTime.from_iso8601() |> elem(1)
    older = "2022-02-03T23:50:07Z" |> DateTime.from_iso8601() |> elem(1)
    begining_of_month = Date.from_iso8601!("2022-03-01")
    end_of_month = Date.from_iso8601!("2022-03-31")

    ledger =
      general_ledger_fixture(%{now: now, older: older, preload_accounts: true, transactions: true})

    history_period_ledger = PeriodLedger.build(ledger, %{period_before: begining_of_month})

    period_period_ledger =
      PeriodLedger.build(ledger, %{period_start: begining_of_month, period_end: end_of_month})

    %{
      history_period_ledger: history_period_ledger,
      period_period_ledger: period_period_ledger
    }
  end

  describe "return_on_assets/1" do
    test "will generate a return on assets value", %{
      history_period_ledger: history_period_ledger,
      period_period_ledger: period_period_ledger
    } do
      result =
        Core.return_on_assets(%{
          history: history_period_ledger,
          period: period_period_ledger
        })

      assert result == 0.174
    end
  end
end
