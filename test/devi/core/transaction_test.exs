defmodule Devi.Core.TransactionTest do
  use ExUnit.Case, async: true
  alias Devi.Core.Account
  alias Devi.Core.AccountEntry
  alias Devi.Core.Transaction
  alias Devi.LedgerFixtures

  setup do
    %{now: "2022-03-03T23:50:07Z" |> DateTime.from_iso8601() |> elem(1)}
  end

  # dumb test coverage hack
  # these get created and tests in TransactionCreateCommands
  test "requires all keys to be created" do
    assert %Transaction{inserted_at: nil, account_entries: []}
  end

  describe "group_account_entries_by_accounts/1" do
    test "will return entries in a nested grouping by account", %{now: now} do
      transactions = LedgerFixtures.ledger_fixture(now)

      result = Transaction.group_account_entries_by_accounts(transactions)
      assert Map.keys(result) == [:asset, :capital, :dividend, :expense, :liability, :revenue]
      assert Map.keys(result[:asset]) == [:accounts_receivable, :cash, :land, :supplies]

      assert result[:asset][:cash] == [
               %AccountEntry{
                 account: %Account{type: :asset, id: :cash},
                 amount: 30_000,
                 inserted_at: now,
                 type: :increase
               },
               %AccountEntry{
                 account: %Account{type: :asset, id: :cash},
                 amount: 20_000,
                 inserted_at: now,
                 type: :decrease
               },
               %AccountEntry{
                 account: %Account{type: :asset, id: :cash},
                 amount: 5500,
                 inserted_at: now,
                 type: :increase
               },
               %AccountEntry{
                 account: %Account{type: :asset, id: :cash},
                 amount: 2000,
                 inserted_at: now,
                 type: :decrease
               },
               %AccountEntry{
                 account: %Account{type: :asset, id: :cash},
                 amount: 1200,
                 inserted_at: now,
                 type: :decrease
               },
               %AccountEntry{
                 account: %Account{type: :asset, id: :cash},
                 amount: 300,
                 inserted_at: now,
                 type: :decrease
               },
               %AccountEntry{
                 account: %Account{type: :asset, id: :cash},
                 amount: 2000,
                 inserted_at: now,
                 type: :increase
               },
               %AccountEntry{
                 account: %Account{type: :asset, id: :cash},
                 amount: 5000,
                 inserted_at: now,
                 type: :decrease
               }
             ]
    end
  end

  describe "group_by_account_types/1" do
    test "will return entries grouped by account_type", %{now: now} do
      transactions = LedgerFixtures.ledger_fixture(now)

      result = Transaction.group_by_account_types(transactions)
      assert Map.keys(result) == [:asset, :capital, :dividend, :expense, :liability, :revenue]

      assert result[:revenue] == [
               %Devi.Core.AccountEntry{
                 account: %Devi.Core.Account{id: :service, type: :revenue},
                 amount: 5500,
                 inserted_at: now,
                 type: :increase
               },
               %Devi.Core.AccountEntry{
                 account: %Devi.Core.Account{id: :service, type: :revenue},
                 amount: 3000,
                 inserted_at: now,
                 type: :increase
               }
             ]
    end
  end
end
