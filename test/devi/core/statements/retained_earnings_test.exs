defmodule Devi.Core.Statements.RetainedEarningsTest do
  use ExUnit.Case, async: true
  import Devi.CoreFixtures

  alias Devi.Core
  alias Devi.Core.PeriodLedger
  alias Devi.Core.Statements.RetainedEarnings

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
      begining_of_month: begining_of_month,
      end_of_month: end_of_month,
      history_period_ledger: history_period_ledger,
      period_period_ledger: period_period_ledger
    }
  end

  describe "new/1" do
    test "will generate an retained earnings statememnt", %{
      history_period_ledger: history_period_ledger,
      period_period_ledger: period_period_ledger,
      begining_of_month: begining_of_month,
      end_of_month: end_of_month
    } do
      result =
        Core.generate_retained_earnings_statement(%{
          history: history_period_ledger,
          period: period_period_ledger
        })

      assert result == %RetainedEarnings{
               dividends: 5000,
               period_end: end_of_month,
               ending: 600,
               net_income: 5300,
               period_start: begining_of_month,
               starting: 300
             }
    end
  end
end
