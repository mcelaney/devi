defmodule Devi.CoreTest do
  use ExUnit.Case, async: true
  import Devi.CoreFixtures

  alias Devi.Core
  alias Devi.Core.GeneralLedger

  describe "add_to_ledger" do
    setup do
      now = "2022-03-01T23:50:07Z" |> DateTime.from_iso8601() |> elem(1)
      ledger = general_ledger_fixture(%{preload_accounts: true})
      %{now: now, ledger: ledger}
    end

    test "functions can pipe", %{ledger: ledger, now: now} do
      result =
        ledger
        |> Core.accept_investing_liability(%{
          asset_account: Core.fetch_account!(ledger, :land),
          liability_asset: Core.fetch_account!(ledger, :mortgage),
          amount: 200_000,
          inserted_at: now
        })
        |> Core.accept_operating_liability(%{
          asset_account: Core.fetch_account!(ledger, :supplies),
          liability_account: Core.fetch_account!(ledger, :accounts_payable),
          amount: 500,
          inserted_at: now
        })
        |> Core.pay_dividend(%{
          dividend_account: Core.fetch_account!(ledger, :mac_dividend),
          asset_account: Core.fetch_account!(ledger, :cash),
          amount: 5000,
          inserted_at: now
        })
        |> Core.pay_investment(%{
          asset_account: Core.fetch_account!(ledger, :cash),
          investment_account: Core.fetch_account!(ledger, :land),
          amount: 20_000,
          inserted_at: now
        })
        |> Core.pay_operating_expense(%{
          expense_account: Core.fetch_account!(ledger, :rent),
          asset_account: Core.fetch_account!(ledger, :cash),
          amount: 2000,
          inserted_at: now
        })
        |> Core.receive_capital(%{
          capital_account: Core.fetch_account!(ledger, :mac_capital),
          asset_account: Core.fetch_account!(ledger, :cash),
          amount: 30_000,
          inserted_at: now
        })
        |> Core.receive_payment_on_account(%{
          receivable_account: Core.fetch_account!(ledger, :accounts_receivable),
          asset_account: Core.fetch_account!(ledger, :cash),
          amount: 2000,
          inserted_at: now
        })
        |> Core.receive_revenue(%{
          asset_account: Core.fetch_account!(ledger, :cash),
          revenue_account: Core.fetch_account!(ledger, :service),
          amount: 5500,
          inserted_at: now
        })
        |> Core.repay_investing_obligation(%{
          asset_account: Core.fetch_account!(ledger, :cash),
          liability_asset: Core.fetch_account!(ledger, :mortgage),
          amount: 30_000,
          inserted_at: now
        })
        |> Core.repay_operating_obligation(%{
          asset_account: Core.fetch_account!(ledger, :cash),
          liability_account: Core.fetch_account!(ledger, :accounts_payable),
          amount: 300,
          inserted_at: now
        })

      assert %GeneralLedger{journal_entries: journal_entries} = result
      assert Enum.count(journal_entries) == 10

      assert Enum.map(journal_entries, fn %{meta: %{activity_tag: tag}} -> tag end) == [
               :operating,
               :investing,
               :collecting,
               :collecting,
               :financing,
               :operating,
               :investing,
               :financing,
               :operating,
               :investing
             ]
    end
  end
end
