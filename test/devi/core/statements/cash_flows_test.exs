defmodule Devi.Core.Statements.CashFlowsTest do
  use ExUnit.Case, async: true
  import Devi.CoreFixtures

  alias Devi.Core
  alias Devi.Core.PeriodLedger
  alias Devi.Core.Statements.CashFlows

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
        Core.generate_cash_flows_statement(%{
          cash_id: :cash,
          history: history_period_ledger,
          period: period_period_ledger
        })

      assert result == %CashFlows{
               financing: %{
                 capital: [%{account: %{id: :mac_capital, type: :capital}, amount: 30_000}],
                 dividend: [%{account: %{id: :mac_dividend, type: :dividend}, amount: -5000}],
                 total: 25_000
               },
               investing: %{
                 assets: [%{account: %{id: :land, type: :asset}, amount: -20_000}],
                 total: -20_000
               },
               operating: %{
                 expense: [
                   %{account: %{id: :rent, type: :expense}, amount: -2000},
                   %{account: %{id: :salary, type: :expense}, amount: -1200},
                   %{account: %{id: :accounts_payable, type: :liability}, amount: -300}
                 ],
                 revenue: [
                   %{account: %{id: :service, type: :revenue}, amount: 5500},
                   %{account: %{id: :accounts_receivable, type: :asset}, amount: 2000}
                 ],
                 total: 4000
               },
               period_end: end_of_month,
               period_end_balance: 18_000,
               period_start: begining_of_month,
               period_start_balance: 9000,
               total: 9000
             }
    end
  end
end
