defmodule Devi.Core.Transaction.CreateCommandsTest do
  use ExUnit.Case, async: true
  import Devi.CoreFixtures
  alias Devi.Core.Account
  alias Devi.Core.AccountEntry

  setup do
    %{
      now: "2022-03-03T23:50:07Z" |> DateTime.from_iso8601() |> elem(1),
      cash_account: asset_account_fixture(:cash),
      capital_account: capital_account_fixture(:mac),
      dividend_account: dividend_account_fixture(:mac),
      land_account: asset_account_fixture(:land),
      supplies_account: asset_account_fixture(:supplies),
      accounts_payable_account: liability_account_fixture(:accounts_payable),
      service_account: revenue_account_fixture(:service),
      rent_account: expense_account_fixture(:rent)
    }
  end

  describe "make_contribution/2" do
    test "creates an increase to capital and asset accounts", %{
      now: now,
      cash_account: cash_account,
      capital_account: owner_account
    } do
      %{account_entries: entries, inserted_at: inserted_at} =
        Devi.make_contribution(
          %{capital_account: owner_account, asset_account: cash_account, amount: 30_000},
          now
        )

      assert inserted_at == now

      assert Enum.any?(entries, fn entry ->
               entry == %AccountEntry{
                 account: %Account{type: :capital, id: :mac},
                 amount: 30_000,
                 inserted_at: now,
                 type: :increase
               }
             end)

      assert Enum.any?(entries, fn entry ->
               entry == %AccountEntry{
                 account: %Account{type: :asset, id: :cash},
                 amount: 30_000,
                 inserted_at: now,
                 type: :increase
               }
             end)
    end
  end

  describe "purchase_with_asset/2" do
    test "decreases an asset account and increases another", %{
      now: now,
      cash_account: cash_account,
      land_account: land_account
    } do
      %{account_entries: entries, inserted_at: inserted_at} =
        Devi.purchase_with_asset(
          %{from_account: cash_account, to_account: land_account, amount: 20_000},
          now
        )

      assert inserted_at == now

      assert Enum.any?(entries, fn entry ->
               entry == %AccountEntry{
                 account: %Account{type: :asset, id: :cash},
                 amount: 20_000,
                 inserted_at: now,
                 type: :decrease
               }
             end)

      assert Enum.any?(entries, fn entry ->
               entry == %AccountEntry{
                 account: %Account{type: :asset, id: :land},
                 amount: 20_000,
                 inserted_at: now,
                 type: :increase
               }
             end)
    end
  end

  describe "purchase_on_account/2" do
    test "increases an asset account as well as a liability account", %{
      now: now,
      supplies_account: supplies_account,
      accounts_payable_account: accounts_payable_account
    } do
      %{account_entries: entries, inserted_at: inserted_at} =
        Devi.purchase_on_account(
          %{
            asset_account: supplies_account,
            liability_account: accounts_payable_account,
            amount: 500
          },
          now
        )

      assert inserted_at == now

      assert Enum.any?(entries, fn entry ->
               entry == %AccountEntry{
                 account: %Account{type: :liability, id: :accounts_payable},
                 amount: 500,
                 inserted_at: now,
                 type: :increase
               }
             end)

      assert Enum.any?(entries, fn entry ->
               entry == %AccountEntry{
                 account: %Account{type: :asset, id: :supplies},
                 amount: 500,
                 inserted_at: now,
                 type: :increase
               }
             end)
    end
  end

  describe "earn_asset_revenue/2" do
    test "increases an asset account and a revenue account", %{
      now: now,
      cash_account: cash_account,
      service_account: service_account
    } do
      %{account_entries: entries, inserted_at: inserted_at} =
        Devi.earn_asset_revenue(
          %{asset_account: cash_account, revenue_account: service_account, amount: 5500},
          now
        )

      assert inserted_at == now

      assert Enum.any?(entries, fn entry ->
               entry == %AccountEntry{
                 account: %Account{type: :asset, id: :cash},
                 amount: 5500,
                 inserted_at: now,
                 type: :increase
               }
             end)

      assert Enum.any?(entries, fn entry ->
               entry == %AccountEntry{
                 account: %Account{type: :revenue, id: :service},
                 amount: 5500,
                 inserted_at: now,
                 type: :increase
               }
             end)
    end
  end

  describe "pay_on_account/2" do
    test "decreases an asset account as well as a liability account", %{
      now: now,
      cash_account: cash_account,
      accounts_payable_account: accounts_payable_account
    } do
      %{account_entries: entries, inserted_at: inserted_at} =
        Devi.pay_on_account(
          %{
            asset_account: cash_account,
            liability_account: accounts_payable_account,
            amount: 300
          },
          now
        )

      assert inserted_at == now

      assert Enum.any?(entries, fn entry ->
               entry == %AccountEntry{
                 account: %Account{type: :asset, id: :cash},
                 amount: 300,
                 inserted_at: now,
                 type: :decrease
               }
             end)

      assert Enum.any?(entries, fn entry ->
               entry == %AccountEntry{
                 account: %Account{type: :liability, id: :accounts_payable},
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
      cash_account: cash_account,
      rent_account: rent_account
    } do
      %{account_entries: entries, inserted_at: inserted_at} =
        Devi.pay_expenses(
          %{expense_account: rent_account, asset_account: cash_account, amount: 2000},
          now
        )

      assert inserted_at == now

      assert Enum.any?(entries, fn entry ->
               entry == %AccountEntry{
                 account: %Account{type: :asset, id: :cash},
                 amount: 2000,
                 inserted_at: now,
                 type: :decrease
               }
             end)

      assert Enum.any?(entries, fn entry ->
               entry == %AccountEntry{
                 account: %Account{type: :expense, id: :rent},
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
      dividend_account: dividend_account,
      cash_account: cash_account
    } do
      %{account_entries: entries, inserted_at: inserted_at} =
        Devi.pay_dividend(
          %{dividend_account: dividend_account, asset_account: cash_account, amount: 5000},
          now
        )

      assert inserted_at == now

      assert Enum.any?(entries, fn entry ->
               entry == %AccountEntry{
                 account: %Account{type: :asset, id: :cash},
                 amount: 5000,
                 inserted_at: now,
                 type: :decrease
               }
             end)

      assert Enum.any?(entries, fn entry ->
               entry == %AccountEntry{
                 account: %Account{type: :dividend, id: :mac},
                 amount: 5000,
                 inserted_at: now,
                 type: :increase
               }
             end)
    end
  end
end
