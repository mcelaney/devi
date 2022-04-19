defmodule Devi.Core.Statements.BalanceSheetTest do
  use ExUnit.Case, async: true
  import Devi.CoreFixtures

  alias Devi.Core
  alias Devi.Core.PeriodLedger
  alias Devi.Core.Statements.BalanceSheet

  setup do
    now = "2022-03-03T23:50:07Z" |> DateTime.from_iso8601() |> elem(1)
    begining_of_month = Date.from_iso8601!("2022-03-01")
    end_of_month = Date.from_iso8601!("2022-03-31")
    ledger = general_ledger_fixture(%{now: now, preload_accounts: true, transactions: true})

    period_ledger =
      PeriodLedger.build(ledger, %{period_start: begining_of_month, period_end: end_of_month})

    %{period_ledger: period_ledger}
  end

  describe "new/1" do
    test "generates a balance sheet", %{period_ledger: period_ledger} do
      result = Core.generate_balance_sheet_statement(period_ledger)

      assert result == %BalanceSheet{
               asset_sheet: %{
                 assets: %{
                   cash: 9000,
                   accounts_receivable: 1000,
                   supplies: 500,
                   land: 20_000
                 },
                 total: 30_500
               },
               equity_liability_sheet: %{
                 liability: %{
                   liabilities: %{
                     accounts_payable: 200
                   },
                   total: 200
                 },
                 equity: %{
                   capital: %{
                     mac_capital: 30_000
                   },
                   capital_subtotal: 30_000,
                   retained_earnings: %{
                     revenues: 8500,
                     expenses: 3200,
                     dividends: 5000
                   },
                   retained_earnings_subtotal: 300,
                   total: 30_300
                 },
                 total: 30_500
               },
               period_end: ~D[2022-03-31]
             }
    end
  end
end
