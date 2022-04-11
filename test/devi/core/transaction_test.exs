defmodule Devi.Core.TransactionTest do
  use ExUnit.Case, async: true
  alias Devi.Core
  alias Devi.Core.Transaction

  setup do
    %{now: DateTime.from_iso8601("2022-03-03T23:50:07Z") |> elem(1)}
  end

  describe "group_account_entries_by_accounts/1" do
    test "will group by accounts within parent accounts", %{now: now} do
      transactions = [
        Devi.Core.make_contribution(%{owner: :mac, asset: :cash, amount: 30_000}, now),
        Devi.Core.purchase_with_asset(%{from: :cash, to: :land, amount: 20_000}, now),
        Devi.Core.purchase_on_account(
          %{asset: :supplies, account: :accounts_payable, amount: 500},
          now
        ),
        Devi.Core.earn_asset_revenue(%{asset: :cash, revenue: :service, amount: 5500}, now),
        Devi.Core.earn_asset_revenue(
          %{asset: :accounts_receivable, revenue: :service, amount: 3000},
          now
        ),
        Devi.Core.pay_expenses(%{expense: :rent, asset: :cash, amount: 2000}, now),
        Devi.Core.pay_expenses(%{expense: :salary, asset: :cash, amount: 1200}, now),
        Devi.Core.pay_on_account(%{asset: :cash, payment: :accounts_payable, amount: 300}, now),
        Devi.Core.purchase_with_asset(
          %{from: :accounts_receivable, to: :cash, amount: 2000},
          now
        ),
        Devi.Core.pay_dividend(%{dividend: :dividend, asset: :cash, amount: 5000}, now)
      ]

      result = Transaction.group_account_entries_by_accounts(transactions)
      assert Map.keys(result) == [:asset, :capital, :dividend, :expense, :liability, :revenue]
      assert Map.keys(result[:asset]) == [:accounts_receivable, :cash, :land, :supplies]

      assert result[:asset][:cash] == [
               %Devi.Core.AccountEntry{
                 account: {:asset, :cash},
                 amount: 30_000,
                 inserted_at: now,
                 type: :increase
               },
               %Devi.Core.AccountEntry{
                 account: {:asset, :cash},
                 amount: 20_000,
                 inserted_at: now,
                 type: :decrease
               },
               %Devi.Core.AccountEntry{
                 account: {:asset, :cash},
                 amount: 5500,
                 inserted_at: now,
                 type: :increase
               },
               %Devi.Core.AccountEntry{
                 account: {:asset, :cash},
                 amount: 2000,
                 inserted_at: now,
                 type: :decrease
               },
               %Devi.Core.AccountEntry{
                 account: {:asset, :cash},
                 amount: 1200,
                 inserted_at: now,
                 type: :decrease
               },
               %Devi.Core.AccountEntry{
                 account: {:asset, :cash},
                 amount: 300,
                 inserted_at: now,
                 type: :decrease
               },
               %Devi.Core.AccountEntry{
                 account: {:asset, :cash},
                 amount: 2000,
                 inserted_at: now,
                 type: :increase
               },
               %Devi.Core.AccountEntry{
                 account: {:asset, :cash},
                 amount: 5000,
                 inserted_at: now,
                 type: :decrease
               }
             ]
    end
  end

  describe "limit_by_date_range/2" do
    test "will filter transactions not in the date range from a list" do
      last_month = DateTime.from_iso8601("2022-01-03T23:50:07Z") |> elem(1)
      this_month = DateTime.from_iso8601("2022-02-03T23:50:07Z") |> elem(1)
      next_month = DateTime.from_iso8601("2022-03-03T23:50:07Z") |> elem(1)

      transactions = [
        Core.make_contribution(%{owner: :mac, asset: :cash, amount: 10_000}, last_month),
        Core.make_contribution(%{owner: :mac, asset: :cash, amount: 20_000}, this_month),
        Core.make_contribution(%{owner: :mac, asset: :cash, amount: 3000}, next_month)
      ]

      result = Transaction.limit_by_date_range(transactions, "2022-02-01", "2022-02-28")

      assert result == [
               Core.make_contribution(%{owner: :mac, asset: :cash, amount: 20_000}, this_month)
             ]
    end
  end
end
