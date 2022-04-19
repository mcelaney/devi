defmodule Devi.Core.GeneralLedger.EnterTransactionTest do
  use ExUnit.Case, async: true
  import Devi.CoreFixtures
  alias Devi.Core
  alias Devi.Core.LedgerEntry

  setup do
    now = "2022-03-03T23:50:07Z" |> DateTime.from_iso8601() |> elem(1)

    %{
      now: now,
      ledger: general_ledger_fixture(%{preload_accounts: true})
    }
  end

  describe "make_contribution/2" do
    test "creates an increase to capital and asset accounts", %{now: now, ledger: ledger} do
      %{
        journal_entries: [%{account_entries: entries, inserted_at: inserted_at}] = journal_entries
      } =
        Core.make_contribution(ledger, %{
          capital_account_id: :mac_capital,
          asset_account_id: :cash,
          amount: 30_000,
          inserted_at: now
        })

      assert Enum.count(journal_entries) == 1
      assert inserted_at == now

      assert Enum.any?(entries, fn entry ->
               entry == %LedgerEntry{
                 account: %{type: :capital, id: :mac_capital},
                 amount: 30_000,
                 inserted_at: now,
                 type: :increase
               }
             end)

      assert Enum.any?(entries, fn entry ->
               entry == %LedgerEntry{
                 account: %{type: :asset, id: :cash},
                 amount: 30_000,
                 inserted_at: now,
                 type: :increase
               }
             end)
    end
  end

  describe "purchase_with_asset/2" do
    test "decreases an asset account and increases another", %{now: now, ledger: ledger} do
      %{
        journal_entries: [%{account_entries: entries, inserted_at: inserted_at}] = journal_entries
      } =
        Core.purchase_with_asset(ledger, %{
          from_account_id: :cash,
          to_account_id: :land,
          amount: 20_000,
          inserted_at: now
        })

      assert Enum.count(journal_entries) == 1
      assert inserted_at == now

      assert Enum.any?(entries, fn entry ->
               entry == %LedgerEntry{
                 account: %{type: :asset, id: :cash},
                 amount: 20_000,
                 inserted_at: now,
                 type: :decrease
               }
             end)

      assert Enum.any?(entries, fn entry ->
               entry == %LedgerEntry{
                 account: %{type: :asset, id: :land},
                 amount: 20_000,
                 inserted_at: now,
                 type: :increase
               }
             end)
    end
  end

  describe "purchase_on_account/2" do
    test "increases an asset account as well as a liability account", %{now: now, ledger: ledger} do
      %{
        journal_entries: [%{account_entries: entries, inserted_at: inserted_at}] = journal_entries
      } =
        Core.purchase_on_account(ledger, %{
          asset_account_id: :supplies,
          liability_account_id: :accounts_payable,
          amount: 500,
          inserted_at: now
        })

      assert Enum.count(journal_entries) == 1
      assert inserted_at == now

      assert Enum.any?(entries, fn entry ->
               entry == %LedgerEntry{
                 account: %{type: :liability, id: :accounts_payable},
                 amount: 500,
                 inserted_at: now,
                 type: :increase
               }
             end)

      assert Enum.any?(entries, fn entry ->
               entry == %LedgerEntry{
                 account: %{type: :asset, id: :supplies},
                 amount: 500,
                 inserted_at: now,
                 type: :increase
               }
             end)
    end
  end

  describe "earn_asset_revenue/2" do
    test "increases an asset account and a revenue account", %{now: now, ledger: ledger} do
      %{
        journal_entries: [%{account_entries: entries, inserted_at: inserted_at}] = journal_entries
      } =
        Core.earn_asset_revenue(ledger, %{
          asset_account_id: :cash,
          revenue_account_id: :service,
          amount: 5500,
          inserted_at: now
        })

      assert Enum.count(journal_entries) == 1
      assert inserted_at == now

      assert Enum.any?(entries, fn entry ->
               entry == %LedgerEntry{
                 account: %{type: :asset, id: :cash},
                 amount: 5500,
                 inserted_at: now,
                 type: :increase
               }
             end)

      assert Enum.any?(entries, fn entry ->
               entry == %LedgerEntry{
                 account: %{type: :revenue, id: :service},
                 amount: 5500,
                 inserted_at: now,
                 type: :increase
               }
             end)
    end
  end

  describe "pay_on_account/2" do
    test "decreases an asset account as well as a liability account", %{now: now, ledger: ledger} do
      %{
        journal_entries: [%{account_entries: entries, inserted_at: inserted_at}] = journal_entries
      } =
        Core.pay_on_account(ledger, %{
          asset_account_id: :cash,
          liability_account_id: :accounts_payable,
          amount: 300,
          inserted_at: now
        })

      assert Enum.count(journal_entries) == 1
      assert inserted_at == now

      assert Enum.any?(entries, fn entry ->
               entry == %LedgerEntry{
                 account: %{type: :asset, id: :cash},
                 amount: 300,
                 inserted_at: now,
                 type: :decrease
               }
             end)

      assert Enum.any?(entries, fn entry ->
               entry == %LedgerEntry{
                 account: %{type: :liability, id: :accounts_payable},
                 amount: 300,
                 inserted_at: now,
                 type: :decrease
               }
             end)
    end
  end

  describe "pay_expenses/2" do
    test "decreases an asset account and increases an expense account", %{
      now: now,
      ledger: ledger
    } do
      %{
        journal_entries: [%{account_entries: entries, inserted_at: inserted_at}] = journal_entries
      } =
        Core.pay_expenses(ledger, %{
          expense_account_id: :rent,
          asset_account_id: :cash,
          amount: 2000,
          inserted_at: now
        })

      assert Enum.count(journal_entries) == 1
      assert inserted_at == now

      assert Enum.any?(entries, fn entry ->
               entry == %LedgerEntry{
                 account: %{type: :asset, id: :cash},
                 amount: 2000,
                 inserted_at: now,
                 type: :decrease
               }
             end)

      assert Enum.any?(entries, fn entry ->
               entry == %LedgerEntry{
                 account: %{type: :expense, id: :rent},
                 amount: 2000,
                 inserted_at: now,
                 type: :increase
               }
             end)
    end
  end

  describe "pay_dividend/2" do
    test "decreases an asset account and increases a dividend account", %{
      now: now,
      ledger: ledger
    } do
      %{
        journal_entries: [%{account_entries: entries, inserted_at: inserted_at}] = journal_entries
      } =
        Core.pay_dividend(ledger, %{
          dividend_account_id: :mac_dividend,
          asset_account_id: :cash,
          amount: 5000,
          inserted_at: now
        })

      assert Enum.count(journal_entries) == 1
      assert inserted_at == now

      assert Enum.any?(entries, fn entry ->
               entry == %LedgerEntry{
                 account: %{type: :asset, id: :cash},
                 amount: 5000,
                 inserted_at: now,
                 type: :decrease
               }
             end)

      assert Enum.any?(entries, fn entry ->
               entry == %LedgerEntry{
                 account: %{type: :dividend, id: :mac_dividend},
                 amount: 5000,
                 inserted_at: now,
                 type: :increase
               }
             end)
    end
  end
end
