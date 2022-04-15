defmodule Devi.Core.TransactionTest do
  use ExUnit.Case, async: true
  alias Devi.Core.AccountEntry
  alias Devi.Core.Transaction
  alias Devi.LedgerFixtures

  setup do
    %{now: "2022-03-03T23:50:07Z" |> DateTime.from_iso8601() |> elem(1)}
  end

  describe "group_account_entries_by_accounts/1" do
    test "will group by accounts within parent accounts", %{now: now} do
      transactions = LedgerFixtures.ledger_fixture(now)

      result = Transaction.group_account_entries_by_accounts(transactions)
      assert Map.keys(result) == [:asset, :capital, :dividend, :expense, :liability, :revenue]
      assert Map.keys(result[:asset]) == [:accounts_receivable, :cash, :land, :supplies]

      assert result[:asset][:cash] == [
               %AccountEntry{
                 account: {:asset, :cash},
                 amount: 30_000,
                 inserted_at: now,
                 type: :increase
               },
               %AccountEntry{
                 account: {:asset, :cash},
                 amount: 20_000,
                 inserted_at: now,
                 type: :decrease
               },
               %AccountEntry{
                 account: {:asset, :cash},
                 amount: 5500,
                 inserted_at: now,
                 type: :increase
               },
               %AccountEntry{
                 account: {:asset, :cash},
                 amount: 2000,
                 inserted_at: now,
                 type: :decrease
               },
               %AccountEntry{
                 account: {:asset, :cash},
                 amount: 1200,
                 inserted_at: now,
                 type: :decrease
               },
               %AccountEntry{
                 account: {:asset, :cash},
                 amount: 300,
                 inserted_at: now,
                 type: :decrease
               },
               %AccountEntry{
                 account: {:asset, :cash},
                 amount: 2000,
                 inserted_at: now,
                 type: :increase
               },
               %AccountEntry{
                 account: {:asset, :cash},
                 amount: 5000,
                 inserted_at: now,
                 type: :decrease
               }
             ]
    end
  end
end
